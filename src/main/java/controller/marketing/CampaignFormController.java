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
                forwardForm(request, response, "Edit Campaign - CRM");

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/marketing/campaign");
            }
        } else {
            // Create mode: hiển thị form trống
            forwardForm(request, response, "Create New Campaign - CRM");
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
                throw new IllegalArgumentException("Name of campaign is not empty.");
            }

            BigDecimal budget;
            try {
                budget = new BigDecimal(budgetStr);
                if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Budget must be a positive number.");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid budget format.");
            }

            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            if (startDateStr == null || startDateStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Start date is not empty.");
            }
            if (endDateStr == null || endDateStr.trim().isEmpty()) {
                throw new IllegalArgumentException("End date is not empty.");
            }
            LocalDate startDate = LocalDate.parse(startDateStr);
            if (startDate.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException("Start date must be today or a future date.");
            }
            LocalDate endDate = LocalDate.parse(endDateStr);
            if (endDate.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException("End date must be today or a future date.");
            }

            if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                throw new IllegalArgumentException("End date must be after start date.");
            }

            String channel = request.getParameter("channel");
            if (channel == null || channel.trim().isEmpty()) {
                throw new IllegalArgumentException("Marketing channel is not empty.");
            }

            int createdBy = ((User) request.getSession().getAttribute("user")).getUserId();

            Campaign campaign = new Campaign(0, name, description, budget, startDate, endDate,
                    channel, "ACTIVE", createdBy, null, null);

            campaignService.createCampaign(campaign);
            request.getSession().setAttribute("successMessage", "Campaign \"" + name + "\" has been created successfully!");
            response.sendRedirect(request.getContextPath() + "/marketing/campaign");

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response, "Create Campaign - CRM");
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
                throw new IllegalArgumentException("Campaign name is not empty.");
            }

            BigDecimal budget;
            try {
                budget = new BigDecimal(budgetStr);
                if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Budget must be a positive number.");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid budget format.");
            }

            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                throw new IllegalArgumentException("Status is not empty.");
            }

            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            if (startDateStr == null || startDateStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Start date is not empty.");
            }
            if (endDateStr == null || endDateStr.trim().isEmpty()) {
                throw new IllegalArgumentException("End date is not empty.");
            }
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);
            if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                throw new IllegalArgumentException("End date must be after start date.");
            }

            LocalDate today = LocalDate.now();
            String normalizedStatus = status.trim().toUpperCase();
            if ("PLANNING".equals(normalizedStatus)) {
                if (startDate.isBefore(today)) {
                    throw new IllegalArgumentException("Campaign is in PLANNING status: start date must be today or later.");
                }
                if (endDate.isBefore(today)) {
                    throw new IllegalArgumentException("Campaign is in PLANNING status: end date must be today or later.");
                }
            } else if ("ACTIVE".equals(normalizedStatus)) {
                // ACTIVE: hôm nay phải nằm trong khoảng chạy
                if (startDate.isAfter(today)) {
                    throw new IllegalArgumentException("Campaign is in ACTIVE status: start date must be today or later.");
                }
                if (endDate.isBefore(today)) {
                    throw new IllegalArgumentException("Campaign is in ACTIVE status: end date must be today or later.");
                }
            } else if ("COMPLETED".equals(normalizedStatus)) {
                // COMPLETED: đã kết thúc (endDate ở quá khứ hoặc hôm nay)
                if (endDate.isAfter(today)) {
                    throw new IllegalArgumentException("Campaign is in COMPLETED status: end date must be today or earlier.");
                }
            } else if ("PAUSED".equals(normalizedStatus)) {
                // PAUSED: có thể tạm dừng trước khi chạy hoặc trong khi chạy,
                // nhưng không hợp lý nếu endDate đã qua (nên là COMPLETED).
                if (endDate.isBefore(today)) {
                    throw new IllegalArgumentException("Campaign is in PAUSED status: end date must be today or later.");
                }
            } else {
                throw new IllegalArgumentException("Invalid campaign status.");
            }

            String channel = request.getParameter("channel");
            if (channel == null || channel.trim().isEmpty()) {
                throw new IllegalArgumentException("Marketing channel cannot be empty.");
            }

            Campaign campaign = new Campaign(campaignId, name, description, budget, startDate,
                    endDate, channel, status, 0, null, null);

            if (campaignService.updateCampaign(campaign)) {
                request.getSession().setAttribute("successMessage", "Campaign \"" + name + "\" has been updated successfully!");
                response.sendRedirect(request.getContextPath() + "/marketing/campaign");
            } else {
                throw new Exception("Failed to update campaign.");
            }

        } catch (Exception e) {
            Campaign campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("campaign", campaign);
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response, " Edit Campaign - CRM");
        }
    }
}
