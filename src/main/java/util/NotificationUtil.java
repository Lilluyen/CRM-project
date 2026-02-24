package util;

/**
 * Utility class for notification constants and helpers
 * Used by controllers and services for consistent notification handling
 */
public class NotificationUtil {

    // Notification Types
    public static final String NOTIFICATION_TYPE_TASK = "TASK";
    public static final String NOTIFICATION_TYPE_ALERT = "ALERT";
    public static final String NOTIFICATION_TYPE_INFO = "INFO";

    // Task Status Constants
    public static final String TASK_STATUS_PENDING = "PENDING";
    public static final String TASK_STATUS_ASSIGNED = "ASSIGNED";
    public static final String TASK_STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String TASK_STATUS_COMPLETED = "COMPLETED";
    public static final String TASK_STATUS_CANCELLED = "CANCELLED";

    // Task Priority Constants
    public static final String PRIORITY_LOW = "LOW";
    public static final String PRIORITY_MEDIUM = "MEDIUM";
    public static final String PRIORITY_HIGH = "HIGH";
    public static final String PRIORITY_URGENT = "URGENT";

    // WebSocket Connection Status
    public static final String WS_STATUS_CONNECTING = "CONNECTING";
    public static final String WS_STATUS_CONNECTED = "CONNECTED";
    public static final String WS_STATUS_DISCONNECTED = "DISCONNECTED";
    public static final String WS_STATUS_ERROR = "ERROR";

    // Notification Messages
    public static String getTaskAssignedMessage(String taskTitle) {
        return "You have been assigned a new task: " + taskTitle;
    }

    public static String getTaskStatusChangedMessage(String taskTitle, String newStatus) {
        return "Task '" + taskTitle + "' status changed to: " + newStatus;
    }

    public static String getTaskDueSoonMessage(String taskTitle, String dueDate) {
        return "Task '" + taskTitle + "' is due on: " + dueDate;
    }

    // Validation Methods
    public static boolean isValidStatus(String status) {
        return status != null && (
                status.equals(TASK_STATUS_PENDING) ||
                status.equals(TASK_STATUS_ASSIGNED) ||
                status.equals(TASK_STATUS_IN_PROGRESS) ||
                status.equals(TASK_STATUS_COMPLETED) ||
                status.equals(TASK_STATUS_CANCELLED)
        );
    }

    public static boolean isValidPriority(String priority) {
        return priority != null && (
                priority.equals(PRIORITY_LOW) ||
                priority.equals(PRIORITY_MEDIUM) ||
                priority.equals(PRIORITY_HIGH) ||
                priority.equals(PRIORITY_URGENT)
        );
    }

    public static boolean isCompletedStatus(String status) {
        return TASK_STATUS_COMPLETED.equals(status) || TASK_STATUS_CANCELLED.equals(status);
    }
}
