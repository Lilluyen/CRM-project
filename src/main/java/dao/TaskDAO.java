package dao;

import model.Task;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {

    private Connection connection;

    public TaskDAO(Connection connection) {
        this.connection = connection;
    }

    // =============================
    // 1. Create Task
    // =============================
    public boolean createTask(Task task) {
        String sql = "INSERT INTO Tasks (title, description, related_type, related_id, assigned_to, priority, status, due_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, task.getTitle());
            ps.setString(2, task.getDescription());
            ps.setString(3, task.getRelatedType());
            ps.setInt(4, task.getRelatedId());
            ps.setInt(5, task.getAssignedTo());
            ps.setString(6, task.getPriority());
            ps.setString(7, task.getStatus());
            ps.setDate(8, Date.valueOf(task.getDueDate()));

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 2. Update Task
    // =============================
    public boolean updateTask(Task task) {
        String sql = "UPDATE Tasks SET title=?, description=?, related_type=?, related_id=?, priority=?, status=?, due_date=? "
                   + "WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, task.getTitle());
            ps.setString(2, task.getDescription());
            ps.setString(3, task.getRelatedType());
            ps.setInt(4, task.getRelatedId());
            ps.setString(5, task.getPriority());
            ps.setString(6, task.getStatus());
            ps.setDate(7, Date.valueOf(task.getDueDate()));
            ps.setInt(8, task.getTaskId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 3. View Task List
    // =============================
    public List<Task> getAllTasks() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT * FROM Tasks";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSet(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =============================
    // 4. View Task Details
    // =============================
    public Task getTaskById(int id) {
        String sql = "SELECT * FROM Tasks WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSet(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // =============================
    // 5. Assign Task
    // =============================
    public boolean assignTask(int taskId, int userId) {
        String sql = "UPDATE Tasks SET assigned_to=?, status='ASSIGNED' WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, taskId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 6. Track Task Progress (Update Status)
    // =============================
    public boolean updateTaskStatus(int taskId, String status) {
        String sql = "UPDATE Tasks SET status=? WHERE task_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, taskId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 7. Announce Assigned Task (Insert Notification)
    // =============================
    public boolean announceAssignedTask(int userId, String title, String content) {
        String sql = "INSERT INTO Notifications (user_id, title, content, type) VALUES (?, ?, ?, 'TASK')";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, content);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // Map ResultSet
    // =============================
    private Task mapResultSet(ResultSet rs) throws SQLException {
        Task task = new Task();

        task.setTaskId(rs.getInt("task_id"));
        task.setTitle(rs.getString("title"));
        task.setDescription(rs.getString("description"));
        task.setRelatedType(rs.getString("related_type"));
        task.setRelatedId(rs.getInt("related_id"));
        task.setAssignedTo(rs.getInt("assigned_to"));
        task.setPriority(rs.getString("priority"));
        task.setStatus(rs.getString("status"));

        Date dueDate = rs.getDate("due_date");
        if (dueDate != null) {
            task.setDueDate(dueDate.toLocalDate());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            task.setCreatedAt(createdAt.toLocalDateTime());
        }

        return task;
    }
}