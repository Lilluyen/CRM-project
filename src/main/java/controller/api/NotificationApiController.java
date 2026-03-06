package controller.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.NotificationService;
import util.DBContext;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /api/notifications
 * Create notification(s) for one or many users (JSON).
 *
 * Auth: requires session user.
 */
@WebServlet("/api/notifications")
public class NotificationApiController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationApiController.class.getName());
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();
    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    static class RuleDto {
        String ruleType;          // e.g. "ONCE"
        Integer intervalValue;    // nullable
        String intervalUnit;      // nullable
        String nextRun;           // yyyy-MM-dd'T'HH:mm
    }

    static class CreateDto {
        Integer userId;
        List<Integer> userIds;
        String title;
        String content;
        String type;
        String relatedType;
        Integer relatedId;
        RuleDto rule;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User sessionUser = (User) req.getSession().getAttribute("user");
        if (sessionUser == null) {
            writeJson(resp, 401, fail("Unauthorized"));
            return;
        }

        CreateDto body = readJson(req, CreateDto.class);
        if (body == null || body.title == null || body.title.isBlank()) {
            writeJson(resp, 400, fail("Missing title"));
            return;
        }

        List<Integer> recipients = new ArrayList<>();
        if (body.userIds != null && !body.userIds.isEmpty()) {
            recipients.addAll(body.userIds);
        } else if (body.userId != null) {
            recipients.add(body.userId);
        } else {
            recipients.add(sessionUser.getUserId());
        }

        String type = body.type != null ? body.type : "INFO";

        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);

            boolean ok;
            if (body.rule != null && body.rule.nextRun != null && !body.rule.nextRun.isBlank()) {
                LocalDateTime nextRun = LocalDateTime.parse(body.rule.nextRun, DT_FMT);
                String rt = body.rule.ruleType != null ? body.rule.ruleType : "ONCE";

                if (recipients.size() == 1) {
                    ok = ns.createForUserWithRule(
                            recipients.get(0),
                            body.title,
                            body.content,
                            type,
                            body.relatedType,
                            body.relatedId,
                            rt,
                            body.rule.intervalValue,
                            body.rule.intervalUnit,
                            nextRun
                    );
                } else {
                    ok = ns.broadcastToUsersWithRule(
                            recipients,
                            body.title,
                            body.content,
                            type,
                            body.relatedType,
                            body.relatedId,
                            rt,
                            body.rule.intervalValue,
                            body.rule.intervalUnit,
                            nextRun
                    );
                }
            } else {
                if (recipients.size() == 1) {
                    ok = ns.createForUser(recipients.get(0), body.title, body.content, type, body.relatedType, body.relatedId);
                } else {
                    ns.broadcastToUsers(recipients, body.title, body.content, type, body.relatedType, body.relatedId);
                    ok = true;
                }
            }

            writeJson(resp, 200, ok ? "{\"success\":true}" : fail("Create failed"));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "API create notification error", ex);
            writeJson(resp, 500, fail("Server error"));
        }
    }

    private static <T> T readJson(HttpServletRequest req, Class<T> cls) {
        try {
            return GSON.fromJson(req.getReader(), cls);
        } catch (Exception e) {
            return null;
        }
    }

    private static String fail(String msg) {
        JsonObject o = new JsonObject();
        o.addProperty("success", false);
        o.addProperty("message", msg);
        return GSON.toJson(o);
    }

    private static void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}

