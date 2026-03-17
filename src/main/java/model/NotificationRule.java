package model;

/**
 * Adapter model cho UI/Controller - tương thích với code cũ.
 * Thực chất ánh xạ từ NotificationRuleEngine.
 *
 * Lưu ý: Model này chỉ dùng cho presentation layer.
 * Business logic nên dùng trực tiếp NotificationRuleEngine.
 */
public class NotificationRule {
    private int ruleId;
    private String ruleName;
    private String ruleType;
    private String description;
    private String triggerEvent;
    private String entityType;
    private String conditionField;
    private String conditionOperator;
    private Integer conditionValue;
    private String conditionUnit;
    private String cronExpression;
    private java.time.LocalDateTime nextRunAt;
    private java.time.LocalDateTime lastRunAt;
    private String notificationTitleTemplate;
    private String notificationContentTemplate;
    private String notificationType;
    private String notificationPriority;
    private String recipientType;
    private Integer recipientUserId;
    private Integer escalateAfterMinutes;
    private Integer escalateToUserId;
    private boolean isActive;
    private Integer createdBy;
    private java.time.LocalDateTime createdAt;
    private java.time.LocalDateTime updatedAt;

    // Field từ UI cũ - ánh xạ sang NotificationRuleEngine
    private int notificationId;  // FK to Notifications table

    public NotificationRule() {}

    // Copy constructor từ NotificationRuleEngine
    public NotificationRule(NotificationRuleEngine engine) {
        if (engine == null) return;
        this.ruleId = engine.getRuleId();
        this.ruleName = engine.getRuleName();
        this.ruleType = engine.getRuleType();
        this.description = engine.getDescription();
        this.triggerEvent = engine.getTriggerEvent();
        this.entityType = engine.getEntityType();
        this.conditionField = engine.getConditionField();
        this.conditionOperator = engine.getConditionOperator();
        this.conditionValue = engine.getConditionValue();
        this.conditionUnit = engine.getConditionUnit();
        this.cronExpression = engine.getCronExpression();
        this.nextRunAt = engine.getNextRunAt();
        this.lastRunAt = engine.getLastRunAt();
        this.notificationTitleTemplate = engine.getNotificationTitleTemplate();
        this.notificationContentTemplate = engine.getNotificationContentTemplate();
        this.notificationType = engine.getNotificationType();
        this.notificationPriority = engine.getNotificationPriority();
        this.recipientType = engine.getRecipientType();
        this.recipientUserId = engine.getRecipientUserId();
        this.escalateAfterMinutes = engine.getEscalateAfterMinutes();
        this.escalateToUserId = engine.getEscalateToUserId();
        this.isActive = engine.isActive();
        this.createdBy = engine.getCreatedBy();
        this.createdAt = engine.getCreatedAt();
        this.updatedAt = engine.getUpdatedAt();
    }

    // Convert sang NotificationRuleEngine
    public NotificationRuleEngine toEngine() {
        NotificationRuleEngine engine = new NotificationRuleEngine();
        engine.setRuleId(this.ruleId);
        engine.setRuleName(this.ruleName);
        engine.setRuleType(this.ruleType);
        engine.setDescription(this.description);
        engine.setTriggerEvent(this.triggerEvent);
        engine.setEntityType(this.entityType);
        engine.setConditionField(this.conditionField);
        engine.setConditionOperator(this.conditionOperator);
        engine.setConditionValue(this.conditionValue);
        engine.setConditionUnit(this.conditionUnit);
        engine.setCronExpression(this.cronExpression);
        engine.setNextRunAt(this.nextRunAt);
        engine.setLastRunAt(this.lastRunAt);
        engine.setNotificationTitleTemplate(this.notificationTitleTemplate);
        engine.setNotificationContentTemplate(this.notificationContentTemplate);
        engine.setNotificationType(this.notificationType);
        engine.setNotificationPriority(this.notificationPriority);
        engine.setRecipientType(this.recipientType);
        engine.setRecipientUserId(this.recipientUserId);
        engine.setEscalateAfterMinutes(this.escalateAfterMinutes);
        engine.setEscalateToUserId(this.escalateToUserId);
        engine.setActive(this.isActive);
        engine.setCreatedBy(this.createdBy);
        engine.setCreatedAt(this.createdAt);
        engine.setUpdatedAt(this.updatedAt);
        return engine;
    }

    // Getters and Setters
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

    public java.time.LocalDateTime getNextRunAt() { return nextRunAt; }
    public void setNextRunAt(java.time.LocalDateTime nextRunAt) { this.nextRunAt = nextRunAt; }

    public java.time.LocalDateTime getLastRunAt() { return lastRunAt; }
    public void setLastRunAt(java.time.LocalDateTime lastRunAt) { this.lastRunAt = lastRunAt; }

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

    public java.time.LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.LocalDateTime createdAt) { this.createdAt = createdAt; }

    public java.time.LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(java.time.LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // For UI compatibility - maps notificationId
    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }
}
