package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import dto.CustomerDetailDTO;
import dto.CustomerListDTO;
import model.CustomerMeasurement;
import model.StyleTag;

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

    public CustomerDetailDTO getCustomerDetail(int customerId, Connection connection) throws SQLException {
        CustomerDetailDTO dto = null;
        List<CustomerMeasurement> measurements = new java.util.ArrayList<>();
        List<StyleTag> styleTags = new java.util.ArrayList<>();

        // Gộp 3 câu truy vấn thành 1
        String sql = """
                SELECT
                    c.customer_id,
                    c.name,
                    c.phone,
                    c.email,
                    c.birthday,
                    c.gender,
                    c.address,
                    c.social_link,
                    c.customer_type,
                    c.status,
                    c.loyalty_tier,
                    c.rfm_score,
                    c.return_rate,
                    c.last_purchase,
                    u.full_name AS owner_name,
                    m.measure_id,
                    m.height,
                    m.weight,
                    m.bust,
                    m.waist,
                    m.hips,
                    m.shoulder,
                    m.preferred_size,
                    m.body_shape,
                    m.measured_at,
                    t.tag_id,
                    t.tag_name,
                    t.category
                FROM Customers c
                LEFT JOIN Users u ON c.owner_id = u.user_id
                OUTER APPLY (
                    SELECT TOP 1 *
                    FROM Customer_Measurements
                    WHERE customer_id = c.customer_id
                    ORDER BY measured_at DESC
                ) m
                LEFT JOIN Customer_Style_Map csm ON c.customer_id = csm.customer_id
                LEFT JOIN Style_Tags t ON csm.tag_id = t.tag_id
                WHERE c.customer_id = ?
                ORDER BY m.measure_id DESC, t.tag_id
                """;

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, customerId);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                // Khởi tạo DTO nếu chưa có (lần đầu tiên lặp)
                if (dto == null) {
                    dto = new CustomerDetailDTO();
                    dto.setCustomerId(rs.getInt("customer_id"));
                    dto.setName(rs.getString("name"));
                    dto.setPhone(rs.getString("phone"));
                    dto.setEmail(rs.getString("email"));

                    java.sql.Date birthday = rs.getDate("birthday");
                    if (birthday != null) {
                        dto.setBirthday(birthday.toLocalDate());
                    }

                    dto.setGender(rs.getString("gender"));
                    dto.setAddress(rs.getString("address"));
                    dto.setSocialLink(rs.getString("social_link"));
                    dto.setCustomerType(rs.getString("customer_type"));
                    dto.setStatus(rs.getString("status"));
                    dto.setLoyaltyTier(rs.getString("loyalty_tier"));
                    dto.setRfmScore(rs.getInt("rfm_score"));
                    dto.setReturnRate(rs.getDouble("return_rate"));

                    Timestamp lastPurchase = rs.getTimestamp("last_purchase");
                    if (lastPurchase != null) {
                        dto.setLastPurchase(lastPurchase.toLocalDateTime());
                    }

                    dto.setOwnerName(rs.getString("owner_name"));
                }

                // Thêm Measurement nếu tồn tại
                if (rs.getInt("measure_id") != 0) {
                    if (measurements.isEmpty()) { // Chỉ thêm 1 lần (do OUTER APPLY TOP 1)
                        CustomerMeasurement measurement = new CustomerMeasurement();
                        measurement.setMeasureId(rs.getInt("measure_id"));
                        measurement.setCustomerId(rs.getInt("customer_id"));
                        measurement.setHeight(rs.getBigDecimal("height"));
                        measurement.setWeight(rs.getBigDecimal("weight"));
                        measurement.setBust(rs.getBigDecimal("bust"));
                        measurement.setWaist(rs.getBigDecimal("waist"));
                        measurement.setHips(rs.getBigDecimal("hips"));
                        measurement.setShoulder(rs.getBigDecimal("shoulder"));
                        measurement.setPreferredSize(rs.getString("preferred_size"));
                        measurement.setBodyShape(rs.getString("body_shape"));

                        Timestamp measuredAt = rs.getTimestamp("measured_at");
                        if (measuredAt != null) {
                            measurement.setMeasuredAt(measuredAt.toLocalDateTime());
                        }

                        measurements.add(measurement);
                    }
                }

                // Thêm Style Tag nếu tồn tại (có thể nhiều tags)
                if (rs.getInt("tag_id") != 0) {
                    StyleTag tag = new StyleTag();
                    tag.setTagId(rs.getInt("tag_id"));
                    tag.setTagName(rs.getString("tag_name"));
                    tag.setCategory(rs.getString("category"));
                    styleTags.add(tag);
                }
            }
        }

        // Set dữ liệu vào DTO
        if (dto != null) {
            dto.setMeasurements(measurements);
            dto.setStyleTags(styleTags);
        }

        return dto;
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

}
