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
import model.Lead;
import service.CampaignService;
import service.LeadService;

@WebServlet(name = "LeadListController", urlPatterns = {"/marketing/leads"})
public class LeadListController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private final CampaignService campaignService = new CampaignService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Đọc params ---
        String keyword = request.getParameter("search");
        String status = request.getParameter("status");

        // Lọc theo campaign (từ Campaign Detail → Xem Leads)
        int campaignId = 0;
        try {
            if (request.getParameter("campaignId") != null) {
                campaignId = Integer.parseInt(request.getParameter("campaignId"));
            }
        } catch (NumberFormatException ignored) {
        }

        int page = 1;
        int pageSize = 10;
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
        int totalItems = leadService.countLeads(keyword, status, campaignId, request.getParameter("interest"));

        // --- Tạo Pagination DTO ---
        Pagination pagination = new Pagination(page, pageSize, totalItems);

        // --- Lấy danh sách theo trang ---
        List<Lead> leads = leadService.searchLeads(
                keyword, status, campaignId, request.getParameter("interest"), pagination.getCurrentPage(), pageSize);

        // --- Đặt request attributes ---
        request.setAttribute("leads", leads);
        request.setAttribute("pagination", pagination);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterInterest", request.getParameter("interest"));

        // Nếu đang lọc theo campaign → load thông tin campaign
        if (campaignId > 0) {
            Campaign campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("filterCampaign", campaign);
            request.setAttribute("campaign", campaign);
            request.setAttribute("filterCampaignId", campaignId);
        }

        // Flash success message from session (PRG pattern)
        String successMsg = (String) request.getSession().getAttribute("successMessage");
        if (successMsg != null) {
            request.setAttribute("success", successMsg);
            request.getSession().removeAttribute("successMessage");
        }

        // Flash error message from session (PRG pattern)
        String errorMsg = (String) request.getSession().getAttribute("errorMessage");
        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            request.getSession().removeAttribute("errorMessage");
        }

        // Layout attributes
        request.setAttribute("pageTitle", "Leads Management - CRM");
        request.setAttribute("contentPage", "marketing/lead/lead_list.jsp");
        request.setAttribute("pageCss", "lead_list.css");
        request.setAttribute("page", "lead-list");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }
}
