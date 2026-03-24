package service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import dao.CampaignLeadDAO;
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
    // FIX: thêm CampaignLeadDAO để đếm lead qua bảng quan hệ Campaign_Leads
    // Lý do: Campaign_Leads là nguồn dữ liệu CHÍNH XÁC cho quan hệ nhiều-nhiều
    // giữa campaign và lead. Leads.campaign_id chỉ lưu 1 campaign (campaign đầu tiên),
    // không phản ánh đúng khi 1 lead tham gia nhiều campaign.
    private final CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

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
     *
     * FIX: Đếm totalLead và qualifiedLead qua bảng Campaign_Leads thay vì qua
     * Leads.campaign_id.
     *
     * Lý do: - countLeads() dùng GROUP BY(email, status, interest, full_name,
     * phone) để phục vụ UI danh sách → cùng 1 người khác status = 2 nhóm →
     * COUNT sai. - Leads.campaign_id chỉ lưu 1 campaign (campaign đầu tiên
     * import), không phản ánh đúng quan hệ nhiều-nhiều. - Campaign_Leads là
     * bảng quan hệ chính xác: mỗi row = 1 lead thuộc campaign, có cả
     * lead_status → đếm totalLead và qualifiedLead đều đúng.
     *
     * Các luồng KHÔNG bị ảnh hưởng: - MarketingDashboard: vẫn dùng
     * countLeads(campaignId=0) → đếm toàn hệ thống, đúng - LeadList: vẫn dùng
     * countLeads() cho phân trang UI, đúng - CampaignReport: dùng
     * CampaignReportDAO riêng, không liên quan
     */
    public CampaignReport generateReport(int campaignId) {

        // FIX: đếm qua Campaign_Leads — đúng với thiết kế nhiều-nhiều
        int totalLead = campaignLeadDAO.countTotalLeadsByCampaign(campaignId);
        int qualifiedLead = campaignLeadDAO.countLeadByStatus(campaignId, "QUALIFIED");

        DealResultReportDTO dealResult = getDealResultReport(campaignId, null, null);
        int convertedLead = dealResult.getDealsWon();

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
