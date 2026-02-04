package model;

import java.time.LocalDateTime;

public class CampaignLead {
    private int campaignId;
    private int leadId;
    private LocalDateTime joinedAt;

    public CampaignLead() {
    }

    public CampaignLead(int campaignId, int leadId, LocalDateTime joinedAt) {
        this.campaignId = campaignId;
        this.leadId = leadId;
        this.joinedAt = joinedAt;
    }

    // Getters and Setters
    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }

    public int getLeadId() {
        return leadId;
    }

    public void setLeadId(int leadId) {
        this.leadId = leadId;
    }

    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }
}
