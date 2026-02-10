package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import model.Customer;
import model.User;
import ultil.DBContext;
import ultil.PhoneCheck;

public class CustomerDAO extends DBContext {

    private final String BASE_CUSTOMER_QUERY = """
            SELECT c.[customer_id]
                  ,c.[name]
                  ,c.[address]
                  ,c.[industry]
                  ,c.[company_size]
                  ,c.[phone]
                  ,c.[email]
                  ,c.[status]
                  ,c.[customer_type]
                  ,c.[owner_id]
                  ,c.[created_at]
                  ,c.[updated_at]
                  , """;

    public ArrayList<Customer> getAllCustomers() throws SQLException {
        ArrayList<Customer> customers = new ArrayList<>();

        String sql = BASE_CUSTOMER_QUERY + " u.[full_name]" +
                "  FROM [Customers] c JOIN [Users] u ON c.owner_id = u.[user_id]" +
                "  ORDER BY c.[created_at] DESC";

        try (
                PreparedStatement stm = connection.prepareStatement(sql);
                ResultSet rs = stm.executeQuery();) {
            while (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setName(rs.getNString("name"));
                customer.setAddress(rs.getNString("address"));
                customer.setIndustry(rs.getNString("industry"));
                customer.setCompanySize(rs.getString("company_size"));

                // Email and Phone validation
                if (PhoneCheck.isValidPhone(rs.getString("phone"))) {
                    customer.setPhone(rs.getString("phone"));

                } else {
                    customer.setPhone(null);
                }

                if (ultil.EmailCheck.isValidEmail(rs.getString("email"))) {
                    customer.setEmail(rs.getString("email"));
                } else {
                    customer.setEmail(null);
                }

                customer.setStatus(rs.getString("status"));
                User owner = new User();
                owner.setUserId(rs.getInt("owner_id"));
                owner.setFullName(rs.getNString("full_name"));
                customer.setOwner(owner);

                Timestamp createdAtTs = rs.getTimestamp("created_at");
                if (createdAtTs != null) {
                    customer.setCreatedAt(createdAtTs.toLocalDateTime());
                }

                Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) {
                    customer.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                customers.add(customer);
            }
        }

        return customers;
    }

    public Customer getCustomerById(int customerId) throws SQLException {
        String sql = BASE_CUSTOMER_QUERY + "WHERE customer_id = ?";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, customerId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setName(rs.getNString("name"));
                customer.setAddress(rs.getNString("address"));
                customer.setIndustry(rs.getNString("industry"));
                customer.setCompanySize(rs.getString("company_size"));

                // Email and Phone validation
                if (PhoneCheck.isValidPhone(rs.getString("phone"))) {
                    customer.setPhone(rs.getString("phone"));

                } else {
                    customer.setPhone(null);
                }

                if (ultil.EmailCheck.isValidEmail(rs.getString("email"))) {
                    customer.setEmail(rs.getString("email"));
                } else {
                    customer.setEmail(null);
                }

                customer.setStatus(rs.getString("status"));
                User owner = new User();
                owner.setUserId(rs.getInt("owner_id"));
                owner.setFullName(rs.getNString("full_name"));
                customer.setOwner(owner);

                Timestamp createdAtTs = rs.getTimestamp("created_at");
                if (createdAtTs != null) {
                    customer.setCreatedAt(createdAtTs.toLocalDateTime());
                }

                Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) {
                    customer.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                return customer;
            }
        }

        return null;
    }

    public void addCustomer(Customer customer) throws SQLException {
        String sql = "INSERT INTO [Customers] ([name], [address], [industry], [company_size], [phone], [email], [status], [owner_id], [created_at], [updated_at]) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setNString(1, customer.getName());
            stm.setNString(2, customer.getAddress());
            stm.setNString(3, customer.getIndustry());
            stm.setNString(4, customer.getCompanySize());
            stm.setString(5, customer.getPhone());
            stm.setString(6, customer.getEmail());
            stm.setString(7, customer.getStatus());
            stm.setInt(8, customer.getOwner().getUserId());
            stm.setTimestamp(9, Timestamp.valueOf(customer.getCreatedAt()));
            stm.setTimestamp(10, Timestamp.valueOf(customer.getUpdatedAt()));

            stm.executeUpdate();
        }
    }

}
