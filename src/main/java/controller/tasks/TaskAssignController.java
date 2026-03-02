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
 * POST /tasks/assign
 * Gán hoặc bỏ gán user khỏi một task (AJAX JSON).
 *
 * Request params:
 *   taskId (int)    – bắt buộc
 *   userId (int)    – bắt buộc
 *   action (String) – "add" (mặc định) hoặc "remove"
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/tasks/assign")
public class TaskAssignController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        int    taskId = Integer.parseInt(req.getParameter("taskId"));
        int    userId = Integer.parseInt(req.getParameter("userId"));
        String action = req.getParameter("action"); // "add" hoặc "remove"

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            boolean ok;

            if ("remove".equals(action)) {
                ok = svc.removeAssignee(taskId, userId);
            } else {
                Task task = svc.getTaskById(taskId);
                ok = svc.assignTask(taskId, userId, task);
            }

            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Thao tác thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(TaskAssignController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
