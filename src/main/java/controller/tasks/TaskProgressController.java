package controller.tasks;

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
 * POST /tasks/progress
 * Cập nhật phần trăm tiến độ của task (AJAX JSON).
 * Tự động đổi status: 0 → Pending | 1-99 → In Progress | 100 → Done.
 *
 * Request params:
 *   taskId   (int) – bắt buộc
 *   progress (int) – 0 đến 100
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/tasks/progress")
public class TaskProgressController extends HttpServlet {

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
        int taskId   = Integer.parseInt(req.getParameter("taskId"));
        int progress = Integer.parseInt(req.getParameter("progress"));

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new TaskService(conn).updateProgress(taskId, progress);
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Cập nhật tiến độ thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(TaskProgressController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
