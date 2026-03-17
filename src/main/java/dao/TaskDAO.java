package dao;

import model.Task;
import model.TaskAssignee;
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
          + "completed_at, progress, created_by, created_at, updated_at) "
          + "VALUES (?,?,?,?,?,?,?,?,?,GETDATE(),GETDATE())";

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
          + "due_date=?,start_date=?,completed_at=?,progress=?,updated_at=GETDATE() "
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
            ps.setInt(9, task.getTaskId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. UPDATE STATUS ONLY
    //    When status = Done  → set completed_at = now
    //    Otherwise           → clear completed_at (reopen / cancel / overdue)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTaskStatus(int taskId, String status) {
        String sql =
            "UPDATE Tasks "
          + "SET status=?, "
          + "    completed_at = CASE WHEN ? = 'Done' THEN GETDATE() ELSE NULL END, "
          + "    start_date   = CASE WHEN ? = 'In Progress' AND start_date IS NULL THEN GETDATE() ELSE start_date END, "
          + "    updated_at=GETDATE() "
          + "WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);  // for completed_at CASE
            ps.setString(3, status);  // for start_date CASE
            ps.setInt(4, taskId);
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
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        List<Task> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder sql = new StringBuilder(TASK_BASE_SELECT + "WHERE 1=1 ");
        appendTaskFilters(sql, params, title, description, status, priority, fromDate, toDate, assigneeUserId);

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
                                  Integer assigneeUserId) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Tasks t WHERE 1=1 ");
        appendTaskFilters(sql, params, title, description, status, priority, fromDate, toDate, assigneeUserId);

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
    public boolean addAssignee(int taskId, int userId) {
        String sql =
            "IF NOT EXISTS (SELECT 1 FROM Task_Assignees WHERE task_id=? AND user_id=?) "
          + "INSERT INTO Task_Assignees (task_id, user_id, assigned_at) VALUES (?,?,GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId); ps.setInt(2, userId);
            ps.setInt(3, taskId); ps.setInt(4, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeAssignee(int taskId, int userId) {
        String sql = "DELETE FROM Task_Assignees WHERE task_id=? AND user_id=?";
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
        String sql = "INSERT INTO Task_History (task_id, changed_by, changed_at) VALUES (?,?,GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, taskId);
            ps.setInt(2, changedBy);
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
                                   Integer assigneeUserId) {
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

        Timestamp due       = rs.getTimestamp("due_date");
        Timestamp start     = rs.getTimestamp("start_date");
        Timestamp completed = rs.getTimestamp("completed_at");
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");

        if (due       != null) t.setDueDate(due.toLocalDateTime());
        if (start     != null) t.setStartDate(start.toLocalDateTime());
        if (completed != null) t.setCompletedAt(completed.toLocalDateTime());
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
            "SELECT ta.task_id, ta.assigned_at, "
          + "       u.user_id, u.full_name, u.email, u.username, "
          + "       r.role_id, r.role_name "
          + "FROM Task_Assignees ta "
          + "JOIN  Users u  ON ta.user_id  = u.user_id "
          + "LEFT JOIN Roles r ON u.role_id = r.role_id "
          + "WHERE ta.task_id=?";
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
                    list.add(ta);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}