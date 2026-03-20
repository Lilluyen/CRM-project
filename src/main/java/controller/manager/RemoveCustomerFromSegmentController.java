package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerSegmentService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = "/customers/segment/remove-customer")
public class RemoveCustomerFromSegmentController extends HttpServlet {

    private final CustomerSegmentService service = new CustomerSegmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/customers/segments");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(req.getParameter("customer_id"));
            int segmentId = Integer.parseInt(req.getParameter("segment_id"));
            service.removeCustomer(customerId, segmentId);
            service.updateSegmentCount(segmentId);
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=success");
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=failed");
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=failed");
            throw new RuntimeException(e);
        }
    }
}
