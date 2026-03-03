package controller.tasks;

import dao.UserDAO;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET  /tasks/create  – hiển thị form tạo task mới
 * POST /tasks/create  – lưu task mới, gán assignees, redirect sang list
 */
@WebServlet("/tasks/create")
public class TaskCreateController extends HttpServlet {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        loadAllUsers(req);
        req.setAttribute("pageTitle",   "Create Task");
        req.setAttribute("contentPage", "/view/tasks/task-create.jsp");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Task task = buildTask(req, user);

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            boolean ok = svc.createTask(task);

            if (!ok) {
                req.setAttribute("error",       "Không thể tạo task. Vui lòng kiểm tra lại thông tin.");
                req.setAttribute("pageTitle",   "Create Task");
                req.setAttribute("contentPage", "/frontend/tasks/task-create.jsp");
                loadAllUsers(req);
                req.getRequestDispatcher("/frontend/layout.jsp").forward(req, resp);
                return;
            }

            // Gán assignees
            String[] assigneeIds = req.getParameterValues("assigneeIds");
            if (assigneeIds != null && task.getTaskId() != null) {
                for (String uid : assigneeIds) {
                    svc.assignTask(task.getTaskId(), Integer.parseInt(uid), task);
                }
            }

            req.getSession().setAttribute("flashSuccess", "Task \"" + task.getTitle() + "\" đã được tạo.");
            resp.sendRedirect(req.getContextPath() + "/tasks/list");
        } catch (SQLException ex) {
            Logger.getLogger(TaskCreateController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private Task buildTask(HttpServletRequest req, User creator) {
        Task t = new Task();
        t.setTitle(req.getParameter("title"));
        t.setDescription(req.getParameter("description"));
        t.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "Pending");
        t.setPriority(req.getParameter("priority") != null ? req.getParameter("priority") : "Medium");
        t.setCreatedBy(creator);

        String progress = req.getParameter("progress");
        t.setProgress(progress != null && !progress.isBlank() ? Integer.parseInt(progress) : 0);

        String due = req.getParameter("dueDate");
        if (due != null && !due.isBlank()) {
            t.setDueDate(LocalDateTime.parse(due, DT_FMT));
        }
        return t;
    }

    private void loadAllUsers(HttpServletRequest req) throws ServletException {
        try (Connection conn = DBContext.getConnection()) {
            List<User> users = new UserDAO().getAllUsers(conn);
            req.setAttribute("allUsers", users);
        } catch (Exception e) {
            throw new ServletException("Không thể tải danh sách users", e);
        }
    }
}
