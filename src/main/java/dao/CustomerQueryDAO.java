package dao;

import com.microsoft.sqlserver.jdbc.SQLServerDataTable;
import dto.CustomerFilterRequest;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import dto.CustomerListDTO;
import dto.CustomerPageResult;

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
            int size) throws SQLException {

        List<CustomerListDTO> customerList = new ArrayList<>();
        int totalRecords = 0;

        try (CallableStatement cs = connection.prepareCall("{call sp_GetCustomersPaged(?,?)}")) {

            cs.setInt(1, page);
            cs.setInt(2, size);

            boolean hasResult = cs.execute();

            // ===== ResultSet 1: TotalRecords =====
            if (hasResult) {
                try (ResultSet rsTotal = cs.getResultSet()) {
                    if (rsTotal.next()) {
                        totalRecords = rsTotal.getInt("TotalRecords");
                    }
                }
            }

            // Move to ResultSet 2
            if (cs.getMoreResults()) {

                try (ResultSet rs = cs.getResultSet()) {

                    while (rs.next()) {
                        CustomerListDTO dto = mapRow(rs);

                        customerList.add(dto);
                    }
                }
            }
        }

        return new CustomerPageResult(customerList, totalRecords);
    }

    public int countTotalCustomers(Connection connection) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Customers";

        try (PreparedStatement stm = connection.prepareStatement(sql); ResultSet rs = stm.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

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
        String deleteMeasurementSql = "DELETE FROM Customer_Measurements WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteMeasurementSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // 4. Xóa Customer Segment Map
        String deleteCsmSegmentSql = "DELETE FROM Customer_Segment_Map WHERE customer_id = ?";
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
            CustomerFilterRequest filterRequest
    ) throws SQLException {

        List<CustomerListDTO> list = new ArrayList<>();
        int totalRecords = 0;

        String sql = "{call dbo.sp_FilterCustomersAdvanced(?,?,?,?,?,?,?,?)}";

        try (CallableStatement cs = connection.prepareCall(sql)) {

            // ===== BASIC PARAMS =====
            cs.setInt(1, filterRequest.getPage());
            cs.setInt(2, filterRequest.getPageSize());
            cs.setString(3, filterRequest.getKeyword());

            // ===== TVP PARAMS =====
            SQLServerDataTable tierTVP = toStringTVP(filterRequest.getLoyaltyTiers());
            SQLServerDataTable shapeTVP = toStringTVP(filterRequest.getBodyShapes());
            SQLServerDataTable sizeTVP = toStringTVP(filterRequest.getSizes());
            SQLServerDataTable tagTVP = toIntTVP(filterRequest.getTagIds());

            cs.unwrap(com.microsoft.sqlserver.jdbc.SQLServerCallableStatement.class)
                    .setStructured(4, "dbo.StringList", tierTVP);

            cs.unwrap(com.microsoft.sqlserver.jdbc.SQLServerCallableStatement.class)
                    .setStructured(5, "dbo.StringList", shapeTVP);

            cs.unwrap(com.microsoft.sqlserver.jdbc.SQLServerCallableStatement.class)
                    .setStructured(6, "dbo.StringList", sizeTVP);

            cs.unwrap(com.microsoft.sqlserver.jdbc.SQLServerCallableStatement.class)
                    .setStructured(7, "dbo.IntList", tagTVP);

            cs.setString(8, filterRequest.getReturnRateMode());

            // ===== EXECUTE =====
            boolean hasResults = cs.execute();
            int resultIndex = 0;

            while (hasResults || cs.getUpdateCount() != -1) {

                if (hasResults) {
                    try (ResultSet rs = cs.getResultSet()) {

                        if (resultIndex == 0) {
                            if (rs.next()) {
                                totalRecords = rs.getInt("TotalRecords");
                            }
                        } else if (resultIndex == 1) {
                            while (rs.next()) {
                                list.add(mapRow(rs));
                            }
                        }
                    }
                    resultIndex++;
                }

                hasResults = cs.getMoreResults();
            }
        }

        return new CustomerPageResult(list, totalRecords);
    }

}
