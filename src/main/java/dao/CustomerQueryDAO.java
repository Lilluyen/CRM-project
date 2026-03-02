package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import dto.CustomerListDTO;

public class CustomerQueryDAO {

    public List<CustomerListDTO> getCustomerList(Connection connection) throws SQLException {

        // Implement the logic to fetch customer list with necessary details
        List<CustomerListDTO> customerList = new java.util.ArrayList<>();

        String sql = """
                SELECT
                    c.customer_id,
                    c.[name],
                    c.phone,
                    c.loyalty_tier,
                    c.rfm_score,

                	CASE
                    WHEN m.preferred_size IS NULL THEN NULL
                    ELSE CONCAT(
                        m.preferred_size,
                        ' (',
                        CAST(m.height AS INT),
                        'cm - ',
                        CAST(m.weight AS INT),
                        'kg)'
                    )
                END AS fit_profile,

                    m.body_shape,

                    STUFF((
                        SELECT ', ' + t.tag_name
                        FROM Customer_Style_Map csm
                        JOIN Style_Tags t ON csm.tag_id = t.tag_id
                        WHERE csm.customer_id = c.customer_id
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS style_tags,

                    c.return_rate,
                    c.last_purchase AS last_purchase_date,
                    c.[status]

                FROM Customers c

                OUTER APPLY (
                    SELECT TOP 1 *
                    FROM Customer_Measurements
                    WHERE customer_id = c.customer_id
                    ORDER BY measured_at DESC
                ) m

                ORDER BY c.rfm_score DESC;
                """;

        try (
                PreparedStatement stm = connection.prepareStatement(sql);
                ResultSet rs = stm.executeQuery();) {
            while (rs.next()) {
                CustomerListDTO dto = new CustomerListDTO();
                dto.setCustomerId(rs.getInt("customer_id"));
                dto.setName(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setLoyaltyTier(rs.getString("loyalty_tier"));
                dto.setRfmScore(rs.getInt("rfm_score"));
                dto.setPreferredSize(rs.getString("fit_profile"));
                dto.setBodyShape(rs.getString("body_shape"));

                String styleTagsStr = rs.getString("style_tags");

                if (styleTagsStr != null && !styleTagsStr.isBlank()) {
                    List<String> tags = Arrays.asList(styleTagsStr.replace("[", "")
                            .replace("]", "")
                            .split("\\s*,\\s*"));
                    dto.setStyleTags(tags);
                }

                dto.setReturnRate(rs.getDouble("return_rate"));
                Timestamp ts = rs.getTimestamp("last_purchase_date");
                if (ts != null) {
                    dto.setLastPurchase(ts.toLocalDateTime());
                }
                customerList.add(dto);
            }
        }
        return customerList;
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

        // Level 2: Xóa Tickets (FK → Customers)
        String deleteTicketsSql = "DELETE FROM Tickets WHERE customer_id = ?";
        try (PreparedStatement stm = connection.prepareStatement(deleteTicketsSql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }

        // Level 3: Xóa dữ liệu liên quan khác
        // 1. Xóa Customer OTP
//        String deleteOtpSql = "DELETE FROM CustomerOTP WHERE customer_id = ?";
//        try (PreparedStatement stm = connection.prepareStatement(deleteOtpSql)) {
//            stm.setInt(1, customerId);
//            stm.executeUpdate();
//        }

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

}
