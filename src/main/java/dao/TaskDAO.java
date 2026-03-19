package dao;

import model.Task;
import model.TaskAssignee;
import model.TaskComment;
import model.TaskHistory;
import model.TaskHistoryDetail;
import model.User;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TaskDAO – aligned with the CRM_System schema.
 *
 * Changes from previous version:
 *  1. Extracted TASK_BASE_SELECT constant – eliminates 4 copies of the same JOIN block.
 *  2. Unified appendTaskFilters() – single source of truth for WHERE clauses; fixes the
 *     previous bug where getTasksPaged filtered on start_date while countTasksFiltered
 *     filtered on due_date.  Both now use due_date consistently.
 *  3. appendTaskFilters uses EXISTS subquery for assignee – removes the implicit LEFT JOIN
 *     from countTasksFiltered and avoids phantom duplicates.
 *  4. getTasksPaged now calls appendTaskFilters (no more inline duplicate).
 *  5. resolveSortColumn() is a proper private helper (was commented-out dead code).
 *  6. deleteTask() now cascades to Task_Comments.
 *  7. findByAssigneePaged() + countByAssignee() replace the old unpaged findByAssignee().
 *  8. findOverdueTasks() + markOverdue() support the scheduler overdue scenario.
 *  9. getAllTasks() retained for small dropdowns only – its N+1 loadAssignees() call is
 *     intentional for that tiny use-case.
 */
public class TaskDAO {

    private final Connection connection;

    public TaskDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BASE SELECT – reused by all list/detail queries
    // ─────────────────────────────────────────────────────────────────────────
    private static final String TASK_BASE_SELECT =
        "SELECT t.*, "
      + "u.user_id AS u_id, u.full_name, u.email, u.username, "
      + "r.role_id, r.role_name "
      + "FROM Tasks t "
      + "LEFT JOIN Users u ON t.created_by = u.user_id "
      + "LEFT JOIN Roles r ON u.role_id = r.role_id ";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. CREATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createTask(Task task) {
        if (task == null || task.getTitle() == null || task.getTitle().isBlank()) return false;

        String sql =
            "INSERT INTO Tasks (title, description, status, priority, due_date, start_date, "
          + "completed_at, progress, created_by, related_type, related_id, created_at, updated_at) "
          + "VALUES (?,?,?,?,?,?,?,?,?,?,?,GETDATE(),GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, task.getTitle().trim());
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus()   != null ? task.getStatus()   : "Pending");
            ps.setString(4, task.getPriority() != null ? task.getPriority() : "Medium");
            ps.setObject(5, task.getDueDate()     != null ? Timestamp.valueOf(task.getDueDate())     : null, Types.TIMESTAMP);
            ps.setObject(6, task.getStartDate()   != null ? Timestamp.valueOf(task.getStartDate())   : null, Types.TIMESTAMP);
            ps.setObject(7, task.getCompletedAt() != null ? Timestamp.valueOf(task.getCompletedAt()) : null, Types.TIMESTAMP);
            ps.setInt(8, task.getProgress() != null ? task.getProgress() : 0);
            ps.setInt(9, task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0);
            ps.setString(10, task.getRelatedType());
            ps.setObject(11, task.getRelatedId(), Types.INTEGER);

            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) task.setTaskId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. UPDATE (full update)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTask(Task task) {
        if (task == null || task.getTaskId() == null || task.getTaskId() <= 0) return false;

        String sql =
            "UPDATE Tasks SET title=?,description=?,status=?,priority=?,"
          + "due_date=?,start_date=?,completed_at=?,progress=?,related_type=?,related_id=?,updated_at=GETDATE() "
          + "WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, task.getTitle()       != null ? task.getTitle().trim()       : "");
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus()      != null ? task.getStatus()             : "Pending");
            ps.setString(4, task.getPriority()    != null ? task.getPriority()           : "Medium");
            ps.setObject(5, task.getDueDate()     != null ? Timestamp.valueOf(task.getDueDate())     : null, Types.TIMESTAMP);
            ps.setObject(6, task.getStartDate()   != null ? Timestamp.valueOf(task.getStartDate())   : null, Types.TIMESTAMP);
            ps.setObject(7, task.getCompletedAt() != null ? Timestamp.valueOf(task.getCompletedAt()) : null, Types.TIMESTAMP);
            ps.setInt(8, task.getProgress() != null ? task.getProgress() : 0);
            ps.setString(9, task.getRelatedType());
            ps.setObject(10, task.getRelatedId(), Types.INTEGER);
            ps.setInt(11, task.getTaskId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. UPDATE STATUS ONLY
    //    When status = Done      → set completed_at = now
    //    When status = Cancelled → set cancelled_at = now
    //    Otherwise               → clear completed_at/cancelled_at (reopen / overdue)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTaskStatus(int taskId, String status) {
        String sql =
            "UPDATE Tasks "
          + "SET status=?, "
          + "    completed_at = CASE WHEN ? = 'Done' THEN GETDATE() ELSE NULL END, "
          + "    cancelled_at = CASE WHEN ? = 'Cancelled' THEN GETDATE() ELSE NULL END, "
          + "    start_date   = CASE WHEN ? = 'In Progress' AND start_date IS NULL THEN GETDATE() ELSE start_date END, "
          + "    updated_at=GETDATE() "
          + "WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);  // for completed_at CASE
            ps.setString(3, status);  // for cancelled_at CASE
            ps.setString(4, status);  // for start_date CASE
            ps.setInt(5, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. UPDATE PROGRESS – auto-derives status from progress value
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress) {
        if (progress < 0 || progress > 100) return false;

        String derivedStatus  = progress >= 100 ? "Done" : (progress > 0 ? "In Progress" : "Pending");
        String sql =
            "UPDATE Tasks "
          + "SET progress=?, status=?, "
          + "    completed_at = CASE WHEN ? >= 100 THEN GETDATE() ELSE NULL END, "
          + "    start_date   = CASE WHEN ? > 0 AND start_date IS NULL THEN GETDATE() ELSE start_date END, "
          + "    updated_at=GETDATE() "
          + "WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, progress);
            ps.setString(2, derivedStatus);
            ps.setInt(3, progress);  // for completed_at CASE
            ps.setInt(4, progress);  // for start_date CASE
            ps.setInt(5, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. MARK OVERDUE – scheduler sets status = Overdue for past-due tasks
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Mark a single task as Overdue.
     */
    public boolean markOverdue(int taskId) {
        String sql =
            "UPDATE Tasks SET status='Overdue', updated_at=GETDATE() "
          + "WHERE task_id=? AND status NOT IN ('Done','Cancelled','Overdue')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Scheduler query: find tasks whose due_date has passed and are still active.
     * Returns at most {@code batchSize} rows, ordered by due_date ASC.
     */
    public List<Task> findOverdueTasks(int batchSize) {
        List<Task> list = new ArrayList<>();
        String sql =
            TASK_BASE_SELECT
          + "WHERE t.due_date < GETDATE() "
          + "  AND t.status NOT IN ('Done','Cancelled','Overdue') "
          + "ORDER BY t.due_date ASC "
          + "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. GET ALL TASKS (for dropdowns / small sets only – loads assignees N+1)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = TASK_BASE_SELECT + "ORDER BY t.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Task task = mapRow(rs);
                task.setAssignees(loadAssignees(task.getTaskId()));
                list.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. PAGED + FILTERED LIST
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(String title, String description,
                                    String status, String priority,
                                    String fromDate, String toDate,
                                    Integer assigneeUserId,
                                    Integer createdByUserId,
                                    String relatedType,
                                    Integer relatedId,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        List<Task> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder sql = new StringBuilder(TASK_BASE_SELECT + "WHERE 1=1 ");
        appendTaskFilters(sql, params, title, description, status, priority, fromDate, toDate, assigneeUserId, createdByUserId, relatedType, relatedId);

        sql.append("ORDER BY ").append(resolveSortColumn(sortField)).append(" ");
        sql.append("DESC".equalsIgnoreCase(sortDir) ? "DESC " : "ASC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTasksFiltered(String title, String description,
                                  String status, String priority,
                                  String fromDate, String toDate,
                                  Integer assigneeUserId,
                                  Integer createdByUserId,
                                  String relatedType,
                                  Integer relatedId) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Tasks t WHERE 1=1 ");
        appendTaskFilters(sql, params, title, description, status, priority, fromDate, toDate, assigneeUserId, createdByUserId, relatedType, relatedId);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. GET BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Task getTaskById(int id) {
        String sql = TASK_BASE_SELECT + "WHERE t.task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(id));
                    return task;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. FIND BY ASSIGNEE – paged (replaces the old unpaged findByAssignee)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> findByAssigneePaged(int userId, int page, int pageSize) {
        List<Task> list = new ArrayList<>();
        String sql =
            TASK_BASE_SELECT
          + "WHERE EXISTS (SELECT 1 FROM Task_Assignees ta WHERE ta.task_id=t.task_id AND ta.user_id=?) "
          + "ORDER BY t.created_at DESC "
          + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countByAssignee(int userId) {
        String sql =
            "SELECT COUNT(*) FROM Tasks t "
          + "WHERE EXISTS (SELECT 1 FROM Task_Assignees ta WHERE ta.task_id=t.task_id AND ta.user_id=?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10. ADD / REMOVE ASSIGNEE
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Add assignee with tracking of who assigned (assignedBy).
     * Uses MERGE to handle both new assignments and re-activations.
     */
    public boolean addAssignee(int taskId, int userId, int assignedBy) {
        String sql =
            "MERGE Task_Assignees AS target "
          + "USING (VALUES (?, ?)) AS src(task_id, user_id) "
          + "   ON target.task_id = src.task_id AND target.user_id = src.user_id "
          + "WHEN MATCHED AND target.is_active = 0 THEN "
          + "   UPDATE SET is_active = 1, assigned_at = GETDATE(), assigned_by = ? "
          + "WHEN NOT MATCHED THEN "
          + "   INSERT (task_id, user_id, assigned_at, assigned_by, is_primary, is_active) "
          + "   VALUES (?, ?, GETDATE(), ?, 0, 1);";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            ps.setInt(3, assignedBy);
            ps.setInt(4, taskId);
            ps.setInt(5, userId);
            ps.setInt(6, assignedBy);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Remove assignee by setting is_active = 0 (soft delete for audit).
     */
    public boolean removeAssignee(int taskId, int userId) {
        String sql = "UPDATE Task_Assignees SET is_active = 0 WHERE task_id=? AND user_id=? AND is_active = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId); ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11. DELETE – cascades through all child tables including Task_Comments
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteTask(int taskId) {
        String[] cascadeStatements = {
            "DELETE FROM Task_Assignees   WHERE task_id=?",
            "DELETE FROM Task_Comments    WHERE task_id=?",
            "DELETE FROM Task_History_Detail WHERE history_id IN (SELECT history_id FROM Task_History WHERE task_id=?)",
            "DELETE FROM Task_History     WHERE task_id=?",
            "DELETE FROM Tasks            WHERE task_id=?"
        };
        try {
            for (String sql : cascadeStatements) {
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, taskId);
                    ps.executeUpdate();
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12. TASK HISTORY – insert header row, return generated history_id
    // ─────────────────────────────────────────────────────────────────────────
    public int insertTaskHistory(int taskId, int changedBy) {
        return insertTaskHistory(taskId, changedBy, "update", null);
    }

    public int insertTaskHistory(int taskId, int changedBy, String action, String note) {
        String sql = "INSERT INTO Task_History (task_id, changed_by, changed_at, action, note) VALUES (?,?,GETDATE(),?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, taskId);
            ps.setInt(2, changedBy);
            ps.setString(3, action != null ? action : "update");
            ps.setString(4, note);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 13. TASK HISTORY DETAIL – one row per changed field
    // ─────────────────────────────────────────────────────────────────────────
    public boolean insertTaskHistoryDetail(int historyId, String fieldName, String oldValue, String newValue) {
        String sql =
            "INSERT INTO Task_History_Detail (history_id, field_name, old_value, new_value) "
          + "VALUES (?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, historyId);
            ps.setString(2, fieldName);
            ps.setString(3, oldValue != null ? oldValue : "");
            ps.setString(4, newValue != null ? newValue : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 14. LIST TASK HISTORY BY TASK ID (audit log page)
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskHistory> listTaskHistoryByID(int taskId) {
        List<TaskHistory> list = new ArrayList<>();
        String sql =
            "SELECT th.history_id, th.task_id, th.changed_by, th.changed_at, "
          + "       u.full_name AS changer_name "
          + "FROM Task_History th "
          + "LEFT JOIN Users u ON th.changed_by = u.user_id "
          + "WHERE th.task_id=? ORDER BY th.changed_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TaskHistory th = new TaskHistory();
                    th.setHistoryId(rs.getInt("history_id"));
                    th.setTaskId(rs.getInt("task_id"));
                    th.setChangedBy(rs.getInt("changed_by"));
                    th.setChangerName(rs.getString("changer_name"));
                    Timestamp cat = rs.getTimestamp("changed_at");
                    if (cat != null) th.setChangedAt(cat.toLocalDateTime());
                    list.add(th);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 15. LIST TASK HISTORY DETAILS BY HISTORY ID
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskHistoryDetail> listTaskHistoryDetailsByID(int historyId) {
        List<TaskHistoryDetail> list = new ArrayList<>();
        String sql =
            "SELECT detail_id, history_id, field_name, old_value, new_value "
          + "FROM Task_History_Detail WHERE history_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, historyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TaskHistoryDetail d = new TaskHistoryDetail();
                    d.setDetailId(rs.getInt("detail_id"));
                    d.setHistoryId(rs.getInt("history_id"));
                    d.setFieldName(rs.getString("field_name"));
                    d.setOldValue(rs.getString("old_value"));
                    d.setNewValue(rs.getString("new_value"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Shared WHERE-clause builder used by both getTasksPaged and countTasksFiltered.
     * Date range always operates on due_date (not start_date).
     * Assignee filter always uses EXISTS to avoid JOIN-based duplicates.
     */
    private void appendTaskFilters(StringBuilder sql, List<Object> params,
                                   String title, String description,
                                   String status, String priority,
                                   String fromDate, String toDate,
                                   Integer assigneeUserId,
                                   Integer createdByUserId,
                                   String relatedType,
                                   Integer relatedId) {
        if (title != null && !title.isBlank()) {
            sql.append("AND t.title LIKE ? ");
            params.add("%" + title.trim() + "%");
        }
        if (description != null && !description.isBlank()) {
            sql.append("AND t.description LIKE ? ");
            params.add("%" + description.trim() + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND t.status = ? ");
            params.add(status.trim());
        }
        if (priority != null && !priority.isBlank()) {
            sql.append("AND t.priority = ? ");
            params.add(priority.trim());
        }
        if (fromDate != null && !fromDate.isBlank()) {
            sql.append("AND t.due_date >= ? ");
            params.add(fromDate.trim() + " 00:00:00");
        }
        if (toDate != null && !toDate.isBlank()) {
            sql.append("AND t.due_date <= ? ");
            params.add(toDate.trim() + " 23:59:59");
        }
        if (assigneeUserId != null && assigneeUserId > 0) {
            sql.append("AND EXISTS (SELECT 1 FROM Task_Assignees ta WHERE ta.task_id=t.task_id AND ta.user_id=?) ");
            params.add(assigneeUserId);
        }
        if (createdByUserId != null && createdByUserId > 0) {
            sql.append("AND t.created_by = ? ");
            params.add(createdByUserId);
        }
        if (relatedType != null && !relatedType.isBlank()) {
            sql.append("AND t.related_type = ? ");
            params.add(relatedType.trim());
        }
        if (relatedId != null && relatedId > 0) {
            sql.append("AND t.related_id = ? ");
            params.add(relatedId);
        }
    }

    /**
     * Maps sort field names from the UI to safe SQL column expressions.
     * Only whitelisted values are returned – prevents SQL injection.
     */
    private String resolveSortColumn(String sortField) {
        if (sortField == null) return "t.created_at";
        return switch (sortField) {
            case "dueDate"   -> "t.due_date";
            case "startDate" -> "t.start_date";
            case "priority"  -> "CASE t.priority WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END";
            case "progress"  -> "t.progress";
            case "title"     -> "t.title";
            default          -> "t.created_at";
        };
    }

    private Task mapRow(ResultSet rs) throws SQLException {
        Task t = new Task();
        t.setTaskId(rs.getInt("task_id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setPriority(rs.getString("priority"));
        t.setProgress(rs.getInt("progress"));

        // ✅ THÊM MỚI: related_type, related_id, cancelled_at
        t.setRelatedType(rs.getString("related_type"));
        int relatedId = rs.getInt("related_id");
        if (!rs.wasNull()) t.setRelatedId(relatedId);

        Timestamp due        = rs.getTimestamp("due_date");
        Timestamp start      = rs.getTimestamp("start_date");
        Timestamp completed  = rs.getTimestamp("completed_at");
        Timestamp cancelled  = rs.getTimestamp("cancelled_at");
        Timestamp createdAt  = rs.getTimestamp("created_at");
        Timestamp updatedAt  = rs.getTimestamp("updated_at");

        if (due       != null) t.setDueDate(due.toLocalDateTime());
        if (start     != null) t.setStartDate(start.toLocalDateTime());
        if (completed != null) t.setCompletedAt(completed.toLocalDateTime());
        if (cancelled != null) t.setCancelledAt(cancelled.toLocalDateTime());
        if (createdAt != null) t.setCreatedAt(createdAt.toLocalDateTime());
        if (updatedAt != null) t.setUpdatedAt(updatedAt.toLocalDateTime());

        int uId = rs.getInt("u_id");
        if (!rs.wasNull() && uId > 0) {
            User u = new User();
            u.setUserId(uId);
            u.setFullName(rs.getString("full_name"));
            u.setEmail(rs.getString("email"));
            u.setUsername(rs.getString("username"));
            int roleId = rs.getInt("role_id");
            if (!rs.wasNull()) {
                Role r = new Role();
                r.setRoleId(roleId);
                r.setRoleName(rs.getString("role_name"));
                u.setRole(r);
            }
            t.setCreatedBy(u);
        }
        return t;
    }

    private List<TaskAssignee> loadAssignees(int taskId) {
        List<TaskAssignee> list = new ArrayList<>();
        String sql =
            "SELECT ta.task_id, ta.assigned_at, ta.assigned_by, ta.is_primary, ta.is_active, "
          + "       u.user_id, u.full_name, u.email, u.username, "
          + "       r.role_id, r.role_name "
          + "FROM Task_Assignees ta "
          + "JOIN  Users u  ON ta.user_id  = u.user_id "
          + "LEFT JOIN Roles r ON u.role_id = r.role_id "
          + "WHERE ta.task_id=? AND ta.is_active = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setUsername(rs.getString("username"));
                    int roleId = rs.getInt("role_id");
                    if (!rs.wasNull()) {
                        Role r = new Role();
                        r.setRoleId(roleId);
                        r.setRoleName(rs.getString("role_name"));
                        u.setRole(r);
                    }
                    TaskAssignee ta = new TaskAssignee();
                    ta.setTaskId(rs.getInt("task_id"));
                    ta.setUser(u);
                    Timestamp at = rs.getTimestamp("assigned_at");
                    if (at != null) ta.setAssignedAt(at.toLocalDateTime());
                    // ✅ THÊM MỚI: assigned_by, is_primary, is_active
                    int assignedBy = rs.getInt("assigned_by");
                    if (!rs.wasNull()) ta.setAssignedBy(assignedBy);
                    ta.setPrimary(rs.getBoolean("is_primary"));
                    ta.setActive(rs.getBoolean("is_active"));
                    list.add(ta);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 17. SCHEDULE – tasks within a date range (for weekly timetable)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> findTasksInDateRange(java.time.LocalDateTime start, java.time.LocalDateTime end,
                                           Integer assigneeUserId) {
        List<Task> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(TASK_BASE_SELECT);
        sql.append("WHERE (");
        sql.append("  (t.start_date BETWEEN ? AND ?) ");
        sql.append("  OR (t.due_date BETWEEN ? AND ?) ");
        sql.append(") ");
        if (assigneeUserId != null && assigneeUserId > 0) {
            sql.append("AND EXISTS (SELECT 1 FROM Task_Assignees ta WHERE ta.task_id=t.task_id AND ta.user_id=?) ");
        }
        sql.append("ORDER BY COALESCE(t.start_date, t.due_date) ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setTimestamp(idx++, Timestamp.valueOf(start));
            ps.setTimestamp(idx++, Timestamp.valueOf(end));
            ps.setTimestamp(idx++, Timestamp.valueOf(start));
            ps.setTimestamp(idx++, Timestamp.valueOf(end));
            if (assigneeUserId != null && assigneeUserId > 0) {
                ps.setInt(idx++, assigneeUserId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 18. GET TASKS BY USER (recursive - owner + assignee + subtask supporter)
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Find all tasks where user is involved:
     * 1. Task owner (created_by)
     * 2. Task assignee (Task_Assignees)
     * 3. Tagged in work items (Task_Comments.assigned_to)
     *
     * This is a "recursive" query that finds all tasks the user is connected to.
     */
    public List<Task> findTasksByUser(int userId, int page, int pageSize) {
        List<Task> list = new ArrayList<>();
        String sql = """
            SELECT DISTINCT t.*,
                   u.user_id AS u_id, u.full_name, u.email, u.username,
                   r.role_id, r.role_name
            FROM Tasks t
            LEFT JOIN Users u ON t.created_by = u.user_id
            LEFT JOIN Roles r ON u.role_id = r.role_id
            WHERE t.task_id IN (
                -- Tasks where user is owner
                SELECT task_id FROM Tasks WHERE created_by = ?
                UNION
                -- Tasks where user is assignee
                SELECT task_id FROM Task_Assignees WHERE user_id = ? AND is_active = 1
                UNION
                -- Tasks where user is tagged in work items
                SELECT task_id FROM Task_Comments WHERE assigned_to = ? AND is_deleted = 0
            )
            ORDER BY t.created_at DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, (page - 1) * pageSize);
            ps.setInt(5, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTasksByUser(int userId) {
        String sql = """
            SELECT COUNT(DISTINCT t.task_id)
            FROM Tasks t
            WHERE t.task_id IN (
                SELECT task_id FROM Tasks WHERE created_by = ?
                UNION
                SELECT task_id FROM Task_Assignees WHERE user_id = ? AND is_active = 1
                UNION
                SELECT task_id FROM Task_Comments WHERE assigned_to = ? AND is_deleted = 0
            )
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 20. SCHEDULE - Get tasks for a specific week with subtasks
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Get tasks and subtasks for a user's schedule within a date range.
     * For employee: returns their own tasks + tasks they're assigned to
     * For manager: returns all root tasks of their subordinates
     *
     * @param userId current user ID
     * @param isManager whether user is manager/admin
     * @param startDate range start
     * @param endDate range end
     * @return list of schedule items (tasks and subtasks)
     */
    public List<Task> getScheduleTasks(int userId, boolean isManager,
                                       java.time.LocalDate startDate,
                                       java.time.LocalDate endDate) {
        List<Task> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        if (isManager) {
            // Manager: get all root tasks (no parent) of subordinates
            // Subordinates = users with role_id != 1 (not admin) and under this manager
            sql.append("""
                SELECT DISTINCT t.*,
                       u.user_id AS u_id, u.full_name, u.email, u.username,
                       r.role_id, r.role_name
                FROM Tasks t
                LEFT JOIN Users u ON t.created_by = u.user_id
                LEFT JOIN Roles r ON u.role_id = r.role_id
                WHERE t.task_id IN (
                    -- Root tasks created by subordinates (not admin, not this user)
                    SELECT t2.task_id
                    FROM Tasks t2
                    JOIN Users sub ON t2.created_by = sub.user_id
                    WHERE sub.role_id != 1
                    AND t2.task_id NOT IN (
                        SELECT task_id FROM Task_Comments WHERE parent_comment_id IS NOT NULL
                    )
                )
                AND (t.start_date IS NOT NULL OR t.due_date IS NOT NULL)
                AND (
                    (t.start_date >= ? AND t.start_date < ?)
                    OR (t.due_date >= ? AND t.due_date < ?)
                    OR (t.start_date <= ? AND t.due_date >= ?)
                )
                ORDER BY t.start_date ASC, t.due_date ASC
                """);
        } else {
            // Employee: get own tasks + assigned tasks
            sql.append("""
                SELECT DISTINCT t.*,
                       u.user_id AS u_id, u.full_name, u.email, u.username,
                       r.role_id, r.role_name
                FROM Tasks t
                LEFT JOIN Users u ON t.created_by = u.user_id
                LEFT JOIN Roles r ON u.role_id = r.role_id
                WHERE t.task_id IN (
                    -- Tasks where user is owner
                    SELECT task_id FROM Tasks WHERE created_by = ?
                    UNION
                    -- Tasks where user is assignee
                    SELECT task_id FROM Task_Assignees WHERE user_id = ? AND is_active = 1
                )
                AND (t.start_date IS NOT NULL OR t.due_date IS NOT NULL)
                AND (
                    (t.start_date >= ? AND t.start_date < ?)
                    OR (t.due_date >= ? AND t.due_date < ?)
                    OR (t.start_date <= ? AND t.due_date >= ?)
                )
                ORDER BY t.start_date ASC, t.due_date ASC
                """);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            if (isManager) {
                ps.setObject(1, startDate);
                ps.setObject(2, endDate);
                ps.setObject(3, startDate);
                ps.setObject(4, endDate);
                ps.setObject(5, endDate.minusDays(1));
                ps.setObject(6, startDate);
            } else {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                ps.setObject(3, startDate);
                ps.setObject(4, endDate);
                ps.setObject(5, startDate);
                ps.setObject(6, endDate);
                ps.setObject(7, endDate.minusDays(1));
                ps.setObject(8, startDate);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    // Load assignees for each task
                    task.setAssignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get subtasks (work items) for specific tasks within a date range.
     * Uses Task_Comments where assigned_to is set.
     */
    public List<TaskComment> getScheduleSubtasks(List<Integer> taskIds,
                                                  java.time.LocalDate startDate,
                                                  java.time.LocalDate endDate) {
        List<TaskComment> list = new ArrayList<>();
        if (taskIds == null || taskIds.isEmpty()) {
            return list;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < taskIds.size(); i++) {
            placeholders.append(i > 0 ? "," : "").append("?");
        }

        String sql = String.format("""
            SELECT tc.*, u.user_id AS a_u_id, u.full_name AS a_full_name,
                   t.title AS task_title
            FROM Task_Comments tc
            LEFT JOIN Users u ON tc.assigned_to = u.user_id
            LEFT JOIN Tasks t ON tc.task_id = t.task_id
            WHERE tc.task_id IN (%s)
            AND tc.assigned_to IS NOT NULL
            AND tc.is_deleted = 0
            AND tc.created_at >= ? AND tc.created_at < ?
            ORDER BY tc.created_at ASC
            """, placeholders.toString());

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer taskId : taskIds) {
                ps.setInt(idx++, taskId);
            }
            ps.setObject(idx++, startDate);
            ps.setObject(idx, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TaskComment tc = new TaskComment();
                    tc.setCommentId(rs.getInt("comment_id"));
                    tc.setTaskId(rs.getInt("task_id"));
                    tc.setContent(rs.getString("content"));
                    tc.setCompleted(rs.getBoolean("is_completed"));

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    if (createdAt != null) {
                        tc.setCreatedAt(createdAt.toLocalDateTime());
                    }

                    int aUid = rs.getInt("a_u_id");
                    if (!rs.wasNull()) {
                        User assignedUser = new User();
                        assignedUser.setUserId(aUid);
                        assignedUser.setFullName(rs.getString("a_full_name"));
                        tc.setAssignedToUser(assignedUser);
                    }

                    tc.setTaskTitle(rs.getString("task_title"));
                    list.add(tc);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}