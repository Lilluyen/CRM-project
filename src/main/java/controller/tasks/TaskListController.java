package controller.tasks;

import dto.Pagination;
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
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/list
 *
 * Filter params (all optional):
 *   title, description, status, priority, fromDate, toDate
 *
 * Sort params:
 *   sortField (dueDate | priority | progress | title)
 *   sortDir   (ASC | DESC)
 *
 * Pagination:
 *   page     – 1-based (default 1)
 *   pageSize – 5 | 10 | 15 | 20 (default 10)
 *
 * Uses {@link dto.Pagination} DTO so the shared pagination.jsp component works correctly.
 */
@WebServlet("/tasks/list")
public class TaskListController extends HttpServlet {

    private static final int   DEFAULT_PAGE_SIZE = 10;
    private static final int[] ALLOWED_SIZES     = {5, 10, 15, 20};
    private static final Logger LOG = Logger.getLogger(TaskListController.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // ── Filter params ──
        String title       = nvl(req.getParameter("title"),       "");
        String description = nvl(req.getParameter("description"), "");
        String status      = nvl(req.getParameter("status"),      "");
        String priority    = nvl(req.getParameter("priority"),    "");
        String fromDate    = nvl(req.getParameter("fromDate"),    "");
        String toDate      = nvl(req.getParameter("toDate"),      "");
        // New filters: createdBy, relatedType, relatedId
        String createdBy   = nvl(req.getParameter("createdBy"),   "");
        String relatedType = nvl(req.getParameter("relatedType"), "");
        String relatedId   = nvl(req.getParameter("relatedId"),  "");

        // ── Sort params ──
        String sortField = nvl(req.getParameter("sortField"), "");
        String sortDir   = nvl(req.getParameter("sortDir"),   "ASC");
        if (!sortDir.equalsIgnoreCase("DESC")) sortDir = "ASC";

        // ── Pagination ──
        int pageSize = parsePageSize(req.getParameter("pageSize"));
        int page     = parsePage(req.getParameter("page"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            // Parse new filter values
            Integer createdByInt  = parseIntOrNull(createdBy);
            Integer relatedIdInt  = parseIntOrNull(relatedId);
            String  relTypeBlank  = blank(relatedType);

            int total = svc.countTasks(user,
                    blank(title), blank(description), blank(status), blank(priority),
                    blank(fromDate), blank(toDate),
                    createdByInt, relTypeBlank, relatedIdInt);

            // Build Pagination DTO (clamps page to valid range)
            Pagination pagination = new Pagination(page, pageSize, total);

            List<Task> tasks = svc.getTasksPaged(user,
                    blank(title), blank(description), blank(status), blank(priority),
                    blank(fromDate), blank(toDate),
                    createdByInt, relTypeBlank, relatedIdInt,
                    sortField, sortDir,
                    pagination.getCurrentPage(), pagination.getPageSize());

            // ── Request attributes for JSP ──
            req.setAttribute("tasks",      tasks);
            req.setAttribute("pagination", pagination);   // Pagination DTO for pagination.jsp

            // Convenience aliases still available for legacy JSP snippets
            req.setAttribute("currentPage",  pagination.getCurrentPage());
            req.setAttribute("totalPages",   pagination.getTotalPages());
            req.setAttribute("totalRecords", pagination.getTotalItems());
            req.setAttribute("pageSize",     pagination.getPageSize());

            // Pass filter values back so they stay visible in the search form
            req.setAttribute("f_title",       title);
            req.setAttribute("f_description", description);
            req.setAttribute("f_status",      status);
            req.setAttribute("f_priority",    priority);
            req.setAttribute("f_fromDate",    fromDate);
            req.setAttribute("f_toDate",      toDate);
            req.setAttribute("f_sortField",   sortField);
            req.setAttribute("f_sortDir",     sortDir);
            req.setAttribute("f_createdBy",   createdBy);
            req.setAttribute("f_relatedType", relatedType);
            req.setAttribute("f_relatedId",   relatedId);

            req.setAttribute("pageTitle",   "Task List");
            req.setAttribute("contentPage", "/view/tasks/tasklist.jsp");
            req.setAttribute("page",        "task-list");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error loading task list", ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    /** Return null when the trimmed string is blank so service/DAO ignores the filter. */
    private static String blank(String s) {
        return (s != null && !s.isBlank()) ? s.trim() : null;
    }

    private static String nvl(String s, String def) {
        return s != null ? s : def;
    }

    private static int parsePage(String val) {
        try {
            int p = Integer.parseInt(val);
            return p > 0 ? p : 1;
        } catch (Exception e) {
            return 1;
        }
    }

    private static int parsePageSize(String val) {
        try {
            int s = Integer.parseInt(val);
            for (int a : ALLOWED_SIZES) if (a == s) return s;
        } catch (Exception ignored) {
        }
        return DEFAULT_PAGE_SIZE;
    }

    private static Integer parseIntOrNull(String val) {
        if (val == null || val.isBlank()) return null;
        try { return Integer.parseInt(val.trim()); }
        catch (NumberFormatException e) { return null; }
    }
}