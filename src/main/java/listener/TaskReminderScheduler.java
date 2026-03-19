package listener;

import model.Task;
import service.NotificationService;
import service.TaskReminderService;
import service.TaskService;
import util.DBContext;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * TaskReminderScheduler – Scenario 7 (Reminder Notification)
 *
 * Chạy nền mỗi 5 phút:
 *   1. Poll Task_Reminders table for due reminders (remind_at <= now AND is_sent = 0)
 *   2. For each due reminder:
 *      a. Load associated Task to get title/assignees
 *      b. Create notification for task assignees
 *      c. Mark reminder as sent
 *
 * Đăng ký tự động qua @WebListener.
 *
 * Tuning:
 *   INITIAL_DELAY_SECONDS – chờ trước khi chạy lần đầu (default 30s để app khởi động xong)
 *   INTERVAL_MINUTES     – chu kỳ kiểm tra (default 5 phút)
 *   BATCH_SIZE          – số reminder tối đa xử lý mỗi lần (default 100)
 */
@WebListener
public class TaskReminderScheduler implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(TaskReminderScheduler.class.getName());

    private static final long INITIAL_DELAY_SECONDS = 30;
    private static final long INTERVAL_MINUTES = 5;
    private static final int BATCH_SIZE = 100;

    private ScheduledExecutorService scheduler;

    // ─────────────────────────────────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "task-reminder-scheduler");
            t.setDaemon(true);
            return t;
        });

        scheduler.scheduleAtFixedRate(
                this::runReminderCheck,
                INITIAL_DELAY_SECONDS,
                INTERVAL_MINUTES,
                TimeUnit.MINUTES
        );

        LOG.info("TaskReminderScheduler started – runs every "
                + INTERVAL_MINUTES + " minute(s), batch size=" + BATCH_SIZE);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            LOG.info("TaskReminderScheduler stopped.");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Core job
    // ─────────────────────────────────────────────────────────────────────────

    private void runReminderCheck() {
        try (Connection conn = DBContext.getConnection()) {
            TaskReminderService reminderSvc = new TaskReminderService(conn);
            TaskService taskSvc = new TaskService(conn);
            NotificationService notifSvc = new NotificationService(conn);

            // Poll due reminders
            List<model.TaskReminder> dueReminders = reminderSvc.pollDueReminders(BATCH_SIZE);

            int processed = 0;
            for (model.TaskReminder reminder : dueReminders) {
                try {
                    // Load the task
                    Task task = taskSvc.getTaskById(reminder.getTaskId());
                    if (task == null) {
                        // Task was deleted, mark as sent and skip
                        reminderSvc.markAsSent(reminder.getReminderId());
                        continue;
                    }

                    // Get assignees who should receive the reminder
                    List<model.TaskAssignee> taskAssignees = task.getAssignees();

                    if (taskAssignees != null && !taskAssignees.isEmpty()) {
                        String title = "Task Reminder: " + (task.getTitle() != null ? task.getTitle() : "Untitled");
                        String content = String.format(
                                "Task \"%s\" is due at %s (reminder: %d %s before)",
                                task.getTitle(),
                                task.getDueDate() != null ? task.getDueDate().toString().replace('T', ' ') : "N/A",
                                reminder.getRemindBeforeValue(),
                                reminder.getRemindBeforeUnit()
                        );

                        // Send notification to each assignee
                        for (model.TaskAssignee ta : taskAssignees) {
                            if (ta.getUser() != null) {
                                notifSvc.createForUser(
                                        ta.getUser().getUserId(),
                                        title,
                                        content,
                                        "TASK",
                                        "Task",
                                        task.getTaskId()
                                );
                            }
                        }
                    }

                    // Mark reminder as sent
                    reminderSvc.markAsSent(reminder.getReminderId());
                    processed++;

                } catch (Exception e) {
                    LOG.log(Level.WARNING, "Error processing reminder id=" + reminder.getReminderId(), e);
                }
            }

            if (processed > 0) {
                LOG.info("TaskReminderScheduler: processed " + processed + " reminder(s).");
            }

        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "TaskReminderScheduler: error during reminder check", ex);
        }
    }
}
