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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /activities/create  – hiển thị form tạo activity
 * POST /activities/create  – lưu activity mới, redirect sang list
 */
@WebServlet("/activities/create")
public class ActivityCreateController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.setAttribute("pageTitle",   "Create Activity");
        req.setAttribute("contentPage", "/view/activities/activity-create.jsp");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Activity activity = buildActivity(req, user);

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new ActivityService(conn).createActivity(activity);

            if (!ok) {
                req.setAttribute("error",       "Không thể tạo activity. Vui lòng kiểm tra lại.");
                req.setAttribute("activity",    activity);
                req.setAttribute("pageTitle",   "Create Activity");
                req.setAttribute("contentPage", "/frontend/activities/activity-create.jsp");
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }

            req.getSession().setAttribute("flashSuccess", "Activity \"" + activity.getSubject() + "\" đã được tạo.");
            resp.sendRedirect(req.getContextPath() + "/activities/list");
        } catch (SQLException ex) {
            Logger.getLogger(ActivityCreateController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private Activity buildActivity(HttpServletRequest req, User creator) {
        Activity a = new Activity();
        a.setSubject(req.getParameter("subject"));
        a.setActivityType(req.getParameter("activityType"));
        a.setRelatedType(req.getParameter("relatedType"));
        a.setDescription(req.getParameter("description"));
        a.setCreatedBy(creator);

        String relId = req.getParameter("relatedId");
        if (relId != null && !relId.isBlank()) {
            a.setRelatedId(Integer.parseInt(relId));
        }

        String dt = req.getParameter("activityDate");
        if (dt != null && !dt.isBlank()) {
            a.setActivityDate(LocalDateTime.parse(dt, DT_FMT));
        }
        return a;
    }
}
