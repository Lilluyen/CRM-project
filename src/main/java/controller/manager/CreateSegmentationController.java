package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.CustomerSegmentService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = "/customers/create-segment")
public class CreateSegmentationController extends HttpServlet {

    private final CustomerSegmentService service = new CustomerSegmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/customers/segments");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String segmentName = req.getParameter("segment_name");
        String logic = req.getParameter("criteria_logic");
        String type = req.getParameter("type");
        HttpSession session = req.getSession(false);

        if (session != null) {
            User user = (User) session.getAttribute("user");

            if (segmentName == null || segmentName.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");
            }
            if (segmentName.length() > 255) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");

            }
            if (logic.length() > 1000) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");

            }
            if (!type.equals("STATIC") && !type.equals("DYNAMIC")) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");
            }

            try {
                boolean isCreated = service.createSegmentation(segmentName, logic, type, user.getUserId());

                if (isCreated) {
                    resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Success");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");
                }

            } catch (SQLException e) {
                resp.sendRedirect(req.getContextPath() + "/customers/segments?created=Failed");

                throw new RuntimeException(e);
            }
        }
    }
}
