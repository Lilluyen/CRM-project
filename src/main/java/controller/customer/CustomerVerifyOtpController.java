package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.CustomerOtpService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/customer/verify-otp")
public class CustomerVerifyOtpController extends HttpServlet {

    private CustomerOtpService otpService;

    @Override
    public void init() throws ServletException {
        otpService = new CustomerOtpService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra có email trong session không
        String email = (String) request.getSession().getAttribute("otp_email");

        if (email == null) {
            // Nếu chưa gửi OTP mà vào thẳng thì quay lại request
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        request.getRequestDispatcher("/verify-otp.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String otp = request.getParameter("d1")
                + request.getParameter("d2")
                + request.getParameter("d3")
                + request.getParameter("d4")
                + request.getParameter("d5")
                + request.getParameter("d6");

        String email = (String) request.getSession().getAttribute("otp_email");

        // TODO: gọi otpService.verifyOtp(email, otp)

        boolean valid = false;
        try {
            valid = otpService.verifyOtp(email, otp);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        if (valid) {
            request.getSession().removeAttribute("otp_email");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("error", "Invalid or expired OTP.");
            request.getRequestDispatcher("/verify-otp.jsp")
                    .forward(request, response);
        }
    }
}