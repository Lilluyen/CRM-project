package service;

import dao.CustomerDAO;
import dao.CustomerOtpDAO;
import model.Customer;
import model.CustomerOtp;
import util.Email;
import util.EmailService;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;

public class CustomerOtpService {

    private static final int OTP_EXPIRE_MINUTES = 5;
    private static final int MAX_FAILED_ATTEMPT = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 60;
    private static final int MAX_SEND_PER_WINDOW = 5;
    private static final int BLOCK_MINUTES = 30;

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerOtpDAO otpDAO = new CustomerOtpDAO();

    /* =============================
       GỬI OTP
       ============================= */
    public void generateAndSendOtp(String email) throws Exception {

        Customer customer = customerDAO.findByEmail(email);

        if (customer == null) {
            throw new Exception("Email không tồn tại trong hệ thống.");
        }

        CustomerOtp existingOtp = otpDAO.findByCustomerId(customer.getCustomerId());

        LocalDateTime now = LocalDateTime.now();

        if (existingOtp != null) {

            // 1️⃣ Nếu đã gửi >= 5 lần
            if (existingOtp.getSendCount() >= MAX_SEND_PER_WINDOW) {

                long minutesSinceLastSend = Duration.between(
                        existingOtp.getLastSend(),
                        now
                ).toMinutes();

                // Nếu chưa đủ 30 phút thì block
                long secondsSinceLastSend = Duration.between(
                        existingOtp.getLastSend(),
                        now
                ).getSeconds();

                long blockSeconds = BLOCK_MINUTES * 60;
                long remainingBlockSeconds = blockSeconds - secondsSinceLastSend;

                if (remainingBlockSeconds > 0) {

                    long minutes = remainingBlockSeconds / 60;
                    long seconds = remainingBlockSeconds % 60;

                    throw new Exception(
                            "Bạn đã gửi OTP quá 5 lần. Vui lòng thử lại sau "
                                    + minutes + " phút "
                                    + seconds + " giây."
                    );
                }

                // Nếu đã đủ 30 phút → reset
                existingOtp.setSendCount(0);
            }

            // 2️⃣ Kiểm tra cooldown 60 giây
            long seconds = Duration.between(
                    existingOtp.getLastSend(),
                    now
            ).getSeconds();

            if (seconds < RESEND_COOLDOWN_SECONDS) {

                long remainingSeconds = RESEND_COOLDOWN_SECONDS - seconds;

                throw new Exception(
                        "Vui lòng chờ " + remainingSeconds
                                + " giây trước khi gửi lại OTP."
                );
            }
        }

        // 3️⃣ Tạo OTP
        String rawOtp = generateOtp();
        String hashedOtp = hashOtp("123456");

        LocalDateTime expireTime = now.plusMinutes(5);

        if (existingOtp == null) {
            CustomerOtp newOtp = new CustomerOtp();
            newOtp.setCustomerId(customer.getCustomerId());
            newOtp.setOtpHash(hashedOtp);
            newOtp.setOtpExpiredAt(expireTime);
            newOtp.setFailedAttempt(0);
            newOtp.setSendCount(1);
            newOtp.setLastSend(now);

            otpDAO.insertOTP(newOtp);

        } else {

            existingOtp.setOtpHash(hashedOtp);
            existingOtp.setOtpExpiredAt(expireTime);
            existingOtp.setFailedAttempt(0);
            existingOtp.setSendCount(existingOtp.getSendCount() + 1);
            existingOtp.setLastSend(now);

            otpDAO.updateOTP(existingOtp);
        }

        // Gửi email
        // sendOtpEmail(customer.getEmail(), rawOtp);
    }

    /* =============================
       VERIFY OTP
       ============================= */
    public boolean verifyOtp(String email, String inputOtp) throws Exception {

        Customer customer = customerDAO.findByEmail(email);
        if (customer == null) return false;

        CustomerOtp otp = otpDAO.findByCustomerId(customer.getCustomerId());
        if (otp == null) return false;

        // Check expired
        if (otp.getOtpExpiredAt().isBefore(LocalDateTime.now())) {
            otpDAO.deleteByCustomerId(customer.getCustomerId());
            return false;
        }

        // Check lock
        if (otp.getFailedAttempt() >= MAX_FAILED_ATTEMPT) {
            return false;
        }

        String hashedInput = hashOtp(inputOtp);

        if (!hashedInput.equals(otp.getOtpHash())) {
            otp.setFailedAttempt(otp.getFailedAttempt() + 1);
            otpDAO.updateFailedAttempt(otp);
            return false;
        }

        // Thành công -> xóa OTP
        otpDAO.deleteByCustomerId(customer.getCustomerId());

        return true;
    }

    /* =============================
       TẠO OTP 6 SỐ
       ============================= */
    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /* =============================
       HASH OTP (SHA-256)
       ============================= */
    private String hashOtp(String otp) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashed = md.digest(otp.getBytes());
            return Base64.getEncoder().encodeToString(hashed);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi hash OTP");
        }
    }

    /* =============================
       GỬI EMAIL (DEMO)
       ============================= */
    private void sendOtpEmail(String toEmail, String otp) {
        String subject = "Mã xác thực OTP của bạn";

        String htmlContent = """
            <div style="font-family: Arial, sans-serif; font-size:14px;">
                <h2>Xác thực tài khoản</h2>
                <p>Mã OTP của bạn là:</p>
                <h1 style="color:#2e6cff; letter-spacing:3px;">%s</h1>
                <p>Mã có hiệu lực trong 5 phút.</p>
                <p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email.</p>
            </div>
            """.formatted(otp);

        Email email = new Email();
        email.setTo(toEmail);
        email.setSubject(subject);
        email.setBodyHtml(htmlContent); // gửi dạng HTML

        boolean sent = EmailService.send(email);

        if (!sent) {
            throw new RuntimeException("Không thể gửi OTP email.");
        }
    }
}