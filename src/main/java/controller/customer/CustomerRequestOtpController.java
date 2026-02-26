package controller.customer;

import service.CustomerOtpService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/customer/request-otp")
public class CustomerRequestOtpController extends HttpServlet {

    private CustomerOtpService otpService;

    @Override
    public void init() throws ServletException {
        otpService = new CustomerOtpService();
    }

    /**
     * Hiển thị trang nhập email
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/request-otp.jsp")
                .forward(request, response);
    }

    /**
     * Xử lý gửi OTP
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        try {
            otpService.generateAndSendOtp(email);

            // Lưu email vào session để verify bước sau
            request.getSession().setAttribute("otp_email", email);

            // Redirect sang trang nhập OTP
            response.sendRedirect(request.getContextPath() + "/customer/verify-otp");
            return;

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("request-otp.jsp")
                    .forward(request, response);
        }
    }
}