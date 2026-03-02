package service;

import dao.TaskDAO;
import model.Task;
import model.User;

import java.sql.Connection;
import java.util.Collections;
import java.util.List;

/**
 * TaskService – business logic layer for Tasks.
 *
 * Role-based visibility:
 *   ADMIN / MANAGER  → all tasks
 *   Others           → only tasks they are assigned to
 */
public class TaskService {

    private final TaskDAO taskDAO;
    private final NotificationService notificationService;

    public TaskService(Connection connection) {
        this.taskDAO = new TaskDAO(connection);
        this.notificationService = new NotificationService(connection);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST (paged + filtered)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(User currentUser,
                                    String title, String status, String priority,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        try {
            boolean isPrivileged = isAdminOrManager(currentUser);
            Integer assigneeFilter = isPrivileged ? null : currentUser.getUserId();
            return taskDAO.getTasksPaged(title, status, priority,
                    assigneeFilter, sortField, sortDir, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countTasks(User currentUser, String title, String status, String priority) {
        try {
            boolean isPrivileged = isAdminOrManager(currentUser);
            Integer assigneeFilter = isPrivileged ? null : currentUser.getUserId();
            return taskDAO.countTasksFiltered(title, status, priority, assigneeFilter);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CRUD
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createTask(Task task) {
        try { return taskDAO.createTask(task); } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateTask(Task task) {
        try { return taskDAO.updateTask(task); } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteTask(int taskId) {
        try { return taskDAO.deleteTask(taskId); } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public Task getTaskById(int id) {
        try { return taskDAO.getTaskById(id); } catch (Exception e) { e.printStackTrace(); return null; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ASSIGN TASK – adds to Task_Assignees and sends notification
    // ─────────────────────────────────────────────────────────────────────────
    public boolean assignTask(int taskId, int userId, Task task) {
        try {
            boolean ok = taskDAO.addAssignee(taskId, userId);
            if (ok && task != null) {
                notificationService.createForUser(userId,
                        "New Task Assigned",
                        "Task \"" + task.getTitle() + "\" has been assigned to you. Priority: " + task.getPriority(),
                        "TASK", "Task", taskId);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeAssignee(int taskId, int userId) {
        try { return taskDAO.removeAssignee(taskId, userId); }
        catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PROGRESS / STATUS
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress) {
        try { return taskDAO.updateProgress(taskId, progress); }
        catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateStatus(int taskId, String status, Task task) {
        try {
            boolean ok = taskDAO.updateTaskStatus(taskId, status);
            if (ok && task != null) {
                List<model.TaskAssignee> assignees = task.getassignees();
                if (assignees != null) {
                    for (model.TaskAssignee ta : assignees) {
                        notificationService.createForUser(
                                ta.getUser().getUserId(),
                                "Task Status Updated",
                                "Task \"" + task.getTitle() + "\" status changed to: " + status,
                                "TASK", "Task", taskId);
                    }
                }
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    private boolean isAdminOrManager(User user) {
        if (user == null || user.getRole() == null) return false;
        String rn = user.getRole().getRoleName();
        return "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }
}
