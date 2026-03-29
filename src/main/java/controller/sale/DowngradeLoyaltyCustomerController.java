package controller.sale;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.CustomerService;
import util.CustomerActivityUtil;

import java.io.IOException;

@WebServlet(urlPatterns = "/customers/downgrade")
public class DowngradeLoyaltyCustomerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String customerIdParam = req.getParameter("customerId");
        try {
            if (customerIdParam == null || customerIdParam.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                return;
            }

            int customerId;
            try {
                customerId = Integer.parseInt(customerIdParam);
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                return;
            }

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

            boolean success = customerService.downgradeToLoyaltyCustomer(customerId);
            if (success) {
                User user = (User) req.getSession().getAttribute("user");
                CustomerActivityUtil.logCustomerActivity(
                        customerId,
                        "UPDATE",
                        "Loyalty downgraded",
                        "Downgraded customer loyalty tier.",
                        user);
                resp.sendRedirect(req.getContextPath() + "/customers?status=success");
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                return;
            }

        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }
    }

}
