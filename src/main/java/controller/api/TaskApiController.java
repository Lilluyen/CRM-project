package controller.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import model.User;
import service.NotificationService;
import service.TaskService;
import util.DBContext;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * /api/tasks
 *
 * POST   → create task (JSON)
 * PUT    → update task (JSON)
 * DELETE → delete task (?id=)
 *
 * Auth: requires session user.
 */
@WebServlet("/api/tasks")
public class TaskApiController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(TaskApiController.class.getName());
    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();

    // ─────────────────────────────────────────────────────────────────────────
    // DTOs
    // ─────────────────────────────────────────────────────────────────────────
    static class TaskCreateReq {
        String title;
        String description;
        String status;
        String priority;
        String dueDate; // yyyy-MM-dd'T'HH:mm
        Integer progress;
        Set<Integer> assigneeIds;
    }

    static class TaskUpdateReq {
        Integer taskId;
        String title;
        String description;
        String status;
        String priority;
        String dueDate; // yyyy-MM-dd'T'HH:mm
        Integer progress;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            writeJson(resp, 401, jsonFail("Unauthorized"));
            return;
        }

        TaskCreateReq body = readJson(req, TaskCreateReq.class);
        if (body == null || body.title == null || body.title.isBlank()) {
            writeJson(resp, 400, jsonFail("Missing title"));
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            Task t = new Task();
            t.setTitle(body.title);
            t.setDescription(body.description);
            t.setStatus(body.status != null ? body.status : "Pending");
            t.setPriority(body.priority != null ? body.priority : "Medium");
            t.setProgress(body.progress != null ? body.progress : 0);
            t.setCreatedBy(user);

            if (body.dueDate != null && !body.dueDate.isBlank()) {
                t.setDueDate(LocalDateTime.parse(body.dueDate, DT_FMT));
            }

            boolean ok = svc.createTask(t);
            if (!ok || t.getTaskId() == null) {
                writeJson(resp, 500, jsonFail("Create failed"));
                return;
            }

            // Assign rules mirror UI:
            if (isManagerOrAdmin(user)) {
                Set<Integer> desired = body.assigneeIds != null ? new HashSet<>(body.assigneeIds) : new HashSet<>();
                svc.updateAssigneesBulk(t, user.getUserId(), desired);
            } else {
                svc.assignTask(t.getTaskId(), user.getUserId(), t, user.getUserId());
                if (t.getDueDate() != null) {
                    new NotificationService(conn).createForUserWithRule(
                            user.getUserId(),
                            "Task Reminder",
                            "Task \"" + (t.getTitle() != null ? t.getTitle() : "") + "\" is due at " + t.getDueDate().toString().replace('T', ' '),
                            "TASK",
                            "Task",
                            t.getTaskId(),
                            "ONCE",
                            null,
                            null,
                            t.getDueDate()
                    );
                }
            }

            JsonObject res = new JsonObject();
            res.addProperty("success", true);
            res.addProperty("taskId", t.getTaskId());
            writeJson(resp, 200, GSON.toJson(res));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "API create task error", ex);
            writeJson(resp, 500, jsonFail("Server error"));
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            writeJson(resp, 401, jsonFail("Unauthorized"));
            return;
        }

        TaskUpdateReq body = readJson(req, TaskUpdateReq.class);
        if (body == null || body.taskId == null) {
            writeJson(resp, 400, jsonFail("Missing taskId"));
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task existing = svc.getTaskById(body.taskId);
            if (existing == null) {
                writeJson(resp, 404, jsonFail("Task not found"));
                return;
            }

            boolean canEditDuePri = isManagerOrAdmin(user) || !creatorIsManagement(existing);

            if (body.title != null) existing.setTitle(body.title);
            if (body.description != null) existing.setDescription(body.description);
            if (body.status != null) existing.setStatus(body.status);
            if (body.progress != null) existing.setProgress(body.progress);

            if (canEditDuePri) {
                if (body.priority != null) existing.setPriority(body.priority);
                if (body.dueDate != null) {
                    if (body.dueDate.isBlank()) existing.setDueDate(null);
                    else existing.setDueDate(LocalDateTime.parse(body.dueDate, DT_FMT));
                }
            }

            boolean ok = svc.updateTask(existing, user.getUserId());
            writeJson(resp, ok ? 200 : 500, ok ? "{\"success\":true}" : jsonFail("Update failed"));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "API update task error", ex);
            writeJson(resp, 500, jsonFail("Server error"));
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            writeJson(resp, 401, jsonFail("Unauthorized"));
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            writeJson(resp, 400, jsonFail("Missing id"));
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task t = svc.getTaskById(taskId);
            if (t == null) {
                writeJson(resp, 404, jsonFail("Task not found"));
                return;
            }

            if (!isManagerOrAdmin(user)) {
                if (creatorIsManagement(t)) {
                    writeJson(resp, 403, jsonFail("Cannot delete management-created task"));
                    return;
                }
                int creatorId = t.getCreatedBy() != null ? t.getCreatedBy().getUserId() : 0;
                if (creatorId != user.getUserId()) {
                    writeJson(resp, 403, jsonFail("Only creator can delete"));
                    return;
                }
            }

            boolean ok = svc.deleteTask(taskId);
            writeJson(resp, ok ? 200 : 500, ok ? "{\"success\":true}" : jsonFail("Delete failed"));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "API delete task error", ex);
            writeJson(resp, 500, jsonFail("Server error"));
        }
    }

    private static boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    private static boolean creatorIsManagement(Task task) {
        if (task == null || task.getCreatedBy() == null || task.getCreatedBy().getRole() == null) return false;
        int rid = task.getCreatedBy().getRole().getRoleId();
        return rid == 1 || rid == 5;
    }

    private static <T> T readJson(HttpServletRequest req, Class<T> cls) {
        try {
            return GSON.fromJson(req.getReader(), cls);
        } catch (Exception e) {
            return null;
        }
    }

    private static String jsonFail(String msg) {
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

