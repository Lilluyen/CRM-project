package dao;

import model.CustomerMergeRequest;
import model.CustomerMergeRequest.Status;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MergeRequestDAO {

    // ── Insert ────────────────────────────────────────────────────────────
    public int insert(Connection conn, CustomerMergeRequest req) throws SQLException {
        String sql = """
                INSERT INTO customer_merge_request
                    (source_id, target_id, status, field_overrides, reason, created_by)
                VALUES (?, ?, ?, ?, ?, ?)
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, req.getSourceId());
            ps.setInt(2, req.getTargetId());
            ps.setString(3, Status.PENDING.name());
            ps.setString(4, req.getFieldOverrides());
            ps.setString(5, req.getReason());
            ps.setInt(6, req.getCreatedBy());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Insert merge request failed — no generated key");
    }

    // ── Find by ID ────────────────────────────────────────────────────────
    public CustomerMergeRequest findById(Connection conn, int id) throws SQLException {
        String sql = """
                SELECT id, source_id, target_id, status, field_overrides,
                       reason, reject_reason, created_by, reviewed_by,
                       created_at, reviewed_at
                FROM customer_merge_request
                WHERE id = ?
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // ── Tất cả PENDING — dành cho manager ─────────────────────────────────
    public List<CustomerMergeRequest> findPending(Connection conn) throws SQLException {
        String sql = """
                SELECT id, source_id, target_id, status, field_overrides,
                       reason, reject_reason, created_by, reviewed_by,
                       created_at, reviewed_at
                FROM customer_merge_request
                WHERE status = 'PENDING'
                ORDER BY created_at DESC
                """;
        return query(conn, sql);
    }

    // ── Requests của 1 user (người tạo) ───────────────────────────────────
    public List<CustomerMergeRequest> findByCreator(Connection conn, int userId)
            throws SQLException {
        String sql = """
                SELECT id, source_id, target_id, status, field_overrides,
                       reason, reject_reason, created_by, reviewed_by,
                       created_at, reviewed_at
                FROM customer_merge_request
                WHERE created_by = ?
                ORDER BY created_at DESC
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return mapAll(ps.executeQuery());
        }
    }

    // ── Requests liên quan đến 1 customer (source hoặc target) ────────────
    public List<CustomerMergeRequest> findByCustomerId(Connection conn, int customerId)
            throws SQLException {
        String sql = """
                SELECT id, source_id, target_id, status, field_overrides,
                       reason, reject_reason, created_by, reviewed_by,
                       created_at, reviewed_at
                FROM customer_merge_request
                WHERE source_id = ? OR target_id = ?
                ORDER BY created_at DESC
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            return mapAll(ps.executeQuery());
        }
    }

    // ── Kiểm tra đã có request PENDING giữa 2 customer chưa ───────────────
    public boolean existsPending(Connection conn, int sourceId, int targetId)
            throws SQLException {
        String sql = """
                SELECT 1 FROM customer_merge_request
                WHERE status = 'PENDING'
                  AND ((source_id = ? AND target_id = ?)
                    OR (source_id = ? AND target_id = ?))
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sourceId);
            ps.setInt(2, targetId);
            ps.setInt(3, targetId);
            ps.setInt(4, sourceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Approve ───────────────────────────────────────────────────────────
    public void approve(Connection conn, int requestId, int reviewerId)
            throws SQLException {
        String sql = """
                UPDATE customer_merge_request
                SET status = 'APPROVED',
                    reviewed_by = ?,
                    reviewed_at = GETDATE()
                WHERE id = ? AND status = 'PENDING'
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerId);
            ps.setInt(2, requestId);
            ps.executeUpdate();
        }
    }

    // ── Reject ────────────────────────────────────────────────────────────
    public void reject(Connection conn, int requestId, int reviewerId, String rejectReason)
            throws SQLException {
        String sql = """
                UPDATE customer_merge_request
                SET status = 'REJECTED',
                    reviewed_by = ?,
                    reject_reason = ?,
                    reviewed_at = GETDATE()
                WHERE id = ? AND status = 'PENDING'
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerId);
            ps.setString(2, rejectReason);
            ps.setInt(3, requestId);
            ps.executeUpdate();
        }
    }

    // ── Đánh dấu MERGED sau khi execute xong ──────────────────────────────
    public void markMerged(Connection conn, int requestId) throws SQLException {
        String sql = """
                UPDATE customer_merge_request
                SET status = 'MERGED'
                WHERE id = ?
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.executeUpdate();
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private List<CustomerMergeRequest> query(Connection conn, String sql)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            return mapAll(ps.executeQuery());
        }
    }

    private List<CustomerMergeRequest> mapAll(ResultSet rs) throws SQLException {
        List<CustomerMergeRequest> list = new ArrayList<>();
        while (rs.next()) list.add(map(rs));
        return list;
    }

    private CustomerMergeRequest map(ResultSet rs) throws SQLException {
        CustomerMergeRequest r = new CustomerMergeRequest();
        r.setId(rs.getInt("id"));
        r.setSourceId(rs.getInt("source_id"));
        r.setTargetId(rs.getInt("target_id"));
        r.setStatus(Status.valueOf(rs.getString("status")));
        r.setFieldOverrides(rs.getString("field_overrides"));
        r.setReason(rs.getString("reason"));
        r.setRejectReason(rs.getString("reject_reason"));
        r.setCreatedBy(rs.getInt("created_by"));

        int reviewedBy = rs.getInt("reviewed_by");
        if (!rs.wasNull()) r.setReviewedBy(reviewedBy);

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) r.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp reviewedAt = rs.getTimestamp("reviewed_at");
        if (reviewedAt != null) r.setReviewedAt(reviewedAt.toLocalDateTime());

        return r;
    }
}