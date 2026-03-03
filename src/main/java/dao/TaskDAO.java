package dao;

import model.Task;
import model.TaskAssignee;
import model.User;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TaskDAO – aligned with the actual CRM_System schema:
 *
 * Tasks          : task_id, title, description, status, priority,
 *                  due_date, progress, created_by, created_at, updated_at
 * Task_Assignees : task_id, user_id, assigned_at
 * Users          : user_id, username, full_name, email, role_id …
 * Roles          : role_id, role_name …
 *
 * Key design decisions
 * ─────────────────────
 * • getAllTasks / getTaskById fetch Tasks + creator (LEFT JOIN Users+Roles)
 * • assignees are loaded separately via loadAssignees() to keep queries simple.
 * • createTask / updateTask operate only on the Tasks row.
 * • addAssignee / removeAssignee manage Task_Assignees.
 * • announceTask inserts into Notifications + Notification_Recipients (two-table
 *   schema used in CRM_System).
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
        if (task == null || task.getTitle() == null || task.getTitle().isBlank()) return false;

        String sql = "INSERT INTO Tasks (title, description, status, priority, due_date, progress, created_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, task.getTitle().trim());
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus()   != null ? task.getStatus()   : "Pending");
            ps.setString(4, task.getPriority() != null ? task.getPriority() : "Medium");
            if (task.getDueDate() != null)
                ps.setTimestamp(5, Timestamp.valueOf(task.getDueDate()));
            else
                ps.setNull(5, Types.TIMESTAMP);
            ps.setInt(6, task.getProgress() != null ? task.getProgress() : 0);
            ps.setInt(7, task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0);

            int rows = ps.executeUpdate();
            if (rows > 0) {
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
    // 2. UPDATE TASK
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateTask(Task task) {
        if (task == null || task.getTaskId() == null || task.getTaskId() <= 0) return false;

        String sql = "UPDATE Tasks SET title=?, description=?, status=?, priority=?, "
                   + "due_date=?, progress=?, updated_at=GETDATE() WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, task.getTitle()       != null ? task.getTitle().trim()       : "");
            ps.setString(2, task.getDescription() != null ? task.getDescription().trim() : "");
            ps.setString(3, task.getStatus()      != null ? task.getStatus()             : "Pending");
            ps.setString(4, task.getPriority()    != null ? task.getPriority()           : "Medium");
            if (task.getDueDate() != null)
                ps.setTimestamp(5, Timestamp.valueOf(task.getDueDate()));
            else
                ps.setNull(5, Types.TIMESTAMP);
            ps.setInt(6, task.getProgress() != null ? task.getProgress() : 0);
            ps.setInt(7, task.getTaskId());

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
        String sql = "UPDATE Tasks SET status=?, updated_at=GETDATE() WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. UPDATE PROGRESS (0-100)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateProgress(int taskId, int progress) {
        if (progress < 0 || progress > 100) return false;
        String newStatus = progress >= 100 ? "Done" : (progress > 0 ? "In Progress" : "Pending");
        String sql = "UPDATE Tasks SET progress=?, status=?, updated_at=GETDATE() WHERE task_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, progress);
            ps.setString(2, newStatus);
            ps.setInt(3, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. GET ALL TASKS (with creator info via JOIN)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
                   + "       r.role_id, r.role_name "
                   + "FROM Tasks t "
                   + "LEFT JOIN Users u ON t.created_by = u.user_id "
                   + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                   + "ORDER BY t.created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
    //    Supports: title, status, priority, assigneeUserId
    // ─────────────────────────────────────────────────────────────────────────
    public List<Task> getTasksPaged(String title, String status, String priority,
                                    Integer assigneeUserId,
                                    String sortField, String sortDir,
                                    int page, int pageSize) {
        List<Task> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
          + "r.role_id, r.role_name "
          + "FROM Tasks t "
          + "LEFT JOIN Users u  ON t.created_by  = u.user_id "
          + "LEFT JOIN Roles r  ON u.role_id      = r.role_id "
          + "LEFT JOIN Task_Assignees ta ON t.task_id = ta.task_id "
          + "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (title != null && !title.isBlank()) {
            sql.append("AND t.title LIKE ? ");
            params.add("%" + title.trim() + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND t.status = ? ");
            params.add(status.trim());
        }
        if (priority != null && !priority.isBlank()) {
            sql.append("AND t.priority = ? ");
            params.add(priority.trim());
        }
        if (assigneeUserId != null && assigneeUserId > 0) {
            sql.append("AND ta.user_id = ? ");
            params.add(assigneeUserId);
        }

        // Sort
        String safe = "t.created_at";
        if ("dueDate".equals(sortField))   safe = "t.due_date";
        else if ("priority".equals(sortField)) safe = "t.priority";
        else if ("status".equals(sortField))   safe = "t.status";
        else if ("progress".equals(sortField)) safe = "t.progress";
        String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
        sql.append("ORDER BY ").append(safe).append(" ").append(dir).append(" ");

        int offset = (page - 1) * pageSize;
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
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

    public int countTasksFiltered(String title, String status, String priority, Integer assigneeUserId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT t.task_id) "
          + "FROM Tasks t "
          + "LEFT JOIN Task_Assignees ta ON t.task_id = ta.task_id "
          + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (title != null && !title.isBlank()) {
            sql.append("AND t.title LIKE ? "); params.add("%" + title.trim() + "%");
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND t.status = ? "); params.add(status.trim());
        }
        if (priority != null && !priority.isBlank()) {
            sql.append("AND t.priority = ? "); params.add(priority.trim());
        }
        if (assigneeUserId != null && assigneeUserId > 0) {
            sql.append("AND ta.user_id = ? "); params.add(assigneeUserId);
        }
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
    // 7. GET TASK BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Task getTaskById(int id) {
        String sql = "SELECT t.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
                   + "       r.role_id, r.role_name "
                   + "FROM Tasks t "
                   + "LEFT JOIN Users u ON t.created_by = u.user_id "
                   + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                   + "WHERE t.task_id = ?";
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
                   + "       r.role_id, r.role_name "
                   + "FROM Tasks t "
                   + "JOIN Task_Assignees ta ON t.task_id = ta.task_id AND ta.user_id = ? "
                   + "LEFT JOIN Users u ON t.created_by = u.user_id "
                   + "LEFT JOIN Roles r ON u.role_id = r.role_id "
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
                   + "INSERT INTO Task_Assignees (task_id, user_id) VALUES (?, ?)";
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
    // 10. DELETE TASK
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteTask(int taskId) {
        try {
            // remove assignees first (FK)
            try (PreparedStatement ps = connection.prepareStatement(
                    "DELETE FROM Task_Assignees WHERE task_id=?")) {
                ps.setInt(1, taskId); ps.executeUpdate();
            }
            try (PreparedStatement ps = connection.prepareStatement(
                    "DELETE FROM Task_History WHERE task_id=?")) {
                ps.setInt(1, taskId); ps.executeUpdate();
            }
            try (PreparedStatement ps = connection.prepareStatement(
                    "DELETE FROM Tasks WHERE task_id=?")) {
                ps.setInt(1, taskId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11. ANNOUNCE: insert Notification + Recipient row
    // ─────────────────────────────────────────────────────────────────────────
    public boolean announceAssignedTask(int userId, String title, String content) {
        String sqlNotif = "INSERT INTO Notifications (title, content, type, related_type) "
                        + "VALUES (?, ?, 'TASK', 'Task')";
        String sqlRecip = "INSERT INTO Notification_Recipients (notification_id, user_id) VALUES (?, ?)";
        try {
            int notifId;
            try (PreparedStatement ps = connection.prepareStatement(sqlNotif,
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, title);
                ps.setString(2, content);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) return false;
                    notifId = keys.getInt(1);
                }
            }
            try (PreparedStatement ps = connection.prepareStatement(sqlRecip)) {
                ps.setInt(1, notifId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
        if (due != null) t.setDueDate(due.toLocalDateTime());

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) t.setCreatedAt(cat.toLocalDateTime());

        Timestamp uat = rs.getTimestamp("updated_at");
        if (uat != null) t.setUpdatedAt(uat.toLocalDateTime());

        // creator
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
        String sql = "SELECT ta.task_id, ta.assigned_at, "
                   + "       u.user_id, u.full_name, u.email, u.username, "
                   + "       r.role_id, r.role_name "
                   + "FROM Task_Assignees ta "
                   + "JOIN Users u ON ta.user_id = u.user_id "
                   + "LEFT JOIN Roles r ON u.role_id = r.role_id "
                   + "WHERE ta.task_id = ?";
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
