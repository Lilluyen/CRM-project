package filter;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/customer/*")
public class CustomerFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request,
                            HttpServletResponse response,
                            FilterChain chain)
            throws IOException, ServletException {

        String context = request.getContextPath();
        String uri = request.getRequestURI();

        // ===== 0️⃣ Whitelist (không chặn) =====
        if (uri.equals(context + "/customer/request-otp")
                || uri.equals(context + "/customer/resend-otp")
                || uri.equals(context + "/customer/verify-otp")) {

            chain.doFilter(request, response);
            return;
        }

        // ❗ Không tạo session mới
        HttpSession session = request.getSession(false);

        // ===== 1️⃣ Chưa xác thực =====
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(context + "/customer/request-otp");
            return;
        }

        chain.doFilter(request, response);
    }
}