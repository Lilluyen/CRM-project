package model;

import java.time.LocalDateTime;

public class CustomerOtp {

    private int customerId;
    private String otpHash;
    private LocalDateTime otpExpiredAt;

    private int failedAttempt;
    private int sendCount;
    private LocalDateTime lastSend;

    private Customer customer; // quan hệ 1-1 (optional)

    public CustomerOtp() {
    }

    // ===== Getter & Setter =====

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
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

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }
}