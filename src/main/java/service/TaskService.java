package service;

import dao.TaskDAO;
import dao.UserDAO;
import model.*;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * TaskService – business logic layer for Tasks.
 * <p>
 * Responsibilities:
 * • Role-based visibility (ADMIN/MANAGER see all; others see own tasks)
 * • CRUD with change-logging via Task_History / Task_History_Detail
 * • Activity creation for every task lifecycle event (Scenarios 1–10)
 * • In-app Notifications via NotificationService
 * • Email Notifications via TaskEmailService (async, fire-and-forget)
 * • Scheduler support: markOverdueTasks() (Scenario 9)
 * <p>
 * Activity mapping (scenario → activity_type):
 * create task → task_created
 * assign task → task_assigned
 * reassign task → task_reassigned
 * start task → task_started (status → In Progress)
 * update progress → task_progress_update
 * add comment → task_comment (called from CommentService)
 * complete task → task_completed (status → Done)
 * reopen task → task_reopened (status → Reopened / Pending)
 * cancel task → task_cancelled (status → Cancelled)
 * overdue → task_overdue (scheduler)
 */
public class TaskService {

    private final TaskDAO taskDAO;
    private final ActivityService activityService;
    private final NotificationService notificationService;
    /**
     * Email notification service – tất cả gửi async, không block.
     */
    private final TaskEmailService taskEmailService;

    public TaskService(Connection connection) {
        this.taskDAO = new TaskDAO(connection);
        this.activityService = new ActivityService(connection);
        this.notificationService = new NotificationService(connection);
        this.taskEmailService = new TaskEmailService();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST (paged + filtered) - với createdBy, relatedType, relatedId filters
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(User currentUser,
                                    String title, String description,
                                    String status, String priority,
                                    String fromDate, String toDate,
                                    Integer createdBy, String relatedType, Integer relatedId,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        try {
            Integer assigneeFilter = isPrivileged(currentUser) ? null : currentUser.getUserId();
            return taskDAO.getTasksPaged(title, description, status, priority,
                    fromDate, toDate, assigneeFilter, createdBy, relatedType, relatedId,
                    sortField, sortDir, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countTasks(User currentUser,
                          String title, String description,
                          String status, String priority,
                          String fromDate, String toDate,
                          Integer createdBy, String relatedType, Integer relatedId) {
        try {
            Integer assigneeFilter = isPrivileged(currentUser) ? null : currentUser.getUserId();
            return taskDAO.countTasksFiltered(title, description, status, priority,
                    fromDate, toDate, assigneeFilter, createdBy, relatedType, relatedId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST (paged) - backward compatible overload (khong co new filters)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(User currentUser,
                                    String title, String description,
                                    String status, String priority,
                                    String fromDate, String toDate,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        return getTasksPaged(currentUser, title, description, status, priority,
                fromDate, toDate, null, null, null, sortField, sortDir, page, pageSize);
    }

    public int countTasks(User currentUser,
                          String title, String description,
                          String status, String priority,
                          String fromDate, String toDate) {
        return countTasks(currentUser, title, description, status, priority,
                fromDate, toDate, null, null, null);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SCHEDULE - get tasks for weekly timetable view
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksForSchedule(java.time.LocalDateTime start,
                                          java.time.LocalDateTime end,
                                          User currentUser) {
        try {
            Integer assigneeFilter = isPrivileged(currentUser) ? null : currentUser.getUserId();
            return taskDAO.findTasksInDateRange(start, end, assigneeFilter);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST BY ASSIGNEE (paged) – for "My Tasks" view
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksByAssigneePaged(int userId, int page, int pageSize) {
        try {
            return taskDAO.findByAssigneePaged(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countTasksByAssignee(int userId) {
        try {
            return taskDAO.countByAssignee(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LIST BY USER (recursive - owner + assignee + subtask supporter)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksByUserPaged(int userId, int page, int pageSize) {
        try {
            return taskDAO.findTasksByUser(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countTasksByUser(int userId) {
        try {
            return taskDAO.countTasksByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CREATE (Scenario 1)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @param relatedType entity that "owns" this task in the CRM timeline
     *                    (e.g. "Customer", "Lead") – may be null
     * @param relatedId   PK of that entity – may be null
     */
    public boolean createTask(Task task, String relatedType, Integer relatedId) {
        try {
            if (task != null && isCompletedState(task.getStatus(), task.getProgress())) {
                task.setCompletedAt(LocalDateTime.now());
            }

            boolean ok = taskDAO.createTask(task, relatedType, relatedId);
            if (ok && task.getTaskId() != null) {

                // Audit log
                int hid = taskDAO.insertTaskHistory(task.getTaskId(),
                        task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0);
                if (hid > 0) {
                    taskDAO.insertTaskHistoryDetail(hid, "created", "", task.getTitle());
                }

                // Activity: task_created (Scenario 1)
                activityService.createActivity(buildTaskActivity(
                        "task_created",
                        "Task created: " + task.getTitle(),
                        null,
                        task.getTaskId(),
                        relatedType, relatedId,
                        task.getCreatedBy()));

                // ── EMAIL: xác nhận tạo task cho người tạo ──
                taskEmailService.notifyTaskCreated(task, task.getCreatedBy());

                // INSTANT: Check and notify overdue immediately after creation
                checkAndNotifyOverdue(task);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload – no related entity context.
     */
//    public boolean createTask(Task task) {
//        return createTask(task, null, null);
//    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE – logs every changed field (Scenarios 3, 4, 6, 7, 10)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTask(Task newTask, int changedByUserId) {
        try {
            if (newTask == null)
                return false;

            // Derive completed_at and start_date before persisting
            if (isCompletedState(newTask.getStatus(), newTask.getProgress())) {
                newTask.setCompletedAt(LocalDateTime.now());
            } else {
                newTask.setCompletedAt(null);
            }
            if ("In Progress".equalsIgnoreCase(newTask.getStatus()) && newTask.getStartDate() == null) {
                newTask.setStartDate(LocalDateTime.now());
            }

            Task old = taskDAO.getTaskById(newTask.getTaskId());
            boolean ok = taskDAO.updateTask(newTask);

            if (ok) {
                // Audit log – one header, one detail per changed field
                int hid = taskDAO.insertTaskHistory(newTask.getTaskId(), changedByUserId);
                if (hid > 0 && old != null) {
                    logDiff(hid, "title", old.getTitle(), newTask.getTitle());
                    logDiff(hid, "description", old.getDescription(), newTask.getDescription());
                    logDiff(hid, "status", old.getStatus(), newTask.getStatus());
                    logDiff(hid, "priority", old.getPriority(), newTask.getPriority());
                    logDiff(hid, "progress",
                            str(old.getProgress()), str(newTask.getProgress()));
                    logDiff(hid, "dueDate",
                            str(old.getDueDate()), str(newTask.getDueDate()));
                    logDiff(hid, "startDate",
                            str(old.getStartDate()), str(newTask.getStartDate()));
                    logDiff(hid, "completedAt",
                            str(old.getCompletedAt()), str(newTask.getCompletedAt()));
                }

                // Activity – derive the activity_type from the status transition
                String activityType = resolveStatusActivityType(
                        old != null ? old.getStatus() : null, newTask.getStatus());
                User actor = changedByUserId > 0 ? userWithId(changedByUserId) : null;
                String relatedType = old != null ? old.getRelatedType() : null;
                Integer relatedId = old != null ? old.getRelatedId() : null;
                activityService.createActivity(buildTaskActivity(
                        activityType,
                        buildStatusSubject(newTask, activityType),
                        null,
                        newTask.getTaskId(),
                        relatedType, relatedId, actor));

                List<User> assigneeUsers = assigneesAsUsers(old);

                // In-app: notify all current assignees
                notifyAssignees(old, "Task Updated",
                        "Task \"" + newTask.getTitle() + "\" has been updated.",
                        newTask.getTaskId());

                // ── EMAIL: status change hoặc update tổng quát ──
                // Fetch full User để email hiển thị đúng tên "Updated by"
                User actorFull = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;
                String oldStatus = old != null ? old.getStatus() : null;
                String newStatus = newTask.getStatus();
                if (!Objects.equals(oldStatus, newStatus)) {
                    taskEmailService.notifyStatusChanged(
                            newTask, oldStatus, newStatus, actorFull, assigneeUsers);
                } else {
                    taskEmailService.notifyTaskUpdated(
                            newTask, actorFull,
                            "Task details have been updated.",
                            assigneeUsers);
                }

                // INSTANT: Check and notify overdue immediately after update
                checkAndNotifyOverdue(newTask);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload – changedBy = 0.
     */
    public boolean updateTask(Task task) {
        return updateTask(task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE STATUS ONLY (Scenarios 3, 6, 7, 10)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateStatus(int taskId, String newStatus, Task task, int changedByUserId) {
        try {
            String oldStatus = task != null && task.getStatus() != null ? task.getStatus() : "";
            boolean ok = taskDAO.updateTaskStatus(taskId, newStatus);
            if (ok) {
                // Audit log
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0)
                    logDiff(hid, "status", oldStatus, newStatus);

                // Activity – include relatedType/relatedId for CRM timeline
                String activityType = resolveStatusActivityType(oldStatus, newStatus);
                User actor = changedByUserId > 0 ? userWithId(changedByUserId) : null;
                String subject = task != null
                        ? buildStatusSubject(task, activityType)
                        : activityType.replace('_', ' ');
                String relType = task != null ? task.getRelatedType() : null;
                Integer relId = task != null ? task.getRelatedId() : null;
                activityService.createActivity(buildTaskActivity(
                        activityType, subject, null, taskId, relType, relId, actor));

                List<User> assigneeUsers = assigneesAsUsers(task);

                // In-app notification
                notifyAssignees(task, "Task Status Updated",
                        "Task " + (task != null ? "\"" + task.getTitle() + "\" " : "") +
                                "status changed to: " + newStatus,
                        taskId);

                // ── EMAIL: thông báo status thay đổi ──
                // actor đã được tạo ở trên với userWithId(); fetch full để email có tên đúng
                User actorFullStatus = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;
                taskEmailService.notifyStatusChanged(
                        task, oldStatus, newStatus, actorFullStatus, assigneeUsers);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload.
     */
    public boolean updateStatus(int taskId, String status, Task task) {
        return updateStatus(taskId, status, task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE PROGRESS (Scenario 4)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress, int changedByUserId) {
        try {
            Task old = taskDAO.getTaskById(taskId);
            boolean ok = taskDAO.updateProgress(taskId, progress);
            if (ok) {
                // Audit log
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0 && old != null) {
                    logDiff(hid, "progress", str(old.getProgress()), String.valueOf(progress));
                    String autoStatus = progress >= 100 ? "Done" : (progress > 0 ? "In Progress" : "Pending");
                    logDiff(hid, "status",
                            old.getStatus() != null ? old.getStatus() : "", autoStatus);
                }

                // Activity: task_progress_update (Scenario 4)
                User actor = changedByUserId > 0 ? userWithId(changedByUserId) : null;
                String title = old != null && old.getTitle() != null ? old.getTitle() : "";
                String relType = old != null ? old.getRelatedType() : null;
                Integer relId = old != null ? old.getRelatedId() : null;
                activityService.createActivity(buildTaskActivity(
                        "task_progress_update",
                        "Task progress updated to " + progress + "%: " + title,
                        null, taskId, relType, relId, actor));

                List<User> assigneeUsers = assigneesAsUsers(old);

                // In-app notification
                notifyAssignees(old, "Task Progress Updated",
                        "Task \"" + title + "\" progress is now " + progress + "%.",
                        taskId);

                // ── EMAIL: tiến độ cập nhật ──
                User actorFullProg = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;
                taskEmailService.notifyProgressUpdated(
                        old != null ? old : taskWithId(taskId, title),
                        progress, actorFullProg, assigneeUsers);

                // If progress drives to 100 → also fire task_completed activity
                if (progress >= 100 && (old == null || !"Done".equalsIgnoreCase(old.getStatus()))) {
                    activityService.createActivity(buildTaskActivity(
                            "task_completed",
                            "Task completed: " + title,
                            null, taskId, relType, relId, actor));
                }
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload.
     */
    public boolean updateProgress(int taskId, int progress) {
        return updateProgress(taskId, progress, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ASSIGN (Scenario 2)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean assignTask(int taskId, int userId, Task task, int changedByUserId) {
        try {
            // DAO expects 3 params: taskId, userId, assignedBy
            boolean ok = taskDAO.addAssignee(taskId, userId, changedByUserId);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0)
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_added", "", String.valueOf(userId));

                // Activity: task_assigned (Scenario 2)
                User actor = changedByUserId > 0 ? userWithId(changedByUserId) : null;
                String title = task != null ? task.getTitle() : "";
                String relType = task != null ? task.getRelatedType() : null;
                Integer relId = task != null ? task.getRelatedId() : null;
                activityService.createActivity(buildTaskActivity(
                        "task_assigned",
                        "Task assigned: " + title,
                        "Assigned to user #" + userId,
                        taskId, relType, relId, actor));

                // In-app notification to assignee
                if (task != null) {
                    notificationService.createForUser(userId,
                            "New Task Assigned",
                            "Task \"" + title + "\" has been assigned to you. Priority: " + task.getPriority(),
                            "TASK", "Task", taskId);
                }

                // ── EMAIL: thông báo được giao task ──
                // fetchUserById để email có tên "Assigned by" đầy đủ
                User assigneeUser = fetchUserById(userId);
                User assignedByUser = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;
                taskEmailService.notifyTaskAssigned(task, assigneeUser, assignedByUser, false);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload.
     */
    public boolean assignTask(int taskId, int userId, Task task) {
        return assignTask(taskId, userId, task, 0);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // REMOVE ASSIGNEE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean removeAssignee(int taskId, int userId, int changedByUserId, Task task) {
        try {
            boolean ok = taskDAO.removeAssignee(taskId, userId);
            if (ok) {
                int hid = taskDAO.insertTaskHistory(taskId, changedByUserId);
                if (hid > 0)
                    taskDAO.insertTaskHistoryDetail(hid, "assignee_removed", String.valueOf(userId), "");

                // In-app notification
                if (task != null) {
                    notificationService.createForUser(userId,
                            "Task Assignment Cancelled",
                            "You have been unassigned from task \"" + task.getTitle() + "\".",
                            "TASK", "Task", taskId);
                }

                // ── EMAIL: thông báo bị gỡ khỏi task ──
                User removedUser = fetchUserById(userId);
                User removedByUser = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;
                taskEmailService.notifyTaskUnassigned(task, removedUser, removedByUser);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Backward-compat overload.
     */
    public boolean removeAssignee(int taskId, int userId) {
        return removeAssignee(taskId, userId, 0, null);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // REASSIGN BULK (Scenario 8) – one history record, one activity
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Replace the current assignee set with {@code desiredAssigneeIds}.
     * If the task previously had assignees this is treated as a REASSIGN,
     * otherwise as a fresh ASSIGN.
     */
    public boolean updateAssigneesBulk(Task task, int changedByUserId, Set<Integer> desiredAssigneeIds) {
        if (task == null || task.getTaskId() == null)
            return false;

        Set<Integer> current = new HashSet<>();
        if (task.getAssignees() != null) {
            for (TaskAssignee ta : task.getAssignees()) {
                if (ta.getUser() != null)
                    current.add(ta.getUser().getUserId());
            }
        }

        Set<Integer> desired = desiredAssigneeIds != null ? new HashSet<>(desiredAssigneeIds) : new HashSet<>();
        Set<Integer> toAdd = new HashSet<>(desired);
        toAdd.removeAll(current);
        Set<Integer> toRemove = new HashSet<>(current);
        toRemove.removeAll(desired);

        if (toAdd.isEmpty() && toRemove.isEmpty())
            return true;

        boolean isReassign = !current.isEmpty();
        boolean ok = true;
        // Fetch người thực hiện bulk-assign một lần duy nhất – dùng cho email "Assigned
        // by"
        User changedByUser = changedByUserId > 0 ? fetchUserById(changedByUserId) : null;

        for (int uid : toRemove) {
            if (taskDAO.removeAssignee(task.getTaskId(), uid)) {
                // In-app notification
                notificationService.createForUser(uid,
                        "Task Assignment Cancelled",
                        "You have been unassigned from task \"" + nullSafe(task.getTitle()) + "\".",
                        "TASK", "Task", task.getTaskId());

                // ── EMAIL: bị gỡ khỏi task ──
                User removedUserBulk = fetchUserById(uid);
                taskEmailService.notifyTaskUnassigned(task, removedUserBulk, changedByUser);
            } else {
                ok = false;
            }
        }

        for (int uid : toAdd) {
            if (taskDAO.addAssignee(task.getTaskId(), uid, changedByUserId)) {
                // In-app notification
                notificationService.createForUser(uid,
                        isReassign ? "Task Reassigned" : "New Task Assigned",
                        "Task \"" + nullSafe(task.getTitle()) + "\" has been assigned to you. Priority: "
                                + task.getPriority(),
                        "TASK", "Task", task.getTaskId());

                // ── EMAIL: được giao / reassign task ──
                User addedUserBulk = fetchUserById(uid);
                taskEmailService.notifyTaskAssigned(task, addedUserBulk, changedByUser, isReassign);
            } else {
                ok = false;
            }
        }

        // Single history record for the entire bulk change
        int hid = taskDAO.insertTaskHistory(task.getTaskId(), changedByUserId);
        if (hid > 0) {
            for (int uid : toRemove)
                taskDAO.insertTaskHistoryDetail(hid, "assignee_removed", String.valueOf(uid), "");
            for (int uid : toAdd)
                taskDAO.insertTaskHistoryDetail(hid, "assignee_added", "", String.valueOf(uid));
        }

        // Activity: task_reassigned if there were previous assignees, otherwise
        // task_assigned
        String activityType = isReassign ? "task_reassigned" : "task_assigned";
        User actor = changedByUserId > 0 ? userWithId(changedByUserId) : null;
        activityService.createActivity(buildTaskActivity(
                activityType,
                activityType.replace('_', ' ') + ": " + nullSafe(task.getTitle()),
                null, task.getTaskId(), null, null, actor));

        return ok;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK OVERDUE – Scheduler (Scenario 9)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Called by the scheduler. Finds all overdue tasks and marks each one,
     * creating an Activity and notifying assignees.
     *
     * @param batchSize max tasks to process per scheduler tick
     * @return count of tasks marked overdue in this run
     */
    public int markOverdueTasks(int batchSize) {
        int count = 0;
        try {
            List<Task> overdue = taskDAO.findOverdueTasks(batchSize);
            for (Task task : overdue) {
                boolean ok = taskDAO.markOverdue(task.getTaskId());
                if (ok) {
                    count++;

                    // Activity: task_overdue (Scenario 9)
                    activityService.createActivity(buildTaskActivity(
                            "task_overdue",
                            "Task overdue: " + nullSafe(task.getTitle()),
                            "Due date was " + str(task.getDueDate()),
                            task.getTaskId(), task.getRelatedType(), task.getRelatedId(), null));

                    List<User> assigneeUsers = assigneesAsUsers(task);

                    // In-app notification
                    notifyAssignees(task, "Task Overdue",
                            "Task \"" + nullSafe(task.getTitle()) + "\" is overdue (due: " + str(task.getDueDate())
                                    + ").",
                            task.getTaskId());

                    // ── EMAIL: cảnh báo overdue ──
                    taskEmailService.notifyTaskOverdue(task, assigneeUsers);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteTask(int taskId) {
        try {
            return taskDAO.deleteTask(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Task getTaskById(int id) {
        try {
            return taskDAO.getTaskById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ACTIVITY ACCESSORS (delegates to ActivityService)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Paged activity timeline for the task detail page.
     */
    public List<Activity> getActivitiesForTask(int taskId, int page, int pageSize) {
        try {
            return activityService.getActivitiesByTask(taskId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countActivitiesForTask(int taskId) {
        try {
            return activityService.countActivitiesByTask(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HISTORY ACCESSORS (delegates to TaskDAO)
    // ─────────────────────────────────────────────────────────────────────────
    public List<model.TaskHistory> getHistoryForTask(int taskId) {
        try {
            return taskDAO.listTaskHistoryByID(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public List<model.TaskHistoryDetail> getHistoryDetails(int historyId) {
        try {
            return taskDAO.listTaskHistoryDetailsByID(historyId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EMAIL SERVICE ACCESSOR – cho phép controller dùng trực tiếp khi cần
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Trả về TaskEmailService để controller có thể gọi trực tiếp nếu cần.
     */
    public TaskEmailService getEmailService() {
        return taskEmailService;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Build a minimal Activity for a task event.
     */
    private Activity buildTaskActivity(String activityType,
                                       String subject,
                                       String description,
                                       int taskId,
                                       String relatedType,
                                       Integer relatedId,
                                       User actor) {
        Activity a = new Activity();
        a.setActivityType(activityType);
        a.setSubject(subject);
        a.setDescription(description);
        a.setActivityDate(LocalDateTime.now());
        a.setRelatedType(relatedType);
        a.setRelatedId(relatedId);
        a.setCreatedBy(actor);
        a.setPerformedBy(actor);
        return a;
    }

    /**
     * Maps a status transition to the appropriate activity_type.
     */
    private String resolveStatusActivityType(String oldStatus, String newStatus) {
        if (newStatus == null)
            return "task_updated";
        return switch (newStatus.trim()) {
            case "In Progress" -> "task_started";
            case "Done" -> "task_completed";
            case "Reopened", "Pending" -> "task_reopened";
            case "Cancelled" -> "task_cancelled";
            case "Overdue" -> "task_overdue";
            default -> "task_updated";
        };
    }

    private String buildStatusSubject(Task task, String activityType) {
        String title = task != null ? nullSafe(task.getTitle()) : "";
        return switch (activityType) {
            case "task_started" -> "Task started: " + title;
            case "task_completed" -> "Task completed: " + title;
            case "task_reopened" -> "Task reopened: " + title;
            case "task_cancelled" -> "Task cancelled: " + title;
            case "task_overdue" -> "Task overdue: " + title;
            default -> "Task updated: " + title;
        };
    }

    private boolean isCompletedState(String status, Integer progress) {
        return "Done".equalsIgnoreCase(status) || (progress != null && progress >= 100);
    }

    private boolean isPrivileged(User user) {
        if (user == null || user.getRole() == null)
            return false;
        String rn = user.getRole().getRoleName();
        return "ADMIN".equalsIgnoreCase(rn) || "MANAGER".equalsIgnoreCase(rn);
    }

    /**
     * Only writes a history detail if the value actually changed.
     */
    private void logDiff(int historyId, String field, String oldVal, String newVal) {
        String o = oldVal != null ? oldVal.trim() : "";
        String n = newVal != null ? newVal.trim() : "";
        if (!Objects.equals(o, n)) {
            taskDAO.insertTaskHistoryDetail(historyId, field, o, n);
        }
    }

    /**
     * INSTANT: Check if task is overdue and notify immediately.
     * Called right after create/update to avoid scheduler delay.
     */
    private void checkAndNotifyOverdue(Task task) {
        if (task == null || task.getDueDate() == null)
            return;

        String status = task.getStatus();
        if (status == null)
            return;
        if ("Done".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)
                || "Overdue".equalsIgnoreCase(status))
            return;

        if (task.getDueDate().isBefore(LocalDateTime.now())) {
            boolean marked = taskDAO.markOverdue(task.getTaskId());
            if (marked) {
                task.setStatus("Overdue");

                activityService.createActivity(buildTaskActivity(
                        "task_overdue",
                        "Task overdue: " + task.getTitle(),
                        "Due date was " + task.getDueDate(),
                        task.getTaskId(), task.getRelatedType(), task.getRelatedId(), null));

                List<User> assigneeUsers = assigneesAsUsers(task);

                // In-app
                notifyAssignees(task, "Task Overdue",
                        "Task \"" + task.getTitle() + "\" is overdue (due: " + task.getDueDate() + ").",
                        task.getTaskId());

                // ── EMAIL: overdue alert ──
                taskEmailService.notifyTaskOverdue(task, assigneeUsers);
            }
        }
    }

    private void notifyAssignees(Task task, String title, String message, int taskId) {
        if (task == null || task.getAssignees() == null)
            return;
        for (TaskAssignee ta : task.getAssignees()) {
            if (ta.getUser() != null) {
                notificationService.createForUser(
                        ta.getUser().getUserId(), title, message, "TASK", "Task", taskId);
            }
        }
    }

    /**
     * Chuyển danh sách TaskAssignee → danh sách User (lọc null).
     * Dùng để truyền vào TaskEmailService.
     */
    private List<User> assigneesAsUsers(Task task) {
        if (task == null || task.getAssignees() == null)
            return Collections.emptyList();
        return task.getAssignees().stream()
                .map(TaskAssignee::getUser)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    /**
     * Lấy User theo userId qua UserDAO.
     * Trả về null nếu không tìm thấy hoặc lỗi – TaskEmailService xử lý null an
     * toàn.
     */
    private User fetchUserById(int userId) {
        try {
            return new UserDAO().getUserById(userId);
        } catch (Exception e) {
            // Không ảnh hưởng luồng chính nếu lookup thất bại
            return null;
        }
    }

    /**
     * Lightweight User shell used when we only have an ID (avoids a DB round-trip).
     */
    private User userWithId(int userId) {
        User u = new User();
        u.setUserId(userId);
        return u;
    }

    /**
     * Tạo Task tạm với taskId và title – dùng khi không có task object đầy đủ.
     */
    private Task taskWithId(int taskId, String title) {
        Task t = new Task();
        t.setTaskId(taskId);
        t.setTitle(title);
        return t;
    }

    private String str(Object o) {
        return o != null ? o.toString() : "";
    }

    private String nullSafe(String s) {
        return s != null ? s : "";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MONTHLY TIMELINE
    // ─────────────────────────────────────────────────────────────────────────

    public List<Task> getMonthlyTasks(int userId, boolean isManager) {
        try {
            return taskDAO.getMonthlyTasks(userId, isManager);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public List<TaskComment> getMonthlySubtasks(int userId, boolean isManager, List<Integer> taskIds) {
        try {
            return taskDAO.getMonthlySubtasks(userId, isManager, taskIds);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}