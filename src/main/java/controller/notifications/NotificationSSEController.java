package controller.notifications;

import model.Notification;
import model.User;
import service.NotificationService;
import util.DBContext;

import jakarta.servlet.AsyncContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /notifications/stream
 *
 * Server-Sent Events endpoint – keeps an async connection open and pushes
 * unread notification counts + new notification payloads to the browser.
 *
 * The client (header.jsp) connects via EventSource and refreshes the
 * notification bell badge + dropdown in real time without a page reload.
 *
 * Poll interval: 8 seconds (balances freshness vs. DB load).
 */
@WebServlet(urlPatterns = "/notifications/stream", asyncSupported = true)
public class NotificationSSEController extends HttpServlet {

    private static final long   POLL_INTERVAL_MS = 1_000;
    private static final long   TIMEOUT_MS       = 60_000 * 5; // 5 min max
    private static final Logger LOG = Logger.getLogger(NotificationSSEController.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED); return; }

        resp.setContentType("text/event-stream");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        resp.setHeader("X-Accel-Buffering", "no"); // disable Nginx buffering if present

        final int userId = user.getUserId();
        final AsyncContext async = req.startAsync();
        async.setTimeout(TIMEOUT_MS);

        // Run the polling loop in a dedicated thread
        async.start(() -> {
            long startTime = System.currentTimeMillis();
            try {
                PrintWriter out = async.getResponse().getWriter();

                while (!out.checkError()
                        && (System.currentTimeMillis() - startTime) < TIMEOUT_MS) {

                    try (Connection conn = DBContext.getConnection()) {
                        NotificationService ns = new NotificationService(conn);
                        List<Notification> unread = ns.getUnreadForUser(userId);

                        StringBuilder sb = new StringBuilder();
                        sb.append("{\"count\":").append(unread.size()).append(",\"items\":[");
                        for (int i = 0; i < unread.size(); i++) {
                            Notification n = unread.get(i);
                            if (i > 0) sb.append(",");
                            sb.append("{")
                              .append("\"id\":").append(n.getNotificationId()).append(",")
                              .append("\"title\":\"").append(escJson(n.getTitle())).append("\",")
                              .append("\"content\":\"").append(escJson(n.getContent())).append("\",")
                              .append("\"createdAt\":\"").append(n.getCreatedAt() != null ? n.getCreatedAt().toString() : "").append("\"")
                              .append("}");
                        }
                        sb.append("]}");

                        out.write("data: " + sb + "\n\n");
                        out.flush();
                    } catch (Exception e) {
                        LOG.log(Level.WARNING, "SSE DB error for user " + userId, e);
                    }

                    Thread.sleep(POLL_INTERVAL_MS);
                }
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
            } catch (IOException ignored) {
                // Client disconnected
            } finally {
                async.complete();
            }
        });
    }

    private static String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
