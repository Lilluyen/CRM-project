package controller.tasks;

import model.Task;
import model.User;
import service.NotificationService;
import service.TaskService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /tasks/create  – hiển thị form tạo task mới
 * POST /tasks/create  – lưu task mới, gán assignees, redirect sang list
 *
 * Hỗ trợ tạo task gắn với entity CRM (Customer / Lead / Deal) thông qua
 * hidden params {@code relatedType} và {@code relatedId} (Scenario 1).
 * Khi form được mở từ trang Customer/Lead/Deal, hai giá trị này được truyền
 * vào để {@link TaskService#createTask(Task, String, Integer)} tạo Activity
 * đúng kịch bản.
 */
@WebServlet("/tasks/create")
public class TaskCreateController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final Logger LOG =
            Logger.getLogger(TaskCreateController.class.getName());

    // ─────────────────────────────────────────────────────────────────────────
    // GET – render form
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        boolean isManager = isManagerOrAdmin(user);
        req.setAttribute("isManager", isManager);
        // Users loaded via AJAX from /api/related-entities?type=user

        // Giữ lại relatedType/relatedId để form biết mình đang tạo task cho entity nào
        req.setAttribute("relatedType", nvl(req.getParameter("relatedType"), ""));
        req.setAttribute("relatedId",   nvl(req.getParameter("relatedId"),   ""));

        req.setAttribute("pageTitle",   "Create Task");
        req.setAttribute("contentPage", "/view/tasks/task-create.jsp");
        req.setAttribute("page",        "task-create");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST – save
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        boolean isManager = isManagerOrAdmin(user);
        Task task = buildTask(req, user);

        // ── CRM entity link (Scenario 1: activity gắn với Customer/Lead/Deal) ──
        String  relatedType = nvl(req.getParameter("relatedType"), "").trim();
        String  relatedIdRaw = nvl(req.getParameter("relatedId"), "").trim();
        Integer relatedId   = null;
        if (!relatedType.isEmpty() && !relatedIdRaw.isEmpty()) {
            try { relatedId = Integer.parseInt(relatedIdRaw); }
            catch (NumberFormatException ignored) { relatedType = ""; }
        }
        String relatedTypeFinal = relatedType.isEmpty() ? null : relatedType;

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            // FIX: gọi overload có relatedType/relatedId để activity được tạo đúng
            boolean ok = svc.createTask(task, relatedTypeFinal, relatedId);

            if (!ok) {
                req.setAttribute("error",       "Không thể tạo task. Vui lòng kiểm tra lại thông tin.");
                req.setAttribute("pageTitle",   "Create Task");
                req.setAttribute("isManager",   isManager);
                req.setAttribute("contentPage", "/view/tasks/task-create.jsp");
                req.setAttribute("page",        "task-create");
                req.setAttribute("relatedType", nvl(relatedTypeFinal, ""));
                req.setAttribute("relatedId",   nvl(relatedIdRaw,     ""));
                // Users loaded via AJAX
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }

            // ── Gán assignees sau khi task được tạo thành công ──
            if (task.getTaskId() != null) {
                if (isManager) {
                    String[] assigneeIds = req.getParameterValues("assigneeIds");
                    Set<Integer> desired = new HashSet<>();
                    if (assigneeIds != null) {
                        for (String uid : assigneeIds) {
                            try { desired.add(Integer.parseInt(uid.trim())); }
                            catch (NumberFormatException ignored) {}
                        }
                    }
                    // Một history-header, nhiều detail; notification cho từng assignee
                    svc.updateAssigneesBulk(task, user.getUserId(), desired);
                } else {
                    // Staff: tự gán cho chính mình như một "reminder"
                    svc.assignTask(task.getTaskId(), user.getUserId(), task, user.getUserId());

                    // Tạo notification nhắc nhở khi đến due date
                    if (task.getDueDate() != null) {
                        new NotificationService(conn).createForUserWithRule(
                                user.getUserId(),
                                "Task Reminder",
                                "Task \"" + nvl(task.getTitle(), "") + "\" is due at "
                                        + task.getDueDate().toString().replace('T', ' '),
                                "TASK", "Task", task.getTaskId(),
                                "ONCE", null, null, task.getDueDate()
                        );
                    }
                }
            }

            req.getSession().setAttribute("flashSuccess",
                    "Task \"" + task.getTitle() + "\" đã được tạo.");

            // Nếu tạo task từ entity CRM, redirect về entity đó; ngược lại về task list
            if (relatedTypeFinal != null && relatedId != null) {
                String entityPath = resolveEntityPath(relatedTypeFinal, relatedId);
                resp.sendRedirect(req.getContextPath() + entityPath);
            } else {
                resp.sendRedirect(req.getContextPath() + "/tasks/list");
            }

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error creating task", ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // helpers
    // ─────────────────────────────────────────────────────────────────────────

    private Task buildTask(HttpServletRequest req, User creator) {
        Task t = new Task();
        t.setTitle(req.getParameter("title"));
        t.setDescription(req.getParameter("description"));
        t.setStatus(nvl(req.getParameter("status"),   "Pending"));
        t.setPriority(nvl(req.getParameter("priority"), "Medium"));
        t.setCreatedBy(creator);

        String progress = req.getParameter("progress");
        t.setProgress(progress != null && !progress.isBlank()
                ? Integer.parseInt(progress) : 0);

        String due = req.getParameter("dueDate");
        if (due != null && !due.isBlank()) t.setDueDate(LocalDateTime.parse(due, DT_FMT));

        String start = req.getParameter("startDate");
        if (start != null && !start.isBlank()) t.setStartDate(LocalDateTime.parse(start, DT_FMT));

        return t;
    }

    /**
     * Trả về đường dẫn redirect phù hợp với loại entity.
     * Mở rộng switch khi thêm các entity mới (Lead, Deal, Ticket…).
     */
    private String resolveEntityPath(String relatedType, int relatedId) {
        return switch (relatedType.toLowerCase()) {
            case "customer" -> "/customers/details?id=" + relatedId;
            case "lead"     -> "/leads/details?id="     + relatedId;
            case "deal"     -> "/deals/details?id="     + relatedId;
            case "ticket"   -> "/tickets/details?id="   + relatedId;
            default         -> "/tasks/list";
        };
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int    rid = user.getRole().getRoleId();
        String rn  = user.getRole().getRoleName();
        return rid == 1 || rid == 5
                || "ADMIN".equalsIgnoreCase(rn)
                || "MANAGER".equalsIgnoreCase(rn);
    }

    private static String nvl(String s, String def) {
        return s != null ? s : def;
    }
}