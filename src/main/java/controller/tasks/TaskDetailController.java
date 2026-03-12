package controller.tasks;

import dao.UserDAO;
import model.Task;
import model.TaskHistory;
import model.TaskHistoryDetail;
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
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/details?id={taskId}
 * Hiển thị chi tiết task kèm danh sách assignees, progress và nút đổi status.
 */
@WebServlet("/tasks/details")
public class TaskDetailController extends HttpServlet {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yy");

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
            return;
        }
        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task task = svc.getTaskById(id);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task không tồn tại: id=" + id);
                return;
            }

            // Load task history so we can show it below the details in one page
            List<TaskHistory> history = svc.getHistoryForTask(id);
            UserDAO userDAO = new UserDAO();

            List<TaskViewHistoryController.HistoryView> views = new ArrayList<>();
            Set<Integer> assigneeUserIds = new HashSet<>();

            if (history != null) {
                for (TaskHistory h : history) {
                    List<TaskHistoryDetail> details = svc.getHistoryDetails(h.getHistoryId());
                    h.setDetails(details);

                    if (details != null) {
                        for (TaskHistoryDetail d : details) {
                            if (d == null || d.getFieldName() == null) continue;
                            if ("assignee_added".equalsIgnoreCase(d.getFieldName())) {
                                parseUserId(d.getNewValue(), assigneeUserIds);
                            } else if ("assignee_removed".equalsIgnoreCase(d.getFieldName())) {
                                parseUserId(d.getOldValue(), assigneeUserIds);
                            }
                        }
                    }

                    User changer = h.getChangedBy() > 0 ? userDAO.getUserById(h.getChangedBy()) : null;
                    String changerName = changer != null
                            ? (notBlank(changer.getFullName()) ? changer.getFullName() : safe(changer.getUsername()))
                            : "";
                    String time = h.getChangedAt() != null ? h.getChangedAt().format(FMT) : "";

                    views.add(new TaskViewHistoryController.HistoryView(h, time, changerName));
                }
            }

            Map<Integer, String> assigneeNames = new HashMap<>();
            for (int uid : assigneeUserIds) {
                User u = userDAO.getUserById(uid);
                if (u != null) {
                    assigneeNames.put(uid, notBlank(u.getFullName()) ? u.getFullName() : safe(u.getUsername()));
                }
            }

            req.setAttribute("task",        task);
            req.setAttribute("historyViews", views);
            req.setAttribute("assigneeNames", assigneeNames);
            req.setAttribute("pageTitle",   "Task Details – " + task.getTitle());
            req.setAttribute("contentPage", "/view/tasks/task-detail.jsp");
            req.setAttribute("page", "task-details");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
        } catch (SQLException ex) {
            Logger.getLogger(TaskDetailController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private static void parseUserId(String raw, Set<Integer> out) {
        if (raw == null) return;
        try {
            int id = Integer.parseInt(raw.trim());
            if (id > 0) out.add(id);
        } catch (Exception ignored) {
            // ignore parse errors (history may store non-numeric values)
        }
    }

    private static boolean notBlank(String s) {
        return s != null && !s.isBlank();
    }

    private static String safe(String s) {
        return s != null ? s : "";
    }
}
