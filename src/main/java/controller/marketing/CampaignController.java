package controller.marketing;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import service.CampaignService;

@WebServlet("/marketing/campaign")
public class CampaignController extends HttpServlet {
    private CampaignService campaignService = new CampaignService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            BigDecimal budget = new BigDecimal(request.getParameter("budget"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            String channel = request.getParameter("channel");
            int createdBy = (Integer) request.getSession().getAttribute("userId");

            Campaign campaign = new Campaign(0, name, description, budget, startDate, endDate, 
                                            channel, "ACTIVE", createdBy, null, null);
            
            try {
                int campaignId = campaignService.createCampaign(campaign);
                response.sendRedirect("campaign?action=list");
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/marketing/campaign_form.jsp").forward(request, response);
            }
        } else if ("update".equals(action)) {
            int campaignId = Integer.parseInt(request.getParameter("campaignId"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            BigDecimal budget = new BigDecimal(request.getParameter("budget"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            String channel = request.getParameter("channel");
            String status = request.getParameter("status");

            Campaign campaign = new Campaign(campaignId, name, description, budget, startDate, 
                                            endDate, channel, status, 0, null, null);
            
            if (campaignService.updateCampaign(campaign)) {
                response.sendRedirect("campaign?action=detail&id=" + campaignId);
            } else {
                request.setAttribute("error", "Update failed");
                request.getRequestDispatcher("/marketing/campaign_form.jsp").forward(request, response);
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("list".equals(action) || action == null) {
            var campaigns = campaignService.getAllCampaigns();
            request.setAttribute("campaigns", campaigns);
            request.getRequestDispatcher("/marketing/campaign_list.jsp").forward(request, response);
        } else if ("detail".equals(action)) {
            int campaignId = Integer.parseInt(request.getParameter("id"));
            var campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("campaign", campaign);
            request.getRequestDispatcher("/marketing/campaign_detail.jsp").forward(request, response);
        }
    }
}