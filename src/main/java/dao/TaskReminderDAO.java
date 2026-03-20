package dao;

import model.TaskReminder;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TaskReminderDAO – CRUD for [dbo].[Task_Reminders] table.
 *
 * Supports Reminder Notification scenario:
 *   - Create reminders relative to task deadline
 *   - Scheduler polls unsent reminders (remind_at <= now)
 *   - Mark as sent after notification delivery
 */
public class TaskReminderDAO {

    private final Connection connection;

    public TaskReminderDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. INSERT
    // ─────────────────────────────────────────────────────────────────────────
    public int insert(TaskReminder r) throws SQLException {
        String sql =
            "INSERT INTO Task_Reminders "
          + "(task_id, remind_before_value, remind_before_unit, remind_at, created_by) "
          + "VALUES (?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, r.getTaskId());
            ps.setInt(2, r.getRemindBeforeValue());
            ps.setString(3, r.getRemindBeforeUnit() != null ? r.getRemindBeforeUnit() : "day");
            ps.setTimestamp(4, Timestamp.valueOf(r.getRemindAt()));
            ps.setObject(5, r.getCreatedBy(), Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    r.setReminderId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. FIND DUE REMINDERS (scheduler: is_sent=0 AND remind_at <= now)
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskReminder> findDueReminders(int batchSize) throws SQLException {
        List<TaskReminder> list = new ArrayList<>();
        String sql =
            "SELECT TOP (?) r.* "
          + "FROM Task_Reminders r "
          + "WHERE r.is_sent = 0 AND r.remind_at <= GETDATE() "
          + "ORDER BY r.remind_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, batchSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. MARK AS SENT
    // ─────────────────────────────────────────────────────────────────────────
    public boolean markSent(int reminderId) throws SQLException {
        String sql =
            "UPDATE Task_Reminders SET is_sent = 1, sent_at = GETDATE() "
          + "WHERE reminder_id = ? AND is_sent = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reminderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. FIND BY TASK
    // ─────────────────────────────────────────────────────────────────────────
    public List<TaskReminder> findByTaskId(int taskId) throws SQLException {
        List<TaskReminder> list = new ArrayList<>();
        String sql =
            "SELECT * FROM Task_Reminders WHERE task_id = ? ORDER BY remind_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. DELETE BY TASK (cascade when task is deleted)
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteByTaskId(int taskId) throws SQLException {
        String sql = "DELETE FROM Task_Reminders WHERE task_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. DELETE SINGLE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean delete(int reminderId) throws SQLException {
        String sql = "DELETE FROM Task_Reminders WHERE reminder_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reminderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPER
    // ─────────────────────────────────────────────────────────────────────────
    private TaskReminder mapRow(ResultSet rs) throws SQLException {
        TaskReminder r = new TaskReminder();
        r.setReminderId(rs.getInt("reminder_id"));
        r.setTaskId(rs.getInt("task_id"));
        r.setRemindBeforeValue(rs.getInt("remind_before_value"));
        r.setRemindBeforeUnit(rs.getString("remind_before_unit"));

        Timestamp ra = rs.getTimestamp("remind_at");
        if (ra != null) r.setRemindAt(ra.toLocalDateTime());

        r.setSent(rs.getBoolean("is_sent"));

        Timestamp sa = rs.getTimestamp("sent_at");
        if (sa != null) r.setSentAt(sa.toLocalDateTime());

        int cb = rs.getInt("created_by");
        r.setCreatedBy(rs.wasNull() ? null : cb);

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) r.setCreatedAt(ca.toLocalDateTime());

        return r;
    }
}
