package controller.marketing;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import service.CampaignService;

@WebServlet(name = "CampaignListController", urlPatterns = {"/marketing/campaign"})
public class CampaignListController extends HttpServlet {

    private final CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchName = request.getParameter("search");
        String status = request.getParameter("status");

        List<Campaign> campaigns;

        if ((searchName != null && !searchName.trim().isEmpty())
                || (status != null && !status.trim().isEmpty())) {

            campaigns = campaignService.searchCampaigns(searchName, status);

            // Nếu tìm thấy đúng 1 kết quả, auto-redirect đến detail
            if (campaigns.size() == 1) {
                Campaign campaign = campaigns.get(0);
                response.sendRedirect(request.getContextPath()
                        + "/marketing/campaign/detail?id=" + campaign.getCampaignId());
                return;
            }

        } else {
            campaigns = campaignService.getAllCampaigns();
        }

        request.setAttribute("campaigns", campaigns);
        request.setAttribute("searchName", searchName);
        request.setAttribute("filterStatus", status);

        // Flash success message from session (PRG pattern)
        String successMsg = (String) request.getSession().getAttribute("successMessage");
        if (successMsg != null) {
            request.setAttribute("success", successMsg);
            request.getSession().removeAttribute("successMessage");
        }

        // Layout attributes
        request.setAttribute("pageTitle", "Quản lý Campaign - CRM");
        request.setAttribute("contentPage", "marketing/campaign/campaign_list.jsp");
        request.setAttribute("pageCss", "campaign_list.css");
        request.setAttribute("page", "campaign-list");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }
}
