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
 * Hiển thị danh sách task với filter, sort và phân trang.
 *
 * Request params (optional):
 *   title, status, priority  – bộ lọc
 *   sortField, sortDir        – sắp xếp (sortField: dueDate | priority | status | progress)
 *   page                      – số trang, mặc định 1
 */
@WebServlet("/tasks/list")
public class TaskListController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String title     = req.getParameter("title");
        String status    = req.getParameter("status");
        String priority  = req.getParameter("priority");
        String sortField = req.getParameter("sortField") != null ? req.getParameter("sortField") : "";
        String sortDir   = req.getParameter("sortDir")   != null ? req.getParameter("sortDir")   : "";
        int    page      = parsePage(req);

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            List<Task> tasks = svc.getTasksPaged(user, title, status, priority, sortField, sortDir, page, PAGE_SIZE);
            int total        = svc.countTasks(user, title, status, priority);
            int totalPages   = (int) Math.ceil((double) total / PAGE_SIZE);

            req.setAttribute("tasks",        tasks);
            req.setAttribute("currentPage",  page);
            req.setAttribute("totalPages",   totalPages);
            req.setAttribute("totalRecords", total);
            req.setAttribute("pageSize",     PAGE_SIZE);
            req.setAttribute("pageTitle",    "Task List");
            req.setAttribute("contentPage",  "/view/tasks/tasklist.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(TaskListController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private int parsePage(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return p > 0 ? p : 1;
        } catch (Exception e) {
            return 1;
        }
    }
}
