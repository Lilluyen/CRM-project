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
import model.User;
import service.CampaignService;

@WebServlet(name = "CampaignFormController", urlPatterns = {"/marketing/campaign/form"})
public class CampaignFormController extends HttpServlet {

    private final CampaignService campaignService = new CampaignService();

    // ======================================================================
    // Helper: forward form page qua layout
    // ======================================================================
    private void forwardForm(HttpServletRequest request, HttpServletResponse response, String pageTitle)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("contentPage", "marketing/campaign/campaign_form.jsp");
        request.setAttribute("pageCss", "campaign_form.css");
        request.setAttribute("page", "campaign-form");
        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }

    // ======================================================================
    // GET: Hiển thị form tạo mới hoặc chỉnh sửa
    // ======================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.isBlank()) {
            // Edit mode: load campaign data
            try {
                int campaignId = Integer.parseInt(idParam);
                Campaign campaign = campaignService.getCampaignById(campaignId);

                if (campaign == null) {
                    response.sendRedirect(request.getContextPath() + "/marketing/campaign");
                    return;
                }

                request.setAttribute("campaign", campaign);
                forwardForm(request, response, "Chỉnh sửa Campaign - CRM");

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/marketing/campaign");
            }
        } else {
            // Create mode: hiển thị form trống
            forwardForm(request, response, "Tạo Campaign Mới - CRM");
        }
    }

    // ======================================================================
    // POST: Xử lý tạo mới hoặc cập nhật campaign
    // ======================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String campaignIdParam = request.getParameter("campaignId");
        boolean isUpdate = (campaignIdParam != null && !campaignIdParam.isBlank());

        if (isUpdate) {
            handleUpdate(request, response, campaignIdParam);
        } else {
            handleCreate(request, response);
        }
    }

    // ======================================================================
    // Create campaign
    // ======================================================================
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String budgetStr = request.getParameter("budget");

            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Tên campaign không được để trống.");
            }

            BigDecimal budget;
            try {
                budget = new BigDecimal(budgetStr);
                if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Ngân sách phải lớn hơn 0.");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Ngân sách không hợp lệ.");
            }

            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

            if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
            }

            String channel = request.getParameter("channel");
            if (channel == null || channel.trim().isEmpty()) {
                throw new IllegalArgumentException("Kênh marketing không được để trống.");
            }

            int createdBy = ((User) request.getSession().getAttribute("user")).getUserId();

            Campaign campaign = new Campaign(0, name, description, budget, startDate, endDate,
                    channel, "ACTIVE", createdBy, null, null);

            campaignService.createCampaign(campaign);
            request.getSession().setAttribute("successMessage", "Campaign \"" + name + "\" đã được tạo thành công!");
            response.sendRedirect(request.getContextPath() + "/marketing/campaign");

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response, "Tạo Campaign - CRM");
        }
    }

    // ======================================================================
    // Update campaign
    // ======================================================================
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
            String campaignIdParam)
            throws ServletException, IOException {
        int campaignId = 0;
        try {
            campaignId = Integer.parseInt(campaignIdParam);
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String budgetStr = request.getParameter("budget");

            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Tên campaign không được để trống.");
            }

            BigDecimal budget;
            try {
                budget = new BigDecimal(budgetStr);
                if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Ngân sách phải lớn hơn 0.");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Ngân sách không hợp lệ.");
            }

            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

            if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
            }

            String channel = request.getParameter("channel");
            if (channel == null || channel.trim().isEmpty()) {
                throw new IllegalArgumentException("Kênh marketing không được để trống.");
            }

            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                throw new IllegalArgumentException("Trạng thái không được để trống.");
            }

            Campaign campaign = new Campaign(campaignId, name, description, budget, startDate,
                    endDate, channel, status, 0, null, null);

            if (campaignService.updateCampaign(campaign)) {
                request.getSession().setAttribute("successMessage", "Campaign \"" + name + "\" đã được cập nhật thành công!");
                response.sendRedirect(request.getContextPath() + "/marketing/campaign");
            } else {
                throw new Exception("Cập nhật campaign thất bại.");
            }

        } catch (Exception e) {
            Campaign campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("campaign", campaign);
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response, "Chỉnh sửa Campaign - CRM");
        }
    }
}
