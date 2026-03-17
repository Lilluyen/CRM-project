/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;
import java.util.List;
/**
 *
 * @author Pham Minh Quan
 */
public class Task {
    private Integer taskId;
    private String title;
    private String description;
    private String status;               // DEFAULT 'Pending'
    private String priority;             // DEFAULT 'Medium'
    private LocalDateTime dueDate;       // DATETIME in DB
    private LocalDateTime startDate;     // DATETIME in DB
    private LocalDateTime completedAt;   // DATETIME in DB
    private Integer progress;            // DEFAULT 0
    private User createdBy;           // FK -> Users(user_id)
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<TaskAssignee> assignees;     // List of users assigned to this task
    private List<TaskHistory> historys;
    public Task() {
    }

    public Task(Integer taskId, String title, String description, String status, String priority, LocalDateTime dueDate, LocalDateTime startDate, LocalDateTime completedAt, Integer progress, User createdBy, LocalDateTime createdAt, LocalDateTime updatedAt, List<TaskAssignee> assignees, List<TaskHistory> historys) {
        this.taskId = taskId;
        this.title = title;
        this.description = description;
        this.status = status;
        this.priority = priority;
        this.dueDate = dueDate;
        this.startDate = startDate;
        this.completedAt = completedAt;
        this.progress = progress;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.assignees = assignees;
        this.historys = historys;
    }

    

    public Integer getTaskId() { return taskId; }
    public void setTaskId(Integer taskId) { this.taskId = taskId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public Integer getProgress() { return progress; }
    public void setProgress(Integer progress) { this.progress = progress; }

    public User getCreatedBy() { return createdBy; }
    public void setCreatedBy(User createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public List<TaskAssignee> getassignees() { return assignees; }
    public void setassignees(List<TaskAssignee> assignees) { this.assignees = assignees; }

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
    
    
}
