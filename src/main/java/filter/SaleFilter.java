package filter;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;

@WebFilter("/sale/*")
public class SaleFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        String context = request.getContextPath();

        // ❗ Không tạo session mới
        HttpSession session = request.getSession(false);

        // ===== 1️⃣ Chưa login =====
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(context + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        int roleId = user.getRole() != null ? user.getRole().getRoleId() : -1;

        // SALE vào toàn bộ /sale/*
        if (roleId == 2 || roleId == 5) {
            chain.doFilter(request, response);
            return;
        }

        response.sendRedirect(context + "/login?error=accessDenied");
    }
}