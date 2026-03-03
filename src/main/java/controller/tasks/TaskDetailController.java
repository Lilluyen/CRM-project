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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/details?id={taskId}
 * Hiển thị chi tiết task kèm danh sách assignees, progress và nút đổi status.
 */
@WebServlet("/tasks/details")
public class TaskDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            Task task = new TaskService(conn).getTaskById(id);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task không tồn tại: id=" + id);
                return;
            }
            req.setAttribute("task",        task);
            req.setAttribute("pageTitle",   "Task Details – " + task.getTitle());
            req.setAttribute("contentPage", "/view/tasks/task-detail.jsp");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(TaskDetailController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
