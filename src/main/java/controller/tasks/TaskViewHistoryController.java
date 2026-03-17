package controller.tasks;

import dao.UserDAO;
import dto.Pagination;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import model.TaskHistory;
import model.TaskHistoryDetail;
import model.User;
import service.TaskService;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/view-history?id={taskId}[&page=1&pageSize=20]
 *
 * Timeline lịch sử thay đổi task, gom nhóm theo historyId.
 * Hỗ trợ phân trang để xử lý task có nhiều lần thay đổi.
 *
 * Request params:
 *   id       (required) – task_id
 *   page     (optional) – trang hiện tại, default 1
 *   pageSize (optional) – 10 | 20 | 50, default 20
 */
@WebServlet("/tasks/view-history")
public class TaskViewHistoryController extends HttpServlet {

    private static final int    DEFAULT_PAGE_SIZE = 20;
    private static final int[]  ALLOWED_SIZES     = {10, 20, 50};
    private static final Logger LOG = Logger.getLogger(TaskViewHistoryController.class.getName());
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yy");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User current = (User) req.getSession().getAttribute("user");
        if (current == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String rawId = req.getParameter("id");
        if (rawId == null) {
            resp.sendRedirect(req.getContextPath() + "/tasks/list");
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(rawId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/tasks/list");
            return;
        }

        int page     = parsePage(req.getParameter("page"));
        int pageSize = parsePageSize(req.getParameter("pageSize"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc  = new TaskService(conn);
            Task task = svc.getTaskById(taskId);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found: id=" + taskId);
                return;
            }

            // Load ALL history records for this task (usually a modest number)
            List<TaskHistory> allHistory = svc.getHistoryForTask(taskId);
            UserDAO userDAO = new UserDAO();

            // Collect every user-id referenced in assignee-change details
            Set<Integer> assigneeUserIds = new HashSet<>();
            List<HistoryView> allViews = new ArrayList<>();

            for (TaskHistory h : allHistory) {
                List<TaskHistoryDetail> details = svc.getHistoryDetails(h.getHistoryId());
                h.setDetails(details);

                if (details != null) {
                    for (TaskHistoryDetail d : details) {
                        if (d == null || d.getFieldName() == null) continue;
                        if ("assignee_added".equalsIgnoreCase(d.getFieldName())) {
                            parseUserId(d.getNewValue(), assigneeUserIds);
                        } else if ("assignee_removed".equalsIgnoreCase(d.getFieldName())) {
                            parseUserId(d.getOldValue(), assigneeUserIds);
                        }
                    }
                }

                User changer = h.getChangedBy() > 0 ? userDAO.getUserById(h.getChangedBy()) : null;
                String changerName = changer != null
                        ? (notBlank(changer.getFullName()) ? changer.getFullName() : safe(changer.getUsername()))
                        : "";
                String time = h.getChangedAt() != null ? h.getChangedAt().format(FMT) : "";
                allViews.add(new HistoryView(h, time, changerName));
            }

            // Resolve assignee names used in history details
            Map<Integer, String> assigneeNames = new HashMap<>();
            for (int uid : assigneeUserIds) {
                User u = userDAO.getUserById(uid);
                if (u != null) {
                    assigneeNames.put(uid, notBlank(u.getFullName()) ? u.getFullName() : safe(u.getUsername()));
                }
            }

            // ── Paginate the view list in-memory ──────────────────────────────
            int total       = allViews.size();
            Pagination pagination = new Pagination(page, pageSize, total);

            int fromIdx = pagination.getOffset();
            int toIdx   = Math.min(fromIdx + pagination.getPageSize(), total);
            List<HistoryView> pagedViews = (total == 0)
                    ? new ArrayList<>()
                    : allViews.subList(fromIdx, toIdx);

            // ── Bind to request ───────────────────────────────────────────────
            req.setAttribute("task",          task);
            req.setAttribute("historyViews",  pagedViews);
            req.setAttribute("assigneeNames", assigneeNames);
            req.setAttribute("pagination",    pagination);   // for pagination.jsp

            req.setAttribute("pageTitle",   "Task History – "
                    + (task.getTitle() != null ? task.getTitle() : ("#" + taskId)));
            req.setAttribute("contentPage", "/view/tasks/view-history.jsp");
            req.setAttribute("page",        "task-history");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error loading task history view id=" + taskId, ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private static void parseUserId(String raw, Set<Integer> out) {
        if (raw == null) return;
        try {
            int id = Integer.parseInt(raw.trim());
            if (id > 0) out.add(id);
        } catch (Exception ignored) {
            ignored.printStackTrace();
        }
    }

    private static int parsePage(String val) {
        try { int p = Integer.parseInt(val); return p > 0 ? p : 1; }
        catch (Exception e) { return 1; }
    }

    private static int parsePageSize(String val) {
        try {
            int s = Integer.parseInt(val);
            for (int a : ALLOWED_SIZES) if (a == s) return s;
        } catch (Exception ignored) {
            ignored.printStackTrace();
        }
        return DEFAULT_PAGE_SIZE;
    }

    private static boolean notBlank(String s) { return s != null && !s.isBlank(); }
    private static String  safe(String s)      { return s != null ? s : ""; }

    // ── Inner DTO for JSP rendering ──────────────────────────────────────────

    /** Small view-model for JSP – wraps TaskHistory with display-friendly fields. */
    public static class HistoryView {
        private final TaskHistory history;
        private final String      changedAtDisplay;
        private final String      changedByName;

        public HistoryView(TaskHistory history, String changedAtDisplay, String changedByName) {
            this.history          = history;
            this.changedAtDisplay = changedAtDisplay;
            this.changedByName    = changedByName;
        }

        public TaskHistory getHistory()          { return history; }
        public String getChangedAtDisplay()      { return changedAtDisplay; }
        public String getChangedByName()         { return changedByName; }
    }
}