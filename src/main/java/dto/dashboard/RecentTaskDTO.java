/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto.dashboard;

import java.time.LocalDateTime;

public class RecentTaskDTO {
    private int taskId;
    private String title, status, priority, assigneeName, relatedName;
    private LocalDateTime dueDate;

    public int getTaskId() { return taskId; }
    public void setTaskId(int v) { this.taskId = v; }
    public String getTitle() { return title; }
    public void setTitle(String v) { this.title = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public String getPriority() { return priority; }
    public void setPriority(String v) { this.priority = v; }
    public String getAssigneeName() { return assigneeName; }
    public void setAssigneeName(String v) { this.assigneeName = v; }
    public String getRelatedName() { return relatedName; }
    public void setRelatedName(String v) { this.relatedName = v; }
    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime v) { this.dueDate = v; }
}
