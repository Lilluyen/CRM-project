package service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import dao.CampaignReportDAO;
import dao.LeadDAO;
import dto.report.CampaignPerformanceReportDTO;
import dto.report.DealResultReportDTO;
import dto.report.LeadFunnelReportDTO;
import dto.report.LeadSourceReportDTO;
import dto.report.MarketingReportKpiDTO;
import model.CampaignReport;

public class ReportService {

    private final CampaignReportDAO reportDAO = new CampaignReportDAO();
    private final LeadDAO leadDAO = new LeadDAO();

    public List<CampaignPerformanceReportDTO> getCampaignPerformance(
            Integer campaignId, String fromDate, String toDate) {
        return reportDAO.getCampaignPerformance(campaignId, fromDate, toDate);
    }

    public int getCampaignPerformanceCount(Integer campaignId, String fromDate, String toDate) {
        return reportDAO.countCampaignPerformance(campaignId, fromDate, toDate);
    }

    public List<CampaignPerformanceReportDTO> getCampaignPerformancePaginated(
            Integer campaignId, String fromDate, String toDate, int offset, int limit) {
        return reportDAO.getCampaignPerformancePaginated(campaignId, fromDate, toDate, offset, limit);
    }

    public List<LeadSourceReportDTO> getLeadSourceReport(
            Integer campaignId, String source, String fromDate, String toDate) {
        return reportDAO.getLeadSourceReport(campaignId, source, fromDate, toDate);
    }

    public LeadFunnelReportDTO getLeadFunnelReport(
            Integer campaignId, String fromDate, String toDate) {
        return reportDAO.getLeadFunnelReport(campaignId, fromDate, toDate);
    }

    public DealResultReportDTO getDealResultReport(
            Integer campaignId, String fromDate, String toDate) {
        return reportDAO.getDealResultReport(campaignId, fromDate, toDate);
    }

    public List<Object[]> getAllCampaignsForFilter() {
        return reportDAO.getAllCampaignsForFilter();
    }

    public List<String> getAllSourcesForFilter() {
        return reportDAO.getAllSourcesForFilter();
    }

    public MarketingReportKpiDTO getMarketingReportKpi(
            Integer campaignId, String fromDate, String toDate) {
        return reportDAO.getMarketingReportKpi(campaignId, fromDate, toDate);
    }

    /**
     * Tạo report thống kê cho một campaign (dùng trong Campaign Detail).
     */
    public CampaignReport generateReport(int campaignId) {
        int totalLead = leadDAO.countLeads(null, null, campaignId, null);
        int qualifiedLead = leadDAO.countLeads(null, "QUALIFIED", campaignId, null);

        DealResultReportDTO dealResult = getDealResultReport(campaignId, null, null);
        int convertedLead = dealResult.getDealsWon(); // Deals Won (not total deals created)

        CampaignReport report = new CampaignReport();
        report.setReportId(0);
        report.setCampaignId(campaignId);
        report.setTotalLead(totalLead);
        report.setQualifiedLead(qualifiedLead);
        report.setConvertedLead(convertedLead);
        report.setCostPerLead(null);
        report.setRoi(BigDecimal.ZERO);
        report.setCreatedAt(LocalDateTime.now());
        return report;
    }
}
