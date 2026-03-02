package service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

import dao.CampaignDAO;
import dao.CampaignLeadDAO;
import dao.LeadDAO;
import model.Campaign;
import model.CampaignReport;

public class CampaignReportService {

    private CampaignDAO campaignDAO = new CampaignDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
    private LeadDAO leadDAO = new LeadDAO();

    /**
     * Tạo báo cáo hiệu quả Campaign. Hybrid approach: ưu tiên đếm từ bảng
     * Campaign_Leads (N:N). Nếu Campaign_Leads chưa có dữ liệu, fallback đếm từ
     * Leads.campaign_id (N:1).
     */
    public CampaignReport generateReport(int campaignId) {
        Campaign campaign = campaignDAO.getCampaignById(campaignId);
        if (campaign == null) {
            return null;
        }

        // Ưu tiên đếm từ Campaign_Leads
        int totalLeads = campaignLeadDAO.countTotalLeadsByCampaign(campaignId);
        int qualifiedLeads;
        int convertedLeads;

        if (totalLeads > 0) {
            // Campaign_Leads có dữ liệu → dùng trạng thái của bảng Campaign_Leads
            qualifiedLeads = campaignLeadDAO.countLeadByStatus(campaignId, "QUALIFIED");
            convertedLeads = campaignLeadDAO.countLeadByStatus(campaignId, "DEAL_CREATED");
        } else {
            // Fallback: đếm từ bảng Leads theo campaign_id
            totalLeads = leadDAO.countLeadsByCampaignId(campaignId);
            qualifiedLeads = leadDAO.countLeadsByCampaignAndStatus(campaignId, "Qualified");
            convertedLeads = leadDAO.countLeadsByCampaignAndStatus(campaignId, "Converted");
        }

        // Cost Per Lead = Budget / Total Leads
        BigDecimal costPerLead = (totalLeads > 0)
                ? campaign.getBudget().divide(new BigDecimal(totalLeads), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // ROI / Conversion Rate = (Converted Leads / Total Leads) * 100
        BigDecimal roi = (totalLeads > 0)
                ? new BigDecimal(convertedLeads).multiply(new BigDecimal(100))
                        .divide(new BigDecimal(totalLeads), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return new CampaignReport(0, campaignId, totalLeads, qualifiedLeads, convertedLeads,
                costPerLead, roi, LocalDateTime.now());
    }
}
