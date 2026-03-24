package controller.manager;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.CustomerService;

import java.io.IOException;

@WebServlet(name = "DeleteContactController", urlPatterns = {"/customers/contacts/delete"})
public class DeleteContactController extends HttpServlet {

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

        int contactId, customerId;
        try {
            contactId = Integer.parseInt(contactIdRaw);
            customerId = Integer.parseInt(customerIdRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }

        try {
            boolean deleted = customerService.deleteContact(contactId, customerId);

            if (deleted) {
                resp.sendRedirect(req.getContextPath()
                        + "/customers/edit?customerId=" + customerId
                        + "&status=contact-deleted");
            } else {
                // contactId không thuộc customerId này → ai đó giả mạo request
                resp.sendRedirect(req.getContextPath()
                        + "/customers/edit?customerId=" + customerId
                        + "&status=failed");
            }
        } catch (Exception e) {
            log("Delete contact error", e);
            resp.sendRedirect(req.getContextPath()
                    + "/customers/edit?customerId=" + customerId
                    + "&status=failed");
        }
    }
}