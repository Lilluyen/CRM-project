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
        String sql = "INSERT INTO Leads(full_name, email, phone, interest, source, status, score, campaign_id, assigned_to, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
        String sql = "INSERT INTO Leads(full_name, email, phone,  interest, source, status, score, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";

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
                    ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                    ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));

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
    public List<Lead> searchLeads(String keyword, String status, int page, int pageSize) {
        String sql = "SELECT * FROM Leads WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND status = ?";
            params.add(status);
        }

        sql += " ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    // ==============================
    // COUNT FOR PAGINATION
    // ==============================
    public int countLeads(String keyword, String status) {
        String sql = "SELECT COUNT(*) FROM Leads WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += " AND status = ?";
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
