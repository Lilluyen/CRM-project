package model;

import java.time.LocalDateTime;

/**
 * Maps to [dbo].[Task_Assignees] table.
 * Represents the many-to-many relationship between Tasks and Users.
 */
public class TaskAssignee {
    private int taskId;                  // FK -> Tasks(task_id)
    private int userId;                  // FK -> Users(user_id)
    private LocalDateTime assignedAt;

    public TaskAssignee() {
    }

    public TaskAssignee(int taskId, int userId, LocalDateTime assignedAt) {
        this.taskId = taskId;
        this.userId = userId;
        this.assignedAt = assignedAt;
    }

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }
}