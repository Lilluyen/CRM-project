package model;

import java.time.LocalDateTime;

public class CustomerSegment {

    private int segmentId;
    private String segmentName;
    private String criteriaLogic;
    private String segmentType;
    private String assignType;
    private String status;
    private LocalDateTime createdAt;
    private String createdBy;
    private LocalDateTime updatedAt;
    private String updatedBy;
    private int numberData;

    public String getAssignType() {
        return assignType;
    }

    public void setAssignType(String assignType) {
        this.assignType = assignType;
    }

    public String getSegmentType() {
        return segmentType;
    }

    public void setSegmentType(String segmentType) {
        this.segmentType = segmentType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    public int getNumberData() {
        return numberData;
    }

    public void setNumberData(int numberData) {
        this.numberData = numberData;
    }

    public CustomerSegment() {
    }

    public int getSegmentId() {
        return segmentId;
    }

    public void setSegmentId(int segmentId) {
        this.segmentId = segmentId;
    }

    public String getSegmentName() {
        return segmentName;
    }

    public void setSegmentName(String segmentName) {
        this.segmentName = segmentName;
    }

    public String getCriteriaLogic() {
        return criteriaLogic;
    }

    public void setCriteriaLogic(String criteriaLogic) {
        this.criteriaLogic = criteriaLogic;
    }
}