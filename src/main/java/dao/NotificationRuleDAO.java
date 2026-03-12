package dao;

import model.NotificationRule;

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

public class NotificationRuleDAO {

    private final Connection connection;

    public NotificationRuleDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Create a rule linked to an existing Notification header row.
     */
    public int insertRule(int notificationId,
                          String ruleType,
                          Integer intervalValue,
                          String intervalUnit,
                          LocalDateTime nextRun) throws SQLException {
        String sql = "INSERT INTO Notification_Rules (notification_id, rule_type, interval_value, interval_unit, next_run, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notificationId);
            ps.setString(2, ruleType);
            if (intervalValue != null) ps.setInt(3, intervalValue);
            else ps.setNull(3, Types.INTEGER);
            if (intervalUnit != null) ps.setString(4, intervalUnit);
            else ps.setNull(4, Types.VARCHAR);
            ps.setTimestamp(5, Timestamp.valueOf(nextRun));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find due rules (next_run <= now) with row locks to avoid double-processing.
     * SQL Server: UPDLOCK + READPAST helps when multiple workers exist.
     */
    public List<NotificationRule> findDueRules(int batchSize) throws SQLException {
        List<NotificationRule> list = new ArrayList<>();
        String sql = "SELECT TOP (?) rule_id, notification_id, rule_type, interval_value, interval_unit, "
                   + "       next_run, last_run, is_active, created_at "
                   + "FROM Notification_Rules WITH (UPDLOCK, READPAST, ROWLOCK) "
                   + "WHERE is_active = 1 AND next_run <= GETDATE() "
                   + "ORDER BY next_run ASC, rule_id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public boolean updateAfterTrigger(int ruleId,
                                      LocalDateTime nextRun,
                                      LocalDateTime lastRun,
                                      boolean active) throws SQLException {
        String sql = "UPDATE Notification_Rules "
                   + "SET next_run=?, last_run=?, is_active=? "
                   + "WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(nextRun));
            if (lastRun != null) ps.setTimestamp(2, Timestamp.valueOf(lastRun));
            else ps.setNull(2, Types.TIMESTAMP);
            ps.setBoolean(3, active);
            ps.setInt(4, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deactivate(int ruleId) throws SQLException {
        String sql = "UPDATE Notification_Rules SET is_active=0 WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    public NotificationRule findById(int ruleId) throws SQLException {
        String sql = "SELECT rule_id, notification_id, rule_type, interval_value, interval_unit, "
                   + "next_run, last_run, is_active, created_at "
                   + "FROM Notification_Rules WHERE rule_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<NotificationRule> findForUser(int userId, int offset, int limit) throws SQLException {
        List<NotificationRule> list = new ArrayList<>();
        String sql = "SELECT r.rule_id, r.notification_id, r.rule_type, r.interval_value, r.interval_unit, "
                   + "       r.next_run, r.last_run, r.is_active, r.created_at "
                   + "FROM Notification_Rules r "
                   + "JOIN Notification_Recipients nr ON r.notification_id = nr.notification_id "
                   + "WHERE nr.user_id = ? "
                   + "ORDER BY r.next_run ASC, r.rule_id ASC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int countForUser(int userId) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT r.rule_id) "
                   + "FROM Notification_Rules r "
                   + "JOIN Notification_Recipients nr ON r.notification_id = nr.notification_id "
                   + "WHERE nr.user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<NotificationRule> findAll(int offset, int limit) throws SQLException {
        List<NotificationRule> list = new ArrayList<>();
        String sql = "SELECT rule_id, notification_id, rule_type, interval_value, interval_unit, "
                   + "       next_run, last_run, is_active, created_at "
                   + "FROM Notification_Rules "
                   + "ORDER BY next_run ASC, rule_id ASC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Notification_Rules";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public boolean updateRule(int ruleId,
                              String ruleType,
                              Integer intervalValue,
                              String intervalUnit,
                              LocalDateTime nextRun,
                              boolean active) throws SQLException {
        String sql = "UPDATE Notification_Rules "
                   + "SET rule_type=?, interval_value=?, interval_unit=?, next_run=?, is_active=? "
                   + "WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ruleType);
            if (intervalValue != null) ps.setInt(2, intervalValue);
            else ps.setNull(2, Types.INTEGER);
            if (intervalUnit != null) ps.setString(3, intervalUnit);
            else ps.setNull(3, Types.VARCHAR);
            ps.setTimestamp(4, Timestamp.valueOf(nextRun));
            ps.setBoolean(5, active);
            ps.setInt(6, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteRule(int ruleId) throws SQLException {
        String sql = "DELETE FROM Notification_Rules WHERE rule_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    private NotificationRule mapRow(ResultSet rs) throws SQLException {
        NotificationRule r = new NotificationRule();
        r.setRuleId(rs.getInt("rule_id"));
        r.setNotificationId(rs.getInt("notification_id"));
        r.setRuleType(rs.getString("rule_type"));

        int iv = rs.getInt("interval_value");
        r.setIntervalValue(rs.wasNull() ? null : iv);
        r.setIntervalUnit(rs.getString("interval_unit"));

        Timestamp nr = rs.getTimestamp("next_run");
        if (nr != null) r.setNextRun(nr.toLocalDateTime());

        Timestamp lr = rs.getTimestamp("last_run");
        if (lr != null) r.setLastRun(lr.toLocalDateTime());

        r.setActive(rs.getBoolean("is_active"));

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) r.setCreatedAt(ca.toLocalDateTime());

        return r;
    }
}

