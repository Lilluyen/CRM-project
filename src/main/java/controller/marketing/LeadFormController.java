package controller.marketing;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import dao.CampaignLeadDAO;
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
import util.EmailCheck;
import util.LeadActivityUtil;
import util.PhoneCheck;

@WebServlet(name = "LeadFormController", urlPatterns = {"/marketing/leads/form"})
public class LeadFormController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private final CampaignService campaignService = new CampaignService();
    private final CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
    private final UserDAO userDAO = new UserDAO();

    // ======================================================================
    // Helper: forward form page qua layout
    // ======================================================================
    private void forwardForm(HttpServletRequest request, HttpServletResponse response, String pageTitle)
            throws ServletException, IOException {
        List<Campaign> campaigns = campaignService.getAllCampaigns();
        request.setAttribute("campaigns", campaigns);

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
            // Edit mode
            try {
                int leadId = Integer.parseInt(idParam);
                Lead lead = leadService.getLeadById(leadId);

                if (lead == null) {
                    request.getSession().setAttribute("errorMessage", "Lead không tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/marketing/leads");
                    return;
                }

                request.setAttribute("lead", lead);

                // FIX: dùng getCampaignsByLeadEmail để lấy TẤT CẢ campaigns
                // (vì list dùng MIN(lead_id) per email, leadId có thể chỉ thuộc 1 campaign)
                List<Campaign> leadCampaigns = campaignLeadDAO.getCampaignsByLeadEmail(leadId);
                request.setAttribute("leadCampaigns", leadCampaigns);

                forwardForm(request, response, "Chỉnh sửa Lead - CRM");

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
            }
        } else {
            // Create mode
            String presetCampaignIdStr = request.getParameter("campaignId");
            if (presetCampaignIdStr != null && !presetCampaignIdStr.isBlank()) {
                try {
                    request.setAttribute("presetCampaignId", Integer.parseInt(presetCampaignIdStr));
                } catch (NumberFormatException ignored) {
                }
            }
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
    // Create lead — giữ nguyên logic cũ
    // ======================================================================
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Lead lead = extractLeadFromRequestForUpdate(request);
            List<Integer> selectedCampaignIds = parseSelectedCampaigns(request);

            // set tạm campaign đầu tiên để validate đúng scope
            if (!selectedCampaignIds.isEmpty()) {
                lead.setCampaignId(selectedCampaignIds.get(0));
            }
            int newId = leadService.createLead(lead, false);
            leadService.updateLeadCampaigns(newId, selectedCampaignIds);
            if (newId > 0) {
                User sessionUser = (User) request.getSession().getAttribute("user");
                LeadActivityUtil.logLeadActivity(
                        newId, lead.getFullName(),
                        "Lead Created - " + lead.getFullName(),
                        "Lead created with email " + lead.getEmail(),
                        sessionUser);

                request.getSession().setAttribute("successMessage",
                        "Lead \"" + lead.getFullName() + "\" đã được tạo thành công!");

                String redirectUrl = request.getContextPath() + "/marketing/leads";
                if (lead.getCampaignId() > 0) {
                    redirectUrl += "?campaignId=" + lead.getCampaignId();
                }
                response.sendRedirect(redirectUrl);
            } else {
                throw new Exception("Tạo lead thất bại.");
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
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

            // Cập nhật thông tin cơ bản (không đụng campaign)
            Lead lead = extractLeadFromRequestForUpdate(request);
            lead.setLeadId(leadId);
            if (!leadService.updateLead(lead, false)) {
                throw new Exception("Cập nhật lead thất bại.");
            }

            // Cập nhật campaign membership theo checkbox
            List<Integer> selectedCampaignIds = parseSelectedCampaigns(request);
            leadService.updateLeadCampaigns(leadId, selectedCampaignIds);

            // Log activity
            User sessionUser = (User) request.getSession().getAttribute("user");
            LeadActivityUtil.logLeadActivity(
                    leadId, lead.getFullName(),
                    "Lead Updated - " + lead.getFullName(),
                    "Lead information and campaigns updated",
                    sessionUser);

            request.getSession().setAttribute("successMessage",
                    "Lead \"" + lead.getFullName() + "\" đã được cập nhật thành công!");

            // Redirect về ĐẦU danh sách lead (page=1, không filter)
            // updated_at vừa được cập nhật → lead tự lên đầu (ORDER BY updated_at DESC)
            response.sendRedirect(request.getContextPath() + "/marketing/leads");

        } catch (Exception e) {
            Lead lead = extractLeadFromRequestSafe(request);
            lead.setLeadId(leadId);
            request.setAttribute("lead", lead);
            request.setAttribute("error", e.getMessage());

            // Re-load leadCampaigns khi forward lại form sau lỗi
            if (leadId > 0) {
                List<Campaign> leadCampaigns = campaignLeadDAO.getCampaignsByLeadEmail(leadId);
                request.setAttribute("leadCampaigns", leadCampaigns);
            }

            forwardForm(request, response, "Chỉnh sửa Lead - CRM");
        }
    }

    // ======================================================================
    // Helper: đọc danh sách campaignId[] được tích từ checkbox
    // ======================================================================
    private List<Integer> parseSelectedCampaigns(HttpServletRequest request) {
        List<Integer> result = new ArrayList<>();
        String[] values = request.getParameterValues("selectedCampaigns");
        if (values != null) {
            for (String v : values) {
                try {
                    result.add(Integer.parseInt(v));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return result;
    }

    // ======================================================================
    // Helper: extract Lead fields — dùng khi TẠO MỚI (có đọc campaignId)
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
        if (!EmailCheck.isValidEmail(email.trim())) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
        if (phone != null && !phone.trim().isEmpty() && !PhoneCheck.isValidPhone(phone.trim())) {
            throw new IllegalArgumentException("Số điện thoại phải gồm đúng 10 chữ số.");
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
            lead.setCampaignId(campaignIdStr != null && !campaignIdStr.isEmpty() ? Integer.parseInt(campaignIdStr) : 0);
        } catch (NumberFormatException e) {
            lead.setCampaignId(0);
        }

        try {
            lead.setAssignedTo(assignedToStr != null && !assignedToStr.isEmpty() ? Integer.parseInt(assignedToStr) : 0);
        } catch (NumberFormatException e) {
            lead.setAssignedTo(0);
        }

        return lead;
    }

    // ======================================================================
    // Helper: extract Lead fields — dùng khi UPDATE (không đọc campaignId)
    // campaign xử lý riêng qua checkbox selectedCampaigns
    // ======================================================================
    private Lead extractLeadFromRequestForUpdate(HttpServletRequest request) {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String interest = request.getParameter("interest");
        String source = request.getParameter("source");
        String status = request.getParameter("status");
        String scoreStr = request.getParameter("score");
        String assignedToStr = request.getParameter("assignedTo");

        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        if (!EmailCheck.isValidEmail(email.trim())) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
        if (phone != null && !phone.trim().isEmpty() && !PhoneCheck.isValidPhone(phone.trim())) {
            throw new IllegalArgumentException("Số điện thoại phải gồm đúng 10 chữ số.");
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

        lead.setCampaignId(0); // LeadService.updateLead() tự restore từ DB

        try {
            lead.setAssignedTo(assignedToStr != null && !assignedToStr.isEmpty() ? Integer.parseInt(assignedToStr) : 0);
        } catch (NumberFormatException e) {
            lead.setAssignedTo(0);
        }

        return lead;
    }

    /**
     * Safe version: re-populate form sau lỗi validation
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
            lead.setCampaignId(campaignIdStr != null && !campaignIdStr.isEmpty() ? Integer.parseInt(campaignIdStr) : 0);
            String assignedToStr = request.getParameter("assignedTo");
            lead.setAssignedTo(assignedToStr != null && !assignedToStr.isEmpty() ? Integer.parseInt(assignedToStr) : 0);
        } catch (Exception ignored) {
        }
        return lead;
    }
}
