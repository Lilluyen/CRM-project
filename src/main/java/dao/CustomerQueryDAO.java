package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import dto.CustomerListDTO;
import util.DBContext;

public class CustomerQueryDAO extends DBContext {

    public List<CustomerListDTO> getCustomerList() throws SQLException {

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
}
