package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.Campaign;
import model.Lead;
import util.DBContext;

public class CampaignLeadDAO {

    // Thêm một lead vào campaign với trạng thái ban đầu
    public boolean assignLeadToCampaign(int campaignId, int leadId, String initialStatus) {
        String sql = "INSERT INTO Campaign_Leads(campaign_id, lead_id, lead_status, assigned_at, updated_at) VALUES(?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Lấy danh sách Lead thuộc một campaign (ưu tiên lead có điểm số cao)
    public List<Lead> getLeadsByCampaignId(int campaignId) {
        String sql = "SELECT l.* FROM Leads l "
                + "INNER JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id "
                + "WHERE cl.campaign_id = ? "
                + "ORDER BY l.score DESC, l.created_at DESC";
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

    // Lấy danh sách lead theo campaign và trạng thái
    public List<Lead> getLeadsByCampaignAndStatus(int campaignId, String leadStatus) {
        String sql = "SELECT l.* FROM Leads l "
                + "INNER JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id "
                + "WHERE cl.campaign_id = ? AND cl.lead_status = ? "
                + "ORDER BY l.score DESC";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    // Kiểm tra lead đã trong campaign chưa
    public boolean isLeadInCampaign(int campaignId, int leadId) {
        String sql = "SELECT COUNT(*) FROM Campaign_Leads WHERE campaign_id = ? AND lead_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setInt(2, leadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đếm tổng số lead trong một campaign
    public int countTotalLeadsByCampaign(int campaignId) {
        String sql = "SELECT COUNT(*) as cnt FROM Campaign_Leads WHERE campaign_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    /**
     * Lấy danh sách Campaigns mà lead tham gia theo leadId đơn lẻ. Dùng khi
     * lead chỉ có 1 record trong bảng Leads.
     */
    public List<Campaign> getCampaignsByLeadId(int leadId) {
        String sql = "SELECT c.campaign_id, c.name, c.status, c.channel, "
                + "c.start_date, c.end_date, cl.lead_status, cl.assigned_at "
                + "FROM Campaign_Leads cl "
                + "INNER JOIN Campaigns c ON cl.campaign_id = c.campaign_id "
                + "WHERE cl.lead_id = ? "
                + "ORDER BY cl.assigned_at DESC";
        List<Campaign> campaigns = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                campaigns.add(mapResultSetToCampaign(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return campaigns;
    }

    /**
     * FIX: Lấy TẤT CẢ campaigns của một người dựa trên EMAIL.
     *
     * Lý do cần method này: - Bảng Leads có thể có nhiều row cùng email (mỗi
     * campaign tạo 1 row riêng, hoặc dùng MIN(lead_id) khi hiển thị list). -
     * searchLeads() chỉ trả về MIN(lead_id) per email → leadId đó chỉ thuộc 1
     * campaign trong Campaign_Leads. - Để hiện đủ campaigns trên trang detail,
     * cần JOIN qua tất cả lead_id có cùng email, không chỉ 1 leadId.
     *
     * SQL: lấy DISTINCT campaigns từ tất cả lead_id có email = email của leadId
     * này.
     */
    public List<Campaign> getCampaignsByLeadEmail(int leadId) {
        String sql = "SELECT DISTINCT c.campaign_id, c.name, c.status, c.channel, "
                + "c.start_date, c.end_date, cl.lead_status, cl.assigned_at "
                + "FROM Campaign_Leads cl "
                + "INNER JOIN Campaigns c ON cl.campaign_id = c.campaign_id "
                + "WHERE cl.lead_id IN ( "
                + "  SELECT lead_id FROM Leads WHERE email = ( "
                + "    SELECT email FROM Leads WHERE lead_id = ? "
                + "  ) "
                + ") "
                + "ORDER BY cl.assigned_at DESC";
        List<Campaign> campaigns = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                campaigns.add(mapResultSetToCampaign(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return campaigns;
    }

    /**
     * Xóa lead khỏi một campaign trong bảng Campaign_Leads
     */
    public boolean removeLeadFromCampaign(int campaignId, int leadId) {
        String sql = "DELETE FROM Campaign_Leads WHERE campaign_id = ? AND lead_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setInt(2, leadId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Map ResultSet → Campaign
    private Campaign mapResultSetToCampaign(ResultSet rs) throws SQLException {
        Campaign c = new Campaign();
        c.setCampaignId(rs.getInt("campaign_id"));
        c.setName(rs.getString("name"));
        c.setStatus(rs.getString("status"));
        c.setChannel(rs.getString("channel"));
        c.setStartDate(rs.getDate("start_date") != null
                ? rs.getDate("start_date").toLocalDate() : null);
        c.setEndDate(rs.getDate("end_date") != null
                ? rs.getDate("end_date").toLocalDate() : null);
        return c;
    }

    // Map dữ liệu từ ResultSet sang đối tượng Lead
    private Lead mapResultSetToLead(ResultSet rs) throws SQLException {
        return new Lead(
                rs.getInt("lead_id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("phone"),
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
