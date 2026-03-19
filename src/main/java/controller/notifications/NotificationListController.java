package controller.notifications;

import dto.Pagination;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Notification;
import model.User;
import service.NotificationService;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /notifications/list
 * Inbox-style list for current user (timeline) with pagination.
 */
@WebServlet("/notifications/list")
public class NotificationListController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationListController.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int[] ALLOWED_SIZES = {5, 10, 15, 20};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int page = parsePage(req.getParameter("page"));
        int pageSize = parsePageSize(req.getParameter("pageSize"));

        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);

            // Get total count for pagination
            int total = ns.countAllForUser(user.getUserId());
            Pagination pagination = new Pagination(page, pageSize, total);

            // Get paginated notifications
            List<Notification> list = ns.getAllForUserPaged(user.getUserId(),
                    pagination.getCurrentPage(), pagination.getPageSize());
            int unreadCount = ns.countUnread(user.getUserId());

            req.setAttribute("notifications", list);
            req.setAttribute("pagination", pagination);
            req.setAttribute("unreadCount", unreadCount);

            // Convenience aliases for legacy JSP
            req.setAttribute("currentPage", pagination.getCurrentPage());
            req.setAttribute("totalPages", pagination.getTotalPages());
            req.setAttribute("totalRecords", pagination.getTotalItems());
            req.setAttribute("pageSize", pagination.getPageSize());

            req.setAttribute("pageTitle", "Notifications");
            req.setAttribute("contentPage", "/view/notifications/notification-list.jsp");
            req.setAttribute("page", "notification-list");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Cannot load notifications list", ex);
            resp.sendError(500);
        }
    }

    private int parsePage(String val) {
        try {
            int p = Integer.parseInt(val);
            return p > 0 ? p : 1;
        } catch (Exception e) {
            return 1;
        }
    }

    private int parsePageSize(String val) {
        try {
            int s = Integer.parseInt(val);
            for (int a : ALLOWED_SIZES) if (a == s) return s;
        } catch (Exception ignored) {
        }
        return DEFAULT_PAGE_SIZE;
    }
}
