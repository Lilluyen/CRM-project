package service;

import dao.TaskReminderDAO;
import model.TaskReminder;
import util.DBContext;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * TaskReminderService – orchestrates reminder scheduling for tasks.
 *
 * Responsibilities:
 *   - Create reminders relative to task deadlines
 *   - Poll due reminders for notification delivery
 *   - Manage reminder lifecycle (mark as sent, delete)
 */
public class TaskReminderService {

    private final TaskReminderDAO reminderDAO;

    public TaskReminderService(Connection connection) {
        this.reminderDAO = new TaskReminderDAO(connection);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Create a reminder for a task.
     *
     * @param taskId            the task to remind about
     * @param remindBeforeValue e.g. 1, 2, 24
     * @param remindBeforeUnit  e.g. "minute", "hour", "day"
     * @param deadline          the task deadline to calculate remind_at from
     * @param createdBy         user creating the reminder (nullable)
     */
    public int createReminder(int taskId, int remindBeforeValue, String remindBeforeUnit,
                              LocalDateTime deadline, Integer createdBy) {
        try {
            LocalDateTime remindAt = calculateRemindAt(remindBeforeValue, remindBeforeUnit, deadline);
            if (remindAt == null) return -1;

            TaskReminder reminder = new TaskReminder();
            reminder.setTaskId(taskId);
            reminder.setRemindBeforeValue(remindBeforeValue);
            reminder.setRemindBeforeUnit(remindBeforeUnit);
            reminder.setRemindAt(remindAt);
            reminder.setCreatedBy(createdBy);
            reminder.setSent(false);

            return reminderDAO.insert(reminder);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POLL DUE REMINDERS (for scheduler)
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Poll reminders that are due for sending.
     * Used by background scheduler to find tasks needing reminder notifications.
     */
    public List<TaskReminder> pollDueReminders(int batchSize) {
        try {
            return reminderDAO.findDueReminders(batchSize > 0 ? batchSize : 50);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK SENT
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Mark a reminder as sent after notification delivery.
     */
    public boolean markAsSent(int reminderId) {
        try {
            return reminderDAO.markSent(reminderId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // READ
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Get all reminders for a specific task.
     */
    public List<TaskReminder> getRemindersByTask(int taskId) {
        try {
            return reminderDAO.findByTaskId(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Delete a single reminder.
     */
    public boolean deleteReminder(int reminderId) {
        try {
            return reminderDAO.delete(reminderId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete all reminders for a task (cascade on task deletion).
     */
    public boolean deleteRemindersByTask(int taskId) {
        try {
            return reminderDAO.deleteByTaskId(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Calculate remind_at timestamp based on deadline and remind_before settings.
     */
    private LocalDateTime calculateRemindAt(int value, String unit, LocalDateTime deadline) {
        if (deadline == null || value <= 0 || unit == null) return null;

        return switch (unit.toLowerCase()) {
            case "minute" -> deadline.minusMinutes(value);
            case "hour"   -> deadline.minusHours(value);
            case "day"    -> deadline.minusDays(value);
            case "week"   -> deadline.minusWeeks(value);
            default       -> deadline.minusDays(value); // default to days
        };
    }

    public static TaskReminderService withDefaultConnection() throws Exception {
        return new TaskReminderService(DBContext.getConnection());
    }
}
