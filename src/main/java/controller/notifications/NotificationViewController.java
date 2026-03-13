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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /notifications/view?id=... Mark-as-read then redirect to related entity
 * view (Task/Lead/Deal...).
 */
@WebServlet("/notifications/view")
public class NotificationViewController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationViewController.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int notifId;
        try {
            notifId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/notifications/list");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);
            ns.markAsRead(notifId, user.getUserId());

            Notification n = ns.getById(notifId);
            if (n == null) {
                resp.sendRedirect(req.getContextPath() + "/notifications/list");
                return;
            }

            String rt = n.getRelatedType() != null ? n.getRelatedType().toLowerCase() : "";
            Integer rid = n.getRelatedId();

            if (rid != null) {

                switch (rt) {

                    case "task":
                        resp.sendRedirect(req.getContextPath() + "/tasks/details?id=" + rid);
                        return;

//                    case "deal":
//                        resp.sendRedirect(req.getContextPath() + "/deals/details?id=" + rid);
//                        return;

                    case "lead":
                        resp.sendRedirect(req.getContextPath() + "marketing/leads/details?id=" + rid);
                        return;

//                    case "ticket":
//                        resp.sendRedirect(req.getContextPath() + "/tickets/details?id=" + rid);
//                        return;

                    case "customer":
                        resp.sendRedirect(req.getContextPath() + "/customers/detail?customerId=" + rid);
                        return;

                    case "campaign":
                        resp.sendRedirect(req.getContextPath() + "/marketing/campaigns/details?id=" + rid);
                        return;

//                    case "security":
//                        resp.sendRedirect(req.getContextPath() + "/customers/details?id=" + rid);
//                        return;

                    default:
                        break;
                }
            }

            // system, report hoặc không có related id
            resp.sendRedirect(req.getContextPath() + "/notifications/list");

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Cannot view notification", ex);
            resp.sendRedirect(req.getContextPath() + "/notifications/list");
        }
    }
}
