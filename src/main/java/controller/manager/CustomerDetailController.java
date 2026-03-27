package controller.manager;

import dao.*;
import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CustomerMergeRequest;
import model.Deal;
import model.CustomerContact;
import model.CustomerNote;
import model.StyleTag;
import model.Task;
import service.CustomerService;
import service.MergeRequestService;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet(name = "CustomerDetailController", urlPatterns = { "/customers/detail" })
public class CustomerDetailController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();
    private final MergeRequestDAO mergeRequestDAO = new MergeRequestDAO();
    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO,
            contactDAO, noteDAO);

    private final MergeRequestService mergeRequestService = new MergeRequestService(
            mergeRequestDAO, customerDAO, customerStyleDAO,
            contactDAO, noteDAO, customerQueryDAO);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String customerIdRaw = request.getParameter("customerId");

            if (customerIdRaw == null || customerIdRaw.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/customers");
                return;
            }
            int customerId;
            try {
                customerId = Integer.parseInt(customerIdRaw);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/customers");

                return;
            }

            // GỌI SERVICE
            CustomerDetailDTO customerDetail = customerService.getCustomerDetail(customerId);
            List<StyleTag> styleTags = customerService.getListStyleTags();
            int totalDeals = customerService.countDealByCusId(customerId);
            List<Deal> deals = customerService.getListDealsByCusId(customerId);
            if (customerDetail == null) {
                response.sendRedirect(request.getContextPath() + "/customers");
                return;
            }

            // Trong CustomerDetailController.doGet() — thêm 2 dòng:
            List<CustomerMergeRequest> mergeRequests = mergeRequestService.getByCustomerId(customerId);
            request.setAttribute("mergeRequests", mergeRequests);

            // Customer report data (contacts, notes, completed tasks)
            try (Connection conn = DBContext.getConnection()) {
                List<CustomerContact> contacts = contactDAO.getByCustomerId(conn, customerId);
                List<CustomerNote> notes = noteDAO.getByCustomerId(conn, customerId);
                TaskDAO taskDAO = new TaskDAO(conn);
                List<Task> completedTasks = taskDAO.findCompletedByRelated("customer", customerId, 20);

                request.setAttribute("contacts", contacts);
                request.setAttribute("notes", notes);
                request.setAttribute("completedTasks", completedTasks);
            }

            String activeTab = request.getParameter("tab");
            request.setAttribute("activeTab", activeTab != null ? activeTab : "growth");

            // Set data cho view
            request.setAttribute("customerDetail", customerDetail);
            request.setAttribute("allStyleTags", styleTags);
            request.setAttribute("totalDeals", totalDeals);
            request.setAttribute("deals", deals);

            // Layout attributes
            request.setAttribute("pageTitle", "Customer Detail | Clothes CRM");
            request.setAttribute("contentPage", "customer/customer_detail.jsp");
            request.setAttribute("pageCss", "customer_detail.css");
            // request.setAttribute("pageJs", "customer_detail.js");
            request.setAttribute("page", "customer-detail");

            request.getRequestDispatcher("/view/layout.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customers");

        } catch (Exception e) {

            log("Error while loading customer detail", e);
            response.sendRedirect(request.getContextPath() + "/customers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("addNote".equalsIgnoreCase(action)) {
            String customerIdRaw = request.getParameter("customerId");
            String noteText = request.getParameter("note");

            int customerId;
            try {
                customerId = Integer.parseInt(customerIdRaw);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/customers");
                return;
            }

            if (noteText != null) noteText = noteText.trim();
            if (noteText == null || noteText.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId + "&tab=notes");
                return;
            }

            Integer userId = 0;
            Object u = request.getSession().getAttribute("user");
            if (u instanceof model.User user) {
                userId = user.getUserId();
            }

            try (Connection conn = DBContext.getConnection()) {
                noteDAO.insertCustomerNote(conn, new CustomerNote(customerId, noteText, userId));
            } catch (Exception e) {
                log("Error while adding customer note", e);
            }

            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId + "&tab=notes");
            return;
        }

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}