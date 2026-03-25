package controller.tasks;

import model.Task;
import model.TaskAssignee;
import model.User;
import service.TaskEmailService;
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
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /tasks/delete
 * Xóa task và toàn bộ dữ liệu liên quan (AJAX JSON).
 * Quyền:
 * - ADMIN/MANAGER (role_id=1 hoặc 5): xóa được mọi task
 * - Non-management: chỉ xóa được task do chính mình tạo VÀ người tạo không phải
 * role 1/5
 *
 * Request params:
 * id (int) – task_id cần xóa
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 *
 * Email notification (async):
 * Sau khi xóa thành công, gửi email cho người tạo và tất cả assignees.
 * Task object được fetch TRƯỚC khi xóa để giữ thông tin cần thiết cho email.
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

            // ── Fetch task TRƯỚC KHI XÓA để lấy thông tin gửi email ──
            // (Bắt buộc phải làm trước khi delete vì sau khi xóa không còn dữ liệu)
            Task task = svc.getTaskById(taskId);

            if (!isManagerOrAdmin(user)) {
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

                // Only creator can delete
                int creatorId = task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0;
                if (creatorId != user.getUserId()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    writeJson(resp, "{\"success\":false,\"message\":\"Bạn chỉ có thể xóa task do chính bạn tạo\"}");
                    return;
                }
            }

            // ── Nếu task vẫn null (manager path) thì fetch lại ──
            if (task == null) {
                task = svc.getTaskById(taskId);
            }

            // Thu thập recipients để gửi email SAU KHI xóa thành công
            // (snapshot trước khi dữ liệu bị xóa)
            final Task taskSnapshot = task;
            final List<User> recipients = buildDeleteRecipients(task, user);

            boolean ok = svc.deleteTask(taskId);

            if (ok) {
                // ── EMAIL: thông báo task đã bị xóa (async, fire-and-forget) ──
                // Dùng TaskEmailService trực tiếp vì không cần DB connection
                if (taskSnapshot != null && !recipients.isEmpty()) {
                    // Truyền thêm `user` (người xóa) để email hiển thị đúng "Updated by"
                    new TaskEmailService().notifyTaskDeleted(taskSnapshot, user, recipients);
                }
                writeJson(resp, "{\"success\":true}");
            } else {
                writeJson(resp, "{\"success\":false,\"message\":\"Xóa task thất bại\"}");
            }

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, null, ex);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, "{\"success\":false,\"message\":\"Lỗi hệ thống\"}");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Xây dựng danh sách người nhận email khi task bị xóa.
     * Bao gồm: người tạo task + tất cả assignees, loại trừ người đang thực hiện
     * xóa.
     */
    private List<User> buildDeleteRecipients(Task task, User deletedBy) {
        List<User> recipients = new ArrayList<>();
        if (task == null)
            return recipients;

        // Người tạo task (nếu không phải người đang xóa)
        if (task.getCreatedBy() != null
                && task.getCreatedBy().getUserId() != deletedBy.getUserId()) {
            recipients.add(task.getCreatedBy());
        }

        // Tất cả assignees (loại trừ người xóa và đã có trong danh sách)
        if (task.getAssignees() != null) {
            for (TaskAssignee ta : task.getAssignees()) {
                if (ta.getUser() == null)
                    continue;
                int uid = ta.getUser().getUserId();
                if (uid == deletedBy.getUserId())
                    continue;
                if (task.getCreatedBy() != null && uid == task.getCreatedBy().getUserId())
                    continue;
                recipients.add(ta.getUser());
            }
        }

        return recipients;
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null)
            return false;
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