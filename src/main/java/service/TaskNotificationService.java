package service;

import controller.api.tasks.TaskNotificationWebSocket;
import dao.TaskDAO;
import model.Task;
import java.sql.Connection;

/**
 * Service for managing real-time task notifications
 * Integrates WebSocket and database notifications
 */
public class TaskNotificationService {

    private TaskDAO taskDAO;

    public TaskNotificationService(Connection connection) {
        this.taskDAO = new TaskDAO(connection);
    }

    /**
     * Assign a task to a user and send real-time notification
     */
    public boolean assignTaskWithNotification(int taskId, int userId, Task task) {
        try {
            // Assign the task
            boolean assigned = taskDAO.assignTask(taskId, userId);

            if (assigned) {
                // Send database notification
                String notificationTitle = "New Task Assigned";
                String notificationContent = "Task: " + task.getTitle() + " has been assigned to you. Priority: " + task.getPriority();
                taskDAO.announceAssignedTask(userId, notificationTitle, notificationContent);

                // Send real-time WebSocket notification
                TaskNotificationWebSocket.notifyTaskAssigned(userId, task.getTitle(), taskId);

                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update task status and notify user with real-time notification
     */
    public boolean updateTaskStatusWithNotification(int taskId, String newStatus, int assignedUserId, String taskTitle) {
        try {
            boolean updated = taskDAO.updateTaskStatus(taskId, newStatus);

            if (updated && assignedUserId > 0) {
                // Send database notification
                String notificationTitle = "Task Status Updated";
                String notificationContent = "Task: " + taskTitle + " status changed to: " + newStatus;
                taskDAO.announceAssignedTask(assignedUserId, notificationTitle, notificationContent);

                // Send real-time WebSocket notification
                TaskNotificationWebSocket.notifyTaskStatusChanged(assignedUserId, taskTitle, newStatus, taskId);

                return true;
            }
            return updated;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send custom notification to user with real-time capability
     */
    public boolean sendNotification(int userId, String title, String content) {
        try {
            // Save to database
            taskDAO.announceAssignedTask(userId, title, content);

            // Send real-time notification (generic message)
            TaskNotificationWebSocket.notifyTaskAssigned(userId, title, 0);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get active WebSocket sessions count
     */
    public static int getActiveNotificationSessions() {
        return TaskNotificationWebSocket.getActiveSessionsCount();
    }
}
