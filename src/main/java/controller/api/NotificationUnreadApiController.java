package controller.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
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
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /api/notifications/unread
 * Returns unread notifications for current user.
 */
@WebServlet("/api/notifications/unread")
public class NotificationUnreadApiController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationUnreadApiController.class.getName());
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            writeJson(resp, 401, "{\"count\":0,\"items\":[]}");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);
            List<Notification> list = ns.getUnreadForUser(user.getUserId());

            JsonObject root = new JsonObject();
            root.addProperty("count", list.size());
            JsonArray items = new JsonArray();
            for (Notification n : list) {
                JsonObject o = new JsonObject();
                o.addProperty("id", n.getNotificationId());
                o.addProperty("title", n.getTitle());
                o.addProperty("content", n.getContent());
                o.addProperty("type", n.getType());
                o.addProperty("relatedType", n.getRelatedType());
                if (n.getRelatedId() != null) o.addProperty("relatedId", n.getRelatedId());
                else o.add("relatedId", null);
                o.addProperty("createdAt", n.getCreatedAt() != null ? n.getCreatedAt().format(FMT) : "");
                items.add(o);
            }
            root.add("items", items);

            writeJson(resp, 200, GSON.toJson(root));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, null, ex);
            writeJson(resp, 500, "{\"count\":0,\"items\":[]}");
        }
    }

    private static void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}

