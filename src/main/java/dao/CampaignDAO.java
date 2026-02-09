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

import model.Campaign;
import ultil.DBContext;

public class CampaignDAO {
    public int insert(Campaign campaign) {
        String sql = "INSERT INTO Campaigns(name, description, budget, start_date, end_date, channel, status, created_by, created_at, updated_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().connection;
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, campaign.getName());
            ps.setString(2, campaign.getDescription());
            ps.setBigDecimal(3, campaign.getBudget());
            ps.setDate(4, java.sql.Date.valueOf(campaign.getStartDate()));
            ps.setDate(5, java.sql.Date.valueOf(campaign.getEndDate()));
            ps.setString(6, campaign.getChannel());
            ps.setString(7, campaign.getStatus());
            ps.setInt(8, campaign.getCreatedBy());
            ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));

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

    public boolean update(Campaign campaign) {
        String sql = "UPDATE Campaigns SET name=?, description=?, budget=?, start_date=?, end_date=?, channel=?, status=?, updated_at=? WHERE campaign_id=?";
        try (Connection conn = new DBContext().connection;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, campaign.getName());
            ps.setString(2, campaign.getDescription());
            ps.setBigDecimal(3, campaign.getBudget());
            ps.setDate(4, java.sql.Date.valueOf(campaign.getStartDate()));
            ps.setDate(5, java.sql.Date.valueOf(campaign.getEndDate()));
            ps.setString(6, campaign.getChannel());
            ps.setString(7, campaign.getStatus());
            ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(9, campaign.getCampaignId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Campaign getById(int campaignId) {
        String sql = "SELECT * FROM Campaigns WHERE campaign_id = ?";
        try (Connection conn = new DBContext().connection;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCampaign(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Campaign> getAll() {
        String sql = "SELECT * FROM Campaigns ORDER BY created_at DESC";
        List<Campaign> campaigns = new ArrayList<>();
        try (Connection conn = new DBContext().connection;
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                campaigns.add(mapResultSetToCampaign(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return campaigns;
    }

    public List<Campaign> getByCampaignStatus(String status) {
        String sql = "SELECT * FROM Campaigns WHERE status = ? ORDER BY created_at DESC";
        List<Campaign> campaigns = new ArrayList<>();
        try (Connection conn = new DBContext().connection;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                campaigns.add(mapResultSetToCampaign(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return campaigns;
    }

    private Campaign mapResultSetToCampaign(ResultSet rs) throws SQLException {
        return new Campaign(
                rs.getInt("campaign_id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getBigDecimal("budget"),
                rs.getDate("start_date").toLocalDate(),
                rs.getDate("end_date").toLocalDate(),
                rs.getString("channel"),
                rs.getString("status"),
                rs.getInt("created_by"),
                rs.getTimestamp("created_at").toLocalDateTime(),
                rs.getTimestamp("updated_at").toLocalDateTime());
    }
}
