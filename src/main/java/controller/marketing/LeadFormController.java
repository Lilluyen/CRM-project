package controller.marketing;

import java.io.IOException;
import java.util.List;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import model.Lead;
import model.User;
import service.CampaignService;
import service.LeadService;

@WebServlet(name = "LeadFormController", urlPatterns = {"/marketing/leads/form"})
public class LeadFormController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private final CampaignService campaignService = new CampaignService();
    private final UserDAO userDAO = new UserDAO();

    // ======================================================================
    // Helper: forward form page qua layout
    // ======================================================================
    private void forwardForm(HttpServletRequest request, HttpServletResponse response, String pageTitle)
            throws ServletException, IOException {
        // Load danh sách campaigns cho dropdown
        List<Campaign> campaigns = campaignService.getAllCampaigns();
        request.setAttribute("campaigns", campaigns);

        // Load danh sách users cho dropdown Assigned To
        List<User> users = userDAO.getActiveSaleStaffs();
        request.setAttribute("users", users);

        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("contentPage", "marketing/lead/lead_form.jsp");
        request.setAttribute("pageCss", "lead_form.css");
        request.setAttribute("page", "lead-form");
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
            // Edit mode: load lead data
            try {
                int leadId = Integer.parseInt(idParam);
                Lead lead = leadService.getLeadById(leadId);

                if (lead == null) {
                    request.getSession().setAttribute("errorMessage", "Lead không tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/marketing/leads");
                    return;
                }

                request.setAttribute("lead", lead);
                forwardForm(request, response, "Chỉnh sửa Lead - CRM");

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
            }
        } else {
            // Create mode: hiển thị form trống
            forwardForm(request, response, "Tạo Lead Mới - CRM");
        }
    }

    // ======================================================================
    // POST: Xử lý tạo mới hoặc cập nhật lead
    // ======================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String leadIdParam = request.getParameter("leadId");
        boolean isUpdate = (leadIdParam != null && !leadIdParam.isBlank());

        if (isUpdate) {
            handleUpdate(request, response, leadIdParam);
        } else {
            handleCreate(request, response);
        }
    }

    // ======================================================================
    // Create lead
    // ======================================================================
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Lead lead = extractLeadFromRequest(request);

            int newId = leadService.createLead(lead);
            if (newId > 0) {
                request.getSession().setAttribute("successMessage",
                        "Lead \"" + lead.getFullName() + "\" đã được tạo thành công!");
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
            } else {
                throw new Exception("Tạo lead thất bại.");
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            // Re-populate form fields
            request.setAttribute("lead", extractLeadFromRequestSafe(request));
            forwardForm(request, response, "Tạo Lead Mới - CRM");
        }
    }

    // ======================================================================
    // Update lead
    // ======================================================================
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
            String leadIdParam) throws ServletException, IOException {
        int leadId = 0;
        try {
            leadId = Integer.parseInt(leadIdParam);
            Lead lead = extractLeadFromRequest(request);
            lead.setLeadId(leadId);

            if (leadService.updateLead(lead)) {
                request.getSession().setAttribute("successMessage",
                        "Lead \"" + lead.getFullName() + "\" đã được cập nhật thành công!");
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
            } else {
                throw new Exception("Cập nhật lead thất bại.");
            }

        } catch (Exception e) {
            Lead lead = extractLeadFromRequestSafe(request);
            lead.setLeadId(leadId);
            request.setAttribute("lead", lead);
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response, "Chỉnh sửa Lead - CRM");
        }
    }

    // ======================================================================
    // Helper: extract Lead fields from request
    // ======================================================================
    private Lead extractLeadFromRequest(HttpServletRequest request) {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String interest = request.getParameter("interest");
        String source = request.getParameter("source");
        String status = request.getParameter("status");
        String scoreStr = request.getParameter("score");
        String campaignIdStr = request.getParameter("campaignId");
        String assignedToStr = request.getParameter("assignedTo");

        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }

        Lead lead = new Lead();
        lead.setFullName(fullName.trim());
        lead.setEmail(email.trim());
        lead.setPhone(phone != null ? phone.trim() : "");
        lead.setInterest(interest != null ? interest.trim() : "");
        lead.setSource(source != null ? source.trim() : "");
        lead.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "NEW_LEAD");

        try {
            lead.setScore(scoreStr != null && !scoreStr.isEmpty() ? Integer.parseInt(scoreStr) : 0);
        } catch (NumberFormatException e) {
            lead.setScore(0);
        }

        try {
            lead.setCampaignId(campaignIdStr != null && !campaignIdStr.isEmpty()
                    ? Integer.parseInt(campaignIdStr) : 0);
        } catch (NumberFormatException e) {
            lead.setCampaignId(0);
        }

        try {
            lead.setAssignedTo(assignedToStr != null && !assignedToStr.isEmpty()
                    ? Integer.parseInt(assignedToStr) : 0);
        } catch (NumberFormatException e) {
            lead.setAssignedTo(0);
        }

        return lead;
    }

    /**
     * Safe version: dùng khi cần re-populate form sau lỗi validation
     */
    private Lead extractLeadFromRequestSafe(HttpServletRequest request) {
        Lead lead = new Lead();
        try {
            lead.setFullName(request.getParameter("fullName"));
            lead.setEmail(request.getParameter("email"));
            lead.setPhone(request.getParameter("phone"));
            lead.setInterest(request.getParameter("interest"));
            lead.setSource(request.getParameter("source"));
            lead.setStatus(request.getParameter("status"));
            String scoreStr = request.getParameter("score");
            lead.setScore(scoreStr != null && !scoreStr.isEmpty() ? Integer.parseInt(scoreStr) : 0);
            String campaignIdStr = request.getParameter("campaignId");
            lead.setCampaignId(campaignIdStr != null && !campaignIdStr.isEmpty()
                    ? Integer.parseInt(campaignIdStr) : 0);
        } catch (Exception ignored) {
        }
        return lead;
    }
}
