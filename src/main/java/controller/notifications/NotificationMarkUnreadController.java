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
 * POST /notifications/markUnread
 * Đánh dấu một notification là CHƯA đọc cho user hiện tại (AJAX JSON).
 *
 * Request params:
 *   id (int) – notification_id
 */
@WebServlet("/notifications/markUnread")
public class NotificationMarkUnreadController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationMarkUnreadController.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        int notifId;
        try {
            notifId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, "{\"success\":false,\"message\":\"Thiếu hoặc sai id\"}");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new NotificationService(conn).markAsUnread(notifId, user.getUserId());
            writeJson(resp, ok ? "{\"success\":true}" : "{\"success\":false}");
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, null, ex);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống\"}");
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}

