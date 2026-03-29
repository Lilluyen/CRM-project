package dao;

import model.TaskComment;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for Task_Comments – doubles as the "Work Items" layer.
 *
 * Schema (after migration):
 * comment_id PK
 * task_id FK → Tasks
 * user_id FK → Users (creator / tagger)
 * content NVARCHAR(MAX)
 * parent_comment_id FK → Task_Comments (nullable – tree parent)
 * assigned_to FK → Users (supporter being tagged)
 * is_completed BIT DEFAULT 0
 * completed_at DATETIME NULL
 * is_deleted BIT DEFAULT 0
 * created_at DATETIME
 * updated_at DATETIME NULL
 *
 * Progress rule:
 * progress = COUNT(is_completed=1 AND is_deleted=0)
 * / COUNT(is_deleted=0) * 100
 * (only root-level items where parent_comment_id IS NULL are counted
 * if you want 1-level; for full tree count include all levels)
 *
 * This implementation counts ALL non-deleted work items (any depth).
 */
public class TaskCommentDAO {

    private final Connection conn;

    public TaskCommentDAO(Connection conn) {
        this.conn = conn;
    }

    // ── SELECT: flat list with author + assignee names ────────────────────────

    /**
     * Load all non-deleted work items for a task, oldest-first.
     * Resolves author name and assigned-to name via JOINs (no N+1).
     */
    public List<TaskComment> findByTaskId(int taskId) throws SQLException {
        String sql = """
                SELECT tc.comment_id, tc.task_id, tc.created_by,
                       tc.content, tc.parent_comment_id,
                       tc.assigned_to, tc.is_completed, tc.completed_at,
                       tc.is_deleted, tc.created_at, tc.updated_at,
                       COALESCE(au.full_name, au.username) AS author_name,
                       COALESCE(su.full_name, su.username) AS assigned_name
                FROM   Task_Comments tc
                LEFT JOIN Users au ON tc.created_by    = au.user_id
                LEFT JOIN Users su ON tc.assigned_to = su.user_id
                WHERE  tc.task_id = ? AND tc.is_deleted = 0
                ORDER  BY tc.created_at ASC
                """;
        List<TaskComment> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(map(rs));
            }
        }
        return list;
    }

    /** Find single work item by PK (any deleted state). */
    public TaskComment findById(int commentId) throws SQLException {
        String sql = """
                SELECT tc.comment_id, tc.task_id, tc.created_by,
                       tc.content, tc.parent_comment_id,
                       tc.assigned_to, tc.is_completed, tc.completed_at,
                       tc.is_deleted, tc.created_at, tc.updated_at,
                       COALESCE(au.full_name, au.username) AS author_name,
                       COALESCE(su.full_name, su.username) AS assigned_name
                FROM   Task_Comments tc
                LEFT JOIN Users au ON tc.created_by    = au.user_id
                LEFT JOIN Users su ON tc.assigned_to = su.user_id
                WHERE  tc.comment_id = ?
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    // ── INSERT ────────────────────────────────────────────────────────────────

    /**
     * Insert a new work item.
     * Sets commentId on the supplied object after successful insert.
     */
    public boolean insert(TaskComment c) throws SQLException {
        String sql = """
                INSERT INTO Task_Comments
                    (task_id, created_by, content, parent_comment_id,
                     assigned_to, is_completed, is_deleted, created_at)
                VALUES (?, ?, ?, ?, ?, 0, 0, ?)
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getTaskId());
            ps.setInt(2, c.getCreatedBy());
            ps.setString(3, c.getContent());
            if (c.getParentCommentId() != null)
                ps.setInt(4, c.getParentCommentId());
            else
                ps.setNull(4, Types.INTEGER);
            if (c.getAssignedTo() != null && c.getAssignedTo() > 0)
                ps.setInt(5, c.getAssignedTo());
            else
                ps.setNull(5, Types.INTEGER);
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));

            int rows = ps.executeUpdate();
            if (rows == 1) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next())
                        c.setCommentId(keys.getInt(1));
                }
            }
            return rows == 1;
        }
    }

    // ── MARK COMPLETE / INCOMPLETE ────────────────────────────────────────────

    /**
     * Toggle completion state of a work item.
     * Sets completed_at = NOW() when completing, NULL when un-completing.
     */
    public boolean setCompleted(int commentId, boolean completed) throws SQLException {
        String sql = """
                UPDATE Task_Comments
                SET    is_completed = ?,
                       completed_at = ?,
                       updated_at   = ?
                WHERE  comment_id = ? AND is_deleted = 0
                """;
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, completed ? 1 : 0);
            ps.setTimestamp(2, completed ? now : null);
            ps.setTimestamp(3, now);
            ps.setInt(4, commentId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── SOFT DELETE ───────────────────────────────────────────────────────────

    public boolean softDelete(int commentId) throws SQLException {
        String sql = """
                UPDATE Task_Comments
                SET    is_deleted = 1, updated_at = ?
                WHERE  comment_id = ? AND is_deleted = 0
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, commentId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Recursively soft-delete a work item AND all its descendants.
     * Performs a depth-first traversal: children are deleted before the parent.
     *
     * @param commentId root item to delete
     * @return true if the root item was successfully soft-deleted
     */
    public boolean softDeleteCascade(int commentId) throws SQLException {
        softDeleteDescendants(commentId);
        return softDelete(commentId);
    }

    /**
     * Recursively find and soft-delete all descendants of the given parent.
     */
    private void softDeleteDescendants(int parentId) throws SQLException {
        String sql = "SELECT comment_id FROM Task_Comments WHERE parent_comment_id = ? AND is_deleted = 0";
        List<Integer> childIds = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    childIds.add(rs.getInt(1));
            }
        }
        for (int childId : childIds) {
            softDeleteDescendants(childId); // depth-first
            softDelete(childId);
        }
    }

    // ── PROGRESS ─────────────────────────────────────────────────────────────

    /**
     * Count {total, completed} non-deleted work items for a task.
     * Used to compute task-level progress %.
     *
     * @return int[]{total, completed}
     */
    public int[] countProgress(int taskId) throws SQLException {
        String sql = """
                SELECT COUNT(*)                                       AS total,
                       SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) AS completed
                FROM   Task_Comments
                WHERE  task_id = ? AND is_deleted = 0
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return new int[] { rs.getInt("total"), rs.getInt("completed") };
            }
        }
        return new int[] { 0, 0 };
    }

    /**
     * Returns true when at least one non-deleted work item is not yet completed.
     * Used to block parent task completion.
     */
    public boolean hasIncompleteWorkItems(int taskId) throws SQLException {
        String sql = """
                SELECT COUNT(*)
                FROM   Task_Comments
                WHERE  task_id = ? AND is_deleted = 0 AND is_completed = 0
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // ── HELPER ────────────────────────────────────────────────────────────────

    private static TaskComment map(ResultSet rs) throws SQLException {
        TaskComment c = new TaskComment();
        c.setCommentId(rs.getInt("comment_id"));
        c.setTaskId(rs.getInt("task_id"));
        c.setCreatedBy(rs.getInt("created_by"));
        c.setContent(rs.getString("content"));

        int parent = rs.getInt("parent_comment_id");
        c.setParentCommentId(rs.wasNull() ? null : parent);

        int assignedTo = rs.getInt("assigned_to");
        c.setAssignedTo(rs.wasNull() ? null : assignedTo);

        c.setCompleted(rs.getBoolean("is_completed"));
        c.setDeleted(rs.getBoolean("is_deleted"));

        Timestamp completedAt = rs.getTimestamp("completed_at");
        if (completedAt != null)
            c.setCompletedAt(completedAt.toLocalDateTime());

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null)
            c.setCreatedAt(ca.toLocalDateTime());

        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null)
            c.setUpdatedAt(ua.toLocalDateTime());

        // Transient display fields from JOIN
        try {
            c.setAuthorName(rs.getString("author_name"));
        } catch (SQLException ignored) {
        }
        try {
            c.setAssignedName(rs.getString("assigned_name"));
        } catch (SQLException ignored) {
        }

        return c;
    }
}