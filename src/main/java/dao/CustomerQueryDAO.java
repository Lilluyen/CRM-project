package dao;

import com.microsoft.sqlserver.jdbc.SQLServerDataTable;
import dto.TimeCondition;
import model.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class CustomerQueryDAO {

    private final String BASE_QUERY = """
            SELECT  [customer_id]
                  ,[name]
                  ,[phone]
                  ,[email]
                  ,[birthday]
                  ,[gender]
                  ,[address]
                  ,[source]
                  ,[status]
                  ,[loyalty_tier]
                  ,[return_rate]
                  ,[last_purchase]
              FROM [Customers]
            """;

//    private CustomerListDTO mapRow(ResultSet rs) throws SQLException {
//
//        CustomerListDTO dto = new CustomerListDTO();
//
//        dto.setCustomerId(rs.getInt("customer_id"));
//        dto.setName(rs.getString("name"));
//        dto.setPhone(rs.getString("phone"));
//        dto.setEmail(rs.getString("email"));
//        dto.setGender(rs.getString("gender"));
//        dto.setLoyaltyTier(rs.getString("loyalty_tier"));
//        dto.setRfmScore(rs.getInt("rfm_score"));
//        dto.setPreferredSize(rs.getString("fit_profile"));
//        dto.setBodyShape(rs.getString("body_shape"));
//        dto.setHeight(rs.getBigDecimal("height"));
//        dto.setWeight(rs.getBigDecimal("weight"));
//
//        String styleTagsStr = rs.getString("style_tags");
//        if (styleTagsStr != null && !styleTagsStr.isBlank()) {
//            dto.setStyleTags(Arrays.asList(styleTagsStr.split("\\s*,\\s*")));
//        }
//
//        dto.setReturnRate(rs.getDouble("return_rate"));
//
//        Timestamp ts = rs.getTimestamp("last_purchase_date");
//        if (ts != null) {
//            dto.setLastPurchase(ts.toLocalDateTime());
//        }
//
//        return dto;
//    }

    public List<Customer> getCustomerList(
            Connection connection,
            int page,
            int size
    ) throws SQLException {
        List<Customer> customerList = new ArrayList<>();
        String sql = BASE_QUERY + """
                  Order by customer_id
                  OFFSET (? - 1) * ? Rows
                  FETCH NEXT ? ROWS only
                """;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, page);
            stm.setInt(2, size);
            stm.setInt(3, size);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setName(rs.getString("name"));
                customer.setPhone(rs.getString("phone"));
                customer.setEmail(rs.getString("email"));
                customer.setBirthday(rs.getDate("birthday").toLocalDate());
                customer.setGender(rs.getString("gender"));
                customer.setAddress(rs.getString("address"));
                customer.setSource(rs.getString("source"));
                customer.setStatus(rs.getString("status"));
                customer.setLoyaltyTier(rs.getString("loyalty_tier"));
                customer.setReturnRate(rs.getDouble("return_rate"));
                Timestamp ts = rs.getTimestamp("last_purchase");
                if (ts != null) {
                    customer.setLastPurchase(ts.toLocalDateTime());
                }
                customerList.add(customer);

            }
            return customerList;
        }

    }

    public int countTotalCustomers(Connection connection,
                                   String returnRate,
                                   String keyword,
                                   List<String> loyaltyTier,
                                   List<String> source, String gender, List<TimeCondition> timeConditions) throws SQLException {

        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*)
                FROM Customers
                WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();

        // keyword search
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (name LIKE ? OR phone LIKE ? OR email LIKE ?)");
            String value = "%" + keyword + "%";
            params.add(value);
            params.add(value);
            params.add(value);
        }

        // return rate filter
        if (returnRate != null && returnRate.equals("HIGH")) {
            sql.append(" AND return_rate >= 40.0");
        } else if (returnRate != null && returnRate.equals("LOW")) {
            sql.append(" AND return_rate < 40.0");
        }

        // loyalty tier filter
        if (loyaltyTier != null && !loyaltyTier.isEmpty()) {
            sql.append(" AND loyalty_tier IN (");
            sql.append(String.join(",", Collections.nCopies(loyaltyTier.size(), "?")));
            sql.append(")");
            params.addAll(loyaltyTier);
        }

        // source filter
        if (source != null && !source.isEmpty()) {
            sql.append(" AND source IN (");
            sql.append(String.join(",", Collections.nCopies(source.size(), "?")));
            sql.append(")");
            params.addAll(source);
        }
        if (gender != null) {
            sql.append(" AND gender = ?");
            params.add(gender);
        }
        if (timeConditions != null && !timeConditions.isEmpty()) {

            sql.append(" AND (");

            for (int i = 0; i < timeConditions.size(); i++) {

                TimeCondition t = timeConditions.get(i);

                // map field -> column
                String column = switch (t.getField()) {
                    case "last_purchase" -> "last_purchase";
                    case "birth_day" -> "birthday";
                    default -> null;
                };

                if (column == null) continue;

                // map operator -> SQL operator
                String op = switch (t.getOperator()) {
                    case "equal" -> "=";
                    case "before" -> "<";
                    case "after" -> ">";
                    default -> "=";
                };

                sql.append(column).append(" ").append(op).append(" ?");

                params.add(Date.valueOf(t.getDate()));

                // add AND / OR
                if (t.getSubCondition() != null && i < timeConditions.size() - 1) {
                    sql.append(" ").append(t.getSubCondition().toUpperCase()).append(" ");
                }
            }

            sql.append(")");
        }

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stm.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
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

    public List<Customer> filterAdvanced(
            Connection connection, String keyword,
            String returnRate, List<String> loyaltyTier,
            List<String> source, String gender, List<TimeCondition> timeConditions, int page, int size) throws SQLException {

        StringBuilder sql = new StringBuilder(
                BASE_QUERY + " WHERE 1=1"
        );


        List<Object> params = new ArrayList<>();
        List<Customer> customerList = new ArrayList<>();

        // keyword search
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(name) LIKE ? OR phone LIKE ? OR email LIKE ?)");
            String value = "%" + keyword.trim().toLowerCase() + "%";
            params.add(value);
            params.add(value);
            params.add(value);
        }

        // return rate filter
        if (returnRate != null && returnRate.equals("HIGH")) {
            sql.append(" AND return_rate > 40.0");
        } else if (returnRate != null && returnRate.equals("LOW")) {
            sql.append(" AND return_rate <= 40.0");
        }

        // loyalty tier filter
        if (loyaltyTier != null && !loyaltyTier.isEmpty()) {
            sql.append(" AND loyalty_tier IN (");
            sql.append(String.join(",", Collections.nCopies(loyaltyTier.size(), "?")));
            sql.append(")");
            params.addAll(loyaltyTier);
        }

        // source filter
        if (source != null && !source.isEmpty()) {
            sql.append(" AND source IN (");
            sql.append(String.join(",", Collections.nCopies(source.size(), "?")));
            sql.append(")");
            params.addAll(source);
        }
        if (gender != null) {
            sql.append(" AND gender = ?");
            params.add(gender);
        }
        if (timeConditions != null && !timeConditions.isEmpty()) {

            sql.append(" AND (");

            for (int i = 0; i < timeConditions.size(); i++) {

                TimeCondition t = timeConditions.get(i);

                // map field -> column
                String column = switch (t.getField()) {
                    case "last_purchase" -> "last_purchase";
                    case "birth_day" -> "birthday";
                    default -> null;
                };

                if (column == null) continue;

                // map operator -> SQL operator
                String op = switch (t.getOperator()) {
                    case "equal" -> "=";
                    case "before" -> "<";
                    case "after" -> ">";
                    default -> "=";
                };

                sql.append(column).append(" ").append(op).append(" ?");

                params.add(Date.valueOf(t.getDate()));

                // add AND / OR
                if (t.getSubCondition() != null && i < timeConditions.size() - 1) {
                    sql.append(" ").append(t.getSubCondition().toUpperCase()).append(" ");
                }
            }

            sql.append(")");
        }
        sql.append(" Order by customer_id OFFSET (? - 1) * ? Rows FETCH NEXT ? ROWS only");
        params.add(page);
        params.add(size);
        params.add(size);


        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stm.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stm.executeQuery()) {
                while (rs.next()) {
                    Customer customer = new Customer();

                    customer.setCustomerId(rs.getInt("customer_id"));
                    customer.setName(rs.getString("name"));
                    customer.setPhone(rs.getString("phone"));
                    customer.setEmail(rs.getString("email"));
                    customer.setBirthday(rs.getDate("birthday").toLocalDate());
                    customer.setGender(rs.getString("gender"));
                    customer.setAddress(rs.getString("address"));
                    customer.setSource(rs.getString("source"));
                    customer.setStatus(rs.getString("status"));
                    customer.setLoyaltyTier(rs.getString("loyalty_tier"));
                    customer.setReturnRate(rs.getDouble("return_rate"));
                    Timestamp ts = rs.getTimestamp("last_purchase");
                    if (ts != null) {
                        customer.setLastPurchase(ts.toLocalDateTime());
                    }
                    customerList.add(customer);
                }
                return customerList;
            }
        }
    }
}
