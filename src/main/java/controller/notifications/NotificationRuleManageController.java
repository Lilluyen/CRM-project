package controller.notifications;

import dao.UserDAO;
import model.NotificationRuleEngine;
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
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /notifications/rules/manage       → form tạo mới
 * GET  /notifications/rules/manage?ruleId=X → form chỉnh sửa
 * POST /notifications/rules/manage       → lưu rule
 */
@WebServlet("/notifications/rules/manage")
public class NotificationRuleManageController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationRuleManageController.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        NotificationRuleEngine rule = null;
        try (Connection conn = DBContext.getConnection()) {
            String ruleIdParam = req.getParameter("ruleId");
            if (ruleIdParam != null && !ruleIdParam.isBlank()) {
                NotificationRuleService svc = new NotificationRuleService(conn);
                rule = svc.getRuleEngineById(Integer.parseInt(ruleIdParam));
            }
            // Load users for recipient dropdown
            List<User> allUsers = new UserDAO().getActiveUsers();
            req.setAttribute("allUsers", allUsers);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Cannot load rule form", ex);
        }

        req.setAttribute("rule", rule);
        req.setAttribute("pageTitle", rule == null ? "Create Alarm Rule" : "Edit Alarm Rule");
        req.setAttribute("contentPage", "/view/notifications/rule-form.jsp");
        req.setAttribute("page", "notification-rules");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try (Connection conn = DBContext.getConnection()) {
            NotificationRuleService svc = new NotificationRuleService(conn);

            // Parse ruleId (null = create new)
            Integer ruleId = parseIntOrNull(req.getParameter("ruleId"));

            // Build engine from form
            NotificationRuleEngine engine = ruleId != null ? svc.getRuleEngineById(ruleId) : new NotificationRuleEngine();
            if (engine == null) engine = new NotificationRuleEngine();

            engine.setRuleName(safe(req.getParameter("ruleName"), "Untitled Rule"));
            engine.setRuleType(safe(req.getParameter("ruleType"), "schedule"));
            engine.setDescription(req.getParameter("description"));
            engine.setTriggerEvent(req.getParameter("triggerEvent"));
            engine.setEntityType(req.getParameter("entityType"));
            engine.setConditionField(req.getParameter("conditionField"));
            engine.setConditionOperator(req.getParameter("conditionOperator"));
            engine.setConditionValue(parseIntOrNull(req.getParameter("conditionValue")));
            engine.setConditionUnit(req.getParameter("conditionUnit"));
            engine.setNotificationTitleTemplate(req.getParameter("notificationTitle"));
            engine.setNotificationContentTemplate(req.getParameter("notificationContent"));
            engine.setNotificationType(req.getParameter("notificationType"));
            engine.setNotificationPriority(safe(req.getParameter("notificationPriority"), "normal"));
            engine.setRecipientType(req.getParameter("recipientType"));
            engine.setRecipientUserId(parseIntOrNull(req.getParameter("recipientUserId")));
            engine.setEscalateAfterMinutes(parseIntOrNull(req.getParameter("escalateAfterMinutes")));
            engine.setEscalateToUserId(parseIntOrNull(req.getParameter("escalateToUserId")));
            engine.setActive("on".equalsIgnoreCase(req.getParameter("active"))
                          || "true".equalsIgnoreCase(req.getParameter("active")));

            // Parse nextRun
            String nextRunStr = req.getParameter("nextRun");
            if (nextRunStr != null && !nextRunStr.isBlank()) {
                engine.setNextRunAt(LocalDateTime.parse(nextRunStr));
            } else if (!"event_trigger".equalsIgnoreCase(engine.getRuleType())) {
                // Schedule/condition: default to now so scheduler picks it up immediately
                engine.setNextRunAt(LocalDateTime.now());
            }

            engine.setCreatedBy(user.getUserId());

            boolean ok;
            if (ruleId != null) {
                ok = svc.updateRuleEngine(engine);
            } else {
                ok = svc.createRuleEngine(engine) > 0;
            }

            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/notifications/rules?success=1");
            } else {
                req.setAttribute("error", "Save failed");
                doGet(req, resp);
            }
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "Cannot save rule", ex);
            req.setAttribute("error", "System error: " + ex.getMessage());
            doGet(req, resp);
        }
    }

    private Integer parseIntOrNull(String val) {
        if (val == null || val.isBlank()) return null;
        try { return Integer.valueOf(val.trim()); } catch (Exception e) { return null; }
    }

    private String safe(String val, String fallback) {
        return val != null && !val.isBlank() ? val.trim() : fallback;
    }
}
