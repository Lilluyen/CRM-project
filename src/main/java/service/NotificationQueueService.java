package service;

import dao.NotificationQueueDAO;
import model.NotificationQueue;
import util.DBContext;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * NotificationQueueService – orchestrates async notification delivery.
 *
 * Responsibilities:
 *   - Enqueue notifications for background processing
 *   - Poll pending notifications for delivery worker
 *   - Handle retry logic for failed notifications
 *   - Track delivery status
 */
public class NotificationQueueService {

    private final NotificationQueueDAO queueDAO;

    public NotificationQueueService(Connection connection) {
        this.queueDAO = new NotificationQueueDAO(connection);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ENQUEUE
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Enqueue a notification for async delivery.
     */
    public int enqueue(NotificationQueue queue) {
        try {
            return queueDAO.enqueue(queue);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    /**
     * Enqueue a simple notification.
     */
    public int enqueue(String title, String content, String type,
                      String relatedType, Integer relatedId,
                      int recipientUserId, String priority,
                      LocalDateTime scheduledAt, int maxRetries) {
        try {
            NotificationQueue queue = new NotificationQueue();
            queue.setTitle(title);
            queue.setContent(content);
            queue.setType(type);
            queue.setRelatedType(relatedType);
            queue.setRelatedId(relatedId);
            queue.setRecipientUserId(recipientUserId);
            queue.setPriority(priority != null ? priority : "normal");
            queue.setStatus("pending");
            queue.setScheduledAt(scheduledAt != null ? scheduledAt : LocalDateTime.now());
            queue.setMaxRetries(maxRetries > 0 ? maxRetries : 3);
            queue.setRetryCount(0);

            return queueDAO.enqueue(queue);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POLL PENDING (for background worker)
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Poll pending notifications ready for delivery.
     */
    public List<NotificationQueue> pollPending(int batchSize) {
        try {
            return queueDAO.pollPending(batchSize > 0 ? batchSize : 50);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK SENT / FAILED
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Mark a notification as successfully sent.
     */
    public boolean markSent(int queueId) {
        try {
            return queueDAO.markSent(queueId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mark a notification as failed. Will auto-retry if retries remain.
     */
    public boolean markFailed(int queueId, String errorMessage) {
        try {
            return queueDAO.markFailed(queueId, errorMessage);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POLL FAILED FOR RETRY
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Poll failed notifications that can be retried.
     */
    public List<NotificationQueue> pollFailedForRetry(int batchSize) {
        try {
            return queueDAO.pollFailedForRetry(batchSize > 0 ? batchSize : 50);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // READ
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Get recent notifications for a user.
     */
    public List<NotificationQueue> getByRecipient(int userId, int limit) {
        try {
            return queueDAO.findByRecipient(userId, limit > 0 ? limit : 50);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STATS
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Count notifications by status (pending, sent, failed).
     */
    public int countByStatus(String status) {
        try {
            return queueDAO.countByStatus(status);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CLEANUP
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Delete old processed notifications.
     */
    public int deleteOld(int daysOld) {
        try {
            return queueDAO.deleteOld(daysOld > 0 ? daysOld : 30);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public static NotificationQueueService withDefaultConnection() throws Exception {
        return new NotificationQueueService(DBContext.getConnection());
    }
}
