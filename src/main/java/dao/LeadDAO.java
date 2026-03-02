package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.Lead;
import util.DBContext;

public class LeadDAO {

    // Tạo mới một lead và trả về ID vừa được sinh ra
    public int createLead(Lead lead) {
        String sql = "INSERT INTO Leads(full_name, email, phone, company_name, interest, source, status, score, campaign_id, assigned_to, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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

    // Cập nhật thông tin một lead theo ID
    public boolean updateLead(Lead lead) {
        String sql = "UPDATE Leads SET full_name=?, email=?, phone=?, company_name=?, interest=?, source=?, status=?, score=?, campaign_id=?, assigned_to=?, updated_at=? WHERE lead_id=?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Lấy thông tin một lead theo ID
    public Lead getLeadById(int leadId) {
        String sql = "SELECT * FROM Leads WHERE lead_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Tìm một lead theo email
    public Lead findLeadByEmail(String email) {
        String sql = "SELECT * FROM Leads WHERE email = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Lấy toàn bộ danh sách lead (mới nhất trước)
    public List<Lead> getAllLeads() {
        String sql = "SELECT * FROM Leads ORDER BY created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    // Lấy danh sách lead theo chiến dịch, sắp xếp mới nhất trước
    public List<Lead> getLeadByCampaignId(int campaignId) {
        String sql = "SELECT * FROM Leads WHERE campaign_id = ? ORDER BY created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Lấy danh sách lead theo trạng thái, sắp xếp theo điểm số cao nhất trước, nếu
    // điểm số bằng nhau thì mới nhất trước
    public List<Lead> getLeadByStatus(String status) {
        String sql = "SELECT * FROM Leads WHERE status = ? ORDER BY score DESC, created_at DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Đếm tổng leads thuộc campaign (qua Leads.campaign_id)
    public int countLeadsByCampaignId(int campaignId) {
        String sql = "SELECT COUNT(*) FROM Leads WHERE campaign_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đếm leads thuộc campaign theo trạng thái (qua Leads.campaign_id + status)
    public int countLeadsByCampaignAndStatus(int campaignId, String status) {
        String sql = "SELECT COUNT(*) FROM Leads WHERE campaign_id = ? AND status = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isDuplicate(String email, String phone) {
        String sql = "SELECT COUNT(*) FROM Leads WHERE email = ? OR phone = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, phone != null ? phone : "");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Import batch leads (dùng transaction)
     *
     * @return số leads được import thành công
     */
    public int importLeads(List<Lead> leads) throws Exception {
        String sql = "INSERT INTO Leads(full_name, email, phone, company_name, interest, source, status, score, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int importedCount = 0;
        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Start transaction

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Lead lead : leads) {
                    ps.setString(1, lead.getFullName());
                    ps.setString(2, lead.getEmail());
                    ps.setString(3, lead.getPhone());
                    ps.setString(4, lead.getCompanyName());
                    ps.setString(5, lead.getInterest());
                    ps.setString(6, lead.getSource());
                    ps.setString(7, lead.getStatus());
                    ps.setInt(8, lead.getScore());
                    ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));

                    ps.addBatch();
                }

                int[] results = ps.executeBatch();
                importedCount = results.length;

                conn.commit(); // Commit transaction
            } catch (Exception e) {
                conn.rollback(); // Rollback if error
                throw e;
            }

        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }

        return importedCount;
    }

    // Map dữ liệu từ ResultSet sang đối tượng Lead
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
                rs.getTimestamp("updated_at").toLocalDateTime());
    }
}
