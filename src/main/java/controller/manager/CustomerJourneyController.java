package controller.manager;

import dao.*;
import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Activity;
import model.Lead;
import model.User;
import service.ActivityService;
import service.CustomerService;
import service.LeadService;
import util.ControllerUltil;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

/**
 * Hiển thị lịch sử hành trình chăm sóc khách hàng theo từng Activity.
 * <p>
 * Tham số:
 * type=customer&customerId=...  -> xem hành trình từ Customer (ngược thời gian)
 * type=lead&leadId=...        -> xem hành trình từ Lead (xuôi thời gian)
 */
@WebServlet(name = "CustomerJourneyController", urlPatterns = {"/customer-journey"})
public class CustomerJourneyController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String type = request.getParameter("type");
        boolean isLead = "lead".equalsIgnoreCase(type);

        try (Connection conn = DBContext.getConnection()) {
            ActivityService activityService = new ActivityService(conn);

            if (isLead) {
                String leadIdRaw = request.getParameter("leadId");
                if (leadIdRaw == null || leadIdRaw.isBlank()) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "leadId is required");
                    return;
                }

                int leadId = Integer.parseInt(leadIdRaw);
                Lead lead = new LeadService().getLeadById(leadId);
                if (lead == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Lead not found");
                    return;
                }

                List<Activity> activities = activityService.getLeadJourney(leadId);

                request.setAttribute("entityType", "Lead");
                request.setAttribute("entityName", lead.getFullName());
                request.setAttribute("entityId", leadId);
                request.setAttribute("activities", activities);
                request.setAttribute("journeyTitle", "Lead Journey");
                request.setAttribute("backUrl", request.getContextPath() + "/marketing/leads/detail?id=" + leadId);

            } else {
                String customerIdRaw = request.getParameter("customerId");
                if (customerIdRaw == null || customerIdRaw.isBlank()) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "customerId is required");
                    return;
                }

                int customerId = Integer.parseInt(customerIdRaw);

                CustomerDAO customerDAO = new CustomerDAO();
                CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
                CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
                CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

                CustomerContactDAO contactDAO = new CustomerContactDAO();
                CustomerNoteDAO noteDAO = new CustomerNoteDAO();
                CustomerService customerService = new CustomerService(
                        customerDAO,
                        customerStyleDAO,
                        customerQueryDAO,
                        customerSegmentDAO,
                        contactDAO, noteDAO);
                CustomerDetailDTO customerDetail = customerService.getCustomerDetail(customerId);
                if (customerDetail == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
                    return;
                }

                List<Activity> activities = activityService.getCustomerJourney(customerId);

                request.setAttribute("entityType", "Customer");
                request.setAttribute("entityName", customerDetail.getName());
                request.setAttribute("entityId", customerId);
                request.setAttribute("activities", activities);
                request.setAttribute("journeyTitle", "Customer Journey");
                request.setAttribute("backUrl", request.getContextPath() + "/customers/detail?customerId=" + customerId);
            }

            request.setAttribute("pageTitle", "Customer Journey | CRM");
            request.setAttribute("contentPage", "customer/customer_journey.jsp");
            request.setAttribute("pageCss", "customer_journey.css");
            request.setAttribute("page", "customer-journey");

            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid id parameter");
        } catch (Exception e) {
            log("Error while loading customer journey", e);
            ControllerUltil.forwardError(
                    request,
                    response,
                    "Internal server error occurred while processing your request.");
        }
    }

}
