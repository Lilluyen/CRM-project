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
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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
                + "ISNULL(lm.total_leads, 0) AS total_leads, "
                + "ISNULL(dm.deals_created, 0) AS deals_created, "
                + "ISNULL(dm.deals_won, 0) AS deals_won, "
                + "ISNULL(dm.deals_lost, 0) AS deals_lost, "
                + "ISNULL(dm.revenue, 0) AS revenue, "
                + "ISNULL(c.budget, 0) AS cost "
                + "FROM Campaigns c "
                + "LEFT JOIN ( "
                + "    SELECT campaign_id, COUNT(DISTINCT lead_id) AS total_leads "
                + "    FROM Campaign_Leads "
                + "    GROUP BY campaign_id "
                + ") lm ON lm.campaign_id = c.campaign_id "
                + "LEFT JOIN ( "
                + "    SELECT campaign_id, "
                + "           COUNT(*) AS deals_created, "
                + "           SUM(CASE WHEN stage = 'Closed Won' THEN 1 ELSE 0 END) AS deals_won, "
                + "           SUM(CASE WHEN stage = 'Closed Lost' THEN 1 ELSE 0 END) AS deals_lost, "
                + "           SUM(CASE WHEN stage = 'Closed Won' THEN ISNULL(actual_value, 0) ELSE 0 END) AS revenue "
                + "    FROM Deals "
                + "    GROUP BY campaign_id "
                + ") dm ON dm.campaign_id = c.campaign_id "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND c.campaign_id = ? ");
            params.add(campaignId);
        }
        // Date filter - filter by campaign start date
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND c.start_date >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND c.start_date <= ? ");
            params.add(toDate);
        }
        sql.append(" ORDER BY c.name");

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int totalLeads = rs.getInt("total_leads");
                int dealsCreated = rs.getInt("deals_created");
                int dealsWon = rs.getInt("deals_won");
                int dealsLost = rs.getInt("deals_lost");
                double conversionRate = totalLeads > 0
                        ? Math.round(dealsWon * 10000.0 / totalLeads) / 100.0
                        : 0;
                double revenue = rs.getDouble("revenue");
                double cost = rs.getDouble("cost");
                double roi = cost > 0
                        ? Math.round(((revenue - cost) * 10000.0 / cost)) / 100.0
                        : 0;
                result.add(new CampaignPerformanceReportDTO(
                        rs.getString("campaign_name"),
                        totalLeads, dealsCreated, dealsWon, dealsLost, conversionRate, roi, revenue, cost));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Đếm tổng số campaign performance (cho phân trang).
     */
    public int countCampaignPerformance(Integer campaignId, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) AS cnt FROM Campaigns c WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND c.campaign_id = ? ");
            params.add(campaignId);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND c.start_date >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND c.start_date <= ? ");
            params.add(toDate);
        }
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
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
     * Lấy campaign performance có phân trang (OFFSET / FETCH).
     */
    public List<CampaignPerformanceReportDTO> getCampaignPerformancePaginated(
            Integer campaignId, String fromDate, String toDate, int offset, int limit) {
        List<CampaignPerformanceReportDTO> result = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.name AS campaign_name, "
                + "ISNULL(lm.total_leads, 0) AS total_leads, "
                + "ISNULL(dm.deals_created, 0) AS deals_created, "
                + "ISNULL(dm.deals_won, 0) AS deals_won, "
                + "ISNULL(dm.deals_lost, 0) AS deals_lost, "
                + "ISNULL(dm.revenue, 0) AS revenue, "
                + "ISNULL(c.budget, 0) AS cost "
                + "FROM Campaigns c "
                + "LEFT JOIN ( "
                + "    SELECT campaign_id, COUNT(DISTINCT lead_id) AS total_leads "
                + "    FROM Campaign_Leads "
                + "    GROUP BY campaign_id "
                + ") lm ON lm.campaign_id = c.campaign_id "
                + "LEFT JOIN ( "
                + "    SELECT campaign_id, "
                + "           COUNT(*) AS deals_created, "
                + "           SUM(CASE WHEN stage = 'Closed Won' THEN 1 ELSE 0 END) AS deals_won, "
                + "           SUM(CASE WHEN stage = 'Closed Lost' THEN 1 ELSE 0 END) AS deals_lost, "
                + "           SUM(CASE WHEN stage = 'Closed Won' THEN ISNULL(actual_value, 0) ELSE 0 END) AS revenue "
                + "    FROM Deals "
                + "    GROUP BY campaign_id "
                + ") dm ON dm.campaign_id = c.campaign_id "
                + "WHERE 1 = 1 AND c.status = 'ACTIVE' ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND c.campaign_id = ? ");
            params.add(campaignId);
        }
        // Date filter - filter by campaign start date
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND c.start_date >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND c.start_date <= ? ");
            params.add(toDate);
        }
        sql.append(" ORDER BY c.name OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        params.add(offset);
        params.add(limit);

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int totalLeads = rs.getInt("total_leads");
                int dealsCreated = rs.getInt("deals_created");
                int dealsWon = rs.getInt("deals_won");
                int dealsLost = rs.getInt("deals_lost");
                double conversionRate = totalLeads > 0
                        ? Math.round(dealsWon * 10000.0 / totalLeads) / 100.0
                        : 0;
                double revenue = rs.getDouble("revenue");
                double cost = rs.getDouble("cost");
                double roi = cost > 0 ? Math.round(((revenue - cost) * 10000.0 / cost)) / 100.0 : 0;
                result.add(new CampaignPerformanceReportDTO(
                        rs.getString("campaign_name"),
                        totalLeads, dealsCreated, dealsWon, dealsLost, conversionRate, roi, revenue, cost));
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
            // Handle "Unknown" source - map both null and empty string to "Unknown"
            if ("Unknown".equals(source)) {
                sql.append(" AND (l.source IS NULL OR l.source = '') ");
            } else {
                sql.append(" AND l.source = ? ");
                params.add(source);
            }
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND l.created_at >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND l.created_at <= DATEADD(day, 1, CAST(? AS DATE)) ");
            params.add(toDate);
        }
        sql.append(" GROUP BY ISNULL(l.source, 'Unknown') ORDER BY lead_count DESC");

        List<LeadSourceReportDTO> tmp = new ArrayList<>();
        int total = 0;
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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
                double percent = total > 0 ? Math.round(dto.getLeadCount() * 10000.0 / total) / 100.0 : 0;
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
                + "ISNULL(SUM(CASE WHEN l.status = 'NURTURING' THEN 1 ELSE 0 END), 0) AS contacted_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'QUALIFIED' THEN 1 ELSE 0 END), 0) AS qualified_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'DEAL_CREATED' THEN 1 ELSE 0 END), 0) AS converted_cnt, "
                + "ISNULL(SUM(CASE WHEN l.status = 'LOST' THEN 1 ELSE 0 END), 0) AS lost_cnt "
                + "FROM Leads l WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND l.campaign_id = ? ");
            params.add(campaignId);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND l.created_at >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND l.created_at <= DATEADD(day, 1, CAST(? AS DATE)) ");
            params.add(toDate);
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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
                """
                    SELECT COUNT(DISTINCT d.deal_id) AS total_deals,
                    COUNT(DISTINCT CASE WHEN d.stage = 'Closed Won' THEN d.deal_id END) AS deals_won,
                    COUNT(DISTINCT CASE WHEN d.stage = 'Closed Lost' THEN d.deal_id END) AS deals_lost
                    FROM Deals d
                    WHERE 1 = 1""");  // ✅ dùng WHERE 1=1 thay vì hardcode campaign_id

        List<Object> params = new ArrayList<>();
        if (campaignId != null) {
            sql.append(" AND d.campaign_id = ? ");  // ✅ chỉ 1 điều kiện duy nhất
            params.add(campaignId);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append(" AND d.created_at >= ? ");
            params.add(fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            sql.append(" AND d.created_at <= DATEADD(day, 1, CAST(? AS DATE)) ");
            params.add(toDate);
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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

    public dto.report.MarketingReportKpiDTO getMarketingReportKpi(
            Integer campaignId, String fromDate, String toDate) {
        // Build date filter conditions
        String dateConditionLeads = "";
        String dateConditionDeals = "";
        String dateConditionCampaigns = "";
        if (fromDate != null && !fromDate.isEmpty()) {
            dateConditionLeads += " AND l.created_at >= ? ";
            dateConditionDeals += " AND d.created_at >= ? ";
            dateConditionCampaigns += " AND c.start_date >= ? ";
        }
        if (toDate != null && !toDate.isEmpty()) {
            dateConditionLeads += " AND l.created_at <= DATEADD(day, 1, CAST(? AS DATE)) ";
            dateConditionDeals += " AND d.created_at <= DATEADD(day, 1, CAST(? AS DATE)) ";
            dateConditionCampaigns += " AND c.start_date <= ? ";
        }

        // Count total parameter placeholders needed
        int paramCount = 0;
        if (campaignId != null) {
            paramCount += 5;
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            paramCount += 3;
        }
        if (toDate != null && !toDate.isEmpty()) {
            paramCount += 3;
        }

        StringBuilder sql = new StringBuilder(
                "SELECT "
                + " (SELECT COUNT(DISTINCT l.lead_id) "
                + "  FROM Leads l "
                + "  WHERE 1 = 1 "
                + (campaignId != null ? " AND l.campaign_id = ? " : "")
                + dateConditionLeads
                + " ) AS total_leads, "
                + " (SELECT COUNT(DISTINCT d.deal_id) "
                + "  FROM Deals d "
                + "  WHERE 1 = 1 "
                + (campaignId != null ? " AND d.campaign_id = ? " : "")
                + dateConditionDeals
                + " ) AS deals_created, "
                + " (SELECT COUNT(DISTINCT CASE WHEN d.stage = 'Closed Won' THEN d.deal_id END) "
                + "  FROM Deals d "
                + "  WHERE 1 = 1 "
                + (campaignId != null ? " AND d.campaign_id = ? " : "")
                + dateConditionDeals
                + " ) AS deals_won, "
                + " (SELECT ISNULL(SUM(CASE WHEN d.stage = 'Closed Won' THEN ISNULL(d.actual_value, 0) ELSE 0 END), 0) "
                + "  FROM Deals d "
                + "  WHERE 1 = 1 "
                + (campaignId != null ? " AND d.campaign_id = ? " : "")
                + dateConditionDeals
                + " ) AS revenue, "
                + " (SELECT ISNULL(SUM(c.budget), 0) "
                + "  FROM Campaigns c "
                + "  WHERE 1 = 1 "
                + (campaignId != null ? " AND c.campaign_id = ? " : "")
                + dateConditionCampaigns
                + " ) AS cost");

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (campaignId != null) {
                // campaignId appears 5 times in the SQL above
                for (int i = 0; i < 5; i++) {
                    ps.setInt(paramIndex++, campaignId);
                }
            }
            // Set date parameters in order: fromDate (3x), toDate (3x)
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setString(paramIndex++, fromDate); // leads
                ps.setString(paramIndex++, fromDate); // deals
                ps.setString(paramIndex++, fromDate); // campaigns
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setString(paramIndex++, toDate); // leads
                ps.setString(paramIndex++, toDate); // deals
                ps.setString(paramIndex++, toDate); // campaigns
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int totalLeads = rs.getInt("total_leads");
                int dealsCreated = rs.getInt("deals_created");
                int dealsWon = rs.getInt("deals_won");
                double revenue = rs.getDouble("revenue");
                double cost = rs.getDouble("cost");

                double conversionRate = totalLeads > 0 ? dealsWon * 100.0 / totalLeads : 0;
                double roi = cost > 0 ? ((revenue - cost) * 100.0 / cost) : 0;

                return new dto.report.MarketingReportKpiDTO(
                        totalLeads, dealsCreated, dealsWon, revenue, cost, conversionRate, roi);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new dto.report.MarketingReportKpiDTO(0, 0, 0, 0, 0, 0, 0);
    }

    public List<Object[]> getAllCampaignsForFilter() {
        List<Object[]> result = new ArrayList<>();
        String sql = "SELECT campaign_id, name FROM Campaigns ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(rs.getString("source"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}
