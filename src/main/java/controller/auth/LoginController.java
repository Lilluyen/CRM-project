package controller.auth;

import java.io.IOException;
import java.util.Optional;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Role;
import model.User;

@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String username = Optional.ofNullable(req.getParameter("username")).orElse("");
        String password = Optional.ofNullable(req.getParameter("password")).orElse("");

        req.setAttribute("username", username);

        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByUsername(username);

        if (user == null || !util.PasswordUtil.check(password, user.getPasswordHash())) {
            req.setAttribute("error", "Invalid username or password.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        if ("LOCKED".equals(user.getStatus())) {
            req.setAttribute("error", "Your account is locked.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        req.getSession().setAttribute("user", user);
        req.getSession().setAttribute("roles", user.getRole().getRoleId());
        userDAO.updateLastLogin(user.getUserId());

        String redirectUrl = getDashboardByRole(user.getRole());
        resp.sendRedirect(req.getContextPath() + redirectUrl);

    }

    private String getDashboardByRole(Role role) {

        if (role == null || role.getRoleName() == null) {
            return "/dashboard";
        }

        switch (role.getRoleName().toUpperCase()) {

            case "ADMIN":
                return "/admin/dashboard";

            case "SALE":
                return "/sale/dashboard";

            case "MARKETING":
                return "/marketing/dashboard";

            case "CS":
                return "/cs/dashboard";

            default:
                return "/dashboard";
        }
    }
}
