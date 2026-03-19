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
        return campaignDAO.insert(campaign);
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
        return campaignDAO.getCampaignByStatus("ACTIVE");
    }

    /**
     * Tìm campaign theo tên và/hoặc status
     */
    public List<Campaign> searchCampaigns(String searchName, String status) {
        return campaignDAO.searchCampaigns(searchName, status);
    }

    /**
     * Tìm campaign theo tên và/hoặc status – có phân trang
     */
    public List<Campaign> searchCampaigns(String searchName, String status, int page, int pageSize) {
        return campaignDAO.searchCampaigns(searchName, status, page, pageSize);
    }

    /**
     * Đếm tổng campaign theo điều kiện lọc (dùng cho phân trang)
     */
    public int countCampaigns(String searchName, String status) {
        return campaignDAO.countCampaigns(searchName, status);
    }
}
