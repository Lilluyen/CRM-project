package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Notification_Recipients] table.
 * Tracks which users received a notification and whether they have read it.
 */
public class NotificationRecipient {
    private int notificationId;          // FK -> Notifications(notification_id)
    private int userId;                  // FK -> Users(user_id)
    private boolean isRead;              // BIT, DEFAULT 0
    private LocalDateTime readAt;

    public NotificationRecipient() {
    }

    public NotificationRecipient(int notificationId, int userId,
                                  boolean isRead, LocalDateTime readAt) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.isRead = isRead;
        this.readAt = readAt;
    }

    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }
}