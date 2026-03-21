package controller.sale;

import dao.CustomerDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/customers/upgrade")
public class UpgradeLoyaltyCustomerController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String customerIdParam = request.getParameter("customerId");
            if (customerIdParam == null || customerIdParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
                return;
            }

            int customerId;
            try {
                customerId = Integer.parseInt(customerIdParam);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
                return;
            }

            boolean success = customerService.upgradeToLoyaltyCustomer(customerId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers?status=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            }
        } catch (SQLException ex) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            throw new ServletException("Database error while upgrading customer: " + ex.getMessage(), ex);
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        }
    }

}
