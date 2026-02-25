package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CampaignLeadService;
import service.LeadService;

@WebServlet("/marketing/lead")
public class LeadController extends HttpServlet {
    private LeadService leadService = new LeadService();
    private CampaignLeadService campaignLeadService = new CampaignLeadService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("score".equals(action)) {
            int leadId = Integer.parseInt(request.getParameter("leadId"));
            int score = Integer.parseInt(request.getParameter("score"));
            
            try {
                if (leadService.scoreLead(leadId, score)) {
                    response.getWriter().write("{\"success\": true}");
                }
            } catch (Exception e) {
                response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
            }
        } else if ("updateStatus".equals(action)) {
            int leadId = Integer.parseInt(request.getParameter("leadId"));
            String status = request.getParameter("status");
            
            if (leadService.updateLeadStatus(leadId, status)) {
                response.sendRedirect(request.getHeader("Referer"));
            }
        } else if ("assignToCampaign".equals(action)) {
            int leadId = Integer.parseInt(request.getParameter("leadId"));
            int campaignId = Integer.parseInt(request.getParameter("campaignId"));
            
            try {
                if (campaignLeadService.assignLeadToCampaign(campaignId, leadId)) {
                    response.sendRedirect("lead?action=list");
                }
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/marketing/lead_list.jsp").forward(request, response);
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("list".equals(action) || action == null) {
            var leads = leadService.getAllLeads();
            request.setAttribute("leads", leads);
            request.getRequestDispatcher("/marketing/lead_list.jsp").forward(request, response);
        } else if ("byCampaign".equals(action)) {
            int campaignId = Integer.parseInt(request.getParameter("campaignId"));
            var leads = campaignLeadService.getLeadsByCampaignId(campaignId);
            request.setAttribute("leads", leads);
            request.setAttribute("campaignId", campaignId);
            request.getRequestDispatcher("/marketing/lead_by_campaign.jsp").forward(request, response);
        }
    }
}