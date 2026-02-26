package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.CustomerOtp;
import util.DBContext;

public class CustomerOtpDAO {

    // =========================
    // 1. Insert OTP (nếu chưa tồn tại)
    // =========================
    public boolean insertOTP(CustomerOtp otp) throws SQLException {

        String sql = """
                INSERT INTO CustomerOTP
                (customer_id, otp_hash, otp_expired_at, failed_attempt, send_count, last_send)
                VALUES (?, ?, ?, ?, ?, ?)
                """;

        try (PreparedStatement stmt = DBContext.getConnection().prepareStatement(sql)) {

            stmt.setInt(1, otp.getCustomerId());
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
    public boolean updateOTP(CustomerOtp otp) throws SQLException {

        String sql = """
                UPDATE CustomerOTP
                SET otp_hash = ?,
                    otp_expired_at = ?,
                    failed_attempt = ?,
                    send_count = ?,
                    last_send = ?
                WHERE customer_id = ?
                """;

        try (PreparedStatement stmt = DBContext.getConnection().prepareStatement(sql)) {

            stmt.setString(1, otp.getOtpHash());
            stmt.setTimestamp(2, java.sql.Timestamp.valueOf(otp.getOtpExpiredAt()));
            stmt.setInt(3, otp.getFailedAttempt());
            stmt.setInt(4, otp.getSendCount());
            stmt.setTimestamp(5, java.sql.Timestamp.valueOf(otp.getLastSend()));
            stmt.setInt(6, otp.getCustomerId());

            return stmt.executeUpdate() > 0;
        }
    }

    // =========================
    // 3. Get OTP by customerId
    // =========================
    public CustomerOtp getByCustomerId(int customerId) throws SQLException {

        String sql = """
                SELECT *
                FROM CustomerOTP
                WHERE customer_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);

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
    public boolean increaseFailedAttempt(int customerId) throws SQLException {

        String sql = """
                UPDATE CustomerOTP
                SET failed_attempt = failed_attempt + 1
                WHERE customer_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // 5. Reset failed attempt (khi nhập đúng OTP)
    // =========================
    public boolean resetFailedAttempt(int customerId) throws SQLException {

        String sql = """
                UPDATE CustomerOTP
                SET failed_attempt = 0
                WHERE customer_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // 6. Delete OTP (optional)
    // =========================
    public boolean deleteByCustomerId(int customerId) throws SQLException {

        String sql = "DELETE FROM CustomerOTP WHERE customer_id = ?";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // Find OTP by customerId
    // =========================
    public CustomerOtp findByCustomerId(int customerId) throws SQLException {

        String sql = """
                SELECT *
                FROM CustomerOTP
                WHERE customer_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOTP(rs);
                }
            }
        }

        return null;
    }

    // =========================
    // Update failed attempt theo object
    // =========================
    public boolean updateFailedAttempt(CustomerOtp otp) throws SQLException {

        String sql = """
                UPDATE CustomerOTP
                SET failed_attempt = ?
                WHERE customer_id = ?
                """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, otp.getFailedAttempt());
            ps.setInt(2, otp.getCustomerId());

            return ps.executeUpdate() > 0;
        }
    }

    // =========================
    // Helper method
    // =========================
    private CustomerOtp mapResultSetToOTP(ResultSet rs) throws SQLException {

        CustomerOtp otp = new CustomerOtp();

        otp.setCustomerId(rs.getInt("customer_id"));
        otp.setOtpHash(rs.getString("otp_hash"));
        otp.setOtpExpiredAt(rs.getTimestamp("otp_expired_at").toLocalDateTime());
        otp.setFailedAttempt(rs.getInt("failed_attempt"));
        otp.setSendCount(rs.getInt("send_count"));

        if (rs.getTimestamp("last_send") != null) {
            otp.setLastSend(rs.getTimestamp("last_send").toLocalDateTime());
        }

        return otp;
    }

}