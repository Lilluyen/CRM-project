package dao;

import model.Deal;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    public boolean updateDealStage(int dealId, String stage, Integer probability, BigDecimal actualValue)
            throws SQLException {
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
        if (search == null)
            search = "";
        if (stage == null)
            stage = "";

        int offset = (page - 1) * pageSize;

        String sql = "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at "
                +
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
        if (search == null)
            search = "";
        if (stage == null)
            stage = "";

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
        if (search == null)
            search = "";
        if (stage == null)
            stage = "";

        String sql = "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at "
                +
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

    public int countDealByCusId(int id) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM Deals WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return count;

    }

    public List<Deal> getListDealsByCusId(int id) {
        List<Deal> list = new ArrayList<>();
        String sql = "SELECT deal_id, customer_id, lead_id, deal_name, expected_value, actual_value, stage, probability, expected_close_date, owner_id, created_at, updated_at FROM Deals WHERE customer_id = ? ORDER BY updated_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDeal(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
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
        if (s.equalsIgnoreCase("Prospecting"))
            return 10;
        if (s.equalsIgnoreCase("Qualified"))
            return 40;
        if (s.equalsIgnoreCase("Proposal"))
            return 60;
        if (s.equalsIgnoreCase("Negotiation"))
            return 75;
        if (s.equalsIgnoreCase("Closed Won"))
            return 100;
        if (s.equalsIgnoreCase("Closed Lost"))
            return 0;
        return null;
    }

    // chuyển id của lead lên id của cus trong deal
    public void updateCustomerForDeal(int dealId, int customerId) throws SQLException {
        String sql = "UPDATE Deals SET customer_id = ?, lead_id = NULL WHERE deal_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, dealId);
            ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DASHBOARD METHODS (Sale Dashboard)
    // ─────────────────────────────────────────────────────────────────────────

    // ─── Helper: bind date range params (2 params: startDate, endDate) ────
    private void bindDateRange(PreparedStatement ps, java.time.LocalDate startDate,
                               java.time.LocalDate endDate, int startIdx) throws SQLException {
        ps.setDate(startIdx,     java.sql.Date.valueOf(startDate));
        ps.setDate(startIdx + 1, java.sql.Date.valueOf(endDate));
    }

    public double getMonthlyRevenue(int userId, boolean isManager,
                                    java.time.LocalDate startDate, java.time.LocalDate endDate)
            throws SQLException {
        if (isManager) {
            String sql = "SELECT COALESCE(SUM(actual_value), 0) FROM Deals "
                       + "WHERE stage = 'Closed Won' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
            }
        } else {
            String sql = "SELECT COALESCE(SUM(actual_value), 0) FROM Deals "
                       + "WHERE stage = 'Closed Won' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?) AND owner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                ps.setInt(3, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
            }
        }
        return 0.0;
    }

    public int countDealsWonThisMonth(int userId, boolean isManager,
                                      java.time.LocalDate startDate, java.time.LocalDate endDate)
            throws SQLException {
        if (isManager) {
            String sql = "SELECT COUNT(*) FROM Deals "
                       + "WHERE stage = 'Closed Won' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } else {
            String sql = "SELECT COUNT(*) FROM Deals "
                       + "WHERE stage = 'Closed Won' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?) AND owner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                ps.setInt(3, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int countDealsLostThisMonth(int userId, boolean isManager,
                                        java.time.LocalDate startDate, java.time.LocalDate endDate)
            throws SQLException {
        if (isManager) {
            String sql = "SELECT COUNT(*) FROM Deals "
                       + "WHERE stage = 'Closed Lost' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } else {
            String sql = "SELECT COUNT(*) FROM Deals "
                       + "WHERE stage = 'Closed Lost' AND updated_at >= ? AND updated_at < DATEADD(day, 1, ?) AND owner_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                ps.setInt(3, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int countNewLeadsThisMonth(int userId, boolean isManager,
                                       java.time.LocalDate startDate, java.time.LocalDate endDate)
            throws SQLException {
        if (isManager) {
            String sql = "SELECT COUNT(*) FROM Leads WHERE created_at >= ? AND created_at < DATEADD(day, 1, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } else {
            String sql = "SELECT COUNT(*) FROM Leads WHERE created_at >= ? AND created_at < DATEADD(day, 1, ?) AND assigned_to = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                bindDateRange(ps, startDate, endDate, 1);
                ps.setInt(3, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int countFollowUpsToday(int userId, java.time.LocalDate today)
            throws SQLException {
        String sql = "SELECT COUNT(*) FROM Tasks t "
                   + "WHERE CAST(t.due_date AS DATE) = ? "
                   + "  AND t.related_type IN ('Lead', 'Customer') "
                   + "  AND t.status NOT IN ('Done', 'Cancelled') "
                   + "  AND EXISTS (SELECT 1 FROM Leads l WHERE l.lead_id = t.related_id AND l.assigned_to = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(today));
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Deal> getOpenDealsForUser(int userId, boolean isManager) throws SQLException {
        List<Deal> list = new ArrayList<>();
        if (isManager) {
            String sql = "SELECT d.deal_id, d.customer_id, d.lead_id, d.deal_name, "
                       + "       d.expected_value, d.actual_value, d.stage, d.probability, "
                       + "       d.expected_close_date, d.owner_id, d.created_at, d.updated_at, "
                       + "       COALESCE(c.name, l.full_name, 'Unknown') AS customer_name "
                       + "FROM Deals d "
                       + "LEFT JOIN Customers c ON d.customer_id = c.customer_id "
                       + "LEFT JOIN Leads l    ON d.lead_id     = l.lead_id "
                       + "WHERE d.stage NOT IN ('Closed Won', 'Closed Lost') "
                       + "ORDER BY d.updated_at DESC OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Deal d = mapDeal(rs);
                    d.setCustomerName(rs.getString("customer_name"));
                    list.add(d);
                }
            }
        } else {
            String sql = "SELECT d.deal_id, d.customer_id, d.lead_id, d.deal_name, "
                       + "       d.expected_value, d.actual_value, d.stage, d.probability, "
                       + "       d.expected_close_date, d.owner_id, d.created_at, d.updated_at, "
                       + "       COALESCE(c.name, l.full_name, 'Unknown') AS customer_name "
                       + "FROM Deals d "
                       + "LEFT JOIN Customers c ON d.customer_id = c.customer_id "
                       + "LEFT JOIN Leads l    ON d.lead_id     = l.lead_id "
                       + "WHERE d.stage NOT IN ('Closed Won', 'Closed Lost') AND d.owner_id = ? "
                       + "ORDER BY d.updated_at DESC OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Deal d = mapDeal(rs);
                        d.setCustomerName(rs.getString("customer_name"));
                        list.add(d);
                    }
                }
            }
        }
        return list;
    }

}
