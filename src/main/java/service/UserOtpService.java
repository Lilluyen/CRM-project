package service;

import dao.UserDAO;
import dao.UserOtpDAO;
import model.User;
import model.UserOTP;
import util.Email;
import util.EmailService;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;

public class UserOtpService {

    private static final int OTP_EXPIRE_MINUTES = 5;
    private static final int MAX_FAILED_ATTEMPT = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 60;
    private static final int MAX_SEND_PER_WINDOW = 5;
    private static final int BLOCK_MINUTES = 30;

    private final UserDAO userDAO = new UserDAO();
    private final UserOtpDAO otpDAO = new UserOtpDAO();

    /* =============================
       GỬI OTP
       ============================= */
    public void generateAndSendOtp(String email) throws Exception {

        User user = userDAO.findByEmail(email);

        if (user == null) {
            throw new Exception("The email does not exist in the system.");
        }

        UserOTP existingOtp = otpDAO.findByUserId(user.getUserId());
        LocalDateTime now = LocalDateTime.now();

        if (existingOtp != null) {

            // 1️⃣ Nếu đã gửi >= 5 lần
            if (existingOtp.getSendCount() >= MAX_SEND_PER_WINDOW) {

                long secondsSinceLastSend =
                        Duration.between(existingOtp.getLastSend(), now).getSeconds();

                long blockSeconds = BLOCK_MINUTES * 60;
                long remainingBlockSeconds = blockSeconds - secondsSinceLastSend;

                if (remainingBlockSeconds > 0) {

                    long minutes = remainingBlockSeconds / 60;
                    long seconds = remainingBlockSeconds % 60;

                    throw new Exception(
                            "You have requested the OTP more than 5 times. Please try again after "
                                    + minutes + " minutes "
                                    + seconds + " seconds."
                    );
                }

                // Reset nếu đủ 30 phút
                existingOtp.setSendCount(0);
            }

            // 2️⃣ Cooldown 60 giây
            long seconds =
                    Duration.between(existingOtp.getLastSend(), now).getSeconds();

            if (seconds < RESEND_COOLDOWN_SECONDS) {

                long remainingSeconds = RESEND_COOLDOWN_SECONDS - seconds;

                throw new Exception(
                        "Please wait " + remainingSeconds
                                + " seconds before requesting a new OTP."
                );
            }
        }

        // 3️⃣ Tạo OTP
        String rawOtp = generateOtp();
        String hashedOtp = hashOtp("123456");
        LocalDateTime expireTime = now.plusMinutes(OTP_EXPIRE_MINUTES);

        if (existingOtp == null) {

            UserOTP newOtp = new UserOTP();
            newOtp.setUserId(user.getUserId());
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

//        // Gửi email
//        sendOtpEmail(user.getEmail(), rawOtp);
    }

    /* =============================
       VERIFY OTP
       ============================= */
    public boolean verifyOtp(String email, String inputOtp) throws Exception {

        User user = userDAO.findByEmail(email);
        if (user == null) return false;

        UserOTP otp = otpDAO.findByUserId(user.getUserId());
        if (otp == null) return false;

        // Check expired
        if (otp.getOtpExpiredAt().isBefore(LocalDateTime.now())) {
            otpDAO.deleteByUserId(user.getUserId());
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

        // Thành công → xóa OTP
        otpDAO.deleteByUserId(user.getUserId());

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
            throw new RuntimeException("OTP hashing error");
        }
    }

    /* =============================
       GỬI EMAIL
       ============================= */
    private void sendOtpEmail(String toEmail, String otp) {

        String subject = "Your OTP Verification Code";

        String htmlContent = """
            <div style="font-family: Arial, sans-serif; font-size:14px;">
                <h2>Account Verification</h2>
                <p>Your OTP code is:</p>
                <h1 style="color:#2e6cff; letter-spacing:3px;">%s</h1>
                <p>This code will expire in 5 minutes.</p>
                <p>If you did not request this code, please ignore this email.</p>
            </div>
            """.formatted(otp);

        Email email = new Email();
        email.setTo(toEmail);
        email.setSubject(subject);
        email.setBodyHtml(htmlContent);

        boolean sent = EmailService.send(email);

        if (!sent) {
            throw new RuntimeException("Cannot send OTP email.");
        }
    }
}