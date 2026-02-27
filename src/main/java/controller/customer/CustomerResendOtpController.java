package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import service.CustomerOtpService;

import java.io.IOException;

@WebServlet("/customer/resend-otp")
public class CustomerResendOtpController extends HttpServlet {

    private CustomerOtpService otpService;

    @Override
    public void init() {
        otpService = new CustomerOtpService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Customer customer = (Customer) request.getSession().getAttribute("customer");

        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        try {
            otpService.generateAndSendOtp(customer.getEmail());

            // dùng session để giữ message sau redirect
            request.getSession().setAttribute("success", "A new OTP has been sent.");

        } catch (Exception e) {

            request.getSession().setAttribute("error", e.getMessage());
        }

        // PRG pattern
        response.sendRedirect(request.getContextPath() + "/customer/verify-otp");
    }
}
