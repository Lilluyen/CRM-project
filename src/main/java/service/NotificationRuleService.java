package service;

import dao.NotificationDAO;
import dao.NotificationRuleDAO;
import model.Notification;
import model.NotificationRule;
import model.NotificationRuleEngine;
import websocket.NotificationWebSocketEndpoint;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * NotificationRuleService – orchestrates Notification_Rule_Engine logic.
 *
 * Supports:
 *   1. Scheduler: processDueRules() for schedule/condition rules
 *   2. Event trigger: fireEventRules() for realtime event-driven rules
 *   3. CRUD: create/update/delete rules (UI)
 *   4. Listing: paged rules for admin and user views
 */
public class NotificationRuleService {

    private static final Logger LOG = Logger.getLogger(NotificationRuleService.class.getName());

    private final Connection connection;
    private final NotificationRuleDAO ruleDAO;
    private final NotificationDAO notificationDAO;

    public NotificationRuleService(Connection connection) {
        this.connection = connection;
        this.ruleDAO = new NotificationRuleDAO(connection);
        this.notificationDAO = new NotificationDAO(connection);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SCHEDULER: Process due rules (next_run_at <= now)
    // ─────────────────────────────────────────────────────────────────────────
    public int processDueRules(int batchSize) throws Exception {
        int triggered = 0;
        List<NotificationRuleEngine> dueRules = ruleDAO.findDueRules(batchSize);

        for (NotificationRuleEngine rule : dueRules) {
            Savepoint sp = connection.setSavepoint();
            try {
                triggered += processOneRule(rule) ? 1 : 0;
            } catch (Exception ex) {
                connection.rollback(sp);
                LOG.log(Level.WARNING, "Failed to process rule " + rule.getRuleId(), ex);
            }
        }
        return triggered;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EVENT TRIGGER: Fire rules matching a specific event
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Called when a CRM event occurs (e.g. task_created, task_completed).
     * Finds all active event_trigger rules matching the event and fires them.
     */
    public int fireEventRules(String triggerEvent) {
        int fired = 0;
        try {
            List<NotificationRuleEngine> rules = ruleDAO.findByTriggerEvent(triggerEvent);
            for (NotificationRuleEngine rule : rules) {
                try {
                    if (processOneRule(rule)) fired++;
                } catch (Exception ex) {
                    LOG.log(Level.WARNING, "Failed to fire event rule " + rule.getRuleId(), ex);
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Cannot load event rules for: " + triggerEvent, e);
        }
        return fired;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CORE: Process a single rule → create notification from template
    // ─────────────────────────────────────────────────────────────────────────
    private boolean processOneRule(NotificationRuleEngine rule) throws SQLException {
        // Build notification from template
        String title = rule.getNotificationTitleTemplate() != null
                ? rule.getNotificationTitleTemplate() : "Notification";
        String content = rule.getNotificationContentTemplate();

        Notification n = new Notification();
        n.setTitle(title);
        n.setContent(content);
        n.setType(rule.getNotificationType());
        n.setPriority(rule.getNotificationPriority());
        n.setStatus("SENT");
        n.setCreatedBy(rule.getCreatedBy());

        int notifId = notificationDAO.insertNotification(n);
        if (notifId <= 0) return false;

        // Determine recipients and add them
        List<Integer> recipientIds = resolveRecipients(rule);
        for (int uid : recipientIds) {
            notificationDAO.addRecipient(notifId, uid);
        }

        // Push via WebSocket
        pushToRecipients(notifId, n, recipientIds);

        // Update rule scheduling
        updateRuleAfterFire(rule);
        return true;
    }

    /**
     * Resolve recipient user IDs based on rule's recipient_type.
     */
    private List<Integer> resolveRecipients(NotificationRuleEngine rule) {
        List<Integer> ids = new ArrayList<>();
        if (rule.getRecipientUserId() != null) {
            ids.add(rule.getRecipientUserId());
        }
        // Escalation: also notify escalation target
        if (rule.getEscalateToUserId() != null) {
            ids.add(rule.getEscalateToUserId());
        }
        return ids;
    }

    /**
     * Push WebSocket notification to all recipients.
     */
    private void pushToRecipients(int notifId, Notification n, List<Integer> recipientIds) {
        try {
            Notification full = notificationDAO.findById(notifId);
            for (int uid : recipientIds) {
                int count = notificationDAO.countUnreadByUser(uid);
                NotificationWebSocketEndpoint.pushNewUnread(uid, full != null ? full : n, count);
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "WebSocket push failed for notification " + notifId, e);
        }
    }

    /**
     * After firing a rule, calculate next_run_at or deactivate if one-time.
     */
    private void updateRuleAfterFire(NotificationRuleEngine rule) throws SQLException {
        String ruleType = rule.getRuleType() != null ? rule.getRuleType().trim() : "";
        boolean keepActive;
        LocalDateTime nextRun;

        if ("event_trigger".equalsIgnoreCase(ruleType)) {
            // Event triggers don't use scheduling - stay active
            keepActive = true;
            nextRun = null;
        } else if ("schedule".equalsIgnoreCase(ruleType) || "condition".equalsIgnoreCase(ruleType)) {
            // Recalculate next run from condition_value/condition_unit
            nextRun = computeNextRun(LocalDateTime.now(),
                    rule.getConditionValue(), rule.getConditionUnit());
            keepActive = nextRun != null;
        } else {
            keepActive = false;
            nextRun = null;
        }

        ruleDAO.updateAfterTrigger(rule.getRuleId(), nextRun, keepActive);
    }

    /**
     * Compute next run time based on interval value and unit.
     */
    private LocalDateTime computeNextRun(LocalDateTime base, Integer value, String unit) {
        if (base == null || value == null || value <= 0) return null;
        if (unit == null || unit.isBlank()) return null;

        return switch (unit.trim().toLowerCase()) {
            case "minute", "minutes", "min" -> base.plusMinutes(value);
            case "hour", "hours", "h"       -> base.plusHours(value);
            case "day", "days", "d"         -> base.plusDays(value);
            case "week", "weeks", "w"       -> base.plusWeeks(value);
            case "month", "months", "m"     -> base.plusMonths(value);
            default -> null;
        };
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CRUD: Rule management (used by controllers)
    // ─────────────────────────────────────────────────────────────────────────

    public NotificationRule getRuleById(int ruleId) throws SQLException {
        NotificationRuleEngine engine = ruleDAO.findById(ruleId);
        return engine != null ? new NotificationRule(engine) : null;
    }

    /** Direct access to the engine model (used by new controller). */
    public NotificationRuleEngine getRuleEngineById(int ruleId) throws SQLException {
        return ruleDAO.findById(ruleId);
    }

    /** Create rule directly from a fully-populated engine object. */
    public int createRuleEngine(NotificationRuleEngine engine) throws SQLException {
        return ruleDAO.insertRule(engine);
    }

    /** Update rule directly from a fully-populated engine object. */
    public boolean updateRuleEngine(NotificationRuleEngine engine) throws SQLException {
        return ruleDAO.updateRule(engine);
    }

    public int createRule(int notificationId, String ruleType,
                          Integer intervalValue, String intervalUnit,
                          LocalDateTime nextRun) throws SQLException {
        NotificationRuleEngine engine = new NotificationRuleEngine();
        engine.setRuleName("Rule for notification #" + notificationId);
        engine.setRuleType(ruleType != null ? ruleType : "schedule");
        engine.setConditionValue(intervalValue);
        engine.setConditionUnit(intervalUnit);
        engine.setNextRunAt(nextRun);
        engine.setActive(true);
        // Load notification to use as template
        Notification base = notificationDAO.findById(notificationId);
        if (base != null) {
            engine.setNotificationTitleTemplate(base.getTitle());
            engine.setNotificationContentTemplate(base.getContent());
            engine.setNotificationType(base.getType());
        }
        return ruleDAO.insertRule(engine);
    }

    public boolean updateRule(int ruleId, String ruleType,
                              Integer intervalValue, String intervalUnit,
                              LocalDateTime nextRun, boolean active) throws SQLException {
        NotificationRuleEngine existing = ruleDAO.findById(ruleId);
        if (existing == null) return false;

        existing.setRuleType(ruleType != null ? ruleType : existing.getRuleType());
        existing.setConditionValue(intervalValue);
        existing.setConditionUnit(intervalUnit);
        existing.setNextRunAt(nextRun);
        existing.setActive(active);
        return ruleDAO.updateRule(existing);
    }

    public boolean deleteRule(int ruleId) throws SQLException {
        return ruleDAO.deleteRule(ruleId);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LISTING: Paged rules for admin/user views
    // ─────────────────────────────────────────────────────────────────────────

    public int countRulesForUser(int userId, boolean isManagement) throws SQLException {
        return isManagement ? ruleDAO.countAll() : ruleDAO.countForUser(userId);
    }

    public List<NotificationRule> listRulesForUser(int userId, boolean isManagement,
                                                    int page, int pageSize) throws SQLException {
        int offset = Math.max(0, (page - 1) * pageSize);
        List<NotificationRuleEngine> engines = isManagement
                ? ruleDAO.findAll(offset, pageSize)
                : ruleDAO.findForUser(userId, offset, pageSize);
        return toRuleList(engines);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // NOTIFICATION LISTING (delegates to NotificationDAO)
    // ─────────────────────────────────────────────────────────────────────────

    public List<Notification> listNotificationsForUser(int userId, boolean isManagement,
                                                       int page, int pageSize) {
        int offset = Math.max(0, (page - 1) * pageSize);
        if (isManagement) {
            return notificationDAO.findAll(offset, pageSize);
        }
        return notificationDAO.findByUserPaged(userId, page, pageSize);
    }

    public int countNotificationsForUser(int userId, boolean isManagement) {
        if (isManagement) {
            return notificationDAO.countAll();
        }
        return notificationDAO.countByUser(userId);
    }

    public Notification getNotificationById(int notificationId) {
        return notificationDAO.findById(notificationId);
    }

    public boolean updateNotification(Notification n) {
        return notificationDAO.updateNotification(n);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    private List<NotificationRule> toRuleList(List<NotificationRuleEngine> engines) {
        List<NotificationRule> rules = new ArrayList<>();
        for (NotificationRuleEngine e : engines) {
            rules.add(new NotificationRule(e));
        }
        return rules;
    }
}
