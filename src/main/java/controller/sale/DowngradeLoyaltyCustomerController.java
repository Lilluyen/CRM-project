package controller.sale;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import service.CustomerService;

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

            CustomerService customerService = new CustomerService();

            boolean success = customerService.downgradeToLoyaltyCustomer(customerId);
            if (success) {
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
