package dao;

import model.CustomerContact;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CustomerContactDAO {

    public void insertCustomerContact(Connection conn, CustomerContact contact) throws SQLException {
        String sql = """
                
                INSERT INTO [customer_contact]
                           ([customer_id]
                           ,[type]
                           ,[value]
                           ,[is_primary]
                           ,[created_at])
                     VALUES
                           (?
                           ,?
                           ,?
                           ,?
                           ,GETDATE())
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contact.getCustomerId());
            ps.setString(2, contact.getType());
            ps.setString(3, contact.getValue());
            ps.setBoolean(4, contact.getPrimary());

            ps.executeUpdate();
        }

    }

    public List<CustomerContact> getByCustomerId(Connection conn, int customerId) throws SQLException {
        String sql = """
                Select id, customer_id, [type], [value], is_primary
                From customer_contact
                Where customer_id = ?
                Order By created_at ASC
                """;
        List<CustomerContact> contacts = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerContact contact = new CustomerContact();

                contact.setContactId(rs.getInt("id"));
                contact.setCustomerId(rs.getInt("customer_id"));
                contact.setPrimary(rs.getBoolean("is_primary"));
                contact.setType(rs.getString("type"));
                contact.setValue(rs.getString("value"));

                contacts.add(contact);
            }
        }
        return contacts;
    }

    public boolean deleteById(Connection conn, int contactId, int customerId)
            throws SQLException {
        // customerId để đảm bảo chỉ xóa contact thuộc đúng customer đó
        String sql = "DELETE FROM customer_contact WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    // Bỏ primary tất cả contact cùng type của 1 customer
    public void clearPrimaryByType(Connection conn, int customerId, String type)
            throws SQLException {
        String sql = "UPDATE customer_contact SET is_primary = 0 " +
                "WHERE customer_id = ? AND type = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, type);
            ps.executeUpdate();
        }
    }

    // Set 1 contact cụ thể thành primary
    public void setPrimary(Connection conn, int contactId, int customerId)
            throws SQLException {
        String sql = "UPDATE customer_contact SET is_primary = 1 " +
                "WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            ps.setInt(2, customerId);
            ps.executeUpdate();
        }
    }


    // Lấy 1 contact theo id
    public CustomerContact findById(Connection conn, int contactId, int customerId)
            throws SQLException {
        String sql = "SELECT id, customer_id, type, value, is_primary " +
                "FROM customer_contact WHERE id = ? AND customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerContact c = new CustomerContact();
                    c.setContactId(rs.getInt("id"));
                    c.setCustomerId(rs.getInt("customer_id"));
                    c.setType(rs.getString("type"));
                    c.setValue(rs.getString("value"));
                    c.setPrimary(rs.getBoolean("is_primary"));
                    return c;
                }
            }
        }
        return null;
    }

    // Trong CustomerContactDAO
    public boolean existsByValue(Connection conn, int customerId, String value)
            throws SQLException {
        String sql = "SELECT 1 FROM customer_contact " +
                "WHERE customer_id = ? AND LOWER(value) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public CustomerContact getByValue(Connection conn, int customerId, String value)
            throws SQLException {
        String sql = "SELECT id, value FROM customer_contact " +
                "WHERE customer_id = ? AND LOWER(value) = LOWER(?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, value);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerContact c = new CustomerContact();
                    c.setContactId(rs.getInt("id"));
                    c.setValue(rs.getString("value"));
                    return c;
                }
                return null; // không tìm thấy
            }
        }
    }
}
