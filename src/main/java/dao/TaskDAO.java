package dao;

import model.Task;
import model.TaskAssignee;
import model.User;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.TaskHistory;
import model.TaskHistoryDetail;

/**
 * TaskDAO – aligned with the actual CRM_System schema.
 *
 * NOTE: Method 11 (announceAssignedTask) has been REMOVED. All notification
 * logic is now handled exclusively by NotificationDAO / NotificationService to
 * maintain proper separation of concerns.
 */
public class TaskDAO {

    private final Connection connection;

    public TaskDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. CREATE TASK
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createTask(Task task) {
        if (task == null || task.getTitle() == null || task.getTitle().isBlank()) {
            return false;
        }

        String sql = "INSERT INTO Tasks (title, description, status, priority, due_date, start_date, completed_at, progress, "
                + "created_by, created_at, updated_at) "
                + "VALUES (?,?,?,?,?,?,?,?,?,GETDATE(),GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, task.getTitle().trim());
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus() != null ? task.getStatus() : "Pending");
            ps.setString(4, task.getPriority() != null ? task.getPriority() : "Medium");
            if (task.getDueDate() != null) {
                ps.setTimestamp(5, Timestamp.valueOf(task.getDueDate()));
            } else {
                ps.setNull(5, Types.TIMESTAMP);
            }
            if (task.getStartDate() != null) {
                ps.setTimestamp(6, Timestamp.valueOf(task.getStartDate()));
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            if (task.getCompletedAt() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(task.getCompletedAt()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            ps.setInt(8, task.getProgress() != null ? task.getProgress() : 0);
            ps.setInt(9, task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0);
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        task.setTaskId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. UPDATE TASK
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTask(Task task) {
        if (task == null || task.getTaskId() == null || task.getTaskId() <= 0) {
            return false;
        }
        String sql = "UPDATE Tasks SET title=?,description=?,status=?,priority=?,due_date=?,start_date=?,completed_at=?,progress=?,"
                + "updated_at=GETDATE() WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, task.getTitle() != null ? task.getTitle().trim() : "");
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus() != null ? task.getStatus() : "Pending");
            ps.setString(4, task.getPriority() != null ? task.getPriority() : "Medium");
            if (task.getDueDate() != null) {
                ps.setTimestamp(5, Timestamp.valueOf(task.getDueDate()));
            } else {
                ps.setNull(5, Types.TIMESTAMP);
            }
            if (task.getStartDate() != null) {
                ps.setTimestamp(6, Timestamp.valueOf(task.getStartDate()));
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            if (task.getCompletedAt() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(task.getCompletedAt()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            ps.setInt(8, task.getProgress() != null ? task.getProgress() : 0);
            ps.setInt(9, task.getTaskId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. UPDATE STATUS
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTaskStatus(int taskId, String status) {
        Timestamp completedAt = "Done".equalsIgnoreCase(status)
                ? new Timestamp(System.currentTimeMillis())
                : null;
        String sql = "UPDATE Tasks SET status=?,completed_at=?,updated_at=GETDATE() WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            if (completedAt != null) {
                ps.setTimestamp(2, completedAt);
            } else {
                ps.setNull(2, Types.TIMESTAMP);
            }
            ps.setInt(3, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. UPDATE PROGRESS (0-100) – auto-derives status
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress) {
        if (progress < 0 || progress > 100) {
            return false;
        }
        String newStatus = progress >= 100 ? "Done" : (progress > 0 ? "In Progress" : "Pending");
        Timestamp completedAt = progress >= 100 ? new Timestamp(System.currentTimeMillis()) : null;
        String sql = "UPDATE Tasks SET progress=?,status=?,completed_at=?,updated_at=GETDATE() WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, progress);
            ps.setString(2, newStatus);
            if (completedAt != null) {
                ps.setTimestamp(3, completedAt);
            } else {
                ps.setNull(3, Types.TIMESTAMP);
            }
            ps.setInt(4, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. GET ALL TASKS
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
                + "r.role_id, r.role_name "
                + "FROM Tasks t "
                + "LEFT JOIN Users u ON t.created_by=u.user_id "
                + "LEFT JOIN Roles r ON u.role_id=r.role_id "
                + "ORDER BY t.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Task task = mapRow(rs);
                task.setassignees(loadAssignees(task.getTaskId()));
                list.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. GET ALL TASKS – PAGED + FILTERED
    //    Supports: title, description, status, priority, fromDate, toDate, assigneeUserId
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(String title, String description, String status, String priority,
            String fromDate, String toDate,
            Integer assigneeUserId,
            String sortField, String sortDir,
            int page, int pageSize) {

        List<Task> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT t.*, "
                + "u.user_id AS u_id, u.full_name, u.email, u.username, "
                + "r.role_id, r.role_name "
                + "FROM Tasks t "
                + "LEFT JOIN Users u ON t.created_by = u.user_id "
                + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                + "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        // filter cơ bản
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
            sql.append("AND t.start_date >= ? ");
            params.add(fromDate.trim() + " 00:00:00");
        }

        if (toDate != null && !toDate.isBlank()) {
            sql.append("AND t.start_date <= ? ");
            params.add(toDate.trim() + " 23:59:59");
        }

        // filter assignee (tránh duplicate)
        if (assigneeUserId != null && assigneeUserId > 0) {
            sql.append(
                    "AND EXISTS ( "
                    + "SELECT 1 FROM Task_Assignees ta "
                    + "WHERE ta.task_id = t.task_id AND ta.user_id = ? ) "
            );
            params.add(assigneeUserId);
        }

        // sorting
        sql.append("ORDER BY ");

        if ("dueDate".equals(sortField)) {
            sql.append("t.due_date ");
        } else if ("startDate".equals(sortField)) {
            sql.append("t.start_date ");
        } else if ("priority".equals(sortField)) {
            sql.append("CASE t.priority ")
                    .append("WHEN 'High' THEN 1 ")
                    .append("WHEN 'Medium' THEN 2 ")
                    .append("WHEN 'Low' THEN 3 ")
                    .append("END ");
        } else if ("progress".equals(sortField)) {
            sql.append("t.progress ");
        } else {
            sql.append("t.created_at ");
        }

        sql.append("DESC".equalsIgnoreCase(sortDir) ? "DESC " : "ASC ");

        // pagination
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setassignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countTasksFiltered(String title, String description, String status, String priority,
            String fromDate, String toDate, Integer assigneeUserId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT t.task_id) FROM Tasks t "
                + "LEFT JOIN Task_Assignees ta ON t.task_id=ta.task_id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, title, description, status, priority, fromDate, toDate, assigneeUserId);
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void appendFilters(StringBuilder sql, List<Object> params,
            String title, String description, String status, String priority,
            String fromDate, String toDate, Integer assigneeUserId) {
        if (title != null && !title.isBlank()) {
            sql.append("AND t.title LIKE ? ");
            params.add("%" + title.trim() + "%");
        }
        if (description != null && !description.isBlank()) {
            sql.append("AND t.description LIKE ? ");
            params.add("%" + description.trim() + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND t.status=? ");
            params.add(status.trim());
        }
        if (priority != null && !priority.isBlank()) {
            sql.append("AND t.priority=? ");
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
            sql.append("AND ta.user_id=? ");
            params.add(assigneeUserId);
        }
    }

//    private String resolveSortCol(String sortField) {
//        if ("dueDate".equals(sortField)) {
//            return "t.due_date";
//        }
//        if ("priority".equals(sortField)) {
//            return "CASE t.priority WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 END";
//        }
//        if ("progress".equals(sortField)) {
//            return "t.progress";
//        }
//        return "t.created_at";
//    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. GET TASK BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Task getTaskById(int id) {
        String sql = "SELECT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
                + "r.role_id, r.role_name "
                + "FROM Tasks t "
                + "LEFT JOIN Users u ON t.created_by=u.user_id "
                + "LEFT JOIN Roles r ON u.role_id=r.role_id "
                + "WHERE t.task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Task task = mapRow(rs);
                    task.setassignees(loadAssignees(id));
                    return task;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. FIND TASKS WHERE USER IS ASSIGNEE
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> findByAssignee(int userId) {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
                + "r.role_id, r.role_name "
                + "FROM Tasks t "
                + "JOIN Task_Assignees ta ON t.task_id=ta.task_id AND ta.user_id=? "
                + "LEFT JOIN Users u ON t.created_by=u.user_id "
                + "LEFT JOIN Roles r ON u.role_id=r.role_id "
                + "ORDER BY t.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task task = mapRow(rs);
                    task.setassignees(loadAssignees(task.getTaskId()));
                    list.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. ADD / REMOVE ASSIGNEE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean addAssignee(int taskId, int userId) {
        String sql = "IF NOT EXISTS (SELECT 1 FROM Task_Assignees WHERE task_id=? AND user_id=?) "
                + "INSERT INTO Task_Assignees (task_id,user_id,assigned_at) VALUES (?,?,GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            ps.setInt(3, taskId);
            ps.setInt(4, userId);
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
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10. DELETE TASK
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteTask(int taskId) {
        try {
            for (String s : new String[]{
                "DELETE FROM Task_Assignees WHERE task_id=?",
                "DELETE FROM Task_History_Detail WHERE history_id IN (SELECT history_id FROM Task_History WHERE task_id=?)",
                "DELETE FROM Task_History WHERE task_id=?",
                "DELETE FROM Tasks WHERE task_id=?"}) {
                try (PreparedStatement ps = connection.prepareStatement(s)) {
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
    // 11. TASK HISTORY – insert header row, return generated history_id
    // ─────────────────────────────────────────────────────────────────────────
    public int insertTaskHistory(int taskId, int changedBy) {
        String sql = "INSERT INTO Task_History (task_id, changed_by, changed_at) VALUES (?,?,GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, taskId);
            ps.setInt(2, changedBy);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12. TASK HISTORY DETAIL – one row per changed field
    // ─────────────────────────────────────────────────────────────────────────
    public boolean insertTaskHistoryDetail(int historyId, String fieldName, String oldValue, String newValue) {
        String sql = "INSERT INTO Task_History_Detail (history_id, field_name, old_value, new_value) "
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
    // 13. LIST TASK HISTORY BY TASK ID
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskHistory> listTaskHistoryByID(int id) {
        List<TaskHistory> list = new ArrayList<>();
        String sql = "SELECT th.history_id, th.task_id, th.changed_by, th.changed_at, "
                + "u.full_name AS changer_name "
                + "FROM Task_History th "
                + "LEFT JOIN Users u ON th.changed_by=u.user_id "
                + "WHERE th.task_id=? ORDER BY th.changed_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TaskHistory th = new TaskHistory();
                    th.setHistoryId(rs.getInt("history_id"));
                    th.setTaskId(rs.getInt("task_id"));
                    th.setChangedBy(rs.getInt("changed_by"));
                    Timestamp cat = rs.getTimestamp("changed_at");
                    if (cat != null) {
                        th.setChangedAt(cat.toLocalDateTime());
                    }
                    list.add(th);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 14. LIST TASK HISTORY DETAILS BY HISTORY ID
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskHistoryDetail> listTaskHistoryDetailsByID(int id) {
        List<TaskHistoryDetail> list = new ArrayList<>();
        String sql = "SELECT detail_id,history_id,field_name,old_value,new_value "
                + "FROM Task_History_Detail WHERE history_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
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
    private Task mapRow(ResultSet rs) throws SQLException {
        Task t = new Task();
        t.setTaskId(rs.getInt("task_id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setStatus(rs.getString("status"));
        t.setPriority(rs.getString("priority"));
        t.setProgress(rs.getInt("progress"));
        Timestamp due = rs.getTimestamp("due_date");
        if (due != null) {
            t.setDueDate(due.toLocalDateTime());
        }
        Timestamp start = rs.getTimestamp("start_date");
        if (start != null) {
            t.setStartDate(start.toLocalDateTime());
        }
        Timestamp completed = rs.getTimestamp("completed_at");
        if (completed != null) {
            t.setCompletedAt(completed.toLocalDateTime());
        }
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) {
            t.setCreatedAt(cat.toLocalDateTime());
        }
        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) {
            t.setUpdatedAt(uat.toLocalDateTime());
        }
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
        String sql = "SELECT ta.task_id, ta.assigned_at, u.user_id, u.full_name, u.email, u.username, "
                + "r.role_id, r.role_name "
                + "FROM Task_Assignees ta "
                + "JOIN Users u ON ta.user_id=u.user_id "
                + "LEFT JOIN Roles r ON u.role_id=r.role_id "
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
                    if (at != null) {
                        ta.setAssignedAt(at.toLocalDateTime());
                    }
                    list.add(ta);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
