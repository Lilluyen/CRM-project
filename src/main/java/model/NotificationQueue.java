package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Notification_Queue] table.
 *
 * Stores queued notifications for async processing with retry logic.
 */
public class NotificationQueue {
    private int queueId;                 // queue_id INT IDENTITY PK
    private Integer notificationId;      // notification_id INT NULL -> Notifications(notification_id)

    // Self-contained fields (if no notification_id)
    private String title;               // title NVARCHAR(200) NOT NULL
    private String content;             // content NVARCHAR(MAX) NULL
    private String type;                // type VARCHAR(30) NULL
    private String relatedType;         // related_type VARCHAR(50) NULL
    private Integer relatedId;          // related_id INT NULL

    private int recipientUserId;        // recipient_user_id INT NOT NULL -> Users(user_id)
    private String status;              // status VARCHAR(20) NOT NULL (pending, sent, failed, cancelled)
    private String priority;             // priority VARCHAR(20) NOT NULL (low, normal, high, urgent)
    private LocalDateTime scheduledAt;  // scheduled_at DATETIME NOT NULL DEFAULT GETDATE()
    private LocalDateTime sentAt;       // sent_at DATETIME NULL
    private LocalDateTime failedAt;     // failed_at DATETIME NULL
    private int retryCount;             // retry_count INT NOT NULL DEFAULT 0
    private int maxRetries;             // max_retries INT NOT NULL DEFAULT 3
    private String errorMessage;        // error_message NVARCHAR(500) NULL
    private LocalDateTime createdAt;    // created_at DATETIME NOT NULL DEFAULT GETDATE()

    public NotificationQueue() {}

    public int getQueueId() { return queueId; }
    public void setQueueId(int queueId) { this.queueId = queueId; }

    public Integer getNotificationId() { return notificationId; }
    public void setNotificationId(Integer notificationId) { this.notificationId = notificationId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getRelatedType() { return relatedType; }
    public void setRelatedType(String relatedType) { this.relatedType = relatedType; }

    public Integer getRelatedId() { return relatedId; }
    public void setRelatedId(Integer relatedId) { this.relatedId = relatedId; }

    public int getRecipientUserId() { return recipientUserId; }
    public void setRecipientUserId(int recipientUserId) { this.recipientUserId = recipientUserId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public LocalDateTime getScheduledAt() { return scheduledAt; }
    public void setScheduledAt(LocalDateTime scheduledAt) { this.scheduledAt = scheduledAt; }

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