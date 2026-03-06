package service;

import dao.NotificationDAO;
import dao.NotificationRuleDAO;
import model.Notification;
import model.NotificationRule;

import java.sql.Connection;
import java.sql.Savepoint;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;

/**
 * Executes notification reminder rules stored in Notification_Rules.
 */
public class NotificationRuleService {

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

                LocalDateTime now = LocalDateTime.now();
                boolean active = true;
                LocalDateTime nextRun = now;

                String rt = rule.getRuleType() != null ? rule.getRuleType().trim() : "";
                if ("ONCE".equalsIgnoreCase(rt)) {
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
                connection.releaseSavepoint(sp);
                triggered++;
            } catch (Exception ex) {
                connection.rollback(sp);
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
}

