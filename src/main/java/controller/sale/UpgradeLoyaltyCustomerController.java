package controller.sale;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

@WebServlet("/customers/upgrade")
public class UpgradeLoyaltyCustomerController extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String customerIdParam = request.getParameter("customerId");
            if (customerIdParam == null || customerIdParam.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Customer ID is required");
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
                return;
            }
            
            int customerId;
            try {
                customerId = Integer.parseInt(customerIdParam);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Customer ID");
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
