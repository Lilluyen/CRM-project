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
 * Quyền:
 *  - ADMIN/MANAGER (role_id=1 hoặc 5): xóa được mọi task
 *  - Non-management: chỉ xóa được task do chính mình tạo VÀ người tạo không phải role 1/5
 *
 * Request params:
 *   id (int) – task_id cần xóa
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/tasks/delete")
public class TaskDeleteController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(TaskDeleteController.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, "{\"success\":false,\"message\":\"Thiếu hoặc sai id\"}");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            // Privileged: always allow
            if (!isManagerOrAdmin(user)) {
                model.Task task = svc.getTaskById(taskId);
                if (task == null) {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeJson(resp, "{\"success\":false,\"message\":\"Task không tồn tại\"}");
                    return;
                }

                // Block delete if task created by management
                int creatorRoleId = task.getCreatedBy() != null && task.getCreatedBy().getRole() != null
                        ? task.getCreatedBy().getRole().getRoleId()
                        : 0;
                if (creatorRoleId == 1 || creatorRoleId == 5) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    writeJson(resp, "{\"success\":false,\"message\":\"Không thể xóa task do quản lý tạo\"}");
                    return;
                }

                // Only creator can delete (safer)
                int creatorId = task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0;
                if (creatorId != user.getUserId()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    writeJson(resp, "{\"success\":false,\"message\":\"Bạn chỉ có thể xóa task do chính bạn tạo\"}");
                    return;
                }
            }

            boolean ok = svc.deleteTask(taskId);
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Xóa task thất bại\"}");
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, null, ex);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống\"}");
        }
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
