package service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

import dao.CampaignDAO;
import dao.CampaignLeadDAO;
import model.Campaign;
import model.CampaignReport;

public class CampaignReportService {

    private CampaignDAO campaignDAO = new CampaignDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

    /**
     * Tạo báo cáo hiệu quả Campaign
     */
    public CampaignReport generateReport(int campaignId) {
        Campaign campaign = campaignDAO.getCampaignById(campaignId);
        if (campaign == null) {
            return null;
        }

        int totalLeads = campaignLeadDAO.countTotalLeadsByCampaign(campaignId);
        int qualifiedLeads = campaignLeadDAO.countLeadByStatus(campaignId, "QUALIFIED");
        int convertedLeads = campaignLeadDAO.countLeadByStatus(campaignId, "DEAL_CREATED");

        // Cost Per Lead = Budget / Total Leads
        BigDecimal costPerLead = (totalLeads > 0)
                ? campaign.getBudget().divide(new BigDecimal(totalLeads), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // ROI = (Converted Leads / Total Leads) * 100
        BigDecimal roi = (totalLeads > 0)
                ? new BigDecimal(convertedLeads).multiply(new BigDecimal(100))
                        .divide(new BigDecimal(totalLeads), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return new CampaignReport(0, campaignId, totalLeads, qualifiedLeads, convertedLeads,
                costPerLead, roi, LocalDateTime.now());
    }
}
