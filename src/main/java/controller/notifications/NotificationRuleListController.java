package controller.notifications;

import dto.Pagination;
import model.NotificationRule;
import model.User;
import service.NotificationRuleService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /notifications/rules
 * List notification reminder rules (with pagination).
 *
 * Note: NotificationRule stores template fields directly (notificationTitleTemplate,
 * notificationContentTemplate, etc.), so no separate notification lookup is needed.
 */
@WebServlet("/notifications/rules")
public class NotificationRuleListController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationRuleListController.class.getName());

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
        boolean isManager = isManagerOrAdmin(user);

        try (Connection conn = DBContext.getConnection()) {
            NotificationRuleService svc = new NotificationRuleService(conn);

            int total = svc.countRulesForUser(user.getUserId(), isManager);
            Pagination pagination = new Pagination(page, pageSize, total);

            List<NotificationRule> rules = svc.listRulesForUser(user.getUserId(), isManager,
                    pagination.getCurrentPage(), pagination.getPageSize());

            req.setAttribute("rules", rules);
            req.setAttribute("pagination", pagination);
            req.setAttribute("isManager", isManager);
            req.setAttribute("pageTitle", "Notification Rules");
            req.setAttribute("contentPage", "/view/notifications/rule-list.jsp");
            req.setAttribute("page", "notification-rules");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Cannot load notification rules list", ex);
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
