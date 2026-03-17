package service;

import dao.NotificationDAO;
import dao.NotificationRuleDAO;
import model.Notification;
import model.NotificationRuleEngine;
import websocket.NotificationWebSocketEndpoint;
import util.DBContext;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * NotificationService – coordinates Notification creation and retrieval
 * using the two-table schema:
 *   Notifications            (shared header)
 *   Notification_Recipients  (per-user is_read state)
 */
public class NotificationService {

    private final NotificationDAO notificationDAO;
    private final NotificationRuleDAO notificationRuleDAO;

    public NotificationService(Connection connection) {
        this.notificationDAO = new NotificationDAO(connection);
        this.notificationRuleDAO = new NotificationRuleDAO(connection);
    }

    /**
     * Create a notification and deliver it to ONE user.
     *
     * @param userId      recipient user id
     * @param title       short title
     * @param content     body text
     * @param type        e.g. "TASK", "DEADLINE", "INFO"
     * @param relatedType e.g. "Task", "Lead"
     * @param relatedId   id of the related entity (nullable)
     */
    public boolean createForUser(int userId, String title, String content,
                                 String type, String relatedType, Integer relatedId) {
        try {
            Notification n = buildNotification(title, content, type, relatedType, relatedId);
            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return false;

            boolean ok = notificationDAO.addRecipient(notifId, userId);
            if (ok) {
                pushNotificationToUser(notifId, userId, n);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Create a notification for ONE user and attach a reminder rule in Notification_Rules.
     *
     * @param nextRun when the rule should first trigger (>= now recommended)
     */
    public boolean createForUserWithRule(int userId,
                                         String title,
                                         String content,
                                         String type,
                                         String relatedType,
                                         Integer relatedId,
                                         String ruleType,
                                         Integer intervalValue,
                                         String intervalUnit,
                                         LocalDateTime nextRun) {
        try {
            Notification n = buildNotification(title, content, type, relatedType, relatedId);
            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return false;
            if (!notificationDAO.addRecipient(notifId, userId)) return false;

            // Build rule engine object
            NotificationRuleEngine rule = new NotificationRuleEngine();
            rule.setRuleName("Auto-created rule for notification " + notifId);
            rule.setRuleType(ruleType);
            rule.setNotificationTitleTemplate(title);
            rule.setNotificationContentTemplate(content);
            rule.setNotificationType(type);
            rule.setNextRunAt(nextRun);
            rule.setConditionValue(intervalValue);
            rule.setConditionUnit(intervalUnit);
            rule.setRecipientType("user");
            rule.setRecipientUserId(userId);
            rule.setActive(true);

            int ruleId = notificationRuleDAO.insertRule(rule);
            boolean ok = ruleId > 0;
            if (ok) {
                pushNotificationToUser(notifId, userId, n);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Convenience overload – no relatedType/relatedId.
     */
    public boolean createForUser(int userId, String title, String content, String type) {
        return createForUser(userId, title, content, type, null, null);
    }

    /**
     * Broadcast to multiple users.
     */
    public void broadcastToUsers(List<Integer> userIds, String title, String content,
                                 String type, String relatedType, Integer relatedId) {
        if (userIds == null || userIds.isEmpty()) return;
        try {
            Notification n = buildNotification(title, content, type, relatedType, relatedId);
            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return;

            // Fetch once outside the loop - avoid N+1 query
            Notification full = notificationDAO.findById(notifId);

            for (int uid : userIds) {
                if (notificationDAO.addRecipient(notifId, uid)) {
                    pushNotificationToUser(full != null ? full : n, uid);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean broadcastToUsersWithRule(List<Integer> userIds,
                                           String title,
                                           String content,
                                           String type,
                                           String relatedType,
                                           Integer relatedId,
                                           String ruleType,
                                           Integer intervalValue,
                                           String intervalUnit,
                                           LocalDateTime nextRun) {
        if (userIds == null || userIds.isEmpty()) return false;
        try {
            Notification n = buildNotification(title, content, type, relatedType, relatedId);
            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return false;

            // Batch add all recipients
            for (int uid : userIds) {
                notificationDAO.addRecipient(notifId, uid);
            }

            // Build rule engine object
            NotificationRuleEngine rule = new NotificationRuleEngine();
            rule.setRuleName("Auto-created broadcast rule for notification " + notifId);
            rule.setRuleType(ruleType);
            rule.setNotificationTitleTemplate(title);
            rule.setNotificationContentTemplate(content);
            rule.setNotificationType(type);
            rule.setNextRunAt(nextRun);
            rule.setConditionValue(intervalValue);
            rule.setConditionUnit(intervalUnit);
            rule.setRecipientType("user");
            rule.setActive(true);

            int ruleId = notificationRuleDAO.insertRule(rule);
            boolean ok = ruleId > 0;
            if (ok) {
                // Fetch once outside the loop - avoid N+1 query
                Notification full = notificationDAO.findById(notifId);
                for (int uid : userIds) {
                    pushNotificationToUser(full != null ? full : n, uid);
                }
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS – Code reuse for notification creation and WebSocket push
    // ─────────────────────────────────────────────────────────────────────────

    /** Build Notification model from parameters */
    private Notification buildNotification(String title, String content,
                                           String type, String relatedType, Integer relatedId) {
        Notification n = new Notification();
        n.setTitle(title);
        n.setContent(content);
        n.setType(type);
        n.setRelatedType(relatedType);
        n.setRelatedId(relatedId);
        return n;
    }

    /** Push notification to user via WebSocket (uses DB fetch for full notification) */
    private void pushNotificationToUser(int notificationId, int userId, Notification fallback) {
        try {
            Notification full = notificationDAO.findById(notificationId);
            int count = notificationDAO.countUnreadByUser(userId);
            NotificationWebSocketEndpoint.pushNewUnread(userId, full != null ? full : fallback, count);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Push notification to user (already has full notification object) */
    private void pushNotificationToUser(Notification full, int userId) {
        try {
            int count = notificationDAO.countUnreadByUser(userId);
            NotificationWebSocketEndpoint.pushNewUnread(userId, full, count);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Notifications (all) for user, newest first. */
    public List<Notification> getAllForUser(int userId) {
        try {
            return notificationDAO.findByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /** Notifications (paged) for user, newest first. */
    public List<Notification> getAllForUserPaged(int userId, int page, int pageSize) {
        try {
            return notificationDAO.findByUserPaged(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /** Total notification count for user (for pagination). */
    public int countAllForUser(int userId) {
        try {
            return notificationDAO.countByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Unread notifications for user. Used for header dropdown + badge. */
    public List<Notification> getUnreadForUser(int userId) {
        try {
            return notificationDAO.findUnreadByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /** Unread count for badge. */
    public int countUnread(int userId) {
        try {
            return notificationDAO.countUnreadByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public Notification getById(int notificationId) {
        try {
            return notificationDAO.findById(notificationId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean markAsRead(int notificationId, int userId) {
        try {
            return notificationDAO.markAsRead(notificationId, userId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAsUnread(int notificationId, int userId) {
        try {
            return notificationDAO.markAsUnread(notificationId, userId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAllAsRead(int userId) {
        try {
            return notificationDAO.markAllAsReadForUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns true if the given user is a recipient of the notification.
     */
    public boolean isRecipient(int notificationId, int userId) {
        try {
            return notificationDAO.findRecipientUserIds(notificationId).contains(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateNotification(Notification n) {
        try {
            return notificationDAO.updateNotification(n);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static NotificationService withDefaultConnection() throws Exception {
        return new NotificationService(DBContext.getConnection());
    }
}
