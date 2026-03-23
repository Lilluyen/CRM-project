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
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

    // Tìm lead theo interest
    public List<Lead> findLeadByInterest(String interest) {
        String sql = "SELECT * FROM Leads WHERE interest = ?";
        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, interest);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                leads.add(mapResultSetToLead(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

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

    public int importLeads(List<Lead> leads) throws Exception {
        String sql = "INSERT INTO Leads(full_name, email, phone, interest, source, status, score, campaign_id, created_at, updated_at, is_converted) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

        int importedCount = 0;
        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Lead lead : leads) {
                    ps.setString(1, lead.getFullName());
                    ps.setString(2, lead.getEmail());
                    // Set NULL thay vì empty string để tránh vi phạm UNIQUE constraint
                    String phoneVal = lead.getPhone();
                    if (phoneVal == null || phoneVal.trim().isEmpty()) {
                        ps.setNull(3, java.sql.Types.VARCHAR);
                    } else {
                        ps.setString(3, phoneVal.trim());
                    }
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
                for (int result : results) {
                    if (result > 0) {
                        importedCount++;
                    }
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
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
    // SEARCH + PAGINATION
    // ==============================
    // FIX: đọc campaign names từ Campaign_Leads thay vì Leads.campaign_id
    private static final String CAMPAIGN_NAMES_SUBQUERY
            = "( "
            + "  SELECT STUFF( "
            + "    (SELECT DISTINCT ' | ' + c_inner.name "
            + "     FROM Campaign_Leads cl_inner "
            + "     INNER JOIN Campaigns c_inner ON cl_inner.campaign_id = c_inner.campaign_id "
            + "     WHERE cl_inner.lead_id IN ( "
            + "       SELECT lead_id FROM Leads WHERE email = l.email "
            + "     ) "
            + "     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') "
            + "  , 1, 3, '') "
            + ") AS campaign_names ";

    public List<Lead> searchLeads(String keyword, String status, int campaignId, String interest, int page, int pageSize) {

        String sql
                = "SELECT l.*, " + CAMPAIGN_NAMES_SUBQUERY
                + "FROM Leads l "
                + "WHERE l.lead_id IN ( "
                + "  SELECT MIN(lead_id) FROM Leads GROUP BY email "
                + ") ";

        List<Object> params = new ArrayList<>();

        // Lọc theo Campaign_Leads — nhất quán với countLeads()
        if (campaignId > 0) {
            sql += "AND l.email IN ( "
                    + "  SELECT l2.email FROM Leads l2 "
                    + "  INNER JOIN Campaign_Leads cl ON cl.lead_id = l2.lead_id "
                    + "  WHERE cl.campaign_id = ? "
                    + ") ";
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?) ";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += "AND l.status = ? ";
            params.add(status);
        }
        if (interest != null && !interest.trim().isEmpty()) {
            sql += "AND l.interest LIKE ? ";
            params.add("%" + interest.trim() + "%");
        }

        sql += "ORDER BY l.updated_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                lead.setCampaignNames(rs.getString("campaign_names"));
                leads.add(lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return leads;
    }

    public List<Lead> searchLeadsForExport(String keyword, String status, int campaignId, String interest) {

        String sql
                = "SELECT l.*, " + CAMPAIGN_NAMES_SUBQUERY
                + "FROM Leads l "
                + "WHERE l.lead_id IN ( "
                + "  SELECT MIN(lead_id) FROM Leads GROUP BY email "
                + ") ";

        List<Object> params = new ArrayList<>();

        // Lọc theo Campaign_Leads — nhất quán với countLeads()
        if (campaignId > 0) {
            sql += "AND l.email IN ( "
                    + "  SELECT l2.email FROM Leads l2 "
                    + "  INNER JOIN Campaign_Leads cl ON cl.lead_id = l2.lead_id "
                    + "  WHERE cl.campaign_id = ? "
                    + ") ";
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?) ";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += "AND l.status = ? ";
            params.add(status);
        }
        if (interest != null && !interest.trim().isEmpty()) {
            sql += "AND l.interest LIKE ? ";
            params.add("%" + interest.trim() + "%");
        }

        sql += "ORDER BY l.updated_at DESC OFFSET 0 ROWS FETCH NEXT 10000 ROWS ONLY";

        List<Lead> leads = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                lead.setCampaignNames(rs.getString("campaign_names"));
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
    public int countLeads(String keyword, String status, int campaignId, String interest) {
        // FIX: GROUP BY email only — mỗi email = 1 người = 1 dòng trên UI
        // Lý do GROUP BY cũ (email, status, interest, full_name, phone) bị sai:
        // cùng 1 email có nhiều row Leads với status/interest/phone khác nhau
        // → GROUP BY tạo ra nhiều nhóm → COUNT ra 4 thay vì 2.
        // GROUP BY email only → đúng 1 nhóm per người.
        String sql
                = "SELECT COUNT(*) FROM ( "
                + "  SELECT MIN(lead_id) AS lead_id "
                + "  FROM Leads "
                + "  WHERE 1=1 ";

        List<Object> params = new ArrayList<>();

        // Lọc theo Campaign_Leads — nhất quán với searchLeads()
        if (campaignId > 0) {
            sql += "AND email IN ( "
                    + "  SELECT l2.email FROM Leads l2 "
                    + "  INNER JOIN Campaign_Leads cl ON cl.lead_id = l2.lead_id "
                    + "  WHERE cl.campaign_id = ? "
                    + ") ";
            params.add(campaignId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?) ";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql += "AND status = ? ";
            params.add(status);
        }
        if (interest != null && !interest.trim().isEmpty()) {
            sql += "AND interest LIKE ? ";
            params.add("%" + interest.trim() + "%");
        }

        sql += "  GROUP BY email "
                + ") AS base ";

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

    // ==============================
    // BULK LOOKUP — dùng cho import performance
    // ==============================
    public Set<String> getExistingEmailsByCampaign(int campaignId) {
        String sql = "SELECT email FROM Leads WHERE campaign_id = ? AND email IS NOT NULL";
        Set<String> emails = new HashSet<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                emails.add(rs.getString("email").toLowerCase());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return emails;
    }

    public Set<String> getExistingPhonesByCampaign(int campaignId) {
        String sql = "SELECT phone FROM Leads WHERE campaign_id = ? AND phone IS NOT NULL AND phone <> ''";
        Set<String> phones = new HashSet<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                phones.add(rs.getString("phone").trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return phones;
    }

    public Set<String> getAllExistingEmails() {
        String sql = "SELECT email FROM Leads WHERE email IS NOT NULL";
        Set<String> emails = new HashSet<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                emails.add(rs.getString("email").toLowerCase());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return emails;
    }

    public Set<String> getAllExistingPhones() {
        String sql = "SELECT phone FROM Leads WHERE phone IS NOT NULL AND phone <> ''";
        Set<String> phones = new HashSet<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                phones.add(rs.getString("phone").trim());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return phones;
    }

    public Map<String, Lead> findLeadsByEmailsAndCampaign(List<String> emails, int campaignId) {
        Map<String, Lead> result = new java.util.HashMap<>();
        if (emails == null || emails.isEmpty()) {
            return result;
        }

        String placeholders = String.join(",", java.util.Collections.nCopies(emails.size(), "?"));
        String sql = "SELECT * FROM Leads WHERE campaign_id = ? AND email IN (" + placeholders + ")";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            for (int i = 0; i < emails.size(); i++) {
                ps.setString(i + 2, emails.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                result.put(lead.getEmail().toLowerCase(), lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public Map<String, Lead> findLeadsByEmails(List<String> emails) {
        Map<String, Lead> result = new java.util.HashMap<>();
        if (emails == null || emails.isEmpty()) {
            return result;
        }

        String placeholders = String.join(",", java.util.Collections.nCopies(emails.size(), "?"));
        String sql = "SELECT * FROM Leads WHERE email IN (" + placeholders + ")";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < emails.size(); i++) {
                ps.setString(i + 1, emails.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                result.put(lead.getEmail().toLowerCase(), lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public Map<String, Lead> findLeadsByEmailMap() {
        String sql = "SELECT * FROM Leads WHERE email IS NOT NULL";
        Map<String, Lead> map = new java.util.HashMap<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                map.put(lead.getEmail().toLowerCase(), lead);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public Map<String, Lead> findLeadsByPhoneMap() {
        String sql = "SELECT * FROM Leads WHERE phone IS NOT NULL AND phone <> ''";
        Map<String, Lead> map = new java.util.HashMap<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Lead lead = mapResultSetToLead(rs);
                if (lead.getPhone() != null && !lead.getPhone().isEmpty()) {
                    map.put(lead.getPhone().trim(), lead);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public void markConverted(Connection conn, int leadId, int customerId) throws SQLException {
        String sql = """
                    UPDATE Leads
                    SET is_converted = 1,
                        converted_customer_id = ?,
                        status = 'Converted',
                        updated_at = GETDATE()
                    WHERE [lead_id] = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, leadId);
            ps.executeUpdate();
        }
    }
}
