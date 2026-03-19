package controller.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.TaskCommentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Activity;
import model.TaskComment;
import model.User;
import service.ActivityService;
import service.NotificationService;
import service.TaskService;
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
 * REST API for Task Work Items (Task_Comments).
 *
 * GET    /api/task-comments?taskId={id}        → list work items
 * POST   /api/task-comments                     → add work item (JSON)
 * PATCH  /api/task-comments?id={id}&done=true  → toggle complete
 * DELETE /api/task-comments?id={id}            → soft-delete
 *
 * POST body:
 * {
 *   "taskId"          : 10,
 *   "content"         : "Check with client",
 *   "assignedTo"      : 7,          // user_id being tagged (optional)
 *   "parentCommentId" : null        // optional – reply to a work item
 * }
 */
@WebServlet("/api/task-comments")
public class TaskCommentApiController extends HttpServlet {

    private static final Logger LOG  = Logger.getLogger(TaskCommentApiController.class.getName());
    private static final Gson   GSON = new GsonBuilder().serializeNulls().create();
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yy");

    static class WorkItemCreateReq {
        Integer taskId;
        String  content;
        Integer assignedTo;       // tagged supporter
        Integer parentCommentId;
    }

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = sessionUser(req);
        if (user == null) { writeJson(resp, 401, fail("Unauthorized")); return; }

        int taskId;
        try { taskId = Integer.parseInt(req.getParameter("taskId")); }
        catch (Exception e) { writeJson(resp, 400, fail("Missing taskId")); return; }

        try (Connection conn = DBContext.getConnection()) {
            if (new TaskService(conn).getTaskById(taskId) == null) {
                writeJson(resp, 404, fail("Task not found")); return;
            }

            List<TaskComment> items = new TaskCommentDAO(conn).findByTaskId(taskId);

            JsonArray arr = new JsonArray();
            for (TaskComment c : items) {
                arr.add(toJson(c));
            }

            // Also return computed progress
            int[] prog = new TaskCommentDAO(conn).countProgress(taskId);
            int total     = prog[0];
            int completed = prog[1];
            int progressPct = total > 0 ? (int) Math.round((double) completed / total * 100) : 0;

            JsonObject root = new JsonObject();
            root.addProperty("count",       items.size());
            root.addProperty("total",       total);
            root.addProperty("completed",   completed);
            root.addProperty("progressPct", progressPct);
            root.add("items", arr);
            writeJson(resp, 200, GSON.toJson(root));

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "GET task-comments", ex);
            writeJson(resp, 500, fail("Server error"));
        }
    }

    // ── POST – add work item ──────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = sessionUser(req);
        if (user == null) { writeJson(resp, 401, fail("Unauthorized")); return; }

        WorkItemCreateReq body = readJson(req, WorkItemCreateReq.class);
        if (body == null || body.taskId == null) { writeJson(resp, 400, fail("Missing taskId")); return; }
        if (body.content == null || body.content.isBlank()) { writeJson(resp, 400, fail("Content required")); return; }

        try (Connection conn = DBContext.getConnection()) {
            TaskService taskSvc = new TaskService(conn);
            model.Task task = taskSvc.getTaskById(body.taskId);
            if (task == null) {
                writeJson(resp, 404, fail("Task not found")); return;
            }

            TaskComment item = new TaskComment();
            item.setTaskId(body.taskId);
            item.setCreatedBy(user.getUserId());
            item.setContent(body.content.trim());
            item.setParentCommentId(body.parentCommentId);
            item.setAssignedTo(body.assignedTo);

            TaskCommentDAO dao = new TaskCommentDAO(conn);
            boolean ok = dao.insert(item);
            if (!ok || item.getCommentId() == null) {
                writeJson(resp, 500, fail("Insert failed")); return;
            }

            NotificationService notifSvc = new NotificationService(conn);
            String from = user.getFullName() != null ? user.getFullName() : user.getUsername();

            // Notify the tagged/assigned user
            if (body.assignedTo != null && body.assignedTo != user.getUserId()) {
                notifSvc.createForUser(
                        body.assignedTo,
                        "You were tagged in a task",
                        from + " tagged you: " + truncate(body.content, 80),
                        "TASK", "Task", body.taskId
                );
            }

            // Notify task owner (if not the commenter)
            if (task.getCreatedBy() != null && task.getCreatedBy().getUserId() != user.getUserId()) {
                notifSvc.createForUser(
                        task.getCreatedBy().getUserId(),
                        "New work item on your task",
                        from + " added a work item on \"" + truncate(task.getTitle(), 60) + "\"",
                        "TASK", "Task", body.taskId
                );
            }

            // Notify task assignees (except commenter and already-notified tagged user)
            if (task.getAssignees() != null) {
                for (model.TaskAssignee ta : task.getAssignees()) {
                    if (ta.getUser() == null) continue;
                    int uid = ta.getUser().getUserId();
                    if (uid == user.getUserId()) continue;
                    if (body.assignedTo != null && uid == body.assignedTo) continue;
                    if (task.getCreatedBy() != null && uid == task.getCreatedBy().getUserId()) continue;
                    notifSvc.createForUser(uid,
                            "New work item on task",
                            from + " added a work item on \"" + truncate(task.getTitle(), 60) + "\"",
                            "TASK", "Task", body.taskId);
                }
            }

            // Log activity for task comment (Scenario 6) – link to CRM entity timeline
            try {
                Activity activity = new Activity();
                activity.setSubject("New comment on task");
                activity.setActivityType("task_comment");
                // Link to CRM entity (Customer/Lead) if task has related entity
                // Also set related_type/related_id to 'task' for task timeline
                if (task.getRelatedType() != null && task.getRelatedId() != null) {
                    activity.setRelatedType(task.getRelatedType());
                    activity.setRelatedId(task.getRelatedId());
                } else {
                    activity.setRelatedType("task");
                    activity.setRelatedId(body.taskId);
                }
                activity.setDescription(truncate(body.content, 200));
                activity.setCreatedBy(user);
                activity.setActivityDate(java.time.LocalDateTime.now());
                new ActivityService(conn).createActivity(activity);
            } catch (Exception e) {
                // Log failure should not fail the whole request
                Logger.getLogger(TaskCommentApiController.class.getName())
                        .log(Level.WARNING, "Failed to log activity for task comment", e);
            }

            // Recompute and return new progress
            int[] prog = dao.countProgress(body.taskId);
            int pct = prog[0] > 0 ? (int) Math.round((double) prog[1] / prog[0] * 100) : 0;

            // Cập nhật progress vào database
            taskSvc.updateProgress(body.taskId, pct, user.getUserId());

            JsonObject res = new JsonObject();
            res.addProperty("success",     true);
            res.addProperty("commentId",   item.getCommentId());
            res.addProperty("progressPct", pct);
            writeJson(resp, 200, GSON.toJson(res));

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "POST task-comments", ex);
            writeJson(resp, 500, fail("Server error"));
        }
    }

    // ── PATCH – toggle complete ───────────────────────────────────────────────

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = sessionUser(req);
        if (user == null) { writeJson(resp, 401, fail("Unauthorized")); return; }

        int commentId;
        try { commentId = Integer.parseInt(req.getParameter("id")); }
        catch (Exception e) { writeJson(resp, 400, fail("Missing id")); return; }

        String doneStr = req.getParameter("done");
        boolean done   = "true".equalsIgnoreCase(doneStr) || "1".equals(doneStr);

        try (Connection conn = DBContext.getConnection()) {
            TaskCommentDAO dao = new TaskCommentDAO(conn);
            TaskComment existing = dao.findById(commentId);

            if (existing == null || existing.isDeleted()) {
                writeJson(resp, 404, fail("Work item not found")); return;
            }

            // Permission: the assigned user OR creator OR manager can complete
            boolean canComplete = existing.getCreatedBy()== user.getUserId()
                    || (existing.getAssignedTo() != null && existing.getAssignedTo() == user.getUserId())
                    || isManagerOrAdmin(user);

            if (!canComplete) { writeJson(resp, 403, fail("Forbidden")); return; }

            boolean ok = dao.setCompleted(commentId, done);

            // Notify on work item completion
            if (ok && done) {
                TaskService taskSvc = new TaskService(conn);
                model.Task task = taskSvc.getTaskById(existing.getTaskId());
                if (task != null) {
                    NotificationService notifSvc = new NotificationService(conn);
                    String from = user.getFullName() != null ? user.getFullName() : user.getUsername();
                    String action = "completed a work item on";

                    // Notify task owner
                    if (task.getCreatedBy() != null && task.getCreatedBy().getUserId() != user.getUserId()) {
                        notifSvc.createForUser(task.getCreatedBy().getUserId(),
                                "Work item completed",
                                from + " " + action + " \"" + truncate(task.getTitle(), 50) + "\"",
                                "TASK", "Task", existing.getTaskId());
                    }
                    // Notify task assignees
                    if (task.getAssignees() != null) {
                        for (model.TaskAssignee ta : task.getAssignees()) {
                            if (ta.getUser() == null) continue;
                            int uid = ta.getUser().getUserId();
                            if (uid == user.getUserId()) continue;
                            if (task.getCreatedBy() != null && uid == task.getCreatedBy().getUserId()) continue;
                            notifSvc.createForUser(uid,
                                    "Work item completed",
                                    from + " " + action + " \"" + truncate(task.getTitle(), 50) + "\"",
                                    "TASK", "Task", existing.getTaskId());
                        }
                    }
                }
            }

            // Recompute task progress
            int[] prog = dao.countProgress(existing.getTaskId());
            int pct = prog[0] > 0 ? (int) Math.round((double) prog[1] / prog[0] * 100) : 0;

            // Cập nhật progress vào database
            new TaskService(conn).updateProgress(existing.getTaskId(), pct, user.getUserId());

            JsonObject res = new JsonObject();
            res.addProperty("success",     ok);
            res.addProperty("progressPct", pct);
            res.addProperty("total",       prog[0]);
            res.addProperty("completed",   prog[1]);
            writeJson(resp, ok ? 200 : 500, GSON.toJson(res));

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "PUT task-comments complete", ex);
            writeJson(resp, 500, fail("Server error"));
        }
    }

    // ── DELETE ────────────────────────────────────────────────────────────────

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = sessionUser(req);
        if (user == null) { writeJson(resp, 401, fail("Unauthorized")); return; }

        int commentId;
        try { commentId = Integer.parseInt(req.getParameter("id")); }
        catch (Exception e) { writeJson(resp, 400, fail("Missing id")); return; }

        try (Connection conn = DBContext.getConnection()) {
            TaskCommentDAO dao = new TaskCommentDAO(conn);
            TaskComment existing = dao.findById(commentId);

            if (existing == null || existing.isDeleted()) {
                writeJson(resp, 404, fail("Not found")); return;
            }

            boolean isOwner = existing.getCreatedBy()== user.getUserId();
            if (!isOwner && !isManagerOrAdmin(user)) {
                writeJson(resp, 403, fail("Forbidden")); return;
            }

            boolean ok = dao.softDelete(commentId);

            int[] prog = dao.countProgress(existing.getTaskId());
            int pct = prog[0] > 0 ? (int) Math.round((double) prog[1] / prog[0] * 100) : 0;

            // Cập nhật progress vào database
            new TaskService(conn).updateProgress(existing.getTaskId(), pct, user.getUserId());

            JsonObject res = new JsonObject();
            res.addProperty("success",     ok);
            res.addProperty("progressPct", pct);
            writeJson(resp, ok ? 200 : 500, GSON.toJson(res));

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "DELETE task-comments", ex);
            writeJson(resp, 500, fail("Server error"));
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static JsonObject toJson(TaskComment c) {
        JsonObject o = new JsonObject();
        o.addProperty("commentId",       c.getCommentId());
        o.addProperty("taskId",          c.getTaskId());
        o.addProperty("userId",          c.getCreatedBy());
        o.addProperty("authorName",      c.getAuthorName());
        o.addProperty("content",         c.getContent());
        o.addProperty("assignedTo",      c.getAssignedTo());
        o.addProperty("assignedName",    c.getAssignedName());
        o.addProperty("isCompleted",     c.isCompleted());
        o.addProperty("completedAt",     c.getCompletedAt() != null ? c.getCompletedAt().format(DateTimeFormatter.ofPattern("HH:mm dd/MM/yy")) : null);
        o.addProperty("parentCommentId", c.getParentCommentId());
        o.addProperty("createdAt",       c.getCreatedAt()   != null ? c.getCreatedAt().format(DateTimeFormatter.ofPattern("HH:mm dd/MM/yy"))   : "");
        return o;
    }

    private static boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        return rid == 1 || rid == 5
                || "ADMIN".equalsIgnoreCase(user.getRole().getRoleName())
                || "MANAGER".equalsIgnoreCase(user.getRole().getRoleName());
    }

    private static String truncate(String s, int max) {
        if (s == null) return "";
        return s.length() <= max ? s : s.substring(0, max) + "…";
    }

    private static User sessionUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute("user");
    }

    private static <T> T readJson(HttpServletRequest req, Class<T> cls) {
        try { return GSON.fromJson(req.getReader(), cls); } catch (Exception e) { return null; }
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
        try (PrintWriter w = resp.getWriter()) { w.write(json); }
    }
}
