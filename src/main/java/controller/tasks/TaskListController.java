package controller.tasks;

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
 *   sortField (dueDate | priority | progress)
 *   sortDir   (ASC | DESC)
 *
 * Pagination:
 *   page     – 1-based (default 1)
 *   pageSize – 5 | 10 | 15 | 20 (default 10)
 */
@WebServlet("/tasks/list")
public class TaskListController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int[] ALLOWED_SIZES   = {5, 10, 15, 20};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        // ── Filter params ──
        String title       = req.getParameter("title");
        String description = req.getParameter("description");
        String status      = req.getParameter("status");
        String priority    = req.getParameter("priority");
        String fromDate    = req.getParameter("fromDate");
        String toDate      = req.getParameter("toDate");

        // ── Sort params ──
        String sortField = nvl(req.getParameter("sortField"), "");
        String sortDir   = nvl(req.getParameter("sortDir"),   "ASC");

        // ── Pagination ──
        int pageSize = parsePageSize(req.getParameter("pageSize"));
        int page     = parsePage(req.getParameter("page"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            List<Task> tasks = svc.getTasksPaged(user,
                    title, description, status, priority, fromDate, toDate,
                    sortField, sortDir, page, pageSize);

            int total      = svc.countTasks(user, title, description, status, priority, fromDate, toDate);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            // ── Request attributes for JSP ──
            req.setAttribute("tasks",        tasks);
            req.setAttribute("currentPage",  page);
            req.setAttribute("totalPages",   totalPages);
            req.setAttribute("totalRecords", total);
            req.setAttribute("pageSize",     pageSize);

            // Pass filters back so they stay in the form
            req.setAttribute("f_title",       nvl(title,       ""));
            req.setAttribute("f_description", nvl(description, ""));
            req.setAttribute("f_status",      nvl(status,      ""));
            req.setAttribute("f_priority",    nvl(priority,    ""));
            req.setAttribute("f_fromDate",    nvl(fromDate,    ""));
            req.setAttribute("f_toDate",      nvl(toDate,      ""));
            req.setAttribute("f_sortField",   sortField);
            req.setAttribute("f_sortDir",     sortDir);

            req.setAttribute("pageTitle",   "Task List");
            req.setAttribute("contentPage", "/view/tasks/tasklist.jsp");
            req.setAttribute("page", "task-list");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(TaskListController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────
    private static int parsePage(String val) {
        try { int p = Integer.parseInt(val); return p > 0 ? p : 1; }
        catch (Exception e) { return 1; }
    }

    private static int parsePageSize(String val) {
        try {
            int s = Integer.parseInt(val);
            for (int a : ALLOWED_SIZES) if (a == s) return s;
        } catch (Exception ignored) {}
        return DEFAULT_PAGE_SIZE;
    }

    private static String nvl(String s, String def) {
        return s != null ? s : def;
    }
}
