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
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /tasks/status
 * Cập nhật status của task và gửi notification đến assignees (AJAX JSON).
 *
 * Request params:
 *   taskId (int)    – bắt buộc
 *   status (String) – Pending | In Progress | Done | Overdue | Cancelled
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/tasks/status")
public class TaskStatusController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }
        if (req.getParameter("taskId") == null) {
            resp.sendRedirect(req.getContextPath()+"/tasks/list");
        }
        int    taskId = Integer.parseInt(req.getParameter("taskId"));
        String status = req.getParameter("status");

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc  = new TaskService(conn);
            Task        task = svc.getTaskById(taskId);
            boolean     ok   = svc.updateStatus(taskId, status, task);

            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Cập nhật status thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(TaskStatusController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
