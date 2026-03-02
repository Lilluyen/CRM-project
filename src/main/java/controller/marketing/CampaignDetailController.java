package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import model.CampaignReport;
import service.CampaignReportService;
import service.CampaignService;

@WebServlet(name = "CampaignDetailController", urlPatterns = {"/marketing/campaign/detail"})
public class CampaignDetailController extends HttpServlet {

    private final CampaignService campaignService = new CampaignService();
    private final CampaignReportService reportService = new CampaignReportService();

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

            // Generate campaign statistics report (reusable via CampaignReportService)
            CampaignReport report = reportService.generateReport(campaignId);
            request.setAttribute("report", report);

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
