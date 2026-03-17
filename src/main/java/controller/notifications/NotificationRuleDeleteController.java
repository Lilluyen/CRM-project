package controller.notifications;

import model.User;
import service.NotificationRuleService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /notifications/rules/delete
 * Delete a reminder rule (AJAX JSON).
 */
@WebServlet("/notifications/rules/delete")
public class NotificationRuleDeleteController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationRuleDeleteController.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        int ruleId;
        try {
            ruleId = Integer.parseInt(req.getParameter("ruleId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, "{\"success\":false,\"message\":\"Thiếu hoặc sai ruleId\"}");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationRuleService ruleSvc = new NotificationRuleService(conn);

            model.NotificationRuleEngine ruleEngine = null;
            try {
                ruleEngine = ruleSvc.getRuleEngineById(ruleId);
            } catch (Exception ignored) {
            }

            if (ruleEngine == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(resp, "{\"success\":false,\"message\":\"Rule không tồn tại\"}");
                return;
            }

            boolean isManager = isManagerOrAdmin(user);
            if (!isManager) {
                // Non-managers can only delete rules they created
                if (ruleEngine.getCreatedBy() == null || ruleEngine.getCreatedBy() != user.getUserId()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    writeJson(resp, "{\"success\":false,\"message\":\"Không có quyền\"}");
                    return;
                }
            }

            boolean ok = ruleSvc.deleteRule(ruleId);
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Xóa thất bại\"}");
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, null, ex);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống\"}");
        }
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
