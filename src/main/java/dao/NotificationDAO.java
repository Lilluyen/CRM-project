package dao;

import model.Notification;
import model.NotificationRecipient;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAO – aligned with CRM_System two-table schema:
 *
 * Notifications            : notification_id, title, content, type,
 *                            related_type, related_id, created_at
 * Notification_Recipients  : notification_id, user_id, is_read, read_at
 *
 * Usage pattern:
 *   1. insertNotification()         → creates the shared Notification row
 *   2. addRecipient()               → creates Notification_Recipients row(s)
 *   3. getUnreadForUser()           → JOIN query for the header badge
 *   4. markAsRead()                 → sets is_read=1 for one recipient row
 *   5. markAllAsReadForUser()       → bulk mark
 */
public class NotificationDAO {

    private final Connection connection;

    public NotificationDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. INSERT NOTIFICATION (header row only – no recipient yet)
    // ─────────────────────────────────────────────────────────────────────────
    public int insertNotification(Notification n) {
        String sql = "INSERT INTO Notifications (title, content, type, related_type, related_id) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getContent());
            ps.setString(3, n.getType());
            ps.setString(4, n.getRelatedType());
            if (n.getRelatedId() != null)
                ps.setInt(5, n.getRelatedId());
            else
                ps.setNull(5, Types.INTEGER);

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
    // 2. ADD RECIPIENT
    // ─────────────────────────────────────────────────────────────────────────
    public boolean addRecipient(int notificationId, int userId) {
        String sql = "INSERT INTO Notification_Recipients (notification_id, user_id) VALUES (?, ?)";
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
    // 3. GET ALL NOTIFICATIONS FOR A USER (JOIN)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.notification_id, n.title, n.content, n.type, "
                   + "       n.related_type, n.related_id, n.created_at, "
                   + "       nr.user_id, nr.is_read, nr.read_at "
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
    // 4. GET UNREAD NOTIFICATIONS FOR A USER
    // ─────────────────────────────────────────────────────────────────────────
    public List<Notification> findUnreadByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.notification_id, n.title, n.content, n.type, "
                   + "       n.related_type, n.related_id, n.created_at, "
                   + "       nr.user_id, nr.is_read, nr.read_at "
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
    // 5. COUNT UNREAD (for badge)
    // ─────────────────────────────────────────────────────────────────────────
    public int countUnreadByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM Notification_Recipients "
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
    // 6. MARK SINGLE NOTIFICATION AS READ
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE Notification_Recipients SET is_read=1, read_at=GETDATE() "
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
    // 7. MARK ALL AS READ FOR USER
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markAllAsReadForUser(int userId) {
        String sql = "UPDATE Notification_Recipients SET is_read=1, read_at=GETDATE() "
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
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Maps a Notification row (without recipient context)
     */
    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        n.setRelatedType(rs.getString("related_type"));
        
        int relId = rs.getInt("related_id");
        if (!rs.wasNull()) n.setRelatedId(relId);

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) n.setCreatedAt(cat.toLocalDateTime());

        return n;
    }

    /**
     * Maps a Notification row WITH recipient context (for JOINs with Notification_Recipients).
     * Creates a Notification with a single NotificationRecipient object embedded.
     */
    private Notification mapRowWithRecipient(ResultSet rs) throws SQLException {
        Notification n = mapRow(rs);
        
        // Create recipient object from the JOIN columns
        NotificationRecipient nr = new NotificationRecipient();
        nr.setNotificationId(rs.getInt("notification_id"));
        nr.setUserId(rs.getInt("user_id")); // This requires adding user_id to the SELECT
        nr.setRead(rs.getBoolean("is_read"));
        
        Timestamp readAt = rs.getTimestamp("read_at");
        if (readAt != null) nr.setReadAt(readAt.toLocalDateTime());
        
        // Create a list with this one recipient
        List<NotificationRecipient> recipients = new ArrayList<>();
        recipients.add(nr);
        n.setNrs(recipients);
        
        return n;
    }
}
