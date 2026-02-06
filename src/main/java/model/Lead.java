package model;

import java.time.LocalDateTime;

public class Lead {

    private int leadId;
    private String fullName;
    private String email;
    private String phone;
    private String companyName;
    private String interest;
    private String source;
    private String status;
    private int score;
    private int campaignId;
    private int assignedTo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Lead() {
    }

    public Lead(int leadId, String fullName, String email, String phone, String companyName,
            String interest, String source, String status, int score, int campaignId, int assignedTo,
            LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.leadId = leadId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.companyName = companyName;
        this.interest = interest;
        this.source = source;
        this.status = status;
        this.score = score;
        this.campaignId = campaignId;
        this.assignedTo = assignedTo;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getLeadId() {
        return leadId;
    }

    public void setLeadId(int leadId) {
        this.leadId = leadId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getInterest() {
        return interest;
    }

    public void setInterest(String interest) {
        this.interest = interest;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }

    public int getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

}
