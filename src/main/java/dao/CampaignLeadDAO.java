package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.Lead;
import ultil.DBContext;

public class CampaignLeadDAO {

    // Thêm một lead vào campaign với trạng thái ban đầu
    public boolean assignLeadToCampaign(int campaignId, int leadId, String initialStatus) {
        String sql = "INSERT INTO Campaign_Leads(campaign_id, lead_id, lead_status, assigned_at, updated_at) VALUES(?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            Timestamp now = Timestamp.valueOf(LocalDateTime.now());
            ps.setInt(1, campaignId);
            ps.setInt(2, leadId);
            ps.setString(3, initialStatus != null ? initialStatus : "NEW");
            ps.setTimestamp(4, now);
            ps.setTimestamp(5, now);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật trạng thái lead trong một campaign
    public boolean updateLeadStatus(int campaignId, int leadId, String leadStatus) {
        String sql = "UPDATE Campaign_Leads SET lead_status = ?, updated_at = ? WHERE campaign_id = ? AND lead_id = ?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, leadStatus);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(3, campaignId);
            ps.setInt(4, leadId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy dang sách Lead thuộc một campaign (ưu tiên lead có điểm số cao)  
    public List<Lead> getLeadsByCampaignId(int campaignId) {
        String sql = "SELECT l.* FROM Leads l "
                + "INNER JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id "
                + "WHERE cl.campaign_id = ? "
                + "ORDER BY l.score DESC, l.created_at DESC";
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

    // Lấy danh sách lead theo campaign và trạng thái
    public List<Lead> getLeadsByCampaignAndStatus(int campaignId, String leadStatus) {
        String sql = "SELECT l.* FROM Leads l "
                + "INNER JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id "
                + "WHERE cl.campaign_id = ? AND cl.lead_status = ? "
                + "ORDER BY l.score DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setString(2, leadStatus);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    // Đếm số lượng lead theo trạng thái trong một campaign
    public int countLeadByStatus(int campaignId, String leadStatus) {
        String sql = "SELECT COUNT(*) as cnt FROM Campaign_Leads WHERE campaign_id = ? AND lead_status = ?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setString(2, leadStatus);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đếm tổng số lead trong một campaign
    public int countTotalLeadsByCampaign(int campaignId) {
        String sql = "SELECT COUNT(*) as cnt FROM Campaign_Leads WHERE campaign_id = ?";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
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
                rs.getTimestamp("updated_at").toLocalDateTime()
        );
    }
}
