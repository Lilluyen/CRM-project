package model;

import java.time.LocalDateTime;

public class CampaignLead {

    private int campaignId;
    private int leadId;
    private String leadStatus;
    private LocalDateTime assignedAt;
    private LocalDateTime updatedAt;

    public CampaignLead() {
    }

    public CampaignLead(int campaignId, int leadId, String leadStatus, LocalDateTime assignedAt, LocalDateTime updatedAt) {
        this.campaignId = campaignId;
        this.leadId = leadId;
        this.leadStatus = leadStatus;
        this.assignedAt = assignedAt;
        this.updatedAt = updatedAt;
    }

    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }

    public String getLeadStatus() {
        return leadStatus;
    }

    public void setLeadStatus(String leadStatus) {
        this.leadStatus = leadStatus;
    }

    public int getLeadId() {
        return leadId;
    }

    public void setLeadId(int leadId) {
        this.leadId = leadId;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
