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
public class TaskHistory {
    private int historyId;
    private int taskId;
    private int changedBy;
    private LocalDateTime changedAt;
    List<TaskHistoryDetail> details;
    public TaskHistory() {
    }

    public TaskHistory(int historyId, int taskId, int changedBy, LocalDateTime changedAt, List<TaskHistoryDetail> details) {
        this.historyId = historyId;
        this.taskId = taskId;
        this.changedBy = changedBy;
        this.changedAt = changedAt;
        this.details = details;
    }

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(int changedBy) {
        this.changedBy = changedBy;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }

    public List<TaskHistoryDetail> getDetails() {
        return details;
    }

    public void setDetails(List<TaskHistoryDetail> details) {
        this.details = details;
    }
    
}
