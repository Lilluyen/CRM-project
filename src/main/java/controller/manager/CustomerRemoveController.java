package controller.manager;

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

@WebServlet("/customers/remove")
public class CustomerRemoveController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();

    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,

            customerSegmentDAO);

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
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
                return;
            }

            int customerId;
            try {
                customerId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
                return;
            }

            boolean deleted = customerService.removeCustomer(customerId);

            if (deleted) {
                request.getSession().setAttribute("successMessage", "Khách hàng đã được xóa thành công");
                response.sendRedirect(request.getContextPath() + "/customers?status=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?status=failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
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
