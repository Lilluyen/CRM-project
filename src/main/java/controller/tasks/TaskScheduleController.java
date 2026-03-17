package controller.tasks;

import model.Task;
import model.TaskComment;
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
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/schedule - Show weekly schedule view
 *
 * Query params:
 *   weekOffset - offset from current week (-10 to +10)
 *   view - "week" (default) or "month" - currently just week view
 *
 * For employee: shows their tasks + subtasks for the selected week
 * For manager: shows all root tasks of subordinates for the selected week
 */
@WebServlet("/tasks/schedule")
public class TaskScheduleController extends HttpServlet {

    private static final int MAX_WEEK_OFFSET = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Parse week offset
        int weekOffset = 0;
        try {
            String offsetStr = req.getParameter("weekOffset");
            if (offsetStr != null && !offsetStr.isBlank()) {
                weekOffset = Integer.parseInt(offsetStr);
            }
        } catch (NumberFormatException ignored) {}

        // Clamp week offset to [-10, +10]
        weekOffset = Math.max(-MAX_WEEK_OFFSET, Math.min(MAX_WEEK_OFFSET, weekOffset));

        // Calculate the target week's start and end
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.plusWeeks(weekOffset).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(7); // Exclusive end

        // Check if user is manager
        boolean isManager = isManagerOrAdmin(user);

        // Get tasks and subtasks for the week
        List<Task> tasks = new ArrayList<>();
        List<TaskComment> subtasks = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);

            tasks = svc.getScheduleTasks(user.getUserId(), isManager, weekStart, weekEnd);

            // Get task IDs to fetch subtasks
            List<Integer> taskIds = tasks.stream()
                    .map(Task::getTaskId)
                    .collect(Collectors.toList());

            if (!taskIds.isEmpty()) {
                subtasks = svc.getScheduleSubtasks(taskIds, weekStart, weekEnd);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TaskScheduleController.class.getName()).log(Level.SEVERE, null, ex);
        }

        // Build week days
        List<LocalDate> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            weekDays.add(weekStart.plusDays(i));
        }

        // Format week range for display
        String weekRange;
        if (weekStart.getMonth() == weekEnd.minusDays(1).getMonth()) {
            weekRange = weekStart.format(DateTimeFormatter.ofPattern("MMM d")) + " - "
                      + weekEnd.minusDays(1).format(DateTimeFormatter.ofPattern("d, yyyy"));
        } else if (weekStart.getYear() == weekEnd.minusDays(1).getYear()) {
            weekRange = weekStart.format(DateTimeFormatter.ofPattern("MMM d")) + " - "
                      + weekEnd.minusDays(1).format(DateTimeFormatter.ofPattern("MMM d, yyyy"));
        } else {
            weekRange = weekStart.format(DateTimeFormatter.ofPattern("MMM d, yyyy")) + " - "
                      + weekEnd.minusDays(1).format(DateTimeFormatter.ofPattern("MMM d, yyyy"));
        }

        // Build week options for dropdown (-10 to +10)
        List<WeekOption> weekOptions = new ArrayList<>();
        for (int i = -MAX_WEEK_OFFSET; i <= MAX_WEEK_OFFSET; i++) {
            LocalDate ws = today.plusWeeks(i).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            String label;
            if (i == 0) {
                label = "This Week";
            } else if (i < 0) {
                label = Math.abs(i) + " week" + (Math.abs(i) > 1 ? "s" : "") + " ago";
            } else {
                label = "In " + i + " week" + (i > 1 ? "s" : "");
            }
            weekOptions.add(new WeekOption(i, ws.format(DateTimeFormatter.ofPattern("MMM d")), label));
        }

        // Set attributes
        req.setAttribute("tasks", tasks);
        req.setAttribute("subtasks", subtasks);
        req.setAttribute("weekDays", weekDays);
        req.setAttribute("weekStart", weekStart);
        req.setAttribute("weekEnd", weekEnd);
        req.setAttribute("weekOffset", weekOffset);
        req.setAttribute("weekRange", weekRange);
        req.setAttribute("weekOptions", weekOptions);
        req.setAttribute("isManager", isManager);
        req.setAttribute("currentUserId", user.getUserId());

        req.setAttribute("pageTitle", "Task Schedule");
        req.setAttribute("contentPage", "/view/tasks/task-schedule.jsp");
        req.setAttribute("page", "task-schedule");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int roleId = user.getRole().getRoleId();
        String roleName = user.getRole().getRoleName();
        return roleId == 1 || roleId == 5 || "ADMIN".equalsIgnoreCase(roleName) || "MANAGER".equalsIgnoreCase(roleName);
    }

    // Helper class for week dropdown
    public static class WeekOption {
        private final int offset;
        private final String dateLabel;
        private final String displayLabel;

        public WeekOption(int offset, String dateLabel, String displayLabel) {
            this.offset = offset;
            this.dateLabel = dateLabel;
            this.displayLabel = displayLabel;
        }

        public int getOffset() { return offset; }
        public String getDateLabel() { return dateLabel; }
        public String getDisplayLabel() { return displayLabel; }
    }
}
