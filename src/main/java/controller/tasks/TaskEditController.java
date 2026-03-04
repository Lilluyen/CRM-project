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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /tasks/edit?id={taskId}  – hiển thị form chỉnh sửa task
 * POST /tasks/edit               – lưu thay đổi, redirect sang details
 */
@WebServlet("/tasks/edit")
public class TaskEditController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (req.getParameter("id") == null) {
            resp.sendRedirect(req.getContextPath()+"/tasks/list");
        }
        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            Task task = new TaskService(conn).getTaskById(id);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task không tồn tại: id=" + id);
                return;
            }
            req.setAttribute("task",        task);
            req.setAttribute("pageTitle",   "Edit Task – " + task.getTitle());
            req.setAttribute("contentPage", "/view/tasks/task-edit.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(TaskEditController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int taskId = Integer.parseInt(req.getParameter("taskId"));
        Task task  = buildTask(req);
        task.setTaskId(taskId);

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            boolean ok = svc.updateTask(task);

            if (!ok) {
                Task existing = svc.getTaskById(taskId);
                req.setAttribute("task",        existing != null ? existing : task);
                req.setAttribute("error",       "Cập nhật thất bại. Vui lòng thử lại.");
                req.setAttribute("pageTitle",   "Edit Task");
                req.setAttribute("contentPage", "/view/tasks/task-edit.jsp");
                req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
                return;
            }

            req.getSession().setAttribute("flashSuccess", "Task đã được cập nhật.");
            resp.sendRedirect(req.getContextPath() + "/tasks/details?id=" + taskId);
        } catch (SQLException ex) {
            Logger.getLogger(TaskEditController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private Task buildTask(HttpServletRequest req) {
        Task t = new Task();
        t.setTitle(req.getParameter("title"));
        t.setDescription(req.getParameter("description"));
        t.setStatus(req.getParameter("status"));
        t.setPriority(req.getParameter("priority"));

        String progress = req.getParameter("progress");
        t.setProgress(progress != null && !progress.isBlank() ? Integer.parseInt(progress) : 0);

        String due = req.getParameter("dueDate");
        if (due != null && !due.isBlank()) {
            t.setDueDate(LocalDateTime.parse(due, DT_FMT));
        }
        return t;
    }
}
