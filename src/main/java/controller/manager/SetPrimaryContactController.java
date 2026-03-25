package controller.manager;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.CustomerService;
import util.*;

import java.io.IOException;
import model.User;

@WebServlet(name = "SetPrimaryContactController", urlPatterns = { "/customers/contacts/set-primary" })
public class SetPrimaryContactController extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();

    private final CustomerService customerService = new CustomerService(
            customerDAO, customerStyleDAO, customerQueryDAO,
            customerSegmentDAO, contactDAO, noteDAO);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String contactIdRaw = req.getParameter("contactId");
        String customerIdRaw = req.getParameter("customerId");
        String primaryValue = req.getParameter("primaryValue");

        int contactId, customerId;
        try {
            contactId = Integer.parseInt(contactIdRaw);
            customerId = Integer.parseInt(customerIdRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }

        try {
            customerService.setPrimaryContact(contactId, customerId);
            CustomerActivityUtil.logCustomerActivity(customerId, "UPDATE", "Customer updated",
                    "Set " + primaryValue + " to primary contact.",
                    (User) session.getAttribute("user"));
            resp.sendRedirect(req.getContextPath()
                    + "/customers/edit?customerId=" + customerId
                    + "&status=primary-updated");
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath()
                    + "/customers/edit?customerId=" + customerId
                    + "&status=failed");
        } catch (Exception e) {
            log("Set primary contact error", e);
            resp.sendRedirect(req.getContextPath()
                    + "/customers/edit?customerId=" + customerId
                    + "&status=failed");
        }
    }
}