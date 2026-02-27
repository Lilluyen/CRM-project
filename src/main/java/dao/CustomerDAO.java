package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.Customer;

public class CustomerDAO {

    public int insertCustomer(Customer customer, Connection connection) throws SQLException {
        String sql = """
                INSERT INTO [Customers]
                           ([name]
                           ,[phone]
                           ,[email]
                           ,[birthday]
                           ,[gender]
                           ,[address]
                           ,[social_link]
                           ,[owner_id]
                           ,[created_at])
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""";
        try (PreparedStatement stmt = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, customer.getName());
            stmt.setString(2, customer.getPhone());
            stmt.setString(3, customer.getEmail());

            stmt.setDate(4,
                    java.sql.Date.valueOf(customer.getBirthday()) != null
                            ? java.sql.Date.valueOf(customer.getBirthday())
                            : null);
            stmt.setString(5, customer.getGender() != null ? customer.getGender() : null);
            stmt.setString(6, customer.getAddress() != null ? customer.getAddress() : null);
            stmt.setString(7, customer.getSocialLink() != null ? customer.getSocialLink() : null);

            stmt.setInt(8, customer.getOwner().getUserId());
            stmt.setTimestamp(9, new java.sql.Timestamp(System.currentTimeMillis()));

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating customer failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating customer failed, no ID obtained.");
                }
            }
        }
    }

    public boolean existsByPhone(String phone, Connection conn) throws Exception {

        String sql = "SELECT 1 FROM Customers WHERE phone = ?";

        try (var ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);

            try (var rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Customer getCustomerById(int customerId, Connection connection) throws SQLException {
        String sql = "SELECT * FROM Customers WHERE customer_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("customer_id"));
                    customer.setName(rs.getString("name"));
                    customer.setPhone(rs.getString("phone"));
                    customer.setEmail(rs.getString("email"));
                    return customer;
                }
            }
        }
        return null;
    }

    public Customer findByEmail(String email) throws SQLException {

        String sql = "SELECT * FROM Customers WHERE email = ?";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerId(rs.getInt("customer_id"));
                    customer.setName(rs.getString("name"));
                    customer.setPhone(rs.getString("phone"));
                    customer.setEmail(rs.getString("email"));

                    if (rs.getDate("birthday") != null) {
                        customer.setBirthday(rs.getDate("birthday").toLocalDate());
                    }

                    customer.setGender(rs.getString("gender"));
                    customer.setAddress(rs.getString("address"));
                    customer.setSocialLink(rs.getString("social_link"));

                    return customer;
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return null;
    }

    public boolean deleteCustomerById(int customerId, Connection connection) throws SQLException {
        String sql = "DELETE FROM Customers WHERE customer_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        }
    }

}
