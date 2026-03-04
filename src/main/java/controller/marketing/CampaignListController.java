package controller.marketing;

import java.io.IOException;
import java.util.List;

import dto.Pagination;
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

        // --- Đọc params ---
        String searchName = request.getParameter("search");
        String status = request.getParameter("status");

        int page = 1;
        int pageSize = 10; // mặc định
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
        } catch (NumberFormatException ignored) {
        }
        try {
            if (request.getParameter("pageSize") != null) {
                pageSize = Integer.parseInt(request.getParameter("pageSize"));
            }
        } catch (NumberFormatException ignored) {
        }

        // Giới hạn pageSize hợp lệ
        if (pageSize != 5 && pageSize != 10 && pageSize != 20) {
            pageSize = 10;
        }
        if (page < 1) {
            page = 1;
        }

        // --- Đếm tổng bản ghi ---
        int totalItems = campaignService.countCampaigns(searchName, status);

        // --- Tạo Pagination DTO ---
        Pagination pagination = new Pagination(page, pageSize, totalItems);

        // --- Lấy danh sách theo trang ---
        List<Campaign> campaigns = campaignService.searchCampaigns(
                searchName, status, pagination.getCurrentPage(), pageSize);

        // --- Đặt request attributes ---
        request.setAttribute("campaigns", campaigns);
        request.setAttribute("pagination", pagination);
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
