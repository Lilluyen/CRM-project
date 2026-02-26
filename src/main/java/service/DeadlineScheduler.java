package service;

import dao.TaskDAO;
import model.Task;
import util.DBContext;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.time.LocalDate;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class DeadlineScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        // run hourly
        scheduler.scheduleAtFixedRate(new DeadlineChecker(), 0, 1, TimeUnit.HOURS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }

    private static class DeadlineChecker implements Runnable {
        @Override
        public void run() {
            try (Connection conn = DBContext.getConnection()) {
                TaskDAO dao = new TaskDAO(conn);
                List<Task> tasks = dao.getAllTasks();
                LocalDate today = LocalDate.now();
                NotificationService ns = new NotificationService(conn);

                for (Task t : tasks) {
                    if (t.getDueDate() == null) continue;
                    LocalDate due = t.getDueDate();

                    if (due.isBefore(today) && !"OVERDUE".equalsIgnoreCase(t.getStatus())) {
                        dao.updateTaskStatus(t.getTaskId(), "OVERDUE");
                        ns.createPopupNotification(t.getAssignedTo(), "Task Overdue",
                                "Task '" + t.getTitle() + "' is overdue.", "TASK");
                    } else if (due.equals(today.plusDays(3))) {
                        ns.createPopupNotification(t.getAssignedTo(), "Upcoming Task Deadline",
                                "Task '" + t.getTitle() + "' is due in 3 days.", "TASK");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
