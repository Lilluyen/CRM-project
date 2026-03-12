package service;

import dao.NotificationDAO;
import dao.NotificationRuleDAO;
import dto.Pagination;
import model.Notification;
import model.NotificationRule;
import websocket.NotificationWebSocketEndpoint;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Executes notification reminder rules stored in Notification_Rules.
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

    /**
     * Process due rules (next_run <= now). For each rule, create a NEW Notification
     * cloned from the base Notification header and copy its recipients.
     *
     * Caller should manage transaction boundaries (commit/rollback).
     */
    public int processDueRules(int batchSize) throws Exception {
        int triggered = 0;
        List<NotificationRule> due = ruleDAO.findDueRules(batchSize);

        for (NotificationRule rule : due) {
            Savepoint sp = connection.setSavepoint();
            try {
                int baseNotificationId = rule.getNotificationId();
                Notification base = notificationDAO.findById(baseNotificationId);
                if (base == null) {
                    ruleDAO.deactivate(rule.getRuleId());
                    connection.releaseSavepoint(sp);
                    continue;
                }

                // Clone notification header
                Notification n = new Notification();
                n.setTitle(base.getTitle());
                n.setContent(base.getContent());
                n.setType(base.getType());
                n.setRelatedType(base.getRelatedType());
                n.setRelatedId(base.getRelatedId());

                int newNotificationId = notificationDAO.insertNotification(n);
                if (newNotificationId <= 0) {
                    throw new IllegalStateException("Cannot insert cloned notification for rule_id=" + rule.getRuleId());
                }

                // Copy recipients from base notification
                List<Integer> recipientIds = notificationDAO.findRecipientUserIds(baseNotificationId);
                for (int uid : recipientIds) {
                    notificationDAO.addRecipient(newNotificationId, uid);
                }

                // Push real-time notification to connected clients (WebSocket)
                // Note: this runs inside the scheduler transaction; in the unlikely event of a later rollback
                // the client may briefly see a notification that won't be committed.
                Notification full = notificationDAO.findById(newNotificationId);
                for (int uid : recipientIds) {
                    int count = notificationDAO.countUnreadByUser(uid);
                    NotificationWebSocketEndpoint.pushNewUnread(uid, full != null ? full : n, count);
                }

                LocalDateTime now = LocalDateTime.now();
                boolean active = true;
                LocalDateTime nextRun = now;

                String rt = rule.getRuleType() != null ? rule.getRuleType().trim() : "";
                if ("ONCE".equalsIgnoreCase(rt) || "ONE_TIME".equalsIgnoreCase(rt)) {
                    active = false;
                } else {
                    LocalDateTime computed = computeNextRun(now, rule.getIntervalValue(), rule.getIntervalUnit());
                    if (computed == null) {
                        // No recurrence definition → stop the rule after firing once
                        active = false;
                    } else {
                        nextRun = computed;
                    }
                }

                ruleDAO.updateAfterTrigger(rule.getRuleId(), nextRun, now, active);
                triggered++;
            } catch (Exception ex) {
                connection.rollback(sp);
                LOG.log(Level.WARNING, "Failed to process notification rule " + rule.getRuleId(), ex);
                // keep scheduler alive; move on to next rule
            }
        }

        return triggered;
    }

    private LocalDateTime computeNextRun(LocalDateTime base,
                                        Integer intervalValue,
                                        String intervalUnit) {
        if (base == null) return null;
        if (intervalValue == null || intervalValue <= 0) return null;
        if (intervalUnit == null || intervalUnit.isBlank()) return null;

        String u = intervalUnit.trim().toLowerCase(Locale.ROOT);
        return switch (u) {
            case "minute", "minutes", "min", "mins" -> base.plusMinutes(intervalValue);
            case "hour", "hours", "h" -> base.plusHours(intervalValue);
            case "day", "days", "d" -> base.plusDays(intervalValue);
            case "week", "weeks", "w" -> base.plusWeeks(intervalValue);
            case "month", "months", "m" -> base.plusMonths(intervalValue);
            default -> null;
        };
    }

    public NotificationRule getRuleById(int ruleId) throws SQLException {
        return ruleDAO.findById(ruleId);
    }

    public int countRulesForUser(int userId, boolean isManagement) throws SQLException {
        if (isManagement) {
            return ruleDAO.countAll();
        }
        return ruleDAO.countForUser(userId);
    }

    public List<NotificationRule> listRulesForUser(int userId, boolean isManagement, int page, int pageSize) throws SQLException {
        int offset = Math.max(0, (page - 1) * pageSize);
        if (isManagement) {
            return ruleDAO.findAll(offset, pageSize);
        }
        return ruleDAO.findForUser(userId, offset, pageSize);
    }

    public List<Notification> listNotificationsForUser(int userId, boolean isManagement, int page, int pageSize) throws SQLException {
        int offset = Math.max(0, (page - 1) * pageSize);
        if (isManagement) {
            return notificationDAO.findAll(offset, pageSize);
        }
        // no paging support in DAO for user notifications, so do in-memory slice
        List<Notification> all = notificationDAO.findByUser(userId);
        int toIndex = Math.min(offset + pageSize, all.size());
        if (offset > all.size()) return new java.util.ArrayList<>();
        return all.subList(offset, toIndex);
    }

    public int countNotificationsForUser(int userId, boolean isManagement) throws SQLException {
        if (isManagement) {
            return notificationDAO.countAll();
        }
        return notificationDAO.findByUser(userId).size();
    }

    public Notification getNotificationById(int notificationId) throws SQLException {
        return notificationDAO.findById(notificationId);
    }

    public boolean updateNotification(Notification n) throws SQLException {
        return notificationDAO.updateNotification(n);
    }

    public int createRule(int notificationId,
                          String ruleType,
                          Integer intervalValue,
                          String intervalUnit,
                          LocalDateTime nextRun) throws SQLException {
        return ruleDAO.insertRule(notificationId, ruleType, intervalValue, intervalUnit, nextRun);
    }

    public boolean updateRule(int ruleId,
                              String ruleType,
                              Integer intervalValue,
                              String intervalUnit,
                              LocalDateTime nextRun,
                              boolean active) throws SQLException {
        return ruleDAO.updateRule(ruleId, ruleType, intervalValue, intervalUnit, nextRun, active);
    }

    public boolean deleteRule(int ruleId) throws SQLException {
        return ruleDAO.deleteRule(ruleId);
    }
}

