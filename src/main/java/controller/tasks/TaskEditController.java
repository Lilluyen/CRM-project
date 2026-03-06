package controller.tasks;

import dao.UserDAO;
import model.Task;
import model.TaskAssignee;
import model.User;
import service.TaskService;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /tasks/edit?id={taskId}  – unified edit page (info + progress + status + assign)
 * POST /tasks/edit               – save all task changes and assignees
 *
 * Role-based permissions enforced here and in the JSP:
 *   ADMIN (role_id=1) / MANAGER (role_id=5) → full edit + assign management
 *   Others → title, description, status, progress only
 */
@WebServlet("/tasks/edit")
public class TaskEditController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final Logger LOG = Logger.getLogger(TaskEditController.class.getName());

    // ─────────────────────────────────────────────────────────────────────────
    // GET – show form
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireLogin(req, resp); if (user == null) return;
        Integer id = parseId(req, resp, "id"); if (id == null) return;

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task task = svc.getTaskById(id);
            if (task == null) { resp.sendError(404, "Task not found: id=" + id); return; }

            req.setAttribute("task",       task);
            req.setAttribute("history",    svc.getHistoryForTask(id));
            req.setAttribute("isManager",  isManagerOrAdmin(user));
            req.setAttribute("allUsers",   loadUsers(conn));
            req.setAttribute("pageTitle",  "Edit Task – " + task.getTitle());
            req.setAttribute("contentPage","/view/tasks/task-edit.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) { LOG.log(Level.SEVERE, null, ex); }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST – save changes
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // AJAX sub-actions (progress, status, assign) handled separately
        String subAction = req.getParameter("subAction");
        if ("progress".equals(subAction)) { handleProgress(req, resp); return; }
        if ("status".equals(subAction))   { handleStatus(req, resp);   return; }
        if ("assign".equals(subAction))   { handleAssign(req, resp);   return; }

        // ── Full form save ──
        User user = requireLogin(req, resp); if (user == null) return;
        int taskId = Integer.parseInt(req.getParameter("taskId"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc  = new TaskService(conn);
            Task existing    = svc.getTaskById(taskId);
            if (existing == null) { resp.sendError(404); return; }

            Task updated = applyChanges(req, existing, isManagerOrAdmin(user));
            boolean ok   = svc.updateTask(updated, user.getUserId());

            if (!ok) {
                req.setAttribute("task",       svc.getTaskById(taskId));
                req.setAttribute("history",    svc.getHistoryForTask(taskId));
                req.setAttribute("isManager",  isManagerOrAdmin(user));
                req.setAttribute("allUsers",   loadUsers(conn));
                req.setAttribute("error",      "Update failed – please try again.");
                req.setAttribute("pageTitle",  "Edit Task");
                req.setAttribute("contentPage","/view/tasks/task-edit.jsp");
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }
            req.getSession().setAttribute("flashSuccess", "Task updated successfully.");
            resp.sendRedirect(req.getContextPath() + "/tasks/edit?id=" + taskId);
        } catch (SQLException ex) { LOG.log(Level.SEVERE, null, ex); }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // AJAX – update progress
    // ─────────────────────────────────────────────────────────────────────────
    private void handleProgress(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { writeJson(resp, 401, "{\"success\":false,\"message\":\"Unauthorized\"}"); return; }
        int taskId   = parseInt(req, "taskId",   0);
        int progress = parseInt(req, "progress", 0);
        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new TaskService(conn).updateProgress(taskId, progress, user.getUserId());
            writeJson(resp, 200, ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Update failed\"}");
        } catch (SQLException ex) { LOG.log(Level.SEVERE, null, ex); }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // AJAX – update status
    // ─────────────────────────────────────────────────────────────────────────
    private void handleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { writeJson(resp, 401, "{\"success\":false,\"message\":\"Unauthorized\"}"); return; }
        int    taskId = parseInt(req, "taskId", 0);
        String status = req.getParameter("status");
        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task task = svc.getTaskById(taskId);
            boolean ok = svc.updateStatus(taskId, status, task, user.getUserId());
            writeJson(resp, 200, ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Update failed\"}");
        } catch (SQLException ex) { LOG.log(Level.SEVERE, null, ex); }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // AJAX – manage assignees (ADMIN / MANAGER only)
    // ─────────────────────────────────────────────────────────────────────────
    private void handleAssign(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { writeJson(resp, 401, "{\"success\":false,\"message\":\"Unauthorized\"}"); return; }
        if (!isManagerOrAdmin(user)) {
            writeJson(resp, 403, "{\"success\":false,\"message\":\"Forbidden\"}"); return;
        }
        int taskId = parseInt(req, "taskId", 0);
        String[] newIds = req.getParameterValues("assigneeIds");

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc  = new TaskService(conn);
            Task task        = svc.getTaskById(taskId);
            if (task == null) { writeJson(resp, 404, "{\"success\":false,\"message\":\"Task not found\"}"); return; }

            // Tập desired từ request
            Set<Integer> desired = new HashSet<>();
            if (newIds != null) {
                for (String sid : newIds) {
                    try { desired.add(Integer.parseInt(sid.trim())); }
                    catch (NumberFormatException ignored) {}
                }
            }

            boolean ok = svc.updateAssigneesBulk(task, user.getUserId(), desired);
            writeJson(resp, ok ? 200 : 500, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Update failed\"}");
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, null, ex);
            writeJson(resp, 500, "{\"success\":false,\"message\":\"Server error\"}");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────────────────────────────────
    private Task applyChanges(HttpServletRequest req, Task existing, boolean isManager) {
        // Everyone can change these:
        existing.setTitle(req.getParameter("title"));
        existing.setDescription(req.getParameter("description"));
        existing.setStatus(req.getParameter("status"));
        String prog = req.getParameter("progress");
        existing.setProgress(prog != null && !prog.isBlank() ? Integer.parseInt(prog) : existing.getProgress());

        // Only manager / admin:
        if (isManager) {
            existing.setPriority(req.getParameter("priority"));
            String due = req.getParameter("dueDate");
            if (due != null && !due.isBlank()) existing.setDueDate(LocalDateTime.parse(due, DT_FMT));
            else existing.setDueDate(null);
        }
        return existing;
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    private User requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User u = (User) req.getSession().getAttribute("user");
        if (u == null) { resp.sendRedirect(req.getContextPath() + "/login"); }
        return u;
    }

    private Integer parseId(HttpServletRequest req, HttpServletResponse resp, String param) throws IOException {
        String val = req.getParameter(param);
        if (val == null) { resp.sendRedirect(req.getContextPath() + "/tasks/list"); return null; }
        return Integer.parseInt(val);
    }

    private int parseInt(HttpServletRequest req, String name, int def) {
        try { return Integer.parseInt(req.getParameter(name)); } catch (Exception e) { return def; }
    }

    private List<User> loadUsers(Connection conn) throws ServletException {
        try { return new UserDAO().getActiveUsers(); }
        catch (Exception e) { throw new ServletException("Cannot load users", e); }
    }

    private void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) { w.write(json); }
    }
}
