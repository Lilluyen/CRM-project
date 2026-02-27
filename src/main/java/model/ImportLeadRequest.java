package model;

import java.util.List;

/**
 * Model cho import leads request
 */
public class ImportLeadRequest {

    private List<Lead> leads;
    private String source;
    private int campaignId; // optional

    public ImportLeadRequest() {
    }

    public ImportLeadRequest(List<Lead> leads, String source, int campaignId) {
        this.leads = leads;
        this.source = source;
        this.campaignId = campaignId;
    }

    public List<Lead> getLeads() {
        return leads;
    }

    public void setLeads(List<Lead> leads) {
        this.leads = leads;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }
}