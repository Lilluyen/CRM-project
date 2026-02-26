package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Customer;
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

        HttpSession session = request.getSession();

        // Kiểm tra có email trong session không
        Customer customer = (Customer) session.getAttribute("customer");

        if (customer == null) {
            // Nếu chưa gửi OTP mà vào thẳng thì quay lại request
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        String error = (String) session.getAttribute("error");
        String success = (String) session.getAttribute("success");

        if (error != null) {
            request.setAttribute("error", error);
            session.removeAttribute("error");
        }

        if (success != null) {
            request.setAttribute("success", success);
            session.removeAttribute("success");
        }

        request.getRequestDispatcher("/verify-otp.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String otp = request.getParameter("otp");

        if (otp == null || !otp.matches("\\d{6}")) {
            request.setAttribute("error", "OTP phải gồm đúng 6 chữ số.");
            request.getRequestDispatcher("/verify-otp.jsp")
                    .forward(request, response);
            return;
        }

        Customer customer = (Customer) request.getSession().getAttribute("customer");

        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        String email = customer.getEmail();

        boolean valid;
        try {
            valid = otpService.verifyOtp(email, otp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        if (valid) {

            response.sendRedirect(request.getContextPath() + "/login");

        } else {

            request.setAttribute("error", "Invalid or expired OTP.");
            request.getRequestDispatcher("/verify-otp.jsp")
                    .forward(request, response);
        }
    }
}