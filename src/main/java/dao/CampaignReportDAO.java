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

import dto.report.CampaignPerformanceReportDTO;
import dto.report.DealResultReportDTO;
import dto.report.LeadFunnelReportDTO;
import dto.report.LeadSourceReportDTO;
import model.CampaignReport;
import util.DBContext;

public class CampaignReportDAO {

    // Tạo mới một báo cáo chiến dịch và trả về ID vừa được sinh ra
    public int createCampaignReport(CampaignReport report) {
        String sql = "INSERT INTO Campaign_Reports(campaign_id, total_lead, qualified_lead, converted_lead, cost_per_lead, roi, created_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, report.getCampaignId());
            ps.setInt(2, report.getTotalLead());
            ps.setInt(3, report.getQualifiedLead());
            ps.setInt(4, report.getConvertedLead());
            ps.setBigDecimal(5, report.getCostPerLead());
            ps.setBigDecimal(6, report.getRoi());
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));

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

    // Lấy báo cáo chiến dịch mới nhất theo campaign ID
    public CampaignReport getLatestByCampaignId(int campaignId) {
        String sql = "SELECT TOP 1 * FROM Campaign_Reports WHERE campaign_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToReport(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Map dữ liệu từ ResultSet sang đối tượng CampaignReport
    private CampaignReport mapResultSetToReport(ResultSet rs) throws SQLException {
        return new CampaignReport(
                rs.getInt("report_id"),
                rs.getInt("campaign_id"),
                rs.getInt("total_lead"),
                rs.getInt("qualified_lead"),
                rs.getInt("converted_lead"),
                rs.getBigDecimal("cost_per_lead"),
                rs.getBigDecimal("roi"),
                rs.getTimestamp("created_at").toLocalDateTime());
    }

    // ── Report methods (cho trang Marketing Report) ───────────────────────────

    public List<CampaignPerformanceReportDTO> getCampaignPerformance(
            Integer campaignId, String fromDate, String toDate) {
        List<CampaignPerformanceReportDTO> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.name AS campaign_name, "
                + "COUNT(DISTINCT l.lead_id) AS total_leads, "
                + "COUNT(DISTINCT d.deal_id) AS deals_created, "
                + "ISNULL(SUM(CASE WHEN UPPER(d.stage) = 'WON' THEN 1 ELSE 0 END), 0) AS deals_won, "
                + "ISNULL(SUM(CASE WHEN UPPER(d.stage) = 'LOST' THEN 1 ELSE 0 END), 0) AS deals_lost "
                + "FROM Campaigns c "
                + "LEFT JOIN Leads l ON l.campaign_id = c.campaign_id "
                + "LEFT JOIN Deals d ON d.lead_id = l.lead_id "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND c.campaign_id = ? ");
            params.add(campaignId);
        }
        sql.append(" GROUP BY c.campaign_id, c.name ORDER BY c.name");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int totalLeads = rs.getInt("total_leads");
                int dealsCreated = rs.getInt("deals_created");
                int dealsWon = rs.getInt("deals_won");
                int dealsLost = rs.getInt("deals_lost");
                double conversionRate = totalLeads > 0 ? dealsWon * 100.0 / totalLeads : 0;
                result.add(new CampaignPerformanceReportDTO(
                        rs.getString("campaign_name"),
                        totalLeads, dealsCreated, dealsWon, dealsLost, conversionRate));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<LeadSourceReportDTO> getLeadSourceReport(
            Integer campaignId, String source, String fromDate, String toDate) {
        List<LeadSourceReportDTO> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ISNULL(l.source, 'Unknown') AS source_name, COUNT(*) AS lead_count "
                + "FROM Leads l WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND l.campaign_id = ? ");
            params.add(campaignId);
        }
        if (source != null && !source.isEmpty()) {
            sql.append(" AND ISNULL(l.source, '') = ? ");
            params.add(source);
        }
        sql.append(" GROUP BY ISNULL(l.source, 'Unknown') ORDER BY lead_count DESC");

        List<LeadSourceReportDTO> tmp = new ArrayList<>();
        int total = 0;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String src = rs.getString("source_name");
                int cnt = rs.getInt("lead_count");
                total += cnt;
                tmp.add(new LeadSourceReportDTO(src, cnt, 0));
            }
            for (LeadSourceReportDTO dto : tmp) {
                double percent = total > 0 ? dto.getLeadCount() * 100.0 / total : 0;
                dto.setPercent(percent);
                result.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public LeadFunnelReportDTO getLeadFunnelReport(
            Integer campaignId, String fromDate, String toDate) {
        LeadFunnelReportDTO dto = new LeadFunnelReportDTO(0, 0, 0, 0, 0);
        /* Khớp với Marketing Dashboard: NEW_LEAD, CONTACTED, QUALIFIED, DEAL_CREATED, LOST */
        StringBuilder sql = new StringBuilder(
                "SELECT "
                + "ISNULL(SUM(CASE WHEN l.status = 'NEW_LEAD' THEN 1 ELSE 0 END), 0) AS new_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'CONTACTED' THEN 1 ELSE 0 END), 0) AS contacted_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'QUALIFIED' THEN 1 ELSE 0 END), 0) AS qualified_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'DEAL_CREATED' THEN 1 ELSE 0 END), 0) AS converted_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'LOST' THEN 1 ELSE 0 END), 0) AS lost_cnt "
                + "FROM Leads l WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND l.campaign_id = ? ");
            params.add(campaignId);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                dto.setNewCount(rs.getInt("new_cnt"));
                dto.setContactedCount(rs.getInt("contacted_cnt"));
                dto.setQualifiedCount(rs.getInt("qualified_cnt"));
                dto.setConvertedCount(rs.getInt("converted_cnt"));
                dto.setLostCount(rs.getInt("lost_cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }

    public DealResultReportDTO getDealResultReport(
            Integer campaignId, String fromDate, String toDate) {
        DealResultReportDTO dto = new DealResultReportDTO(0, 0, 0);
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) AS total_deals, "
                + "ISNULL(SUM(CASE WHEN UPPER(d.stage) = 'WON' THEN 1 ELSE 0 END), 0) AS deals_won, "
                + "ISNULL(SUM(CASE WHEN UPPER(d.stage) = 'LOST' THEN 1 ELSE 0 END), 0) AS deals_lost "
                + "FROM Deals d INNER JOIN Leads l ON d.lead_id = l.lead_id WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND l.campaign_id = ? ");
            params.add(campaignId);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                dto.setTotalDeals(rs.getInt("total_deals"));
                dto.setDealsWon(rs.getInt("deals_won"));
                dto.setDealsLost(rs.getInt("deals_lost"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }

    public List<Object[]> getAllCampaignsForFilter() {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT campaign_id, name FROM Campaigns ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(new Object[]{rs.getInt("campaign_id"), rs.getString("name")});
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public List<String> getAllSourcesForFilter() {
        List<String> result = new ArrayList<>();
        String sql = "SELECT DISTINCT source FROM Leads WHERE source IS NOT NULL AND source <> '' ORDER BY source";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(rs.getString("source"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}
