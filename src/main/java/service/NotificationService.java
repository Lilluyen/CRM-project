package service;

import dao.NotificationDAO;
import model.Notification;
import util.DBContext;

import java.sql.Connection;
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

    public NotificationService(Connection connection) {
        this.notificationDAO = new NotificationDAO(connection);
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
            Notification n = new Notification();
            n.setTitle(title);
            n.setContent(content);
            n.setType(type);
            n.setRelatedType(relatedType);
            n.setRelatedId(relatedId);

            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return false;

            return notificationDAO.addRecipient(notifId, userId);
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
        try {
            Notification n = new Notification();
            n.setTitle(title);
            n.setContent(content);
            n.setType(type);
            n.setRelatedType(relatedType);
            n.setRelatedId(relatedId);

            int notifId = notificationDAO.insertNotification(n);
            if (notifId <= 0) return;

            for (int uid : userIds) {
                notificationDAO.addRecipient(notifId, uid);
            }
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

    public boolean markAsRead(int notificationId, int userId) {
        try {
            return notificationDAO.markAsRead(notificationId, userId);
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

    public static NotificationService withDefaultConnection() throws Exception {
        return new NotificationService(DBContext.getConnection());
    }
}
