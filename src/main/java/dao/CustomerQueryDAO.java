package dao;

import com.microsoft.sqlserver.jdbc.SQLServerCallableStatement;
import com.microsoft.sqlserver.jdbc.SQLServerDataTable;
import dto.CustomerFilterRequest;
import dto.CustomerListDTO;
import dto.CustomerPageResult;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class CustomerQueryDAO {

    private CustomerListDTO mapRow(ResultSet rs) throws SQLException {

        CustomerListDTO dto = new CustomerListDTO();

        dto.setCustomerId(rs.getInt("customer_id"));
        dto.setName(rs.getString("name"));
        dto.setPhone(rs.getString("phone"));
        dto.setEmail(rs.getString("email"));
        dto.setGender(rs.getString("gender"));
        dto.setLoyaltyTier(rs.getString("loyalty_tier"));
        dto.setRfmScore(rs.getInt("rfm_score"));
        dto.setPreferredSize(rs.getString("fit_profile"));
        dto.setBodyShape(rs.getString("body_shape"));
        dto.setHeight(rs.getBigDecimal("height"));
        dto.setWeight(rs.getBigDecimal("weight"));

        String styleTagsStr = rs.getString("style_tags");
        if (styleTagsStr != null && !styleTagsStr.isBlank()) {
            dto.setStyleTags(Arrays.asList(styleTagsStr.split("\\s*,\\s*")));
        }

        dto.setReturnRate(rs.getDouble("return_rate"));

        Timestamp ts = rs.getTimestamp("last_purchase_date");
        if (ts != null) {
            dto.setLastPurchase(ts.toLocalDateTime());
        }

        return dto;
    }

    public CustomerPageResult getCustomerList(
            Connection connection,
            int page,
            int size,
            String sessionId) throws SQLException {

        List<CustomerListDTO> customerList = new ArrayList<>();
        int totalRecords = 0;
        int totalPages = 0;
        String returnedSessionId = sessionId;
        String nextAnchorRfm = null;
        int nextAnchorId = 0;

        // Trang đầu hoặc chưa có session → fetch total + tạo session mới
        boolean isNewSession = (sessionId == null || sessionId.isBlank());
        boolean fetchTotal = isNewSession || page == 1;

        String sql = """
                {call sp_GetCustomersPaged(?, ?, ?, ?)}""";
        // @PageSize, @PageNumber, @SessionID (NULL nếu mới), @FetchTotal

        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, size);
            cs.setInt(2, page);

            if (isNewSession) {
                cs.setNull(3, Types.CHAR); // @SessionID = NULL → SP tự tạo
            } else {
                cs.setString(3, sessionId);
            }

            cs.setBoolean(4, fetchTotal); // @FetchTotal

            boolean hasResult = cs.execute();

            // ── ResultSet 1: TotalRecords + TotalPages + SessionID (chỉ khi fetchTotal =
            // 1) ──
            if (fetchTotal && hasResult) {
                try (ResultSet rsTotal = cs.getResultSet()) {
                    if (rsTotal.next()) {
                        totalRecords = rsTotal.getInt("TotalRecords");
                        totalPages = rsTotal.getInt("TotalPages");
                        returnedSessionId = rsTotal.getString("SessionID");
                    }
                }
                hasResult = cs.getMoreResults(); // tiến đến ResultSet data
            }

            // ── ResultSet 2 (hoặc 1 nếu không fetch total): Danh sách customers ──
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        CustomerListDTO dto = mapRow(rs);
                        customerList.add(dto);

                        // Lưu anchor của row cuối (dùng để debug hoặc stateless mode)
                        nextAnchorRfm = rs.getString("next_anchor_rfm");
                        nextAnchorId = rs.getInt("next_anchor_id");
                    }
                }
            }
        }

        return new CustomerPageResult(
                customerList,
                totalRecords,
                totalPages,
                page,
                size,
                returnedSessionId, // App giữ lại, truyền vào request tiếp theo
                nextAnchorRfm,
                nextAnchorId);
    }

//    public int countTotalCustomers(Connection connection) throws SQLException {
//        String sql = """
//                SELECT COUNT(*) FROM Customers
//                """;
//
//        try (PreparedStatement stm = connection.prepareStatement(sql); ResultSet rs = stm.executeQuery()) {
//            if (rs.next()) {
//                return rs.getInt(1);
//            }
//        }
//        return 0;
//    }

    // Xóa dữ liệu liên quan đến customer (để chuẩn bị xóa customer)
    public void deleteCustomerRelatedData(int customerId, Connection connection) throws SQLException {
        // ========== XÓA THEO THỨ TỰ FK CONSTRAINT ==========
        // Level 1: Xóa dữ liệu có FK tới Tickets
        // Feedbacks.ticket_id → Tickets.ticket_id
        String deleteFeedbacksSql = """
                DELETE FROM Feedbacks
                WHERE ticket_id IN (
                    SELECT ticket_id FROM Tickets WHERE customer_id = ?
                )
                """;
        try (PreparedStatement stm = connection.prepareStatement(deleteFeedbacksSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        String deleteDealsSql = "DELETE FROM Deals WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteDealsSql);) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // Level 2: Xóa Tickets (FK → Customers)
        String deleteTicketsSql = "DELETE FROM Tickets WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteTicketsSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // Level 3: Xóa dữ liệu liên quan khác
        // 1. Xóa Customer OTP
        String deleteOtpSql = "DELETE FROM CustomerOTP WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteOtpSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }
        // 2. Xóa Customer Style Map
        String deleteCsmSql = "DELETE FROM Customer_Style_Map WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteCsmSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // 3. Xóa Customer Measurements
        String deleteMeasurementSql = """
                DELETE FROM Customer_Measurements WHERE customer_id = ?
                """;
        try (PreparedStatement stm = connection.prepareStatement(deleteMeasurementSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // 4. Xóa Customer Segment Map
        String deleteCsmSegmentSql = """
                DELETE FROM Customer_Segment_Map WHERE customer_id = ?""";
        try (PreparedStatement stm = connection.prepareStatement(deleteCsmSegmentSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // 5. Xóa Virtual Wardrobe
        String deleteWardrobeSql = "DELETE FROM Virtual_Wardrobe WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteWardrobeSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }
    }

    private SQLServerDataTable toStringTVP(List<String> list) throws SQLException {

        SQLServerDataTable tvp = new SQLServerDataTable();
        tvp.addColumnMetadata("value", java.sql.Types.NVARCHAR);

        if (list != null) {
            for (String s : list) {
                tvp.addRow(s);
            }
        }
        return tvp;
    }

    private SQLServerDataTable toIntTVP(List<Integer> list) throws SQLException {

        SQLServerDataTable tvp = new SQLServerDataTable();
        tvp.addColumnMetadata("value", java.sql.Types.INTEGER);

        if (list != null) {
            for (Integer i : list) {
                tvp.addRow(i);
            }
        }
        return tvp;
    }

    public CustomerPageResult filterAdvanced(
            Connection connection,
            CustomerFilterRequest filterRequest,
            String sessionId) throws SQLException {

        List<CustomerListDTO> list = new ArrayList<>();
        int totalRecords = 0;
        int totalPages = 0;
        String returnedSessionId = sessionId;

        boolean isNewSession = (sessionId == null || sessionId.isBlank());
        boolean fetchTotal = isNewSession || filterRequest.getPage() == 1;

        // @PageSize, @PageNumber, @Keyword, @LoyaltyTiers, @BodyShapes,
        // @Sizes, @TagIds, @ReturnRateMode, @SessionID, @FetchTotal
        String sql = """
                {call dbo.sp_FilterCustomersAdvanced(?,?,?,?,?,?,?,?,?,?)}""";

        try (CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, filterRequest.getPageSize());
            cs.setInt(2, filterRequest.getPage());

            if (filterRequest.getKeyword() == null || filterRequest.getKeyword().isBlank()) {
                cs.setNull(3, Types.NVARCHAR);
            } else {
                cs.setString(3, filterRequest.getKeyword());
            }

            // ===== TVP PARAMS =====
            SQLServerCallableStatement scs = cs.unwrap(SQLServerCallableStatement.class);

            scs.setStructured(4, "dbo.StringList", toStringTVP(filterRequest.getLoyaltyTiers()));
            scs.setStructured(5, "dbo.StringList", toStringTVP(filterRequest.getBodyShapes()));
            scs.setStructured(6, "dbo.StringList", toStringTVP(filterRequest.getSizes()));
            scs.setStructured(7, "dbo.IntList", toIntTVP(filterRequest.getTagIds()));

            if (filterRequest.getReturnRateMode() == null) {
                cs.setNull(8, Types.NVARCHAR);
            } else {
                cs.setString(8, filterRequest.getReturnRateMode());
            }

            if (isNewSession) {
                cs.setNull(9, Types.CHAR); // @SessionID = NULL → SP tự tạo
            } else {
                cs.setString(9, sessionId);
            }

            cs.setBoolean(10, fetchTotal); // @FetchTotal

            // ===== EXECUTE =====
            boolean hasResult = cs.execute();

            // ResultSet 1: TotalRecords + TotalPages + SessionID (chỉ khi fetchTotal =
            // true)
            if (fetchTotal && hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        totalRecords = rs.getInt("TotalRecords");
                        totalPages = rs.getInt("TotalPages");
                        returnedSessionId = rs.getString("SessionID");
                    }
                }
                hasResult = cs.getMoreResults();
            }

            // ResultSet 2 (hoặc 1 nếu không fetchTotal): danh sách customers
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        }

        return new CustomerPageResult(
                list,
                totalRecords,
                totalPages,
                filterRequest.getPage(),
                filterRequest.getPageSize(),
                returnedSessionId,
                null, // nextAnchorRfm — filter mode không cần expose
                0);
    }
}
