package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerSegmentService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = "/customers/remove-segmentation")
public class RemoveSegmentationController extends HttpServlet {

    private final CustomerSegmentService service = new CustomerSegmentService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/customers/segments");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String segmentIdRaw = req.getParameter("segment_id");
        try {
            int segmentId = Integer.parseInt(segmentIdRaw);
            boolean isRemoved = service.removeSegmentation(segmentId);
            if (isRemoved) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");
            }
        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");
        }
    }
}
