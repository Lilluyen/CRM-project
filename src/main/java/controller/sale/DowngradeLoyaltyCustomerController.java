package controller.sale;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import dao.CustomerDAO;
import dao.CustomerMeasurementDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
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

            CustomerDAO customerDAO = new CustomerDAO();
            CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
            CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
            CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();
            CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

            CustomerService customerService = new CustomerService(
                    customerDAO,
                    customerStyleDAO,
                    customerQueryDAO,
                    customerMeasurementDAO,
                    customerSegmentDAO);

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
