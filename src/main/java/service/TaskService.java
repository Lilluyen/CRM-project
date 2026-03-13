package service;

import dao.TaskDAO;
import model.Task;
import model.TaskAssignee;
import model.User;
import service.NotificationService;

import java.sql.Connection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/**
 * TaskService – business logic layer for Tasks.
 *
 * Responsibilities:
 *  • Role-based visibility (ADMIN/MANAGER see all; others see own tasks)
 *  • CRUD with change-logging via Task_History / Task_History_Detail
 *  • Notifications via NotificationService (never through TaskDAO)
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
                                    String title, String description,
                                    String status, String priority,
                                    String fromDate, String toDate,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        try {
            Integer assigneeFilter = isPrivileged(currentUser) ? null : currentUser.getUserId();
            return taskDAO.getTasksPaged(title, description, status, priority,
                    fromDate, toDate, assigneeFilter, sortField, sortDir, page, pageSize);
        } catch (Exception e) { e.printStackTrace(); return Collections.emptyList(); }
    }

    public int countTasks(User currentUser,
                          String title, String description,
                          String status, String priority,
                          String fromDate, String toDate) {
        try {
            Integer assigneeFilter = isPrivileged(currentUser) ? null : currentUser.getUserId();
            return taskDAO.countTasksFiltered(title, description, status, priority,
                    fromDate, toDate, assigneeFilter);
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createTask(Task task) {
        try {
            // When a task is created already in a completed state, store completed_at.
            if (task != null) {
                if ("Done".equalsIgnoreCase(task.getStatus()) || (task.getProgress() != null && task.getProgress() >= 100)) {
                    task.setCompletedAt(java.time.LocalDateTime.now());
                }
            }
            boolean ok = taskDAO.createTask(task);
            if (ok && task.getTaskId() != null) {
                // Log creation as a single-field history entry
                int hid = taskDAO.insertTaskHistory(task.getTaskId(),
                        task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0);
                if (hid > 0) {
                    taskDAO.insertTaskHistoryDetail(hid, "created", "", task.getTitle());
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE – logs every changed field
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTask(Task newTask, int changedByUserId) {
        try {
            // If task is marked as done or progress is 100, set completedAt (otherwise clear)
            if (newTask != null) {
                if ("Done".equalsIgnoreCase(newTask.getStatus()) || (newTask.getProgress() != null && newTask.getProgress() >= 100)) {
                    newTask.setCompletedAt(java.time.LocalDateTime.now());
                } else {
                    newTask.setCompletedAt(null);
                }
                // If task is in progress and we don't already have a start date, set it now
                if ("In Progress".equalsIgnoreCase(newTask.getStatus()) && newTask.getStartDate() == null) {
                    newTask.setStartDate(java.time.LocalDateTime.now());
                }
            }

            Task old = taskDAO.getTaskById(newTask.getTaskId());
            boolean ok = taskDAO.updateTask(newTask);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(newTask.getTaskId(), changedByUserId);
                if (hid > 0 && old != null) {
                    logDiff(hid, "title",       old.getTitle(),       newTask.getTitle());
                    logDiff(hid, "description", old.getDescription(), newTask.getDescription());
                    logDiff(hid, "status",      old.getStatus(),      newTask.getStatus());
                    logDiff(hid, "priority",    old.getPriority(),    newTask.getPriority());
                    logDiff(hid, "progress",
                            String.valueOf(old.getProgress() != null ? old.getProgress() : 0),
                            String.valueOf(newTask.getProgress() != null ? newTask.getProgress() : 0));
                    String oldDue = old.getDueDate()     != null ? old.getDueDate().toString()     : "";
                    String newDue = newTask.getDueDate() != null ? newTask.getDueDate().toString() : "";
                    logDiff(hid, "dueDate", oldDue, newDue);

                    String oldStart = old.getStartDate()     != null ? old.getStartDate().toString()     : "";
                    String newStart = newTask.getStartDate() != null ? newTask.getStartDate().toString() : "";
                    logDiff(hid, "startDate", oldStart, newStart);

                    String oldCompleted = old.getCompletedAt()     != null ? old.getCompletedAt().toString()     : "";
                    String newCompleted = newTask.getCompletedAt() != null ? newTask.getCompletedAt().toString() : "";
                    logDiff(hid, "completedAt", oldCompleted, newCompleted);
                }
                // Notify all assignees about the edit
                if (old != null && old.getassignees() != null) {
                    for (TaskAssignee ta : old.getassignees()) {
                        if (ta.getUser() != null) {
                            notificationService.createForUser(
                                    ta.getUser().getUserId(),
                                    "Task Updated",
                                    "Task \"" + newTask.getTitle() + "\" has been updated.",
                                    "TASK", "Task", newTask.getTaskId());
                        }
                    }
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Backward-compat overload – no changedBy (uses 0). */
    public boolean updateTask(Task task) {
        return updateTask(task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteTask(int taskId) {
        try { return taskDAO.deleteTask(taskId); }
        catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Task getTaskById(int id) {
        try { return taskDAO.getTaskById(id); }
        catch (Exception e) { e.printStackTrace(); return null; }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ASSIGN – adds to Task_Assignees, logs history, sends notification
    // ─────────────────────────────────────────────────────────────────────────
    public boolean assignTask(int taskId, int userId, Task task, int changedByUserId) {
        try {
            boolean ok = taskDAO.addAssignee(taskId, userId);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0) {
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_added",
                            "", String.valueOf(userId));
                }
                if (task != null) {
                    notificationService.createForUser(userId,
                            "New Task Assigned",
                            "Task \"" + task.getTitle() + "\" has been assigned to you. Priority: " + task.getPriority(),
                            "TASK", "Task", taskId);
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Backward-compat overload. */
    public boolean assignTask(int taskId, int userId, Task task) {
        return assignTask(taskId, userId, task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // REMOVE ASSIGNEE – logs history, sends notification
    // ─────────────────────────────────────────────────────────────────────────
    public boolean removeAssignee(int taskId, int userId, int changedByUserId, Task task) {
        try {
            boolean ok = taskDAO.removeAssignee(taskId, userId);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0) {
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_removed",
                            String.valueOf(userId), "");
                }
                if (task != null) {
                    notificationService.createForUser(userId,
                            "Task Assignment Cancelled",
                            "You have been unassigned from task \"" + task.getTitle() + "\".",
                            "TASK", "Task", taskId);
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Backward-compat overload. */
    public boolean removeAssignee(int taskId, int userId) {
        return removeAssignee(taskId, userId, 0, null);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE PROGRESS – logs history, notifies assignees
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress, int changedByUserId) {
        try {
            Task old = taskDAO.getTaskById(taskId);
            boolean ok = taskDAO.updateProgress(taskId, progress);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0 && old != null) {
                    logDiff(hid, "progress",
                            String.valueOf(old.getProgress() != null ? old.getProgress() : 0),
                            String.valueOf(progress));
                    // status may have auto-changed
                    String autoStatus = progress >= 100 ? "Done" : (progress > 0 ? "In Progress" : "Pending");
                    logDiff(hid, "status", old.getStatus() != null ? old.getStatus() : "", autoStatus);
                }
                if (old != null && old.getassignees() != null) {
                    for (TaskAssignee ta : old.getassignees()) {
                        if (ta.getUser() != null) {
                            notificationService.createForUser(ta.getUser().getUserId(),
                                    "Task Progress Updated",
                                    "Task \"" + (old.getTitle() != null ? old.getTitle() : "") + "\" progress is now " + progress + "%.",
                                    "TASK", "Task", taskId);
                        }
                    }
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Backward-compat overload. */
    public boolean updateProgress(int taskId, int progress) {
        return updateProgress(taskId, progress, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE STATUS – logs history, notifies assignees
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateStatus(int taskId, String status, Task task, int changedByUserId) {
        try {
            String oldStatus = task != null && task.getStatus() != null ? task.getStatus() : "";
            boolean ok = taskDAO.updateTaskStatus(taskId, status);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0) {
                    logDiff(hid, "status", oldStatus, status);
                }
                if (task != null && task.getassignees() != null) {
                    for (TaskAssignee ta : task.getassignees()) {
                        if (ta.getUser() != null) {
                            notificationService.createForUser(ta.getUser().getUserId(),
                                    "Task Status Updated",
                                    "Task \"" + task.getTitle() + "\" status changed to: " + status,
                                    "TASK", "Task", taskId);
                        }
                    }
                }
            }
            return ok;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Backward-compat overload. */
    public boolean updateStatus(int taskId, String status, Task task) {
        return updateStatus(taskId, status, task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HISTORY ACCESSORS (delegates to TaskDAO)
    // ─────────────────────────────────────────────────────────────────────────
    public java.util.List<model.TaskHistory> getHistoryForTask(int taskId) {
        try { return taskDAO.listTaskHistoryByID(taskId); }
        catch (Exception e) { e.printStackTrace(); return Collections.emptyList(); }
    }

    public java.util.List<model.TaskHistoryDetail> getHistoryDetails(int historyId) {
        try { return taskDAO.listTaskHistoryDetailsByID(historyId); }
        catch (Exception e) { e.printStackTrace(); return Collections.emptyList(); }
    }

    /**
     * Cập nhật danh sách assignee theo kiểu bulk (nhiều người trong 1 lần thay đổi).
     * Chỉ tạo 1 bản ghi Task_History, nhiều bản ghi Task_History_Detail cho từng user add/remove.
     */
    public boolean updateAssigneesBulk(Task task, int changedByUserId, Set<Integer> desiredAssigneeIds) {
        if (task == null || task.getTaskId() == null) return false;

        // Tập hiện tại từ task.getassignees()
        Set<Integer> current = new HashSet<>();
        if (task.getassignees() != null) {
            for (TaskAssignee ta : task.getassignees()) {
                if (ta.getUser() != null) {
                    current.add(ta.getUser().getUserId());
                }
            }
        }

        Set<Integer> desired = desiredAssigneeIds != null ? new HashSet<>(desiredAssigneeIds) : new HashSet<>();

        // Tính toán phần tử cần thêm / cần xóa
        Set<Integer> toAdd = new HashSet<>(desired);
        toAdd.removeAll(current);

        Set<Integer> toRemove = new HashSet<>(current);
        toRemove.removeAll(desired);

        if (toAdd.isEmpty() && toRemove.isEmpty()) {
            // Không có thay đổi
            return true;
        }

        boolean ok = true;

        // Thực hiện remove trước, sau đó add
        for (int uid : toRemove) {
            if (!taskDAO.removeAssignee(task.getTaskId(), uid)) {
                ok = false;
            } else {
                notificationService.createForUser(
                        uid,
                        "Task Assignment Cancelled",
                        "You have been unassigned from task \"" + (task.getTitle() != null ? task.getTitle() : "") + "\".",
                        "TASK", "Task", task.getTaskId());
            }
        }

        for (int uid : toAdd) {
            if (!taskDAO.addAssignee(task.getTaskId(), uid)) {
                ok = false;
            } else {
                notificationService.createForUser(
                        uid,
                        "New Task Assigned",
                        "Task \"" + (task.getTitle() != null ? task.getTitle() : "") + "\" has been assigned to you. Priority: " + task.getPriority(),
                        "TASK", "Task", task.getTaskId());
            }
        }

        // Nếu có ít nhất một thay đổi thành công thì log history (1 bản ghi header)
        if (!toAdd.isEmpty() || !toRemove.isEmpty()) {
            int hid = taskDAO.insertTaskHistory(task.getTaskId(), changedByUserId);
            if (hid > 0) {
                for (int uid : toRemove) {
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_removed",
                            String.valueOf(uid), "");
                }
                for (int uid : toAdd) {
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_added",
                            "", String.valueOf(uid));
                }
            }
        }

        return ok;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────
    private boolean isPrivileged(User user) {
        if (user == null || user.getRole() == null) return false;
        String rn = user.getRole().getRoleName();
        return "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    private void logDiff(int historyId, String field, String oldVal, String newVal) {
        String o = oldVal != null ? oldVal.trim() : "";
        String n = newVal != null ? newVal.trim() : "";
        if (!Objects.equals(o, n)) {
            taskDAO.insertTaskHistoryDetail(historyId, field, o, n);
        }
    }
}
