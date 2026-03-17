package dao;

import java.math.BigDecimal;
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

import model.Deal;

public class DealDAO {

    private final Connection conn;

    public DealDAO(Connection conn) {
        this.conn = conn;
    }

    public int createDeal(Deal deal) throws SQLException {
        String sql = "INSERT INTO Deals(customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int newId = 0;
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (deal.getCustomerId() > 0) {
                ps.setInt(1, deal.getCustomerId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }

            if (deal.getLeadId() > 0) {
                ps.setInt(2, deal.getLeadId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, deal.getDealName());
            ps.setBigDecimal(4, deal.getExpectedValue() != null ? deal.getExpectedValue() : BigDecimal.ZERO);
            if (deal.getActualValue() != null) {
                ps.setBigDecimal(5, deal.getActualValue());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            ps.setString(6, deal.getStage());
            ps.setInt(7, deal.getProbability());
            if (deal.getExpectedCloseDate() != null) {
                ps.setDate(8, java.sql.Date.valueOf(deal.getExpectedCloseDate()));
            } else {
                ps.setNull(8, Types.DATE);
            }
            ps.setInt(9, deal.getOwnerId());
            ps.setTimestamp(10, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(11, Timestamp.valueOf(LocalDateTime.now()));

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newId = rs.getInt(1);
                    }
                }
            }
        }

        return newId;
    }

    public boolean updateDeal(Deal deal) throws SQLException {
        String sql = "UPDATE Deals SET customer_id = ?, lead_id = ?, deal_name = ?, expected_value = ?, actual_value = ?, stage = ?, probability = ?, expected_close_date = ?, updated_at = ? WHERE deal_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (deal.getCustomerId() > 0) {
                ps.setInt(1, deal.getCustomerId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }

            if (deal.getLeadId() > 0) {
                ps.setInt(2, deal.getLeadId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, deal.getDealName());
            ps.setBigDecimal(4, deal.getExpectedValue() != null ? deal.getExpectedValue() : BigDecimal.ZERO);
            if (deal.getActualValue() != null) {
                ps.setBigDecimal(5, deal.getActualValue());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            ps.setString(6, deal.getStage());
            ps.setInt(7, deal.getProbability());
            if (deal.getExpectedCloseDate() != null) {
                ps.setDate(8, java.sql.Date.valueOf(deal.getExpectedCloseDate()));
            } else {
                ps.setNull(8, Types.DATE);
            }
            ps.setTimestamp(9, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(10, deal.getDealId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateDealStage(int dealId, String stage, Integer probability, BigDecimal actualValue) throws SQLException {
        String sql = "UPDATE Deals SET stage = ?, probability = COALESCE(?, probability), actual_value = ?, updated_at = ? WHERE deal_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stage);
            if (probability != null) {
                ps.setInt(2, probability);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (actualValue != null) {
                ps.setBigDecimal(3, actualValue);
            } else {
                ps.setNull(3, Types.DECIMAL);
            }
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(5, dealId);
            return ps.executeUpdate() > 0;
        }
    }

    public Deal getById(int dealId) throws SQLException {
        String sql = "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at FROM Deals WHERE deal_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dealId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDeal(rs);
                }
            }
        }

        return null;
    }

    public List<Deal> getDealList(String search, String stage, int page, int pageSize) throws SQLException {
        if (search == null) search = "";
        if (stage == null) stage = "";

        int offset = (page - 1) * pageSize;

        String sql =
            "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at " +
            "FROM Deals " +
            "WHERE (deal_name LIKE ?) " +
            "AND (? = '' OR stage = ?) " +
            "ORDER BY updated_at DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<Deal> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + search + "%");
            ps.setString(2, stage);
            ps.setString(3, stage);
            ps.setInt(4, offset);
            ps.setInt(5, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeal(rs));
                }
            }
        }

        return list;
    }

    public int countDeals(String search, String stage) throws SQLException {
        if (search == null) search = "";
        if (stage == null) stage = "";

        String sql = "SELECT COUNT(*) FROM Deals WHERE (deal_name LIKE ?) AND (? = '' OR stage = ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + search + "%");
            ps.setString(2, stage);
            ps.setString(3, stage);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public List<Deal> searchDealsForExport(String search, String stage) throws SQLException {
        if (search == null) search = "";
        if (stage == null) stage = "";

        String sql =
            "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at " +
            "FROM Deals " +
            "WHERE (deal_name LIKE ?) " +
            "AND (? = '' OR stage = ?) " +
            "ORDER BY updated_at DESC";

        List<Deal> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + search + "%");
            ps.setString(2, stage);
            ps.setString(3, stage);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeal(rs));
                }
            }
        }

        return list;
    }

    public boolean deleteDeal(int dealId) throws SQLException {
        String sql = "DELETE FROM Deals WHERE deal_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dealId);
            return ps.executeUpdate() > 0;
        }
    }

    private Deal mapDeal(ResultSet rs) throws SQLException {
        Deal d = new Deal();
        d.setDealId(rs.getInt("deal_id"));
        d.setCustomerId(rs.getInt("customer_id"));
        d.setLeadId(rs.getInt("lead_id"));
        d.setDealName(rs.getString("deal_name"));
        d.setExpectedValue(rs.getBigDecimal("expected_value"));
        d.setActualValue(rs.getBigDecimal("actual_value"));
        d.setStage(rs.getString("stage"));
        d.setProbability(rs.getInt("probability"));

        java.sql.Date closeDate = rs.getDate("expected_close_date");
        if (closeDate != null) {
            d.setExpectedCloseDate(closeDate.toLocalDate());
        }

        d.setOwnerId(rs.getInt("owner_id"));

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            d.setCreatedAt(createdTs.toLocalDateTime());
        }

        Timestamp updatedTs = rs.getTimestamp("updated_at");
        if (updatedTs != null) {
            d.setUpdatedAt(updatedTs.toLocalDateTime());
        }

        return d;
    }

    public static List<String> getDefaultStages() {
        List<String> stages = new ArrayList<>();
        stages.add("Prospecting");
        stages.add("Qualified");
        stages.add("Proposal");
        stages.add("Negotiation");
        stages.add("Closed Won");
        stages.add("Closed Lost");
        return stages;
    }

    public static Integer stageToDefaultProbability(String stage) {
        if (stage == null) {
            return null;
        }
        String s = stage.trim();
        if (s.equalsIgnoreCase("Prospecting")) return 10;
        if (s.equalsIgnoreCase("Qualified")) return 40;
        if (s.equalsIgnoreCase("Proposal")) return 60;
        if (s.equalsIgnoreCase("Negotiation")) return 75;
        if (s.equalsIgnoreCase("Closed Won")) return 100;
        if (s.equalsIgnoreCase("Closed Lost")) return 0;
        return null;
    }
}
