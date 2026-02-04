/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;

/**
 *
 * @author Pham Minh Quan
 */
public class CustomerSegmentMap {
    private Integer customerId;
    private Integer segmentId;
    private java.time.LocalDateTime assignedAt;

    public CustomerSegmentMap() {
    }

    public CustomerSegmentMap(Integer customerId, Integer segmentId, LocalDateTime assignedAt) {
        this.customerId = customerId;
        this.segmentId = segmentId;
        this.assignedAt = assignedAt;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getSegmentId() {
        return segmentId;
    }

    public void setSegmentId(Integer segmentId) {
        this.segmentId = segmentId;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }
    
}
