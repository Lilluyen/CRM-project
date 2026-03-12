package controller.notifications;

import dto.Pagination;
import model.Notification;
import model.NotificationRule;
import model.User;
import service.NotificationRuleService;
import service.NotificationService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /notifications/rules/manage
 * POST /notifications/rules/manage
 *
 * Manage (create/edit) notification reminder rules.
 */
@WebServlet("/notifications/rules/manage")
public class NotificationRuleManageController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationRuleManageController.class.getName());

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

        boolean isManager = isManagerOrAdmin(user);

        int notifPage = parsePage(req.getParameter("notifPage"));
        int notifPageSize = parsePageSize(req.getParameter("notifPageSize"));

        Integer ruleId = null;
        try {
            String ruleIdParam = req.getParameter("ruleId");
            if (ruleIdParam != null && !ruleIdParam.isBlank()) {
                ruleId = Integer.valueOf(ruleIdParam);
            }
        } catch (Exception ignored) {
        }

        Integer selectedNotificationId = null;
        try {
            String nParam = req.getParameter("notificationId");
            if (nParam != null && !nParam.isBlank()) {
                selectedNotificationId = Integer.valueOf(nParam);
            }
        } catch (Exception ignored) {
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationRuleService ruleSvc = new NotificationRuleService(conn);
            NotificationService notifSvc = new NotificationService(conn);

            NotificationRule rule = null;
            Notification selectedNotification = null;

            if (ruleId != null) {
                rule = ruleSvc.getRuleById(ruleId);
                if (rule != null) {
                    selectedNotificationId = rule.getNotificationId();
                }
            }

            if (selectedNotificationId != null) {
                selectedNotification = notifSvc.getById(selectedNotificationId);
            }

            // If user is not admin/manager, ensure the user is recipient of the notification (or of the rule base notification)
            if (!isManager && selectedNotification != null) {
                if (!notifSvc.isRecipient(selectedNotification.getNotificationId(), user.getUserId())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            }

            int totalNotifications = ruleSvc.countNotificationsForUser(user.getUserId(), isManager);
            Pagination notifPagination = new Pagination(notifPage, notifPageSize, totalNotifications);
            List<Notification> notifications = ruleSvc.listNotificationsForUser(user.getUserId(), isManager,
                    notifPagination.getCurrentPage(), notifPagination.getPageSize());

            req.setAttribute("rule", rule);
            req.setAttribute("selectedNotification", selectedNotification);
            req.setAttribute("notifications", notifications);
            req.setAttribute("notifPagination", notifPagination);
            req.setAttribute("isManager", isManager);
            req.setAttribute("pageTitle", rule == null ? "Create Rule" : "Edit Rule");
            req.setAttribute("contentPage", "/view/notifications/rule-form.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Cannot load rule form", ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
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

        boolean isManager = isManagerOrAdmin(user);

        // Parse inputs
        Integer ruleId = null;
        try {
            String ruleIdParam = req.getParameter("ruleId");
            if (ruleIdParam != null && !ruleIdParam.isBlank()) ruleId = Integer.valueOf(ruleIdParam);
        } catch (Exception ignored) {
        }

        Integer notificationId = null;
        try {
            String nId = req.getParameter("notificationId");
            if (nId != null && !nId.isBlank()) notificationId = Integer.valueOf(nId);
        } catch (Exception ignored) {
        }

        String title = req.getParameter("title");
        String content = req.getParameter("content");
        String type = req.getParameter("type");
        String relatedType = req.getParameter("relatedType");
        Integer relatedId = null;
        try {
            String rid = req.getParameter("relatedId");
            if (rid != null && !rid.isBlank()) relatedId = Integer.valueOf(rid);
        } catch (Exception ignored) {
        }

        String ruleType = req.getParameter("ruleType");
        Integer intervalValue = null;
        try {
            String iv = req.getParameter("intervalValue");
            if (iv != null && !iv.isBlank()) intervalValue = Integer.valueOf(iv);
        } catch (Exception ignored) {
        }
        String intervalUnit = req.getParameter("intervalUnit");

        LocalDateTime nextRun = null;
        try {
            String nr = req.getParameter("nextRun");
            if (nr != null && !nr.isBlank()) {
                // Expect format yyyy-MM-dd'T'HH:mm
                nextRun = LocalDateTime.parse(nr);
            }
        } catch (Exception ignored) {
        }

        boolean active = "on".equalsIgnoreCase(req.getParameter("active"));

        if (notificationId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Notification is required");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationRuleService ruleSvc = new NotificationRuleService(conn);
            NotificationService notifSvc = new NotificationService(conn);

            Notification notification = notifSvc.getById(notificationId);
            if (notification == null) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Notification not found");
                return;
            }

            if (!isManager && !notifSvc.isRecipient(notificationId, user.getUserId())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // Save notification changes
            notification.setTitle(title);
            notification.setContent(content);
            notification.setType(type);
            notification.setRelatedType(relatedType);
            notification.setRelatedId(relatedId);
            boolean notifOk = notifSvc.updateNotification(notification);

            if (!notifOk) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not update notification");
                return;
            }

            boolean ok;
            if (ruleId == null) {
                // create new
                if (nextRun == null) {
                    // default to now
                    nextRun = LocalDateTime.now();
                }
                int newRuleId = ruleSvc.createRule(notificationId, ruleType, intervalValue, intervalUnit, nextRun);
                ok = newRuleId > 0;
            } else {
                if (nextRun == null) {
                    nextRun = LocalDateTime.now();
                }
                ok = ruleSvc.updateRule(ruleId, ruleType, intervalValue, intervalUnit, nextRun, active);
            }

            if (!ok) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save rule");
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/notifications/rules?success=1");
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Cannot save reminder rule", ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
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

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }
}
