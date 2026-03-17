package controller.tasks;

import dao.TaskCommentDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import model.TaskComment;
import model.TaskHistory;
import model.TaskHistoryDetail;
import model.User;
import service.TaskService;
import util.DBContext;

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
 * GET /tasks/view-history?id={taskId}
 *
 * Hiển thị toàn bộ lịch sử task bao gồm:
 * - Thông tin task
 * - Danh sách người được giao (assignees)
 * - Work items / Subtasks với trạng thái
 * - Lịch sử thay đổi (audit log)
 *
 * Dùng cho nghiệm thu và chuyển giao công việc.
 */
@WebServlet("/tasks/view-history")
public class TaskViewHistoryController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(TaskViewHistoryController.class.getName());
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yy");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User current = (User) req.getSession().getAttribute("user");
        if (current == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String rawId = req.getParameter("id");
        if (rawId == null) {
            resp.sendRedirect(req.getContextPath() + "/tasks/list");
            return;
        }

        int taskId;
        try {
            taskId = Integer.parseInt(rawId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/tasks/list");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            Task task = svc.getTaskById(taskId);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found: id=" + taskId);
                return;
            }

            // Load work items / subtasks
            TaskCommentDAO commentDAO = new TaskCommentDAO(conn);
            List<TaskComment> workItems = commentDAO.findByTaskId(taskId);

            // Phân biệt root items và replies
            List<TaskComment> rootItems = new ArrayList<>();
            Map<Integer, List<TaskComment>> repliesMap = new HashMap<>();
            for (TaskComment wi : workItems) {
                if (wi.getParentCommentId() == null) {
                    rootItems.add(wi);
                } else {
                    repliesMap.computeIfAbsent(wi.getParentCommentId(), k -> new ArrayList<>()).add(wi);
                }
            }

            // Load history
            List<TaskHistory> allHistory = svc.getHistoryForTask(taskId);
            UserDAO userDAO = new UserDAO();

            // Resolve assignee names in history details
            Set<Integer> assigneeUserIds = new HashSet<>();
            List<HistoryView> allViews = new ArrayList<>();

            for (TaskHistory h : allHistory) {
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
                allViews.add(new HistoryView(h, time, changerName));
            }

            // Resolve assignee names for display
            Map<Integer, String> assigneeNames = new HashMap<>();
            for (int uid : assigneeUserIds) {
                User u = userDAO.getUserById(uid);
                if (u != null) {
                    assigneeNames.put(uid, notBlank(u.getFullName()) ? u.getFullName() : safe(u.getUsername()));
                }
            }

            // Bind to request
            req.setAttribute("task", task);
            req.setAttribute("rootWorkItems", rootItems);
            req.setAttribute("repliesMap", repliesMap);
            req.setAttribute("historyViews", allViews);
            req.setAttribute("assigneeNames", assigneeNames);
            req.setAttribute("workItemCount", workItems.size());
            req.setAttribute("completedCount", (int) workItems.stream().filter(TaskComment::isCompleted).count());

            req.setAttribute("pageTitle", "Task Handover - "
                    + (task.getTitle() != null ? task.getTitle() : ("#" + taskId)));
            req.setAttribute("contentPage", "/view/tasks/view-history.jsp");
            req.setAttribute("page", "task-history");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error loading task history view id=" + taskId, ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private static void parseUserId(String raw, Set<Integer> out) {
        if (raw == null) return;
        try {
            int id = Integer.parseInt(raw.trim());
            if (id > 0) out.add(id);
        } catch (Exception ignored) {
            ignored.printStackTrace();
        }
    }

    private static boolean notBlank(String s) { return s != null && !s.isBlank(); }
    private static String safe(String s) { return s != null ? s : ""; }

    public static class HistoryView {
        private final TaskHistory history;
        private final String changedAtDisplay;
        private final String changedByName;

        public HistoryView(TaskHistory history, String changedAtDisplay, String changedByName) {
            this.history = history;
            this.changedAtDisplay = changedAtDisplay;
            this.changedByName = changedByName;
        }

        public TaskHistory getHistory() { return history; }
        public String getChangedAtDisplay() { return changedAtDisplay; }
        public String getChangedByName() { return changedByName; }
    }
}
