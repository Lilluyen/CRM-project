package model;

import java.time.LocalDateTime;

/**
 * Model for Task_Comments – acts as both a comment and a work-item/subtask.
 *
 * Key fields:
 *  assignedTo   – user_id of the tagged supporter (nullable)
 *  isCompleted  – work-item done flag
 *  completedAt  – timestamp when completed
 *  authorName   – transient, resolved by DAO JOIN
 *  assignedName – transient, resolved by DAO JOIN
 */
public class TaskComment {

    private Integer       commentId;
    private int           taskId;
    private int           createdBy;           // creator / tagger
    private String        content;
    private Integer       parentCommentId;  // null = root work item
    private Integer       assignedTo;       // tagged supporter (nullable)
    private boolean       isCompleted;
    private LocalDateTime completedAt;
    private boolean       isDeleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Transient display fields (populated by DAO JOIN) ─────────────────────
    private String authorName;    // full_name or username of userId
    private String assignedName;  // full_name or username of assignedTo

    // ── Getters / Setters ────────────────────────────────────────────────────

    public Integer getCommentId()              { return commentId; }
    public void    setCommentId(Integer v)     { this.commentId = v; }

    public int     getTaskId()                 { return taskId; }
    public void    setTaskId(int v)            { this.taskId = v; }

    public int     getCreatedBy()                 { return createdBy; }
    public void    setCreatedBy(int v)            { this.createdBy = v; }

    public String  getContent()                { return content; }
    public void    setContent(String v)        { this.content = v; }

    public Integer getParentCommentId()        { return parentCommentId; }
    public void    setParentCommentId(Integer v){ this.parentCommentId = v; }

    public Integer getAssignedTo()             { return assignedTo; }
    public void    setAssignedTo(Integer v)    { this.assignedTo = v; }

    public boolean isCompleted()               { return isCompleted; }
    public void    setCompleted(boolean v)     { this.isCompleted = v; }

    public LocalDateTime getCompletedAt()      { return completedAt; }
    public void    setCompletedAt(LocalDateTime v){ this.completedAt = v; }

    public boolean isDeleted()                 { return isDeleted; }
    public void    setDeleted(boolean v)       { this.isDeleted = v; }

    public LocalDateTime getCreatedAt()        { return createdAt; }
    public void    setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()        { return updatedAt; }
    public void    setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    public String  getAuthorName()             { return authorName; }
    public void    setAuthorName(String v)     { this.authorName = v; }

    public String  getAssignedName()           { return assignedName; }
    public void    setAssignedName(String v)   { this.assignedName = v; }
}
