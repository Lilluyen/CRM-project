package controller.notifications;

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
 * Inbox-style list for current user (timeline).
 */
@WebServlet("/notifications/list")
public class NotificationListController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationListController.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);
            List<Notification> list = ns.getAllForUser(user.getUserId());
            int unreadCount = ns.countUnread(user.getUserId());

            req.setAttribute("notifications", list);
            req.setAttribute("unreadCount", unreadCount);
            req.setAttribute("pageTitle", "Notifications");
            req.setAttribute("contentPage", "/view/notifications/notification-list.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Cannot load notifications list", ex);
            resp.sendError(500);
        }
    }
}

