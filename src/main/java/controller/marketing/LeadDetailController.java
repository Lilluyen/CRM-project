package controller.marketing;

import java.io.IOException;
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

@WebServlet(name = "LeadDetailController", urlPatterns = {"/marketing/leads/detail"})
public class LeadDetailController extends HttpServlet {

    private final LeadService leadService = new LeadService();
    private final CampaignService campaignService = new CampaignService();
    private final CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/marketing/leads");
            return;
        }

        try {
            int leadId = Integer.parseInt(idParam);
            Lead lead = leadService.getLeadById(leadId);

            if (lead == null) {
                request.getSession().setAttribute("errorMessage", "Lead is not found.");
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
                return;
            }

            // Load tên người được assign
            if (lead.getAssignedTo() > 0) {
                User assignedUser = userDAO.getUserById(lead.getAssignedTo());
                if (assignedUser != null) {
                    lead.setAssignedToName(assignedUser.getFullName());
                }
            }

            request.setAttribute("lead", lead);

            // ---------------------------------------------------------------
            // FIX: Dùng getCampaignsByLeadEmail() thay vì getCampaignsByLeadId()
            //
            // Lý do: searchLeads() hiển thị 1 đại diện per email (MIN lead_id),
            // lead_id đó chỉ có 1 row trong Campaign_Leads.
            // getCampaignsByLeadEmail() query qua TẤT CẢ lead_id có cùng email
            // → trả về đủ tất cả campaigns mà người này đã tham gia.
            // ---------------------------------------------------------------
            List<Campaign> leadCampaigns = campaignLeadDAO.getCampaignsByLeadEmail(leadId);
            request.setAttribute("leadCampaigns", leadCampaigns);

            // Tất cả campaigns trong hệ thống (cho checkbox cập nhật)
            List<Campaign> allCampaigns = campaignService.getAllCampaigns();
            request.setAttribute("allCampaigns", allCampaigns);

            // Load danh sách users
            List<User> users = userDAO.getActiveUsers();
            request.setAttribute("users", users);

            // Flash success message (PRG pattern)
            String successMsg = (String) request.getSession().getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("success", successMsg);
                request.getSession().removeAttribute("successMessage");
            }

            request.setAttribute("pageTitle", lead.getFullName() + " - CRM");
            request.setAttribute("contentPage", "marketing/lead/lead_detail.jsp");
            request.setAttribute("pageCss", "lead_detail.css");
            request.setAttribute("page", "lead-detail");

            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/marketing/leads");
        }
    }
}