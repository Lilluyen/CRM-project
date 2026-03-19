package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Task_Assignees] table.
 */
public class TaskAssignee {
    private int taskId;                  // task_id INT NOT NULL -> Tasks(task_id)
    private User user;                   // user_id INT NOT NULL -> Users(user_id)
    private LocalDateTime assignedAt;    // assigned_at DATETIME NOT NULL
    private Integer assignedBy;          // assigned_by INT -> Users(user_id)
    private boolean isPrimary;           // is_primary BIT NOT NULL
    private LocalDateTime removedAt;     // removed_at DATETIME NULL
    private boolean isActive;            // ✅ THÊM MỚI - is_active BIT NOT NULL

    public TaskAssignee() {}

    public TaskAssignee(int taskId, User user, LocalDateTime assignedAt,
                        Integer assignedBy, boolean isPrimary,
                        LocalDateTime removedAt, boolean isActive) {
        this.taskId = taskId;
        this.user = user;
        this.assignedAt = assignedAt;
        this.assignedBy = assignedBy;
        this.isPrimary = isPrimary;
        this.removedAt = removedAt;
        this.isActive = isActive;
    }

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }

    public Integer getAssignedBy() { return assignedBy; }
    public void setAssignedBy(Integer assignedBy) { this.assignedBy = assignedBy; }

    public boolean isPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    public LocalDateTime getRemovedAt() { return removedAt; }
    public void setRemovedAt(LocalDateTime removedAt) { this.removedAt = removedAt; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}