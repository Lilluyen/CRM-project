package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Activities] table.
 */
public class Activity {
    private Integer activityId;     // activity_id INT IDENTITY PK
    private String relatedType;     // related_type VARCHAR(50)
    private Integer relatedId;      // related_id INT
    private String activityType;    // activity_type VARCHAR(50)
    private String subject;         // subject NVARCHAR(100)
    private String description;     // description NVARCHAR(MAX)
    private User createdBy;         // created_by INT -> Users(user_id)
    private LocalDateTime activityDate; // activity_date DATETIME
    private LocalDateTime createdAt;    // created_at DATETIME
    private String sourceType;      // source_type VARCHAR(50)
    private Integer sourceId;       // source_id INT
    private User performedBy;       // performed_by INT -> Users(user_id)
    private String metadata;        // metadata NVARCHAR(MAX)
    private LocalDateTime updatedAt; // updated_at DATETIME
    private String entityType;      // entity_type VARCHAR(50) - used by application code
    private Integer entityId;       // entity_id INT - used by application code

    public Activity() {}

    public Activity(Integer activityId, String relatedType, Integer relatedId,
                    String activityType, String subject, String description,
                    User createdBy, LocalDateTime activityDate, LocalDateTime createdAt,
                    String sourceType, Integer sourceId, User performedBy,
                    String metadata, LocalDateTime updatedAt,
                    String entityType, Integer entityId) {
        this.activityId = activityId;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.activityType = activityType;
        this.subject = subject;
        this.description = description;
        this.createdBy = createdBy;
        this.activityDate = activityDate;
        this.createdAt = createdAt;
        this.sourceType = sourceType;
        this.sourceId = sourceId;
        this.performedBy = performedBy;
        this.metadata = metadata;
        this.updatedAt = updatedAt;
        this.entityType = entityType;
        this.entityId = entityId;
    }

    public Integer getActivityId() { return activityId; }
    public void setActivityId(Integer activityId) { this.activityId = activityId; }

    public String getRelatedType() { return relatedType; }
    public void setRelatedType(String relatedType) { this.relatedType = relatedType; }

    public Integer getRelatedId() { return relatedId; }
    public void setRelatedId(Integer relatedId) { this.relatedId = relatedId; }

    public String getActivityType() { return activityType; }
    public void setActivityType(String activityType) { this.activityType = activityType; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public User getCreatedBy() { return createdBy; }
    public void setCreatedBy(User createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getActivityDate() { return activityDate; }
    public void setActivityDate(LocalDateTime activityDate) { this.activityDate = activityDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getSourceType() { return sourceType; }
    public void setSourceType(String sourceType) { this.sourceType = sourceType; }

    public Integer getSourceId() { return sourceId; }
    public void setSourceId(Integer sourceId) { this.sourceId = sourceId; }

    public User getPerformedBy() { return performedBy; }
    public void setPerformedBy(User performedBy) { this.performedBy = performedBy; }

    public String getMetadata() { return metadata; }
    public void setMetadata(String metadata) { this.metadata = metadata; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public Integer getEntityId() { return entityId; }
    public void setEntityId(Integer entityId) { this.entityId = entityId; }
}