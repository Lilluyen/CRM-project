package model;

import java.time.LocalDateTime;

public class CustomerNote {

    private Integer noteId;
    private Integer customerId;
    private String note;
    private Integer createdBy;
    private LocalDateTime createdAt;

    public CustomerNote(Integer customerId, String note, Integer createdBy) {
        this.customerId = customerId;
        this.note = note;
        this.createdBy = createdBy;
    }

    public Integer getNoteId() {
        return noteId;
    }

    public void setNoteId(Integer noteId) {
        this.noteId = noteId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
