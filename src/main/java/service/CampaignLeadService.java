package service;

import java.util.List;

import dao.CampaignLeadDAO;
import dao.LeadDAO;
import model.Lead;

public class CampaignLeadService {

    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
    private LeadDAO leadDAO = new LeadDAO();

    /**
     * Gán Lead vào Campaign
     */
    public boolean assignLeadToCampaign(int campaignId, int leadId) {
        Lead lead = leadDAO.getById(leadId);
        if (lead == null) {
            throw new IllegalArgumentException("Lead not found");
        }
        lead.setCampaignId(campaignId);
        leadDAO.update(lead);
        return campaignLeadDAO.assignLeadToCampaign(campaignId, leadId, "NEW");
    }

    /**
     * Cập nhật trạng thái Lead trong Campaign
     */
    public boolean updateLeadStatusInCampaign(int campaignId, int leadId, String leadStatus) {
        return campaignLeadDAO.updateLeadStatus(campaignId, leadId, leadStatus);
    }

    /**
     * Lấy danh sách Leads của Campaign
     */
    public List<Lead> getLeadsByCampaignId(int campaignId) {
        return campaignLeadDAO.getLeadsByCampaignId(campaignId);
    }

    /**
     * Lấy Leads theo status trong Campaign
     */
    public List<Lead> getLeadsByCampaignAndStatus(int campaignId, String leadStatus) {
        return campaignLeadDAO.getLeadsByCampaignAndStatus(campaignId, leadStatus);
    }
}
