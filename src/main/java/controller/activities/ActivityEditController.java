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
 * GET  /activities/edit?id={activityId}  – hiển thị form chỉnh sửa
 * POST /activities/edit                   – lưu thay đổi, redirect sang details
 */
@WebServlet("/activities/edit")
public class ActivityEditController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

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
            req.setAttribute("pageTitle",   "Edit Activity");
            req.setAttribute("contentPage", "/view/activities/activity-edit.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(ActivityEditController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int activityId = Integer.parseInt(req.getParameter("activityId"));
        Activity activity = buildActivity(req);
        activity.setActivityId(activityId);

        try (Connection conn = DBContext.getConnection()) {
            ActivityService svc = new ActivityService(conn);
            boolean ok = svc.updateActivity(activity);

            if (!ok) {
                Activity existing = svc.getActivityById(activityId);
                req.setAttribute("activity",    existing != null ? existing : activity);
                req.setAttribute("error",       "Cập nhật thất bại. Vui lòng thử lại.");
                req.setAttribute("pageTitle",   "Edit Activity");
                req.setAttribute("contentPage", "/view/activities/activity-edit.jsp");
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }

            req.getSession().setAttribute("flashSuccess", "Activity đã được cập nhật.");
            resp.sendRedirect(req.getContextPath() + "/activities/details?id=" + activityId);
        } catch (SQLException ex) {
            Logger.getLogger(ActivityEditController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private Activity buildActivity(HttpServletRequest req) {
        Activity a = new Activity();
        a.setSubject(req.getParameter("subject"));
        a.setActivityType(req.getParameter("activityType"));
        a.setRelatedType(req.getParameter("relatedType"));
        a.setDescription(req.getParameter("description"));

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
