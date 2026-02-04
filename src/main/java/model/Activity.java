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
public class Activity {
    private Integer activityId;
    private String relatedType;
    private Integer relatedId;
    private String activityType;
    private String subject;
    private String description;
    private Integer createdBy;
    private java.time.LocalDateTime activityDate;
    private java.time.LocalDateTime createdAt;

    public Activity() {
    }

    public Activity(Integer activityId, String relatedType, Integer relatedId, String activityType, String subject, String description, Integer createdBy, LocalDateTime activityDate, LocalDateTime createdAt) {
        this.activityId = activityId;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.activityType = activityType;
        this.subject = subject;
        this.description = description;
        this.createdBy = createdBy;
        this.activityDate = activityDate;
        this.createdAt = createdAt;
    }

    public Integer getActivityId() {
        return activityId;
    }

    public void setActivityId(Integer activityId) {
        this.activityId = activityId;
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

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getActivityDate() {
        return activityDate;
    }

    public void setActivityDate(LocalDateTime activityDate) {
        this.activityDate = activityDate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
}

