package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Customer;

public class CustomerLookupDAO {

    private final Connection conn;

    public CustomerLookupDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Customer> getAllCustomersBasic() throws SQLException {
        String sql = "SELECT customer_id, name, phone, email FROM Customers ORDER BY name ASC";

        List<Customer> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setName(rs.getString("name"));
                c.setPhone(rs.getString("phone"));
                c.setEmail(rs.getString("email"));
                list.add(c);
            }
        }
        return list;
    }
}
