package model;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Maps to [dbo].[Tasks] table.
 */
public class Task {
    private Integer taskId;              // task_id INT IDENTITY PK
    private String title;                // title NVARCHAR(200) NOT NULL
    private String description;          // description NVARCHAR(MAX)
    private String status;               // status VARCHAR(30) NOT NULL, DEFAULT 'Pending'
    private String priority;             // priority VARCHAR(20) NOT NULL, DEFAULT 'Medium'
    private LocalDateTime dueDate;       // due_date DATETIME
    private LocalDateTime startDate;     // start_date DATETIME
    private LocalDateTime completedAt;   // completed_at DATETIME
    private LocalDateTime cancelledAt;   // ✅ THÊM MỚI - cancelled_at DATETIME NULL
    private Integer progress;            // progress INT NOT NULL, DEFAULT 0
    private User createdBy;              // created_by INT NOT NULL -> Users(user_id)
    private LocalDateTime createdAt;     // created_at DATETIME NOT NULL
    private LocalDateTime updatedAt;     // updated_at DATETIME
    private String relatedType;          // related_type VARCHAR(50)
    private Integer relatedId;           // related_id INT

    private List<TaskAssignee> assignees;
    private List<TaskHistory> historys;

    public Task() {
    }

    public Task(Integer taskId, String title, String description, String status,
                String priority, LocalDateTime dueDate, LocalDateTime startDate,
                LocalDateTime completedAt, LocalDateTime cancelledAt,
                Integer progress, User createdBy,
                LocalDateTime createdAt, LocalDateTime updatedAt,
                String relatedType, Integer relatedId,
                List<TaskAssignee> assignees, List<TaskHistory> historys) {
        this.taskId = taskId;
        this.title = title;
        this.description = description;
        this.status = status;
        this.priority = priority;
        this.dueDate = dueDate;
        this.startDate = startDate;
        this.completedAt = completedAt;
        this.cancelledAt = cancelledAt;
        this.progress = progress;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.assignees = assignees;
        this.historys = historys;
    }

    public Integer getTaskId() {
        return taskId;
    }

    public void setTaskId(Integer taskId) {
        this.taskId = taskId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDateTime dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public LocalDateTime getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(LocalDateTime cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Integer getProgress() {
        return progress;
    }

    public void setProgress(Integer progress) {
        this.progress = progress;
    }

    public User getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(User createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getRelatedType() {
        return relatedType;
    }

    public void setRelatedType(String relatedType) {
        this.relatedType = relatedType;
    }

    public Integer getRelatedId() {
        return relatedId;
    }

    public void setRelatedId(Integer relatedId) {
        this.relatedId = relatedId;
    }

    public List<TaskAssignee> getAssignees() {
        return assignees;
    }

    public void setAssignees(List<TaskAssignee> assignees) {
        this.assignees = assignees;
    }

    public List<TaskHistory> getHistorys() {
        return historys;
    }

    public void setHistorys(List<TaskHistory> historys) {
        this.historys = historys;
    }

    public String getCompletedAtDate() {
        if (completedAt == null) {
            return "";
        }
        return completedAt.toLocalDate().toString();
    }
}