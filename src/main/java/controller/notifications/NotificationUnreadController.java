package controller.notifications;

import model.Notification;
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
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /notifications/unread
 * Trả về JSON danh sách notification chưa đọc của user hiện tại.
 * Dùng cho header dropdown để hiển thị badge và danh sách thông báo.
 *
 * Response JSON:
 * {
 *   "count": 2,
 *   "items": [
 *     { "id": 5, "title": "...", "content": "...", "type": "TASK", "createdAt": "01/03 14:22" }
 *   ]
 * }
 */
@WebServlet("/notifications/unread")
public class NotificationUnreadController extends HttpServlet {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"count\":0,\"items\":[]}");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            List<Notification> list = new NotificationService(conn).getUnreadForUser(user.getUserId());

            StringBuilder sb = new StringBuilder("{\"count\":").append(list.size()).append(",\"items\":[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) sb.append(",");
                Notification n = list.get(i);
                sb.append("{")
                  .append("\"id\":").append(n.getNotificationId()).append(",")
                  .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                  .append("\"content\":\"").append(escapeJson(n.getContent())).append("\",")
                  .append("\"type\":\"").append(escapeJson(n.getType())).append("\",")
                  .append("\"createdAt\":\"").append(n.getCreatedAt() != null ? n.getCreatedAt().format(FMT) : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            writeJson(resp, sb.toString());
        } catch (SQLException ex) {
            Logger.getLogger(NotificationUnreadController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
