package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Lead;

public class LeadLookupDAO {

    private final Connection conn;

    public LeadLookupDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Lead> getAllLeadsBasic() throws SQLException {
        String sql = "SELECT lead_id, full_name, email, phone, status FROM Leads ORDER BY updated_at DESC";

        List<Lead> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Lead l = new Lead();
                l.setLeadId(rs.getInt("lead_id"));
                l.setFullName(rs.getString("full_name"));
                l.setEmail(rs.getString("email"));
                l.setPhone(rs.getString("phone"));
                l.setStatus(rs.getString("status"));
                list.add(l);
            }
        }
        return list;
    }
}
