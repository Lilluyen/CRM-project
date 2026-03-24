package model;

import java.time.LocalDateTime;

public class CustomerMergeRequest {

    public enum Status {
        PENDING, APPROVED, REJECTED, MERGED
    }

    private Integer id;
    private Integer sourceId;       // customer bị xóa sau merge
    private Integer targetId;       // customer được giữ lại
    private Status status;
    private String fieldOverrides;  // JSON string: {"name":"source","phone":"target",...}
    private String reason;          // lý do người tạo điền
    private String rejectReason;    // lý do manager từ chối
    private Integer createdBy;
    private Integer reviewedBy;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;

    // ── Constructors ──────────────────────────────────────────────────────
    public CustomerMergeRequest() {
    }

    public CustomerMergeRequest(int sourceId, int targetId,
                                String fieldOverrides, String reason,
                                int createdBy) {
        this.sourceId = sourceId;
        this.targetId = targetId;
        this.fieldOverrides = fieldOverrides;
        this.reason = reason;
        this.createdBy = createdBy;
        this.status = Status.PENDING;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getSourceId() {
        return sourceId;
    }

    public void setSourceId(Integer sourceId) {
        this.sourceId = sourceId;
    }

    public Integer getTargetId() {
        return targetId;
    }

    public void setTargetId(Integer targetId) {
        this.targetId = targetId;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public String getFieldOverrides() {
        return fieldOverrides;
    }

    public void setFieldOverrides(String v) {
        this.fieldOverrides = v;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String v) {
        this.rejectReason = v;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Integer reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime v) {
        this.createdAt = v;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(LocalDateTime v) {
        this.reviewedAt = v;
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    public boolean isPending() {
        return Status.PENDING == status;
    }

    public boolean isMerged() {
        return Status.MERGED == status;
    }

    public boolean isRejected() {
        return Status.REJECTED == status;
    }
}