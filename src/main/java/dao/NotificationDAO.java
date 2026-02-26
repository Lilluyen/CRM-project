package dao;

import model.Notification;
import model.NotificationStatus;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    private final Connection connection;

    public NotificationDAO(Connection connection) {
        this.connection = connection;
    }

    public boolean insert(Notification notification) {
        String sql = "INSERT INTO Notifications (user_id, title, content, type, is_read, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notification.getUserId());
            ps.setString(2, notification.getTitle());
            ps.setString(3, notification.getContent());
            ps.setString(4, notification.getType());
            ps.setBoolean(5, notification.isRead());
            ps.setTimestamp(6, Timestamp.valueOf(notification.getCreatedAt() != null ? notification.getCreatedAt() : LocalDateTime.now()));
            int r = ps.executeUpdate();
            if (r > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        notification.setNotificationId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> findByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM Notifications WHERE user_id = ? ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = map(rs);
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Notification> findUnreadByUser(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM Notifications WHERE user_id = ? AND (is_read = 0 OR is_read = false) ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = map(rs);
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE Notifications SET is_read = 1 WHERE notification_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        boolean isRead = false;
        try {
            isRead = rs.getBoolean("is_read");
        } catch (SQLException ignored) {
        }
        n.setRead(isRead);
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) n.setCreatedAt(ts.toLocalDateTime());
        return n;
    }
}
