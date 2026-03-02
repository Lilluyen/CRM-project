package controller.notifications;

import model.User;
import service.NotificationService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /notifications/markRead
 * Đánh dấu một notification là đã đọc cho user hiện tại (AJAX JSON).
 *
 * Request params:
 *   id (int) – notification_id
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/notifications/markRead")
public class NotificationMarkReadController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        int notifId = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new NotificationService(conn).markAsRead(notifId, user.getUserId());
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Đánh dấu đã đọc thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(NotificationMarkReadController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
