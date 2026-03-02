package model;

import java.time.LocalDateTime;
import model.User;
/**
 * Maps to [dbo].[Task_Assignees] table.
 * Represents the many-to-many relationship between Tasks and Users.
 */
public class TaskAssignee {
    private int taskId;                  // FK -> Tasks(task_id)
    private User user;                  // FK -> Users(user_id)
    private LocalDateTime assignedAt;

    public TaskAssignee() {
    }

    public TaskAssignee(int taskId, User user, LocalDateTime assignedAt) {
        this.taskId = taskId;
        this.user = user;
        this.assignedAt = assignedAt;
    }

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }
}