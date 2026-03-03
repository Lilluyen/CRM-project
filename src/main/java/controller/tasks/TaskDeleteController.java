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
 * POST /tasks/delete
 * Xóa task và toàn bộ dữ liệu liên quan (AJAX JSON).
 * Chỉ ADMIN và MANAGER được phép xóa.
 *
 * Request params:
 *   id (int) – task_id cần xóa
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/tasks/delete")
public class TaskDeleteController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        String roleName = user.getRole() != null ? user.getRole().getRoleName() : "";
        if (!"ADMIN".equalsIgnoreCase(roleName) && !"MANAGER".equalsIgnoreCase(roleName)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeJson(resp, "{\"success\":false,\"message\":\"Không có quyền xóa task\"}");
            return;
        }

        int taskId = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new TaskService(conn).deleteTask(taskId);
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Xóa task thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(TaskDeleteController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
