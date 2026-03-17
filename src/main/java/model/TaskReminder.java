package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Task_Reminders] table.
 *
 * Stores reminder schedules for tasks:
 *   - Remind before deadline (e.g., 1 day before, 2 hours before)
 *   - One-time or recurring reminders
 */
public class TaskReminder {
    private int reminderId;              // reminder_id INT IDENTITY PK
    private int taskId;                  // task_id INT NOT NULL -> Tasks(task_id)
    private int remindBeforeValue;       // remind_before_value INT NOT NULL
    private String remindBeforeUnit;     // remind_before_unit VARCHAR(20) NOT NULL (minute, hour, day)
    private LocalDateTime remindAt;      // remind_at DATETIME NOT NULL
    private boolean isSent;              // is_sent BIT NOT NULL DEFAULT 0
    private LocalDateTime sentAt;        // sent_at DATETIME NULL
    private Integer createdBy;           // created_by INT NULL -> Users(user_id)
    private LocalDateTime createdAt;     // created_at DATETIME NOT NULL DEFAULT GETDATE()

    public TaskReminder() {}

    public TaskReminder(int reminderId, int taskId, int remindBeforeValue,
                       String remindBeforeUnit, LocalDateTime remindAt,
                       boolean isSent, LocalDateTime sentAt,
                       Integer createdBy, LocalDateTime createdAt) {
        this.reminderId = reminderId;
        this.taskId = taskId;
        this.remindBeforeValue = remindBeforeValue;
        this.remindBeforeUnit = remindBeforeUnit;
        this.remindAt = remindAt;
        this.isSent = isSent;
        this.sentAt = sentAt;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public int getReminderId() { return reminderId; }
    public void setReminderId(int reminderId) { this.reminderId = reminderId; }

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public int getRemindBeforeValue() { return remindBeforeValue; }
    public void setRemindBeforeValue(int remindBeforeValue) { this.remindBeforeValue = remindBeforeValue; }

    public String getRemindBeforeUnit() { return remindBeforeUnit; }
    public void setRemindBeforeUnit(String remindBeforeUnit) { this.remindBeforeUnit = remindBeforeUnit; }

    public LocalDateTime getRemindAt() { return remindAt; }
    public void setRemindAt(LocalDateTime remindAt) { this.remindAt = remindAt; }

    public boolean isSent() { return isSent; }
    public void setSent(boolean sent) { isSent = sent; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
