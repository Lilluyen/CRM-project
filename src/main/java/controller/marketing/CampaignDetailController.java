package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dto.report.DealResultReportDTO;
import model.Campaign;
import model.CampaignReport;
import service.CampaignService;
import service.ReportService;

@WebServlet(name = "CampaignDetailController", urlPatterns = {"/marketing/campaign/detail"})
public class CampaignDetailController extends HttpServlet {

    private final CampaignService campaignService = new CampaignService();
    private final ReportService reportService = new ReportService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/marketing/campaign");
            return;
        }

        try {
            int campaignId = Integer.parseInt(idParam);
            Campaign campaign = campaignService.getCampaignById(campaignId);

            if (campaign == null) {
                response.sendRedirect(request.getContextPath() + "/marketing/campaign");
                return;
            }

            request.setAttribute("campaign", campaign);

            // Generate campaign statistics report
            CampaignReport report = reportService.generateReport(campaignId);
            request.setAttribute("report", report);

            // Deal metrics for this campaign
            DealResultReportDTO dealResult = reportService.getDealResultReport(campaignId, null, null);
            request.setAttribute("dealsWon", dealResult.getDealsWon());
            request.setAttribute("dealsCreated", dealResult.getTotalDeals());
            request.setAttribute("dealsLost", dealResult.getDealsLost());

            double conversionRate = (report != null && report.getTotalLead() > 0)
                    ? dealResult.getDealsWon() * 100.0 / report.getTotalLead()
                    : 0;
            request.setAttribute("conversionRate", String.format("%.1f", conversionRate));

            // Flash success message from session (PRG pattern)
            String successMsg = (String) request.getSession().getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("success", successMsg);
                request.getSession().removeAttribute("successMessage");
            }

            // Layout attributes
            request.setAttribute("pageTitle", campaign.getName() + " - CRM");
            request.setAttribute("contentPage", "marketing/campaign/campaign_detail.jsp");
            request.setAttribute("pageCss", "campaign_detail.css");
            request.setAttribute("page", "campaign-detail");

            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/marketing/campaign");
        }
    }
}
