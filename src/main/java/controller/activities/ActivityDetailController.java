package controller.activities;

import model.Activity;
import model.User;
import service.ActivityService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /activities/details?id={activityId}
 * Hiển thị trang chi tiết của một activity.
 */
@WebServlet("/activities/details")
public class ActivityDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (req.getParameter("id") == null) {
            resp.sendRedirect(req.getContextPath()+"/activities/list");
        }
        int id = Integer.parseInt(req.getParameter("id"));
        try (Connection conn = DBContext.getConnection()) {
            Activity activity = new ActivityService(conn).getActivityById(id);
            if (activity == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Activity không tồn tại: id=" + id);
                return;
            }
            req.setAttribute("activity",    activity);
            req.setAttribute("pageTitle",   "Activity Details – " + activity.getSubject());
            req.setAttribute("contentPage", "/view/activities/activity-detail.jsp");
            req.setAttribute("page", "activity-details");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(ActivityDetailController.class.getName()).log(Level.SEVERE, null, ex);
            
        }
    }
}
