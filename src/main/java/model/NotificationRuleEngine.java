package model;

import java.time.LocalDateTime;

/**
 * ✅ MODEL MỚI - Maps to [dbo].[Notification_Rule_Engine] table.
 */
public class NotificationRuleEngine {
    private int ruleId;                          // rule_id INT IDENTITY PK
    private String ruleName;                     // rule_name NVARCHAR(100) NOT NULL
    private String ruleType;                     // rule_type VARCHAR(30) NOT NULL
    private String description;                  // description NVARCHAR(500) NULL
    private String triggerEvent;                 // trigger_event VARCHAR(50) NULL
    private String entityType;                   // entity_type VARCHAR(50) NULL
    private String conditionField;               // condition_field VARCHAR(50) NULL
    private String conditionOperator;            // condition_operator VARCHAR(30) NULL
    private Integer conditionValue;              // condition_value INT NULL
    private String conditionUnit;                // condition_unit VARCHAR(20) NULL
    private String cronExpression;               // cron_expression VARCHAR(100) NULL
    private LocalDateTime nextRunAt;             // next_run_at DATETIME NULL
    private LocalDateTime lastRunAt;             // last_run_at DATETIME NULL
    private String notificationTitleTemplate;    // notification_title_template NVARCHAR(200) NULL
    private String notificationContentTemplate;  // notification_content_template NVARCHAR(MAX) NULL
    private String notificationType;             // notification_type VARCHAR(30) NULL
    private String notificationPriority;         // notification_priority VARCHAR(20) NOT NULL
    private String recipientType;                // recipient_type VARCHAR(30) NULL
    private Integer recipientUserId;             // recipient_user_id INT NULL (FK -> Users)
    private Integer escalateAfterMinutes;        // escalate_after_minutes INT NULL
    private Integer escalateToUserId;            // escalate_to_user_id INT NULL (FK -> Users)
    private boolean isActive;                    // is_active BIT NOT NULL
    private Integer createdBy;                   // created_by INT NULL (FK -> Users)
    private LocalDateTime createdAt;             // created_at DATETIME NOT NULL
    private LocalDateTime updatedAt;             // updated_at DATETIME NULL

    public NotificationRuleEngine() {}

    public int getRuleId() { return ruleId; }
    public void setRuleId(int ruleId) { this.ruleId = ruleId; }

    public String getRuleName() { return ruleName; }
    public void setRuleName(String ruleName) { this.ruleName = ruleName; }

    public String getRuleType() { return ruleType; }
    public void setRuleType(String ruleType) { this.ruleType = ruleType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTriggerEvent() { return triggerEvent; }
    public void setTriggerEvent(String triggerEvent) { this.triggerEvent = triggerEvent; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public String getConditionField() { return conditionField; }
    public void setConditionField(String conditionField) { this.conditionField = conditionField; }

    public String getConditionOperator() { return conditionOperator; }
    public void setConditionOperator(String conditionOperator) { this.conditionOperator = conditionOperator; }

    public Integer getConditionValue() { return conditionValue; }
    public void setConditionValue(Integer conditionValue) { this.conditionValue = conditionValue; }

    public String getConditionUnit() { return conditionUnit; }
    public void setConditionUnit(String conditionUnit) { this.conditionUnit = conditionUnit; }

    public String getCronExpression() { return cronExpression; }
    public void setCronExpression(String cronExpression) { this.cronExpression = cronExpression; }

    public LocalDateTime getNextRunAt() { return nextRunAt; }
    public void setNextRunAt(LocalDateTime nextRunAt) { this.nextRunAt = nextRunAt; }

    public LocalDateTime getLastRunAt() { return lastRunAt; }
    public void setLastRunAt(LocalDateTime lastRunAt) { this.lastRunAt = lastRunAt; }

    public String getNotificationTitleTemplate() { return notificationTitleTemplate; }
    public void setNotificationTitleTemplate(String notificationTitleTemplate) { this.notificationTitleTemplate = notificationTitleTemplate; }

    public String getNotificationContentTemplate() { return notificationContentTemplate; }
    public void setNotificationContentTemplate(String notificationContentTemplate) { this.notificationContentTemplate = notificationContentTemplate; }

    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String notificationType) { this.notificationType = notificationType; }

    public String getNotificationPriority() { return notificationPriority; }
    public void setNotificationPriority(String notificationPriority) { this.notificationPriority = notificationPriority; }

    public String getRecipientType() { return recipientType; }
    public void setRecipientType(String recipientType) { this.recipientType = recipientType; }

    public Integer getRecipientUserId() { return recipientUserId; }
    public void setRecipientUserId(Integer recipientUserId) { this.recipientUserId = recipientUserId; }

    public Integer getEscalateAfterMinutes() { return escalateAfterMinutes; }
    public void setEscalateAfterMinutes(Integer escalateAfterMinutes) { this.escalateAfterMinutes = escalateAfterMinutes; }

    public Integer getEscalateToUserId() { return escalateToUserId; }
    public void setEscalateToUserId(Integer escalateToUserId) { this.escalateToUserId = escalateToUserId; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}