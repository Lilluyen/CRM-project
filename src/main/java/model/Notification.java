package model;

import java.time.LocalDateTime;

public class Notification {
    private int notificationId;
    private String title;
    private String content;
    private String type;
    private String relatedType;          // e.g. "Task", "Lead", "Deal" ...
    private Integer relatedId;
    private LocalDateTime createdAt;

    public Notification() {
    }

    public Notification(int notificationId, String title, String content,
                        String type, String relatedType, Integer relatedId,
                        LocalDateTime createdAt) {
        this.notificationId = notificationId;
        this.title = title;
        this.content = content;
        this.type = type;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.createdAt = createdAt;
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
}