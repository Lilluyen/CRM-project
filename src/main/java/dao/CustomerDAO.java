package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.CustomerDetailDTO;
import model.Customer;
import util.DBContext;

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
                           ,[source]
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
            stmt.setString(7, customer.getSource() != null ? customer.getSource() : null);

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

    public boolean existsByEmail(String email, Connection conn) throws Exception {

        String sql = "SELECT 1 FROM Customers WHERE email = ?";

        try (var ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);

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
                    customer.setSource(rs.getString("source"));

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

    public CustomerDetailDTO getCustomerBase(Connection conn, int id) throws Exception {

        String sql = """
                    SELECT
                        c.customer_id,
                        c.name,
                        c.phone,
                        c.email,
                        c.birthday,
                        c.gender,
                        c.address,
                        c.source,
                        c.status,
                        c.loyalty_tier,
                        c.rfm_score,
                        c.return_rate,
                        c.last_purchase,
                        u.full_name AS owner_name
                    FROM Customers c
                    LEFT JOIN Users u ON c.owner_id = u.user_id
                    WHERE c.customer_id = ?
                """;

        try (var ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (var rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                CustomerDetailDTO dto = new CustomerDetailDTO();

                dto.setCustomerId(rs.getInt("customer_id"));
                dto.setName(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setEmail(rs.getString("email"));
                dto.setBirthday(rs.getDate("birthday").toLocalDate());
                dto.setGender(rs.getString("gender"));
                dto.setAddress(rs.getString("address"));
                dto.setSource(rs.getString("source"));
                dto.setStatus(rs.getString("status"));
                dto.setLoyaltyTier(rs.getString("loyalty_tier"));
                dto.setRfmScore(rs.getInt("rfm_score"));
                dto.setReturnRate(rs.getDouble("return_rate"));
                dto.setLastPurchase(
                        rs.getTimestamp("last_purchase") != null
                                ? rs.getTimestamp("last_purchase").toLocalDateTime()
                                : null);
                dto.setOwnerName(rs.getString("owner_name"));

                return dto;
            }
        }
    }

    public void updateBasicInfo(Customer customer, Connection conn)
            throws SQLException {

        String sql = """
                    UPDATE Customers
                    SET name = ?,
                        phone = ?,
                        email = ?,
                        birthday = ?,
                        gender = ?,
                        address = ?,
                        source = ?,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE customer_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customer.getName());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());

            if (customer.getBirthday() != null) {
                ps.setDate(4, java.sql.Date.valueOf(customer.getBirthday()));
            } else {
                ps.setNull(4, java.sql.Types.DATE);
            }

            ps.setString(5, customer.getGender());
            ps.setString(6, customer.getAddress());
            ps.setString(7, customer.getSource());

            ps.setInt(8, customer.getCustomerId());

            ps.executeUpdate();
        }
    }

    public boolean existsByPhoneExcludeId(String phone, int customerId, Connection conn)
            throws SQLException {

        String sql = """
                    SELECT 1 FROM Customers
                    WHERE phone = ? AND customer_id <> ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByEmailExcludeId(String email, int customerId, Connection conn)
            throws SQLException {

        String sql = """
                    SELECT 1 FROM Customers
                    WHERE email = ? AND customer_id <> ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
