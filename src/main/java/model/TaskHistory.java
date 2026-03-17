package model;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Maps to [dbo].[Task_History] table.
 */
public class TaskHistory {
    private int historyId;
    private int taskId;
    private int changedBy;
    private LocalDateTime changedAt;

    // ✅ THÊM MỚI - có trong DB nhưng thiếu trong model cũ
    private String action;               // action VARCHAR(50) NULL
    private String note;                 // note NVARCHAR(500) NULL
    private String changerName;          // từ JOIN với User (không có trong DB, chỉ để hiển thị)
    private List<TaskHistoryDetail> details;

    public TaskHistory() {}

    public TaskHistory(int historyId, int taskId, int changedBy, LocalDateTime changedAt,
                       String action, String note, List<TaskHistoryDetail> details) {
        this.historyId = historyId;
        this.taskId = taskId;
        this.changedBy = changedBy;
        this.changedAt = changedAt;
        this.action = action;
        this.note = note;
        this.details = details;
    }

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }

    public int getChangedBy() { return changedBy; }
    public void setChangedBy(int changedBy) { this.changedBy = changedBy; }

    public LocalDateTime getChangedAt() { return changedAt; }
    public void setChangedAt(LocalDateTime changedAt) { this.changedAt = changedAt; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public List<TaskHistoryDetail> getDetails() { return details; }
    public void setDetails(List<TaskHistoryDetail> details) { this.details = details; }

    public String getChangerName() { return changerName; }
    public void setChangerName(String changerName) { this.changerName = changerName; }
}