package controller.tasks;

import dao.UserDAO;
import dto.Pagination;
import model.Activity;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/details?id={taskId}[&activityPage=1]
 *
 * Attributes bound for JSP:
 *   task               – Task object (with assignees)
 *   historyViews       – List<HistoryView> (changerName from SQL JOIN – no N+1)
 *   activities         – List<Activity> paged  (Scenario 14)
 *   activityPagination – Pagination DTO
 *   allUsers           – List<User> active users (for @mention & tag-supporter dropdown)
 *   isManager          – boolean (gate for Reopen button)
 *
 * Note: progress is now computed client-side from /api/task-comments?taskId=
 * No progress is passed from the server; the SVG ring is driven by JS.
 */
@WebServlet("/tasks/details")
public class TaskDetailController extends HttpServlet {

    private static final int    ACTIVITY_PAGE_SIZE = 10;
    private static final Logger LOG = Logger.getLogger(TaskDetailController.class.getName());
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yy");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String rawId = req.getParameter("id");
        if (rawId == null) { resp.sendRedirect(req.getContextPath() + "/tasks/list"); return; }

        int taskId;
        try { taskId = Integer.parseInt(rawId); }
        catch (NumberFormatException e) { resp.sendRedirect(req.getContextPath() + "/tasks/list"); return; }

        int activityPage = parsePage(req.getParameter("activityPage"));

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            // 1. Task
            Task task = svc.getTaskById(taskId);
            if (task == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Task không tồn tại: id=" + taskId);
                return;
            }

            // 2. History – FIX: changerName now comes directly from DAO SQL JOIN
            //    TaskHistory.getChangerName() was set by listTaskHistoryByID JOIN
            //    → zero extra userDAO.getUserById() calls
            List<TaskHistory> historyList = svc.getHistoryForTask(taskId);
            List<TaskViewHistoryController.HistoryView> historyViews = new ArrayList<>();
            for (TaskHistory h : historyList) {
                List<TaskHistoryDetail> details = svc.getHistoryDetails(h.getHistoryId());
                h.setDetails(details);
                // changerName already populated by DAO; fall back gracefully
                String changerName = h.getChangerName() != null && !h.getChangerName().isBlank()
                        ? h.getChangerName() : "";
                String time = h.getChangedAt() != null ? h.getChangedAt().format(FMT) : "";
                historyViews.add(new TaskViewHistoryController.HistoryView(h, time, changerName));
            }

            // 3. Activity timeline (Scenario 14)
            int actTotal = svc.countActivitiesForTask(taskId);
            Pagination actPag = new Pagination(activityPage, ACTIVITY_PAGE_SIZE, actTotal);
            List<Activity> activities = svc.getActivitiesForTask(
                    taskId, actPag.getCurrentPage(), actPag.getPageSize());

            // 4. All active users for @mention autocomplete + tag-supporter picker
            List<User> allUsers;
            try { allUsers = new UserDAO().getActiveUsers(); }
            catch (Exception e) { allUsers = new ArrayList<>(); }

            boolean isManager = isManagerOrAdmin(user);

            req.setAttribute("task",               task);
            req.setAttribute("historyViews",       historyViews);
            req.setAttribute("activities",         activities);
            req.setAttribute("activityPagination", actPag);
            req.setAttribute("allUsers",           allUsers);
            req.setAttribute("isManager",          isManager);
            req.setAttribute("pageTitle",   "Task Details – " + task.getTitle());
            req.setAttribute("contentPage", "/view/tasks/task-detail.jsp");
            req.setAttribute("page",        "task-details");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error loading task detail id=" + taskId, ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private static int parsePage(String val) {
        try { int p = Integer.parseInt(val); return p > 0 ? p : 1; }
        catch (Exception e) { return 1; }
    }

    private static boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int rid = user.getRole().getRoleId();
        String rn = user.getRole().getRoleName();
        return rid == 1 || rid == 5 || "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }
}
