package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import model.Customer;
import ultil.DBContext;

public class CustomerDAO extends DBContext {

    private final String BASE_CUSTOMER_QUERY = """
            SELECT c.[customer_id]
             ,c.[name]
             ,c.[phone]
             ,c.[email]
             ,c.[birthday]
             ,c.[gender]
             ,c.[address]
             ,c.[social_link]
             ,c.[customer_type]
             ,c.[status]
             ,c.[loyalty_tier]
             ,c.[rfm_score]
             ,c.[return_rate]
             ,c.[last_purchase]
             ,c.[owner_id]
             ,c.[created_at]
             ,c.[updated_at]
                    """;

    public ArrayList<Customer> getAllCustomers() throws SQLException {
        ArrayList<Customer> customers = new ArrayList<>();

        String sql = """
                SELECT
                    c.customer_id,
                    c.[name],
                    c.phone,
                    c.loyalty_tier,
                    c.rfm_score,
                    CONCAT(m.preferred_size, ' (', CAST(m.height AS INT), 'cm - ', CAST(m.weight AS INT), 'kg)') AS fit_profile,
                    m.body_shape,
                    STUFF((
                        SELECT ', ' + t.tag_name
                        FROM Customer_Style_Map csm
                        JOIN Style_Tags t ON csm.tag_id = t.tag_id
                        WHERE csm.customer_id = c.customer_id
                        FOR XML PATH('')), 1, 2, '') AS style_tags,
                    c.return_rate,
                    FORMAT(c.last_purchase, 'dd/MM/yyyy') AS last_purchase_date,
                    c.[status]
                FROM Customers c
                LEFT JOIN Customer_Measurements m ON c.customer_id = m.customer_id
                ORDER BY c.rfm_score DESC;
                """;

        try (
                PreparedStatement stm = connection.prepareStatement(sql);
                ResultSet rs = stm.executeQuery();) {
            while (rs.next()) {
                Customer customer = new Customer();

                customers.add(customer);
            }
        }

        return customers;
    }

}
