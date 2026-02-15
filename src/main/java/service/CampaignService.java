package service;

import java.util.List;

import dao.CampaignDAO;
import model.Campaign;

public class CampaignService {

    private CampaignDAO campaignDAO = new CampaignDAO();

    public int createCampaign(Campaign campaign) {
        if (campaign.getName() == null || campaign.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Campaign name is required");
        }
        if (campaign.getStartDate().isAfter(campaign.getEndDate())) {
            throw new IllegalArgumentException("Start date must be before end date");
        }
        return campaignDAO.createCampaign(campaign);
    }

    public boolean updateCampaign(Campaign campaign) {
        if (campaign.getCampaignId() <= 0) {
            throw new IllegalArgumentException("Campaign ID is invalid");
        }
        return campaignDAO.updateCampaign(campaign);
    }

    public Campaign getCampaignById(int campaignId) {
        return campaignDAO.getCampaignById(campaignId);
    }

    public List<Campaign> getAllCampaigns() {
        return campaignDAO.getAllCampaign();
    }

    public List<Campaign> getActiveCampaigns() {
        return campaignDAO.getByCampaignByStatus("ACTIVE");
    }
}
