package filter;

import java.io.IOException;

import dao.UserDAO;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;


public class SessionFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            User sessionUser = (User) session.getAttribute("user");

            if (sessionUser != null) {

                User freshUser = new UserDAO().getUserById(sessionUser.getUserId());

                if (freshUser == null || "LOCKED".equals(freshUser.getStatus())) {
                    session.invalidate();
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                session.setAttribute("user", freshUser);
            }
        }

        chain.doFilter(request, response);
    }
}