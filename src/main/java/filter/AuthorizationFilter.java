//package filter;
//
//import jakarta.servlet.*;
//import jakarta.servlet.annotation.WebFilter;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//import model.Role;
//import model.User;
//
//import java.io.IOException;
//
///**
// * Simple authorization filter enforcing manager-only actions
// */
//@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/manager/*", "/tasks/*"})
//public class AuthorizationFilter implements Filter {
//
//    @Override
//    public void init(FilterConfig filterConfig) throws ServletException {
//    }
//
//    @Override
//    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
//            throws IOException, ServletException {
//        HttpServletRequest req = (HttpServletRequest) servletRequest;
//        HttpServletResponse resp = (HttpServletResponse) servletResponse;
//        HttpSession session = req.getSession(false);
//
//        // allow public access to listing and details for simplicity
//        String path = req.getRequestURI();
//
//        // If user not logged in, redirect to login
//        if (session == null || session.getAttribute("user") == null) {
//            resp.sendRedirect(req.getContextPath() + "/login");
//            return;
//        }
//
//        User user = (User) session.getAttribute("user");
//
//        // Protect manager-only endpoints
//        if (path.contains("/manager/") || (path.matches(".*/tasks/assign.*") )) {
//            Role role = user.getRole();
//            if (role == null || role.getRoleName() == null || !role.getRoleName().equalsIgnoreCase("MANAGER")) {
//                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
//                return;
//            }
//        }
//
//        chain.doFilter(servletRequest, servletResponse);
//    }
//
//    @Override
//    public void destroy() {
//    }
//}
