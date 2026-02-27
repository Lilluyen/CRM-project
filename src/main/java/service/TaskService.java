// service/TaskService.java (additions)
package service;

import dao.TaskDAO;
import model.Task;
import model.User;
import util.DBContext;

import java.sql.Connection;
import java.util.List;
import java.util.Comparator;

/**
 * Service layer: Orchestrates business logic and coordinates between
 * Controller and DAO.
 * 
 * Responsibilities:
 * - Apply business rules
 * - Coordinate multiple DAOs if needed
 * - Transform domain objects
 * - Notify systems (via NotificationService)
 * 
 * NOT responsible for:
 * - HTTP concerns
 * - JSON serialization
 * - Direct database access (delegates to DAO)
 */
public class TaskService {

    private final TaskDAO taskDAO;
    private final NotificationService notificationService;

    public TaskService(Connection connection) {
        this.taskDAO = new TaskDAO(connection);
        this.notificationService = new NotificationService(connection);
    }

    /**
     * Get tasks for a specific user based on role and permissions.
     * This is BUSINESS LOGIC (Service layer responsibility).
     * 
     * @param user Current authenticated user
     * @param sortBy Sort criteria (deadline, status, etc.)
     * @param page Pagination page number
     * @return List of Task domain objects (NOT JSON-serialized)
     */
    public List<Task> getTasksForUser(User user, String sortBy, int page) throws Exception {
        List<Task> tasks;

        // Business rule: Admins and Managers see all tasks; others see only assigned tasks
        if (user != null && user.getRole() != null && 
            ("ADMIN".equalsIgnoreCase(user.getRole().getRoleName()) ||
             "MANAGER".equalsIgnoreCase(user.getRole().getRoleName()))) {
            tasks = taskDAO.getAllTasks();
        } else if (user != null) {
            tasks = taskDAO.findByUser(user.getUserId());
        } else {
            tasks = java.util.Collections.emptyList();
        }

        // Apply sorting (business logic)
        if ("deadline".equals(sortBy)) {
            tasks.sort(Comparator.comparing(Task::getDueDate,
                Comparator.nullsLast(Comparator.naturalOrder())));
        } else if ("status".equals(sortBy)) {
            tasks.sort(Comparator.comparing(Task::getStatus,
                Comparator.nullsLast(Comparator.naturalOrder())));
        }

        return tasks;
    }

    /**
     * Get total count of tasks for a user.
     */
    public int getTotalTasksForUser(User user) throws Exception {
        if (user != null && user.getRole() != null && 
            ("ADMIN".equalsIgnoreCase(user.getRole().getRoleName()) ||
             "MANAGER".equalsIgnoreCase(user.getRole().getRoleName()))) {
            return taskDAO.getAllTasks().size();
        } else if (user != null) {
            return taskDAO.findByUser(user.getUserId()).size();
        }
        return 0;
    }

    /**
     * Create a new task.
     */
    public boolean createTask(Task task) throws Exception {
        return taskDAO.createTask(task);
    }

    /**
     * Update an existing task.
     */
    public boolean updateTask(Task task) throws Exception {
        return taskDAO.updateTask(task);
    }

    /**
     * Update progress of a task.
     */
    public boolean updateProgress(int taskId, int progress) throws Exception {
        return taskDAO.updateProgress(taskId, progress);
    }

}