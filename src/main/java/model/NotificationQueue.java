package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Notification_Queue] table.
 *
 * ❌ ĐÃ XÓA các field không tồn tại trong DB:
 *    title, content, type, relatedType, relatedId, priority, scheduledAt
 */
public class NotificationQueue {
    private int queueId;                 // queue_id INT IDENTITY PK
    private Integer notificationId;      // notification_id INT NULL -> Notifications(notification_id)
    private int recipientUserId;         // recipient_user_id INT NOT NULL -> Users(user_id)
    private String status;               // status VARCHAR(20) NOT NULL
    private LocalDateTime sentAt;        // sent_at DATETIME NULL
    private LocalDateTime failedAt;      // failed_at DATETIME NULL
    private int retryCount;              // retry_count INT NOT NULL
    private int maxRetries;              // max_retries INT NOT NULL
    private String errorMessage;         // error_message NVARCHAR(500) NULL
    private LocalDateTime createdAt;     // created_at DATETIME NOT NULL

    public NotificationQueue() {}

    public NotificationQueue(int queueId, Integer notificationId, int recipientUserId,
                             String status, LocalDateTime sentAt, LocalDateTime failedAt,
                             int retryCount, int maxRetries, String errorMessage,
                             LocalDateTime createdAt) {
        this.queueId = queueId;
        this.notificationId = notificationId;
        this.recipientUserId = recipientUserId;
        this.status = status;
        this.sentAt = sentAt;
        this.failedAt = failedAt;
        this.retryCount = retryCount;
        this.maxRetries = maxRetries;
        this.errorMessage = errorMessage;
        this.createdAt = createdAt;
    }

    public int getQueueId() { return queueId; }
    public void setQueueId(int queueId) { this.queueId = queueId; }

    public Integer getNotificationId() { return notificationId; }
    public void setNotificationId(Integer notificationId) { this.notificationId = notificationId; }

    public int getRecipientUserId() { return recipientUserId; }
    public void setRecipientUserId(int recipientUserId) { this.recipientUserId = recipientUserId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public LocalDateTime getFailedAt() { return failedAt; }
    public void setFailedAt(LocalDateTime failedAt) { this.failedAt = failedAt; }

    public int getRetryCount() { return retryCount; }
    public void setRetryCount(int retryCount) { this.retryCount = retryCount; }

    public int getMaxRetries() { return maxRetries; }
    public void setMaxRetries(int maxRetries) { this.maxRetries = maxRetries; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}