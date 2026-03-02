package controller.manager;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

@WebServlet("/customers/remove")
public class CustomerRemoveController extends HttpServlet {

    private CustomerService customerService;

    @Override
    public void init() throws ServletException {
        customerService = new CustomerService();
    }

    /**
     * Xóa khách hàng theo ID
     * GET: /customers/remove?id=123
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter("customerId");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Customer ID is required");
                return;
            }

            int customerId;
            try {
                customerId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customer ID format");
                return;
            }

            boolean deleted = customerService.removeCustomer(customerId);

            if (deleted) {
                request.getSession().setAttribute("successMessage", "Khách hàng đã được xóa thành công");
                response.sendRedirect(request.getContextPath() + "/customers");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khách hàng không tồn tại");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }

    /**
     * Xóa khách hàng bằng POST (JSON API)
     * POST: /customer/remove
     * Body: { "customerId": 123 }
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

}
