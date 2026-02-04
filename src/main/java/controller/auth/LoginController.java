package controller.auth;

import java.io.IOException;
import java.util.List;
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

        if (user == null || !ultil.PasswordUtil.check(password, user.getPasswordHash())) {
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
        req.getSession().setAttribute("roles", user.getRoles());

        String redirectUrl = getDashboardByRole(user.getRoles());
        resp.sendRedirect(req.getContextPath() + redirectUrl);

    }

    private String getDashboardByRole(List<Role> roles) {

        for (Role role : roles) {
            String roleName = role.getRoleName();

            if (roleName == null) continue;

            switch (roleName.toUpperCase()) {
                case "ADMIN":
                    return "admin.jsp";
                case "SALES":
                    return "sale.jsp";
                case "MARKETING":
                    return "marketing.jsp";
                case "CS":
                    return "cs.jsp";
                    case "Customer":
                    return "customer.jsp";
            }
        }

        // fallback nếu role lạ
        return "/dashboard";
    }
}
