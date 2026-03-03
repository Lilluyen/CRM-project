package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.UserOTP;
import util.DBContext;

public class UserOtpDAO {

    // =========================
    // 1. Insert OTP (nếu chưa tồn tại)
    // =========================
    public boolean insertOTP(UserOTP otp) throws SQLException {

        String sql = """
                INSERT INTO UserOTP
                (user_id, otp_hash, otp_expired_at, failed_attempt, send_count, last_send)
                VALUES (?, ?, ?, ?, ?, ?)
                """;

        try (PreparedStatement stmt = DBContext.getConnection().prepareStatement(sql)) {

            stmt.setInt(1, otp.getUserId());
            stmt.setString(2, otp.getOtpHash());
            stmt.setTimestamp(3, java.sql.Timestamp.valueOf(otp.getOtpExpiredAt()));
            stmt.setInt(4, otp.getFailedAttempt());
            stmt.setInt(5, otp.getSendCount());
            stmt.setTimestamp(6, java.sql.Timestamp.valueOf(otp.getLastSend()));

            return stmt.executeUpdate() > 0;
        }
    }

    // =========================
    // 2. Update OTP (khi gửi lại OTP mới)
    // =========================
    public boolean updateOTP(UserOTP otp) throws SQLException {

        String sql = """
                UPDATE UserOTP
                SET otp_hash = ?,
                    otp_expired_at = ?,
                    failed_attempt = ?,
                    send_count = ?,
                    last_send = ?
                WHERE user_id = ?
                """;

        try (PreparedStatement stmt = DBContext.getConnection().prepareStatement(sql)) {

            stmt.setString(1, otp.getOtpHash());
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(otp.getOtpExpiredAt()));
            stmt.setInt(3, otp.getFailedAttempt());
            stmt.setInt(4, otp.getSendCount());
            stmt.setTimestamp(5, java.sql.Timestamp.valueOf(otp.getLastSend()));
            stmt.setInt(6, otp.getUserId());

            return stmt.executeUpdate() > 0;
        }
    }

    // =========================
    // 3. Get OTP by userId
    // =========================
    public UserOTP getByUserId(int userId) throws SQLException {

        String sql = """
                SELECT *
                FROM UserOTP
                WHERE user_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOTP(rs);
                }
            }
        }

        return null;
    }

    // =========================
    // 4. Increase failed attempt
    // =========================
    public boolean increaseFailedAttempt(int userId) throws SQLException {

        String sql = """
                UPDATE UserOTP
                SET failed_attempt = failed_attempt + 1
                WHERE user_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // 5. Reset failed attempt (khi nhập đúng OTP)
    // =========================
    public boolean resetFailedAttempt(int userId) throws SQLException {

        String sql = """
                UPDATE UserOTP
                SET failed_attempt = 0
                WHERE user_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // 6. Delete OTP
    // =========================
    public boolean deleteByUserId(int userId) throws SQLException {

        String sql = "DELETE FROM UserOTP WHERE user_id = ?";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // Find OTP by userId (alias)
    // =========================
    public UserOTP findByUserId(int userId) throws SQLException {
        return getByUserId(userId);
    }

    // =========================
    // Update failed attempt theo object
    // =========================
    public boolean updateFailedAttempt(UserOTP otp) throws SQLException {

        String sql = """
                UPDATE UserOTP
                SET failed_attempt = ?
                WHERE user_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, otp.getFailedAttempt());
            ps.setInt(2, otp.getUserId());

            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // Helper method
    // =========================
    private UserOTP mapResultSetToOTP(ResultSet rs) throws SQLException {

        UserOTP otp = new UserOTP();

        otp.setUserId(rs.getInt("user_id"));
        otp.setOtpHash(rs.getString("otp_hash"));
        otp.setOtpExpiredAt(rs.getTimestamp("otp_expired_at").toLocalDateTime());
        otp.setFailedAttempt(rs.getInt("failed_attempt"));
        otp.setSendCount(rs.getInt("send_count"));

        if (rs.getTimestamp("last_send") != null) {
            otp.setLastSend(rs.getTimestamp("last_send").toLocalDateTime());
        }

        if (rs.getTimestamp("created_at") != null) {
            otp.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }

        return otp;
    }
}