package dao;

import model.NotificationRuleEngine;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationRuleDAO – aligned with [dbo].[Notification_Rule_Engine] table.
 *
 * Supports all 5 notification types from CRM scenarios:
 *   1. Realtime   – triggered by event (trigger_event IS NOT NULL)
 *   2. Reminder   – scheduler before deadline (rule_type = 'reminder')
 *   3. Condition  – business rule evaluation (rule_type = 'condition')
 *   4. Escalation – overdue escalation (rule_type = 'escalation')
 *   5. Digest     – daily aggregation (rule_type = 'digest')
 */
public class NotificationRuleDAO {

    private final Connection connection;

    public NotificationRuleDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BASE SELECT
    // ─────────────────────────────────────────────────────────────────────────
    private static final String BASE_SELECT =
        "SELECT rule_id, rule_name, rule_type, description, trigger_event, entity_type, "
      + "       condition_field, condition_operator, condition_value, condition_unit, "
      + "       cron_expression, next_run_at, last_run_at, "
      + "       notification_title_template, notification_content_template, "
      + "       notification_type, notification_priority, "
      + "       recipient_type, recipient_user_id, "
      + "       escalate_after_minutes, escalate_to_user_id, "
      + "       is_active, created_by, created_at, updated_at "
      + "FROM Notification_Rule_Engine ";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. INSERT RULE
    // ─────────────────────────────────────────────────────────────────────────
    public int insertRule(NotificationRuleEngine rule) throws SQLException {
        String sql =
            "INSERT INTO Notification_Rule_Engine "
          + "(rule_name, rule_type, description, trigger_event, entity_type, "
          + " condition_field, condition_operator, condition_value, condition_unit, "
          + " cron_expression, next_run_at, "
          + " notification_title_template, notification_content_template, "
          + " notification_type, notification_priority, "
          + " recipient_type, recipient_user_id, "
          + " escalate_after_minutes, escalate_to_user_id, "
          + " is_active, created_by, created_at) "
          + "VALUES (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, rule.getRuleName());
            ps.setString(2, rule.getRuleType());
            ps.setString(3, rule.getDescription());
            ps.setString(4, rule.getTriggerEvent());
            ps.setString(5, rule.getEntityType());
            ps.setString(6, rule.getConditionField());
            ps.setString(7, rule.getConditionOperator());
            ps.setObject(8, rule.getConditionValue(), Types.INTEGER);
            ps.setString(9, rule.getConditionUnit());
            ps.setString(10, rule.getCronExpression());
            ps.setObject(11, rule.getNextRunAt() != null ? Timestamp.valueOf(rule.getNextRunAt()) : null, Types.TIMESTAMP);
            ps.setString(12, rule.getNotificationTitleTemplate());
            ps.setString(13, rule.getNotificationContentTemplate());
            ps.setString(14, rule.getNotificationType());
            ps.setString(15, rule.getNotificationPriority() != null ? rule.getNotificationPriority() : "NORMAL");
            ps.setString(16, rule.getRecipientType());
            ps.setObject(17, rule.getRecipientUserId(), Types.INTEGER);
            ps.setObject(18, rule.getEscalateAfterMinutes(), Types.INTEGER);
            ps.setObject(19, rule.getEscalateToUserId(), Types.INTEGER);
            ps.setBoolean(20, rule.isActive());
            ps.setObject(21, rule.getCreatedBy(), Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    rule.setRuleId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. UPDATE RULE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateRule(NotificationRuleEngine rule) throws SQLException {
        String sql =
            "UPDATE Notification_Rule_Engine SET "
          + "rule_name=?, rule_type=?, description=?, trigger_event=?, entity_type=?, "
          + "condition_field=?, condition_operator=?, condition_value=?, condition_unit=?, "
          + "cron_expression=?, next_run_at=?, "
          + "notification_title_template=?, notification_content_template=?, "
          + "notification_type=?, notification_priority=?, "
          + "recipient_type=?, recipient_user_id=?, "
          + "escalate_after_minutes=?, escalate_to_user_id=?, "
          + "is_active=?, updated_at=GETDATE() "
          + "WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, rule.getRuleName());
            ps.setString(2, rule.getRuleType());
            ps.setString(3, rule.getDescription());
            ps.setString(4, rule.getTriggerEvent());
            ps.setString(5, rule.getEntityType());
            ps.setString(6, rule.getConditionField());
            ps.setString(7, rule.getConditionOperator());
            ps.setObject(8, rule.getConditionValue(), Types.INTEGER);
            ps.setString(9, rule.getConditionUnit());
            ps.setString(10, rule.getCronExpression());
            ps.setObject(11, rule.getNextRunAt() != null ? Timestamp.valueOf(rule.getNextRunAt()) : null, Types.TIMESTAMP);
            ps.setString(12, rule.getNotificationTitleTemplate());
            ps.setString(13, rule.getNotificationContentTemplate());
            ps.setString(14, rule.getNotificationType());
            ps.setString(15, rule.getNotificationPriority() != null ? rule.getNotificationPriority() : "NORMAL");
            ps.setString(16, rule.getRecipientType());
            ps.setObject(17, rule.getRecipientUserId(), Types.INTEGER);
            ps.setObject(18, rule.getEscalateAfterMinutes(), Types.INTEGER);
            ps.setObject(19, rule.getEscalateToUserId(), Types.INTEGER);
            ps.setBoolean(20, rule.isActive());
            ps.setInt(21, rule.getRuleId());
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. UPDATE AFTER TRIGGER (scheduler updates next_run_at + last_run_at)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateAfterTrigger(int ruleId, LocalDateTime nextRunAt, boolean active) throws SQLException {
        String sql =
            "UPDATE Notification_Rule_Engine "
          + "SET next_run_at=?, last_run_at=GETDATE(), is_active=?, updated_at=GETDATE() "
          + "WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setObject(1, nextRunAt != null ? Timestamp.valueOf(nextRunAt) : null, Types.TIMESTAMP);
            ps.setBoolean(2, active);
            ps.setInt(3, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. DEACTIVATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deactivate(int ruleId) throws SQLException {
        String sql = "UPDATE Notification_Rule_Engine SET is_active=0, updated_at=GETDATE() WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. DELETE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteRule(int ruleId) throws SQLException {
        String sql = "DELETE FROM Notification_Rule_Engine WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. FIND BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public NotificationRuleEngine findById(int ruleId) throws SQLException {
        String sql = BASE_SELECT + "WHERE rule_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ruleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. FIND DUE RULES (scheduler: next_run_at <= now, is_active = 1)
    //    Uses UPDLOCK + READPAST to avoid double-processing in concurrent workers
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findDueRules(int batchSize) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        String sql =
            "SELECT TOP (?) rule_id, rule_name, rule_type, description, trigger_event, entity_type, "
          + "       condition_field, condition_operator, condition_value, condition_unit, "
          + "       cron_expression, next_run_at, last_run_at, "
          + "       notification_title_template, notification_content_template, "
          + "       notification_type, notification_priority, "
          + "       recipient_type, recipient_user_id, "
          + "       escalate_after_minutes, escalate_to_user_id, "
          + "       is_active, created_by, created_at, updated_at "
          + "FROM Notification_Rule_Engine WITH (UPDLOCK, READPAST, ROWLOCK) "
          + "WHERE is_active = 1 AND next_run_at <= GETDATE() "
          + "ORDER BY next_run_at ASC, rule_id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. FIND BY TYPE (e.g. all 'reminder' rules, all 'escalation' rules)
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findByType(String ruleType) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE rule_type=? AND is_active=1 ORDER BY rule_id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ruleType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. FIND ALL – PAGED (admin view)
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findAll(int offset, int limit) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY rule_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Notification_Rule_Engine";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10. FIND BY USER (non-admin view) – rules created by or visible to user
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findForUser(int userId, int offset, int limit) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        // Show rules created by this user OR where they are the recipient
        String sql = BASE_SELECT +
            "WHERE created_by = ? OR recipient_user_id = ? " +
            "ORDER BY rule_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, offset);
            ps.setInt(4, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countForUser(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Notification_Rule_Engine WHERE created_by = ? OR recipient_user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11. FIND BY TRIGGER EVENT (for event-driven notifications)
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findByTriggerEvent(String triggerEvent) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        String sql = BASE_SELECT +
            "WHERE trigger_event = ? AND is_active = 1 " +
            "ORDER BY rule_id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, triggerEvent);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12. FIND BY ENTITY (for condition-based rules)
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationRuleEngine> findByEntityType(String entityType) throws SQLException {
        List<NotificationRuleEngine> list = new ArrayList<>();
        String sql = BASE_SELECT +
            "WHERE entity_type = ? AND is_active = 1 " +
            "ORDER BY rule_id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, entityType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPER
    // ─────────────────────────────────────────────────────────────────────────
    private NotificationRuleEngine mapRow(ResultSet rs) throws SQLException {
        NotificationRuleEngine r = new NotificationRuleEngine();
        r.setRuleId(rs.getInt("rule_id"));
        r.setRuleName(rs.getString("rule_name"));
        r.setRuleType(rs.getString("rule_type"));
        r.setDescription(rs.getString("description"));
        r.setTriggerEvent(rs.getString("trigger_event"));
        r.setEntityType(rs.getString("entity_type"));
        r.setConditionField(rs.getString("condition_field"));
        r.setConditionOperator(rs.getString("condition_operator"));

        int cv = rs.getInt("condition_value");
        r.setConditionValue(rs.wasNull() ? null : cv);
        r.setConditionUnit(rs.getString("condition_unit"));
        r.setCronExpression(rs.getString("cron_expression"));

        Timestamp nra = rs.getTimestamp("next_run_at");
        if (nra != null) r.setNextRunAt(nra.toLocalDateTime());

        Timestamp lra = rs.getTimestamp("last_run_at");
        if (lra != null) r.setLastRunAt(lra.toLocalDateTime());

        r.setNotificationTitleTemplate(rs.getString("notification_title_template"));
        r.setNotificationContentTemplate(rs.getString("notification_content_template"));
        r.setNotificationType(rs.getString("notification_type"));
        r.setNotificationPriority(rs.getString("notification_priority"));
        r.setRecipientType(rs.getString("recipient_type"));

        int ruid = rs.getInt("recipient_user_id");
        r.setRecipientUserId(rs.wasNull() ? null : ruid);

        int eam = rs.getInt("escalate_after_minutes");
        r.setEscalateAfterMinutes(rs.wasNull() ? null : eam);

        int etuid = rs.getInt("escalate_to_user_id");
        r.setEscalateToUserId(rs.wasNull() ? null : etuid);

        r.setActive(rs.getBoolean("is_active"));

        int cb = rs.getInt("created_by");
        r.setCreatedBy(rs.wasNull() ? null : cb);

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) r.setCreatedAt(cat.toLocalDateTime());

        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) r.setUpdatedAt(uat.toLocalDateTime());

        return r;
    }
}
