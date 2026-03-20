package dao;

import model.Notification;
import model.NotificationRecipient;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAO – aligned with the FULL CRM_System schema.
 *
 * Notifications table (complete column list):
 *   notification_id, title, content, type, related_type, related_id,
 *   created_at (DB default), priority, status, scheduled_at,
 *   created_by (FK Users), expires_at
 *
 * Notification_Recipients table:
 *   notification_id, user_id, is_read, read_at
 *
 * Changes from previous version:
 *  1. insertNotification() now writes all 8 settable columns (was missing
 *     priority, status, scheduled_at, created_by, expires_at).
 *  2. mapRow() and mapRowWithRecipient() populate those new fields.
 *  3. updateNotification() also updates the new fields.
 *  4. Added findByUserPaged() + countByUser() – eliminates in-memory slicing
 *     in NotificationRuleService.
 *  5. findByUser() / findUnreadByUser() are kept for badge / dropdown use-cases.
 *  6. addRecipient() uses MERGE to silently skip duplicate (PK violation guard).
 */
public class NotificationDAO {

    private final Connection connection;

    public NotificationDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BASE SELECT – reused by all notification queries
    // ─────────────────────────────────────────────────────────────────────────
    private static final String NOTIF_SELECT =
        "SELECT n.notification_id, n.title, n.content, n.type, "
      + "       n.related_type, n.related_id, n.created_at, "
      + "       n.priority, n.status, n.scheduled_at, n.created_by, n.expires_at ";

    private static final String NOTIF_SELECT_WITH_RECIP =
        NOTIF_SELECT
      + "       ,nr.user_id, nr.is_read, nr.read_at ";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. INSERT NOTIFICATION (header row – no recipient yet)
    // ─────────────────────────────────────────────────────────────────────────
    public int insertNotification(Notification n) {
        String sql =
            "INSERT INTO Notifications "
          + "(title, content, type, related_type, related_id, "
          + " priority, status, scheduled_at, created_by, expires_at) "
          + "VALUES (?,?,?,?,?, ?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getContent());
            ps.setString(3, n.getType());
            ps.setString(4, n.getRelatedType());
            ps.setObject(5, n.getRelatedId(),    Types.INTEGER);
            // priority / status have NOT NULL constraints with defaults in practice;
            // fall back to sensible defaults when the caller omits them.
            ps.setString(6, n.getPriority() != null    ? n.getPriority()  : "NORMAL");
            ps.setString(7, n.getStatus()   != null    ? n.getStatus()    : "SENT");
            ps.setObject(8,  n.getScheduledAt() != null
                    ? Timestamp.valueOf(n.getScheduledAt()) : null, Types.TIMESTAMP);
            ps.setObject(9,  n.getCreatedBy(), Types.INTEGER);
            ps.setObject(10, n.getExpiresAt() != null
                    ? Timestamp.valueOf(n.getExpiresAt()) : null, Types.TIMESTAMP);

            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    n.setNotificationId(id);
                    return id;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. ADD RECIPIENT – MERGE prevents duplicate PK exceptions
    // ─────────────────────────────────────────────────────────────────────────
    public boolean addRecipient(int notificationId, int userId) {
        // SQL Server MERGE: insert only if the (notification_id, user_id) pair
        // does not already exist in Notification_Recipients.
        String sql =
            "MERGE Notification_Recipients AS target "
          + "USING (VALUES (?, ?)) AS src(notification_id, user_id) "
          + "   ON target.notification_id = src.notification_id "
          + "  AND target.user_id         = src.user_id "
          + "WHEN NOT MATCHED THEN "
          + "   INSERT (notification_id, user_id, is_read) VALUES (?, ?, 0);";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            ps.setInt(3, notificationId);
            ps.setInt(4, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. GET ALL NOTIFICATIONS FOR A USER – FULL LIST (badge / small dropdown)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql =
            NOTIF_SELECT_WITH_RECIP
          + "FROM Notifications n "
          + "JOIN Notification_Recipients nr ON n.notification_id = nr.notification_id "
          + "WHERE nr.user_id = ? "
          + "ORDER BY n.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithRecipient(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. GET ALL NOTIFICATIONS FOR A USER – PAGED (notification list page)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findByUserPaged(int userId, int page, int pageSize) {
        List<Notification> list = new ArrayList<>();
        String sql =
            NOTIF_SELECT_WITH_RECIP
          + "FROM Notifications n "
          + "JOIN Notification_Recipients nr ON n.notification_id = nr.notification_id "
          + "WHERE nr.user_id = ? "
          + "ORDER BY n.created_at DESC "
          + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithRecipient(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countByUser(int userId) {
        String sql =
            "SELECT COUNT(*) FROM Notification_Recipients WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. GET UNREAD NOTIFICATIONS FOR A USER (header dropdown + badge list)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findUnreadByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql =
            NOTIF_SELECT_WITH_RECIP
          + "FROM Notifications n "
          + "JOIN Notification_Recipients nr ON n.notification_id = nr.notification_id "
          + "WHERE nr.user_id = ? AND nr.is_read = 0 "
          + "ORDER BY n.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithRecipient(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. COUNT UNREAD (badge counter)
    // ─────────────────────────────────────────────────────────────────────────
    public int countUnreadByUser(int userId) {
        String sql =
            "SELECT COUNT(*) FROM Notification_Recipients "
          + "WHERE user_id = ? AND is_read = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. MARK SINGLE NOTIFICATION AS READ / UNREAD
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markAsRead(int notificationId, int userId) {
        String sql =
            "UPDATE Notification_Recipients SET is_read=1, read_at=GETDATE() "
          + "WHERE notification_id=? AND user_id=? AND is_read=0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAsUnread(int notificationId, int userId) {
        String sql =
            "UPDATE Notification_Recipients SET is_read=0, read_at=NULL "
          + "WHERE notification_id=? AND user_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. MARK ALL AS READ FOR USER
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markAllAsReadForUser(int userId) {
        String sql =
            "UPDATE Notification_Recipients SET is_read=1, read_at=GETDATE() "
          + "WHERE user_id=? AND is_read=0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. FIND BY ID (header only – no recipient context)
    // ─────────────────────────────────────────────────────────────────────────
    public Notification findById(int notificationId) {
        String sql =
            NOTIF_SELECT
          + "FROM Notifications n "
          + "WHERE n.notification_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10. UPDATE NOTIFICATION HEADER
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateNotification(Notification n) {
        String sql =
            "UPDATE Notifications "
          + "SET title=?, content=?, type=?, related_type=?, related_id=?, "
          + "    priority=?, status=?, scheduled_at=?, expires_at=? "
          + "WHERE notification_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getContent());
            ps.setString(3, n.getType());
            ps.setString(4, n.getRelatedType());
            ps.setObject(5, n.getRelatedId(), Types.INTEGER);
            ps.setString(6, n.getPriority() != null ? n.getPriority() : "NORMAL");
            ps.setString(7, n.getStatus()   != null ? n.getStatus()   : "SENT");
            ps.setObject(8, n.getScheduledAt() != null
                    ? Timestamp.valueOf(n.getScheduledAt()) : null, Types.TIMESTAMP);
            ps.setObject(9, n.getExpiresAt() != null
                    ? Timestamp.valueOf(n.getExpiresAt()) : null, Types.TIMESTAMP);
            ps.setInt(10, n.getNotificationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11. FIND ALL – PAGED (admin/manager view)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findAll(int offset, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql =
            NOTIF_SELECT
          + "FROM Notifications n "
          + "ORDER BY n.created_at DESC "
          + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Notifications";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12. LIST RECIPIENT USER IDS FOR A NOTIFICATION
    // ─────────────────────────────────────────────────────────────────────────
    public List<Integer> findRecipientUserIds(int notificationId) {
        List<Integer> ids = new ArrayList<>();
        String sql =
            "SELECT user_id FROM Notification_Recipients "
          + "WHERE notification_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("user_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    /** Maps a Notifications row (no recipient JOIN columns). */
    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        n.setRelatedType(rs.getString("related_type"));

        int relId = rs.getInt("related_id");
        if (!rs.wasNull()) n.setRelatedId(relId);

        n.setPriority(rs.getString("priority"));
        n.setStatus(rs.getString("status"));

        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) n.setCreatedBy(createdBy);

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) n.setCreatedAt(cat.toLocalDateTime());

        Timestamp sat = rs.getTimestamp("scheduled_at");
        if (sat != null) n.setScheduledAt(sat.toLocalDateTime());

        Timestamp eat = rs.getTimestamp("expires_at");
        if (eat != null) n.setExpiresAt(eat.toLocalDateTime());

        return n;
    }

    /**
     * Maps a Notifications + Notification_Recipients JOIN row.
     * The caller's SELECT must include: user_id, is_read, read_at from nr.
     */
    private Notification mapRowWithRecipient(ResultSet rs) throws SQLException {
        Notification n = mapRow(rs);

        NotificationRecipient nr = new NotificationRecipient();
        nr.setNotificationId(n.getNotificationId());
        nr.setUserId(rs.getInt("user_id"));
        nr.setRead(rs.getBoolean("is_read"));

        Timestamp readAt = rs.getTimestamp("read_at");
        if (readAt != null) nr.setReadAt(readAt.toLocalDateTime());

        List<NotificationRecipient> recipients = new ArrayList<>();
        recipients.add(nr);
        n.setNrs(recipients);

        return n;
    }
}