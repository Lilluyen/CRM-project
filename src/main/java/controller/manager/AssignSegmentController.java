package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.CustomerSegmentService;
import util.CustomerActivityUtil;

import java.io.IOException;

@WebServlet(urlPatterns = "/customers/assign-segment")
public class AssignSegmentController extends HttpServlet {

    private final CustomerSegmentService segmentService = new CustomerSegmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/customers");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {


        try {
            int segmentId = Integer.parseInt(req.getParameter("segmentId"));
            String customerIdsStr = req.getParameter("customerIds"); // "1,2,3"

            if (customerIdsStr == null || customerIdsStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                return;
            }

            String[] ids = customerIdsStr.split(",");

            int successCount = 0;
            User user = (User) req.getSession().getAttribute("user");

            for (String id : ids) {
                int customerId = Integer.parseInt(id);

                // 🔥 check đã tồn tại chưa
                boolean exists = segmentService.isCustomerInSegment(segmentId, customerId);

                if (!exists) {
                    segmentService.insertCustomersToSegment(segmentId, " customer_id = " + customerId);
                    CustomerActivityUtil.logCustomerActivity(
                            customerId,
                            "UPDATE",
                            "Segment assigned",
                            "Added customer to segment #" + segmentId + ".",
                            user);
                    successCount++;
                }
            }

            segmentService.updateSegmentCount(segmentId);

            // 👉 redirect + message
            if (successCount > 0)
                resp.sendRedirect(req.getContextPath() + "/customers?status=success");
            else {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            }

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }
}
