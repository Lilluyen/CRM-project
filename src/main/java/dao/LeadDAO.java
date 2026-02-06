package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.sql.Statement;
import java.sql.Timestamp;
import model.Lead;
import ultil.DBContext;

public class LeadDAO {

    public int insert(Lead lead) {
        String sql = "INSERT INTO Leads(full_name, email, phone, company_name, interest, source, status, score, campaign_id, assigned_to, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, lead.getFullName());
            ps.setString(2, lead.getEmail());
            ps.setString(3, lead.getPhone());
            ps.setString(4, lead.getCompanyName());
            ps.setString(5, lead.getInterest());
            ps.setString(6, lead.getSource());
            ps.setString(7, lead.getStatus());
            ps.setInt(8, lead.getScore());
            ps.setInt(9, lead.getCampaignId());
            ps.setInt(10, lead.getAssignedTo());
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(12, Timestamp.valueOf(LocalDateTime.now()));

            if (ps.executeUpdate() > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean update(Lead lead) {
        String sql = "UPDATE Leads SET full_name=?, email=?, phone=?, company_name=?, interest=?, source=?, status=?, score=?, campaign_id=?, assigned_to=?, updated_at=? WHERE lead_id=?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lead.getFullName());
            ps.setString(2, lead.getEmail());
            ps.setString(3, lead.getPhone());
            ps.setString(4, lead.getCompanyName());
            ps.setString(5, lead.getInterest());
            ps.setString(6, lead.getSource());
            ps.setString(7, lead.getStatus());
            ps.setInt(8, lead.getScore());
            ps.setInt(9, lead.getCampaignId());
            ps.setInt(10, lead.getAssignedTo());
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(12, lead.getLeadId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Lead getById(int leadId) {
        String sql = "SELECT * FROM Leads WHERE lead_id = ?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Lead findByEmail(String email) {
        String sql = "SELECT * FROM Leads WHERE email = ?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Lead> getAll() {
        String sql = "SELECT * FROM Leads ORDER BY created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    public List<Lead> getByCampaignId(int campaignId) {
        String sql = "SELECT * FROM Leads WHERE campaign_id = ? ORDER BY created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    public List<Lead> getByStatus(String status) {
        String sql = "SELECT * FROM Leads WHERE status = ? ORDER BY score DESC, created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    private Lead mapResultSetToLead(ResultSet rs) throws SQLException {
        return new Lead(
                rs.getInt("lead_id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("company_name"),
                rs.getString("interest"),
                rs.getString("source"),
                rs.getString("status"),
                rs.getInt("score"),
                rs.getInt("campaign_id"),
                rs.getInt("assigned_to"),
                rs.getTimestamp("created_at").toLocalDateTime(),
                rs.getTimestamp("updated_at").toLocalDateTime()
        );
    }
}
