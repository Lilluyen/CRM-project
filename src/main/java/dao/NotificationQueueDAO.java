package dao;

import model.NotificationQueue;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationQueueDAO – CRUD for [dbo].[Notification_Queue] table.
 *
 * Supports async notification processing with retry logic:
 *   - Enqueue notifications for background delivery
 *   - Poll pending items for delivery worker
 *   - Retry failed items
 *   - Track delivery status
 */
public class NotificationQueueDAO {

    private final Connection connection;

    public NotificationQueueDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. ENQUEUE (INSERT)
    // ─────────────────────────────────────────────────────────────────────────
    public int enqueue(NotificationQueue q) throws SQLException {
        String sql =
            "INSERT INTO Notification_Queue "
          + "(notification_id, title, content, type, related_type, related_id, "
          + " recipient_user_id, status, priority, scheduled_at, max_retries) "
          + "VALUES (?,?,?,?,?, ?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setObject(1, q.getNotificationId(), Types.INTEGER);
            ps.setString(2, q.getTitle());
            ps.setString(3, q.getContent());
            ps.setString(4, q.getType());
            ps.setString(5, q.getRelatedType());
            ps.setObject(6, q.getRelatedId(), Types.INTEGER);
            ps.setInt(7, q.getRecipientUserId());
            ps.setString(8, q.getStatus() != null ? q.getStatus() : "pending");
            ps.setString(9, q.getPriority() != null ? q.getPriority() : "normal");
            ps.setTimestamp(10, q.getScheduledAt() != null
                    ? Timestamp.valueOf(q.getScheduledAt())
                    : Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setInt(11, q.getMaxRetries() > 0 ? q.getMaxRetries() : 3);

            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    q.setQueueId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. POLL PENDING (for background worker)
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationQueue> pollPending(int batchSize) throws SQLException {
        List<NotificationQueue> list = new ArrayList<>();
        String sql =
            "SELECT TOP (?) * FROM Notification_Queue "
          + "WHERE status = 'pending' AND scheduled_at <= GETDATE() "
          + "ORDER BY priority DESC, scheduled_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. MARK SENT
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markSent(int queueId) throws SQLException {
        String sql = "UPDATE Notification_Queue SET status = 'sent', sent_at = GETDATE() WHERE queue_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, queueId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. MARK FAILED (with retry logic)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markFailed(int queueId, String errorMessage) throws SQLException {
        String sql =
            "UPDATE Notification_Queue SET " +
            "status = CASE WHEN retry_count + 1 >= max_retries THEN 'failed' ELSE 'pending' END, " +
            "failed_at = GETDATE(), " +
            "retry_count = retry_count + 1, " +
            "error_message = ? " +
            "WHERE queue_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, errorMessage);
            ps.setInt(2, queueId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. POLL FAILED FOR RETRY
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationQueue> pollFailedForRetry(int batchSize) throws SQLException {
        List<NotificationQueue> list = new ArrayList<>();
        String sql =
            "SELECT TOP (?) * FROM Notification_Queue "
          + "WHERE status = 'failed' AND retry_count < max_retries "
          + "ORDER BY failed_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. FIND BY RECIPIENT
    // ─────────────────────────────────────────────────────────────────────────
    public List<NotificationQueue> findByRecipient(int userId, int limit) throws SQLException {
        List<NotificationQueue> list = new ArrayList<>();
        String sql =
            "SELECT TOP (?) * FROM Notification_Queue "
          + "WHERE recipient_user_id = ? ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. COUNT BY STATUS
    // ─────────────────────────────────────────────────────────────────────────
    public int countByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Notification_Queue WHERE status = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. DELETE OLD
    // ─────────────────────────────────────────────────────────────────────────
    public int deleteOld(int daysOld) throws SQLException {
        String sql =
            "DELETE FROM Notification_Queue " +
            "WHERE status IN ('sent', 'cancelled') AND DATEDIFF(DAY, created_at, GETDATE()) > ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, daysOld);
            return ps.executeUpdate();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPER
    // ─────────────────────────────────────────────────────────────────────────
    private NotificationQueue mapRow(ResultSet rs) throws SQLException {
        NotificationQueue q = new NotificationQueue();
        q.setQueueId(rs.getInt("queue_id"));

        int nid = rs.getInt("notification_id");
        q.setNotificationId(rs.wasNull() ? null : nid);

        q.setTitle(rs.getString("title"));
        q.setContent(rs.getString("content"));
        q.setType(rs.getString("type"));
        q.setRelatedType(rs.getString("related_type"));

        int rid = rs.getInt("related_id");
        q.setRelatedId(rs.wasNull() ? null : rid);

        q.setRecipientUserId(rs.getInt("recipient_user_id"));
        q.setStatus(rs.getString("status"));
        q.setPriority(rs.getString("priority"));

        Timestamp sat = rs.getTimestamp("scheduled_at");
        if (sat != null) q.setScheduledAt(sat.toLocalDateTime());

        Timestamp sent = rs.getTimestamp("sent_at");
        if (sent != null) q.setSentAt(sent.toLocalDateTime());

        Timestamp failed = rs.getTimestamp("failed_at");
        if (failed != null) q.setFailedAt(failed.toLocalDateTime());

        q.setRetryCount(rs.getInt("retry_count"));
        q.setMaxRetries(rs.getInt("max_retries"));
        q.setErrorMessage(rs.getString("error_message"));

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) q.setCreatedAt(cat.toLocalDateTime());

        return q;
    }
}
