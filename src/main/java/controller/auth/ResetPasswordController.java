package controller.auth;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import service.UserOtpService;
import util.PasswordUtil;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet("/reset-password")
public class ResetPasswordController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final UserOtpService otpService = new UserOtpService();

    // Regex OTP 6 số
    private static final Pattern OTP_PATTERN = Pattern.compile("^\\d{6}$");

    // Password: >=8 ký tự, 1 hoa, 1 thường, 1 số
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("reset-password.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {

            String email = request.getParameter("email");
            request.setAttribute("email", email);

            if (email == null || email.isBlank()) {
                throw new Exception("Email is required.");
            }

            var user = userDAO.findByEmail(email);

            // =========================
            // 1️⃣ SEND OTP
            // =========================
            if ("sendOtp".equals(action)) {

                // Không tiết lộ user tồn tại
                if (user != null && "ACTIVE".equals(user.getStatus())) {
                    otpService.generateAndSendOtp(email);
                }

                request.setAttribute("message",
                        "If the email exists and is active, an OTP has been sent.");
            }

            // =========================
            // 2️⃣ RESET PASSWORD
            // =========================
            else if ("resetPassword".equals(action)) {

                String otp = request.getParameter("otp");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");

                if (user == null || !"ACTIVE".equals(user.getStatus())) {
                    throw new Exception("Invalid request.");
                }

                // Validate OTP
                if (otp == null || !OTP_PATTERN.matcher(otp).matches()) {
                    throw new Exception("OTP must be exactly 6 digits.");
                }

                // Validate password strength
                if (newPassword == null || !PASSWORD_PATTERN.matcher(newPassword).matches()) {
                    throw new Exception(
                            "Password must be at least 8 characters and include uppercase, lowercase and number."
                    );
                }

                if (!newPassword.equals(confirmPassword)) {
                    throw new Exception("Passwords do not match.");
                }

                boolean validOtp = otpService.verifyOtp(email, otp);

                if (!validOtp) {
                    throw new Exception("Invalid or expired OTP.");
                }

                String passwordHash = PasswordUtil.hash(newPassword);

                boolean updated =
                        userDAO.updatePassword(user.getUserId(), passwordHash);

                if (!updated) {
                    throw new Exception("Cannot update password.");
                }

                request.setAttribute("success",
                        "Password has been reset successfully.");
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("reset-password.jsp")
                .forward(request, response);
    }
}