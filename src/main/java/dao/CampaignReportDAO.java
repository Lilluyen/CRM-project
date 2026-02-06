package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.sql.Statement;
import java.sql.Timestamp;
import model.CampaignReport;
import ultil.DBContext;

public class CampaignReportDAO {

    public int insert(CampaignReport report) {
        String sql = "INSERT INTO Campaign_Reports(campaign_id, total_lead, qualified_lead, converted_lead, cost_per_lead, roi, created_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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

    public CampaignReport getLatestByCampaignId(int campaignId) {
        String sql = "SELECT TOP 1 * FROM Campaign_Reports WHERE campaign_id = ? ORDER BY created_at DESC";
        try (Connection conn = new DBContext().connection; PreparedStatement ps = conn.prepareStatement(sql)) {
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

    private CampaignReport mapResultSetToReport(ResultSet rs) throws SQLException {
        return new CampaignReport(
                rs.getInt("report_id"),
                rs.getInt("campaign_id"),
                rs.getInt("total_lead"),
                rs.getInt("qualified_lead"),
                rs.getInt("converted_lead"),
                rs.getBigDecimal("cost_per_lead"),
                rs.getBigDecimal("roi"),
                rs.getTimestamp("created_at").toLocalDateTime()
        );
    }
}
