package controller.activities;

import dto.Pagination;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/activities/list")
public class ActivityListController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String subject      = req.getParameter("subject");
        String activityType = req.getParameter("activityType");
        String relatedType  = req.getParameter("relatedType");
        String sortField    = req.getParameter("sortField") != null ? req.getParameter("sortField") : "";
        String sortDir      = req.getParameter("sortDir")   != null ? req.getParameter("sortDir")   : "";
        int    page         = parsePage(req);
        int    pageSize     = parsePageSize(req);

        try (Connection conn = DBContext.getConnection()) {
            ActivityService svc = new ActivityService(conn);

            List<Activity> activities = svc.getActivitiesPaged(
                    subject, activityType, relatedType, sortField, sortDir, page, pageSize);
            int total = svc.countActivities(subject, activityType, relatedType);

            req.setAttribute("activities", activities);
            req.setAttribute("pagination", new Pagination(page, pageSize, total)); // ← (currentPage, pageSize, totalItems)

            req.setAttribute("pageTitle",   "Activity List");
            req.setAttribute("contentPage", "/view/activities/activities.jsp");
            req.setAttribute("page",        "activity-list");

            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (SQLException ex) {
            Logger.getLogger(ActivityListController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private int parsePage(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return p > 0 ? p : 1;
        } catch (Exception e) {
            return 1;
        }
    }

    private int parsePageSize(HttpServletRequest req) {
        try {
            int s = Integer.parseInt(req.getParameter("pageSize"));
            return s > 0 ? s : DEFAULT_PAGE_SIZE;
        } catch (Exception e) {
            return DEFAULT_PAGE_SIZE;
        }
    }
}
