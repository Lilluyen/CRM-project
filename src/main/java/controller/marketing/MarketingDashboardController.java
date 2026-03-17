package controller.marketing;

import java.io.IOException;
import java.util.List;

import dto.report.DealResultReportDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import service.CampaignService;
import service.LeadService;
import service.ReportService;

@WebServlet(name = "MarketingDashboardController", urlPatterns = {"/marketing/dashboard"})
public class MarketingDashboardController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private final CampaignService campaignService = new CampaignService();
    private final ReportService reportService = new ReportService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Tổng quan Leads (toàn hệ thống, không filter theo interest)
        int totalLeads = leadService.countLeads(null, null, 0, null);
        int newLeads = leadService.countLeads(null, "NEW_LEAD", 0, null);
        int contactedLeads = leadService.countLeads(null, "CONTACTED", 0, null);
        int qualifiedLeads = leadService.countLeads(null, "QUALIFIED", 0, null);
        int dealCreatedLeads = leadService.countLeads(null, "DEAL_CREATED", 0, null);
        int lostLeads = leadService.countLeads(null, "LOST", 0, null);

        // Tổng quan Campaigns
        int totalCampaigns = campaignService.countCampaigns(null, null);
        int activeCampaigns = campaignService.countCampaigns(null, "ACTIVE");
        int planningCampaigns = campaignService.countCampaigns(null, "PLANNING");
        int completedCampaigns = campaignService.countCampaigns(null, "COMPLETED");

        // Top 5 campaigns đang chạy
        List<Campaign> topCampaigns = campaignService.searchCampaigns(null, "ACTIVE", 1, 5);

        // Leads mới nhất (5 leads, toàn hệ thống)
        List<model.Lead> recentLeads = leadService.searchLeads(
                null, null, 0, null, 1, 5);

        // Conversion rate tổng (thống nhất với ReportService):
        // deals WON / total leads * 100
        DealResultReportDTO overallDealResult = reportService.getDealResultReport(null, null, null);
        int dealsCreated = overallDealResult.getTotalDeals();
        int dealsWon = overallDealResult.getDealsWon();
        double conversionRate = totalLeads > 0
                ? dealsWon * 100.0 / totalLeads
                : 0;

        // Set attributes
        request.setAttribute("totalLeads", totalLeads);
        request.setAttribute("newLeads", newLeads);
        request.setAttribute("contactedLeads", contactedLeads);
        request.setAttribute("qualifiedLeads", qualifiedLeads);
        request.setAttribute("dealCreatedLeads", dealCreatedLeads);
        request.setAttribute("lostLeads", lostLeads);

        request.setAttribute("totalCampaigns", totalCampaigns);
        request.setAttribute("activeCampaigns", activeCampaigns);
        request.setAttribute("planningCampaigns", planningCampaigns);
        request.setAttribute("completedCampaigns", completedCampaigns);

        request.setAttribute("topCampaigns", topCampaigns);
        request.setAttribute("recentLeads", recentLeads);
        request.setAttribute("dealsCreated", dealsCreated);
        request.setAttribute("dealsWon", dealsWon);
        request.setAttribute("conversionRate", String.format("%.1f", conversionRate));

        // Layout
        request.setAttribute("pageTitle", "Marketing Dashboard - CRM");
        request.setAttribute("contentPage", "marketing/marketing_dashboard.jsp");
        request.setAttribute("pageCss", "marketing_dashboard.css");
        request.setAttribute("page", "marketing-dashboard");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }
}
