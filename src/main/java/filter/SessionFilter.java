package filter;

import dao.UserDAO;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import model.User;

@WebFilter("/*")
public class SessionFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
        Optional<User> opt = Optional.ofNullable(request.getSession().getAttribute("user")).map(obj -> (User) obj);
        if (opt.isPresent()) {
            User user = new UserDAO().getUserById(opt.get().getUserId());
            if (user.getStatus().equals("LOCKED")) {
                request.getSession().invalidate();
            } else {
                request.getSession().setAttribute("user", user);
            }
        }
        super.doFilter(request, response, chain);
    }
}
