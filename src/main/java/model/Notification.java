package model;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Maps to [dbo].[Notifications] table.
 *
 * ❌ ĐÃ XÓA: List<NotificationRecipient> nrs — không phải cột DB,
 *    nếu cần thì load riêng qua DAO, không nên nhúng vào model thuần.
 */
public class Notification {
    private int notificationId;
    private String title;
    private String content;
    private String type;
    private String relatedType;
    private Integer relatedId;
    private LocalDateTime createdAt;

    // ✅ THÊM MỚI - có trong DB nhưng thiếu trong model cũ
    private String priority;             // priority VARCHAR(20) NOT NULL
    private String status;               // status VARCHAR(20) NOT NULL
    private LocalDateTime scheduledAt;  // scheduled_at DATETIME NULL
    private Integer createdBy;          // created_by INT NULL (FK -> Users)
    private LocalDateTime expiresAt;    // expires_at DATETIME NULL
    List<NotificationRecipient> nrs; // Not a DB column, but useful for application logic
    public Notification() {}

    public Notification(int notificationId, String title, String content,
                        String type, String relatedType, Integer relatedId,
                        LocalDateTime createdAt, String priority, String status,
                        LocalDateTime scheduledAt, Integer createdBy, LocalDateTime expiresAt) {
        this.notificationId = notificationId;
        this.title = title;
        this.content = content;
        this.type = type;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.createdAt = createdAt;
        this.priority = priority;
        this.status = status;
        this.scheduledAt = scheduledAt;
        this.createdBy = createdBy;
        this.expiresAt = expiresAt;
    }

    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }

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

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getScheduledAt() { return scheduledAt; }
    public void setScheduledAt(LocalDateTime scheduledAt) { this.scheduledAt = scheduledAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public List<NotificationRecipient> getNrs() { return nrs; }
    public void setNrs(List<NotificationRecipient> nrs) { this.nrs = nrs; }
}