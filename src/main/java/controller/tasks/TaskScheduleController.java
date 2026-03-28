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
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /tasks/schedule - Show monthly timeline view of tasks and subtasks
 *
 * Query params:
 *   monthOffset - offset from current month (-3 to +3)
 *
 * For manager (role 1 or 5): shows ALL root tasks of subordinates on timeline
 * For employee: shows tasks owned by, assigned to, or mentioned-in-comments to that user
 */
@WebServlet("/tasks/schedule")
public class TaskScheduleController extends HttpServlet {

    /** Only allow navigating 3 months back and 3 months forward */
    private static final int MAX_MONTH_OFFSET = 3;
    private static final int MAX_ITEMS_PER_DAY = 5;
    private static final String DATE_FMT_MONTH = "MMMM yyyy";
    private static final String DATE_FMT_MONTH_SHORT = "MMM yyyy";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // ── Parse & clamp month offset ──────────────────────────────────────
        int monthOffset = 0;
        try {
            String offsetStr = req.getParameter("monthOffset");
            if (offsetStr != null && !offsetStr.isBlank()) {
                monthOffset = Integer.parseInt(offsetStr);
            }
        } catch (NumberFormatException ignored) {}
        monthOffset = Math.max(-MAX_MONTH_OFFSET, Math.min(MAX_MONTH_OFFSET, monthOffset));

        LocalDate today = LocalDate.now();
        
        YearMonth targetMonth = YearMonth.from(today).plusMonths(monthOffset);
        boolean isManager = isManagerOrAdmin(user);

        // ── Fetch data ────────────────────────────────────────────────────────
        List<Task> tasks = new ArrayList<>();
        List<TaskComment> subtasks = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            tasks = svc.getMonthlyTasks(user.getUserId(), isManager);

            List<Integer> taskIds = tasks.stream()
                    .map(Task::getTaskId)
                    .collect(Collectors.toList());

            if (!taskIds.isEmpty()) {
                subtasks = svc.getMonthlySubtasks(user.getUserId(), isManager, taskIds);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TaskScheduleController.class.getName()).log(Level.SEVERE, null, ex);
        }

        // ── Group tasks/subtasks by date ──────────────────────────────────────
        Map<LocalDate, List<Task>> tasksByDate = tasks.stream()
                .collect(Collectors.toMap(
                        t -> {
                            if (t.getStartDate() != null) return t.getStartDate().toLocalDate();
                            if (t.getDueDate() != null) return t.getDueDate().toLocalDate();
                            return null;
                        },
                        List::of,
                        (a, b) -> { List<Task> m = new ArrayList<>(a); m.addAll(b); return m; }
                ));
        tasksByDate = tasksByDate.entrySet().stream()
                .filter(e -> e.getKey() != null)
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));

        Map<LocalDate, List<TaskComment>> subtasksByDate = subtasks.stream()
                .filter(sc -> sc.getCreatedAt() != null)
                .collect(Collectors.toMap(
                        sc -> sc.getCreatedAt().toLocalDate(),
                        List::of,
                        (a, b) -> { List<TaskComment> m = new ArrayList<>(a); m.addAll(b); return m; }
                ));

        // ── Build single-month strip ─────────────────────────────────────────
        List<DayData> days = new ArrayList<>();
        int firstDow = targetMonth.atDay(1).getDayOfWeek().getValue(); // Mon=1

        // Leading empty cells (before the 1st day)
        for (int i = 1; i < firstDow; i++) {
            days.add(DayData.empty());
        }

        // Actual days of the month
        for (int d = 1; d <= targetMonth.lengthOfMonth(); d++) {
            LocalDate date = targetMonth.atDay(d);
            boolean isToday = date.equals(today);

            List<Task> dayTasks = tasksByDate.getOrDefault(date, Collections.emptyList());
            List<TaskComment> daySubs = subtasksByDate.getOrDefault(date, Collections.emptyList());
            int hidden = Math.max(0, dayTasks.size() - MAX_ITEMS_PER_DAY);

            days.add(new DayData(d, date, isToday, false, dayTasks, daySubs, hidden));
        }

        // Trailing empty cells (fill the last row)
        int totalCells = firstDow - 1 + targetMonth.lengthOfMonth();
        int trailing = (7 - (totalCells % 7)) % 7;
        for (int i = 0; i < trailing; i++) {
            days.add(DayData.empty());
        }

        // Wrap in list for consistent EL (no forEach over a single object)
        List<MonthStripData> monthStrips = Collections.singletonList(new MonthStripData(
                targetMonth,
                targetMonth.format(DateTimeFormatter.ofPattern(DATE_FMT_MONTH)),
                targetMonth.equals(YearMonth.from(today)),
                targetMonth.format(DateTimeFormatter.ofPattern(DATE_FMT_MONTH_SHORT)),
                days
        ));

        // ── Build dropdown options (±3 months) ───────────────────────────────
        List<MonthOptionData> monthOptions = new ArrayList<>();
        for (int i = -MAX_MONTH_OFFSET; i <= MAX_MONTH_OFFSET; i++) {
            YearMonth m = YearMonth.from(today).plusMonths(i);
            String label;
            if (i == 0) {
                label = "This Month";
            } else if (i < 0) {
                int abs = Math.abs(i);
                label = abs + " month" + (abs > 1 ? "s" : "") + " ago";
            } else {
                label = "In " + i + " month" + (i > 1 ? "s" : "");
            }
            monthOptions.add(new MonthOptionData(
                    i,
                    m.format(DateTimeFormatter.ofPattern(DATE_FMT_MONTH_SHORT)),
                    label
            ));
        }

        // ── Stats ──────────────────────────────────────────────────────────────
        long totalTasks = tasks.size();
        long totalSubtasks = subtasks.size();
        long completedSubtasks = subtasks.stream().filter(TaskComment::isCompleted).count();

        // ── Set request attributes ────────────────────────────────────────────
        req.setAttribute("monthStrips", monthStrips);
        req.setAttribute("monthOptions", monthOptions);
        req.setAttribute("targetMonth", targetMonth);
        req.setAttribute("targetMonthName", targetMonth.format(DateTimeFormatter.ofPattern(DATE_FMT_MONTH)));
        req.setAttribute("monthOffset", monthOffset);
        req.setAttribute("isManager", isManager);
        req.setAttribute("currentUserId", user.getUserId());
        req.setAttribute("totalTasks", totalTasks);
        req.setAttribute("totalSubtasks", totalSubtasks);
        req.setAttribute("completedSubtasks", completedSubtasks);

        req.setAttribute("pageTitle", "Task Schedule");
        req.setAttribute("contentPage", "/view/tasks/task-schedule.jsp");
        req.setAttribute("page", "task-schedule");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int roleId = user.getRole().getRoleId();
        String roleName = user.getRole().getRoleName();
        return roleId == 1 || roleId == 5
                || "ADMIN".equalsIgnoreCase(roleName)
                || "MANAGER".equalsIgnoreCase(roleName);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Data classes
    // ─────────────────────────────────────────────────────────────────────────

    public static class MonthOptionData {
        private final int offset;
        private final String monthLabel;
        private final String displayLabel;

        public MonthOptionData(int offset, String monthLabel, String displayLabel) {
            this.offset = offset;
            this.monthLabel = monthLabel;
            this.displayLabel = displayLabel;
        }
        public int getOffset() { return offset; }
        public String getMonthLabel() { return monthLabel; }
        public String getDisplayLabel() { return displayLabel; }
    }

    public static class MonthStripData {
        private final YearMonth yearMonth;
        private final String monthName;
        private final boolean isCurrentMonth;
        private final String monthNameShort;
        private final List<DayData> days;

        public MonthStripData(YearMonth yearMonth, String monthName, boolean isCurrentMonth,
                            String monthNameShort, List<DayData> days) {
            this.yearMonth = yearMonth;
            this.monthName = monthName;
            this.isCurrentMonth = isCurrentMonth;
            this.monthNameShort = monthNameShort;
            this.days = days;
        }
        public YearMonth getYearMonth() { return yearMonth; }
        public String getMonthName() { return monthName; }
        public boolean isCurrentMonth() { return isCurrentMonth; }
        public String getMonthNameShort() { return monthNameShort; }
        public List<DayData> getDays() { return days; }
    }

    public static class DayData {
        private final int dayOfMonth;
        private final LocalDate date;
        private final boolean isToday;
        private final boolean isEmpty;
        private final List<Task> tasks;
        private final List<TaskComment> subtasks;
        private final int hiddenTaskCount;

        private DayData(int dayOfMonth, LocalDate date, boolean isToday, boolean isEmpty,
                       List<Task> tasks, List<TaskComment> subtasks, int hiddenTaskCount) {
            this.dayOfMonth = dayOfMonth;
            this.date = date;
            this.isToday = isToday;
            this.isEmpty = isEmpty;
            this.tasks = tasks;
            this.subtasks = subtasks;
            this.hiddenTaskCount = hiddenTaskCount;
        }

        public static DayData empty() {
            return new DayData(0, null, false, true,
                    Collections.emptyList(), Collections.emptyList(), 0);
        }

        public int getDayOfMonth() { return dayOfMonth; }
        public LocalDate getDate() { return date; }
        public boolean isToday() { return isToday; }
        public boolean isEmpty() { return isEmpty; }
        public List<Task> getTasks() { return tasks; }
        public List<TaskComment> getSubtasks() { return subtasks; }
        public int getHiddenTaskCount() { return hiddenTaskCount; }
    }
}
