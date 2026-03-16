package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.SegmentDetailService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = "/customers/update-segment")
public class UpdateSegmentController extends HttpServlet {
    private final SegmentDetailService service = new SegmentDetailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int segmentId = Integer.parseInt(req.getParameter("segment_id"));
            resp.sendRedirect(req.getContextPath() + "/customers/segment-detail?segment_id=" + segmentId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments");
            throw new RuntimeException(e);
        }

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        try {
            int segmentId = Integer.parseInt(req.getParameter("segment_id"));
            String segmentName = req.getParameter("segment_name");
            String segmentType = req.getParameter("segment_type");
            String logic = req.getParameter("criteria_logic");

            String currentName = req.getParameter("current_name");
            String currentType = req.getParameter("current_type");
            String currentLogic = req.getParameter("current_logic");

            if (segmentName == null && logic == null) {
                return;
            }
            service.updateSegmentation(segmentId, segmentName, logic, segmentType, user.getUserId(), currentName, currentType, currentLogic);
            resp.sendRedirect(req.getContextPath() + "/customers/segment-detail?status=success&segment_customer=" + segmentId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=failed");
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments?created=failed");
            throw new RuntimeException(e);
        }
    }
}
