package model;

import java.time.LocalDateTime;

public class UserOTP {

    private int userId;
    private String otpHash;
    private LocalDateTime otpExpiredAt;
    private int failedAttempt;
    private int sendCount;
    private LocalDateTime lastSend;
    private LocalDateTime createdAt;

    public UserOTP() {
    }

    public UserOTP(int userId, String otpHash, LocalDateTime otpExpiredAt,
                   int failedAttempt, int sendCount,
                   LocalDateTime lastSend, LocalDateTime createdAt) {
        this.userId = userId;
        this.otpHash = otpHash;
        this.otpExpiredAt = otpExpiredAt;
        this.failedAttempt = failedAttempt;
        this.sendCount = sendCount;
        this.lastSend = lastSend;
        this.createdAt = createdAt;
    }

    // ===== Getter & Setter =====

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getOtpHash() {
        return otpHash;
    }

    public void setOtpHash(String otpHash) {
        this.otpHash = otpHash;
    }

    public LocalDateTime getOtpExpiredAt() {
        return otpExpiredAt;
    }

    public void setOtpExpiredAt(LocalDateTime otpExpiredAt) {
        this.otpExpiredAt = otpExpiredAt;
    }

    public int getFailedAttempt() {
        return failedAttempt;
    }

    public void setFailedAttempt(int failedAttempt) {
        this.failedAttempt = failedAttempt;
    }

    public int getSendCount() {
        return sendCount;
    }

    public void setSendCount(int sendCount) {
        this.sendCount = sendCount;
    }

    public LocalDateTime getLastSend() {
        return lastSend;
    }

    public void setLastSend(LocalDateTime lastSend) {
        this.lastSend = lastSend;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}