package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Lead;
import service.LeadService;

@WebServlet(name = "LeadDetailController", urlPatterns = {"/marketing/leads/detail"})
public class LeadDetailController extends HttpServlet {

    private final LeadService leadService = new LeadService();

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
                request.getSession().setAttribute("errorMessage", "Lead không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/marketing/leads");
                return;
            }

            request.setAttribute("lead", lead);

            // Flash success message from session (PRG pattern)
            String successMsg = (String) request.getSession().getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("success", successMsg);
                request.getSession().removeAttribute("successMessage");
            }

            // Layout attributes
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
