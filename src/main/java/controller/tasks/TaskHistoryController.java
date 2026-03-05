package controller.tasks;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import model.TaskHistory;
import model.TaskHistoryDetail;
import model.User;
import service.TaskService;
import util.DBContext;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/history?taskId={id}
 * Trả về JSON lịch sử thay đổi cho một task.
 *
 * Response:
 * [
 *   {
 *     "historyId": 1,
 *     "taskId": 10,
 *     "changedBy": 5,
 *     "changedByName": "Nguyen Van A",
 *     "changedAt": "2025-03-01 14:22",
 *     "details": [
 *       { "fieldName": "status", "oldValue": "Pending", "newValue": "Done" }
 *     ]
 *   }
 * ]
 */
@WebServlet("/tasks/history")
public class TaskHistoryController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(TaskHistoryController.class.getName());
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User current = (User) req.getSession().getAttribute("user");
        if (current == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "[]");
            return;
        }

        String idRaw = req.getParameter("taskId");
        if (idRaw == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, "[]");
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(idRaw);
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, "[]");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            // Đảm bảo task tồn tại
            Task task = svc.getTaskById(taskId);
            if (task == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(resp, "[]");
                return;
            }

            List<TaskHistory> historyList = svc.getHistoryForTask(taskId);

            StringBuilder sb = new StringBuilder();
            sb.append("[");
            UserDAO userDAO = new UserDAO();

            for (int i = 0; i < historyList.size(); i++) {
                TaskHistory h = historyList.get(i);
                if (i > 0) sb.append(",");

                List<TaskHistoryDetail> details = svc.getHistoryDetails(h.getHistoryId());

                String changedAt = h.getChangedAt() != null ? h.getChangedAt().format(FMT) : "";
                User changer = h.getChangedBy() > 0 ? userDAO.getUserById(h.getChangedBy()) : null;
                String changerName = changer != null
                        ? (changer.getFullName() != null && !changer.getFullName().isBlank()
                            ? changer.getFullName()
                            : changer.getUsername())
                        : "";

                sb.append("{")
                  .append("\"historyId\":").append(h.getHistoryId()).append(",")
                  .append("\"taskId\":").append(h.getTaskId()).append(",")
                  .append("\"changedBy\":").append(h.getChangedBy()).append(",")
                  .append("\"changedByName\":\"").append(escapeJson(changerName)).append("\",")
                  .append("\"changedAt\":\"").append(escapeJson(changedAt)).append("\",")
                  .append("\"details\":[");

                for (int j = 0; j < details.size(); j++) {
                    TaskHistoryDetail d = details.get(j);
                    if (j > 0) sb.append(",");
                    sb.append("{")
                      .append("\"fieldName\":\"").append(escapeJson(d.getFieldName())).append("\",")
                      .append("\"oldValue\":\"").append(escapeJson(d.getOldValue())).append("\",")
                      .append("\"newValue\":\"").append(escapeJson(d.getNewValue())).append("\"")
                      .append("}");
                }

                sb.append("]}");
            }

            sb.append("]");
            writeJson(resp, sb.toString());
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error loading task history", ex);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, "[]");
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}

