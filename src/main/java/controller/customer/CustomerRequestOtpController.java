package controller.customer;

import dao.CustomerDAO;
import model.Customer;
import service.CustomerOtpService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/customer/request-otp")
public class CustomerRequestOtpController extends HttpServlet {

    private CustomerOtpService otpService;
    private CustomerDAO customerDAO;

    @Override
    public void init() throws ServletException {
        otpService = new CustomerOtpService();
        customerDAO = new CustomerDAO();
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

            Customer customer = customerDAO.findByEmail(email);
            if (customer == null) {
                throw new Exception("Email không tồn tại trong hệ thống.");
            }

            // Lưu email vào session để verify bước sau
            request.getSession().setAttribute("customer", customer);

            // Redirect sang trang nhập OTP
            response.sendRedirect(request.getContextPath() + "/customer/verify-otp");
            return;

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/request-otp.jsp")
                    .forward(request, response);
        }
    }
}