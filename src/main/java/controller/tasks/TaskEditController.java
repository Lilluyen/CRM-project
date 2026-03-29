package controller.tasks;

import dao.TaskCommentDAO;
import model.Task;
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
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /tasks/edit?id={taskId}  – unified edit page (info + progress + status + assign)
 * POST /tasks/edit               – save all task changes and assignees
 *
 * Role-based permissions enforced here and in the JSP:
 *   ADMIN (role_id=1) / MANAGER (role_id=5) → can manage assignees
 *   DueDate/Priority edit rule:
 *     - If task is created by ADMIN/MANAGER (role_id=1 or 5): only ADMIN/MANAGER can edit dueDate/priority
 *     - Otherwise: creator of the task can edit dueDate/priority (ADMIN/MANAGER also allowed)
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
            req.setAttribute("isManager",  isManagerOrAdmin(user));
            req.setAttribute("canEditDuePriority", canEditDuePriority(task, user));
            // Users loaded via AJAX from /api/related-entities?type=user
            req.setAttribute("pageTitle",  "Edit Task – " + task.getTitle());
            req.setAttribute("contentPage","/view/tasks/task-edit.jsp");
            req.setAttribute("page", "task-edit");
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

            boolean canEditDuePri = canEditDuePriority(existing, user);
            Task updated = applyChanges(req, existing, canEditDuePri);
            boolean ok   = svc.updateTask(updated, user.getUserId());

            if (!ok) {
                req.setAttribute("task",       svc.getTaskById(taskId));
                req.setAttribute("isManager",  isManagerOrAdmin(user));
                req.setAttribute("canEditDuePriority", canEditDuePri);
                // Users loaded via AJAX
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
    private Task applyChanges(HttpServletRequest req, Task existing, boolean canEditDuePriority) {
        // Everyone can change these:
        existing.setTitle(req.getParameter("title"));
        existing.setDescription(req.getParameter("description"));
        existing.setStatus(req.getParameter("status"));
        String prog = req.getParameter("progress");
        int pct=0;
        try (Connection conn = DBContext.getConnection()) {
            TaskCommentDAO dao = new TaskCommentDAO(conn);
            int[] pro = dao.countProgress(existing.getTaskId());
            int add=0;
            if(existing.getStatus().equalsIgnoreCase("Done")){
                add=1;
            }
            pct = pro[0] > 0 ? (int) Math.round((double) (pro[1] +add)/ (pro[0]+1) * 100) : 0;} 
        catch (SQLException ex) {
            Logger.getLogger(TaskEditController.class.getName()).log(Level.SEVERE, null, ex);
        }
        existing.setProgress(pct!=0 ? pct : existing.getProgress());

        // Due date / priority: per-task rule (see canEditDuePriority)
        if (canEditDuePriority) {
            existing.setPriority(req.getParameter("priority"));
            String due = req.getParameter("dueDate");
            if (due != null && !due.isBlank()) existing.setDueDate(LocalDateTime.parse(due, DT_FMT));
            else existing.setDueDate(null);

            String start = req.getParameter("startDate");
            if (start != null && !start.isBlank()) existing.setStartDate(LocalDateTime.parse(start, DT_FMT));
            else existing.setStartDate(null);
        }
        return existing;
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    /**
     * Rule:
     * - ADMIN/MANAGER (role_id=1 or 5): always can edit dueDate/priority
     * - Non-management: can edit dueDate/priority only if the task creator is NOT role 1/5
     */
    private boolean canEditDuePriority(Task task, User currentUser) {
        if (task == null || currentUser == null) return false;

        if (isManagerOrAdmin(currentUser)) return true;
        if (task.getCreatedBy() == null) return false;

        // If creator is management role, lock these fields for non-management users
        if (task.getCreatedBy().getRole() == null) return true;
        int creatorRoleId = task.getCreatedBy().getRole().getRoleId();
        return creatorRoleId != 1 && creatorRoleId != 5;
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

    private void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) { w.write(json); }
    }
}
