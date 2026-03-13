package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.Lead;
import util.DBContext;

public class LeadDAO {

    // Tạo mới một lead và trả về ID vừa được sinh ra
    public int createLead(Lead lead) {
        String sql = "INSERT INTO Leads(full_name, email, phone, interest, source, status, score, campaign_id, assigned_to, created_at, updated_at, is_converted) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, lead.getFullName());
            ps.setString(2, lead.getEmail());
            ps.setString(3, lead.getPhone());
            ps.setString(4, lead.getInterest());
            ps.setString(5, lead.getSource());
            ps.setString(6, lead.getStatus());
            ps.setInt(7, lead.getScore());
            if (lead.getCampaignId() > 0) {
                ps.setInt(8, lead.getCampaignId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            if (lead.getAssignedTo() > 0) {
                ps.setInt(9, lead.getAssignedTo());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));

            if (ps.executeUpdate() > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi tạo lead trong DB: " + e.getMessage(), e);
        }
        return 0;
    }

    // Cập nhật thông tin một lead theo ID
    public boolean updateLead(Lead lead) {
        String sql = "UPDATE Leads SET full_name=?, email=?, phone=?,  interest=?, source=?, status=?, score=?, campaign_id=?, assigned_to=?, updated_at=? WHERE lead_id=?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lead.getFullName());
            ps.setString(2, lead.getEmail());
            ps.setString(3, lead.getPhone());
            ps.setString(4, lead.getInterest());
            ps.setString(5, lead.getSource());
            ps.setString(6, lead.getStatus());
            ps.setInt(7, lead.getScore());
            if (lead.getCampaignId() > 0) {
                ps.setInt(8, lead.getCampaignId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            if (lead.getAssignedTo() > 0) {
                ps.setInt(9, lead.getAssignedTo());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(11, lead.getLeadId());
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

    // Tìm một lead theo số điện thoại
    public Lead findLeadByPhone(String phone) {
        String sql = "SELECT * FROM Leads WHERE phone = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm lead theo email + campaign_id (kiểm tra trùng trong cùng campaign). 1
     * người có thể tham gia nhiều campaign → mỗi campaign có Lead record riêng.
     */
    public Lead findLeadByEmailAndCampaign(String email, int campaignId) {
        String sql = "SELECT * FROM Leads WHERE email = ? AND campaign_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tìm lead theo phone + campaign_id (kiểm tra trùng trong cùng campaign).
     */
    public Lead findLeadByPhoneAndCampaign(String phone, int campaignId) {
        String sql = "SELECT * FROM Leads WHERE phone = ? AND campaign_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm lead theo email và loại trừ lead hiện tại (phục vụ update)
    public Lead findLeadByEmailExcludeLeadId(String email, int excludedLeadId) {
        String sql = "SELECT * FROM Leads WHERE email = ? AND lead_id <> ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, excludedLeadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm lead theo phone và loại trừ lead hiện tại (phục vụ update)
    public Lead findLeadByPhoneExcludeLeadId(String phone, int excludedLeadId) {
        String sql = "SELECT * FROM Leads WHERE phone = ? AND lead_id <> ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, excludedLeadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm lead theo email + campaign và loại trừ lead hiện tại (phục vụ update)
    public Lead findLeadByEmailAndCampaignExcludeLeadId(String email, int campaignId, int excludedLeadId) {
        String sql = "SELECT * FROM Leads WHERE email = ? AND campaign_id = ? AND lead_id <> ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, campaignId);
            ps.setInt(3, excludedLeadId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToLead(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm lead theo phone + campaign và loại trừ lead hiện tại (phục vụ update)
    public Lead findLeadByPhoneAndCampaignExcludeLeadId(String phone, int campaignId, int excludedLeadId) {
        String sql = "SELECT * FROM Leads WHERE phone = ? AND campaign_id = ? AND lead_id <> ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setInt(2, campaignId);
            ps.setInt(3, excludedLeadId);
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
        String sql = "SELECT * FROM Leads ORDER BY updated_at DESC";
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
        String sql = "SELECT * FROM Leads WHERE campaign_id = ? ORDER BY updated_at DESC";
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
        String sql = "INSERT INTO Leads(full_name, email, phone, interest, source, status, score, campaign_id, created_at, updated_at, is_converted) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

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
                    ps.setString(4, lead.getInterest());
                    ps.setString(5, lead.getSource());
                    ps.setString(6, lead.getStatus());
                    ps.setInt(7, lead.getScore());
                    if (lead.getCampaignId() > 0) {
                        ps.setInt(8, lead.getCampaignId());
                    } else {
                        ps.setNull(8, java.sql.Types.INTEGER);
                    }
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

    // Đếm tổng số lead theo campaign_id
    public int countLeadsByCampaignId(int campaignId) {
        String sql = "SELECT COUNT(*) as cnt FROM Leads WHERE campaign_id = ?";
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

    // Đếm số lead theo campaign_id và status
    public int countLeadsByCampaignAndStatus(int campaignId, String status) {
        String sql = "SELECT COUNT(*) as cnt FROM Leads WHERE campaign_id = ? AND status = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==============================
    // SEARCH + PAGINATION (OFFSET / FETCH)
    // ==============================
    public List<Lead> searchLeads(String keyword, String status, int campaignId, int page, int pageSize) {
        String sql = "SELECT DISTINCT l.*, c.name AS campaign_name FROM Leads l "
                + "LEFT JOIN Campaigns c ON l.campaign_id = c.campaign_id ";

        // Nếu lọc theo campaign → LEFT JOIN Campaign_Leads + kiểm tra cả 2 nguồn
        if (campaignId > 0) {
            sql += "LEFT JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id ";
        }

        sql += "WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (campaignId > 0) {
            sql += " AND (l.campaign_id = ? OR cl.campaign_id = ?)";
            params.add(campaignId);
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND l.status = ?";
            params.add(status);
        }

        sql += " ORDER BY l.updated_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                // Set campaign name từ LEFT JOIN
                String campName = rs.getString("campaign_name");
                if (campName != null) {
                    lead.setCampaignName(campName);
                }
                leads.add(lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    public List<Lead> searchLeadsForExport(String keyword, String status, int campaignId) {
        String sql = "SELECT DISTINCT l.*, c.name AS campaign_name FROM Leads l "
                + "LEFT JOIN Campaigns c ON l.campaign_id = c.campaign_id ";

        if (campaignId > 0) {
            sql += "LEFT JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id ";
        }

        sql += "WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (campaignId > 0) {
            sql += " AND (l.campaign_id = ? OR cl.campaign_id = ?)";
            params.add(campaignId);
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND l.status = ?";
            params.add(status);
        }

        sql += " ORDER BY l.updated_at DESC";

        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                String campName = rs.getString("campaign_name");
                if (campName != null) {
                    lead.setCampaignName(campName);
                }
                leads.add(lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    // ==============================
    // COUNT FOR PAGINATION
    // ==============================
    public int countLeads(String keyword, String status, int campaignId) {
        String sql = "SELECT COUNT(DISTINCT l.lead_id) FROM Leads l ";

        // Nếu lọc theo campaign → LEFT JOIN Campaign_Leads + kiểm tra cả 2 nguồn
        if (campaignId > 0) {
            sql += "LEFT JOIN Campaign_Leads cl ON l.lead_id = cl.lead_id ";
        }

        sql += "WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (campaignId > 0) {
            sql += " AND (l.campaign_id = ? OR cl.campaign_id = ?)";
            params.add(campaignId);
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND l.status = ?";
            params.add(status);
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
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
