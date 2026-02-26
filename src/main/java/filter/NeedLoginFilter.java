//package filter;
//
//import java.io.IOException;
//
//import jakarta.servlet.FilterChain;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.http.HttpFilter;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//
//
//public class NeedLoginFilter extends HttpFilter {
//
//    @Override
//    protected void doFilter(HttpServletRequest request,
//            HttpServletResponse response,
//            FilterChain chain)
//            throws IOException, ServletException {
//
//        String uri = request.getRequestURI();
//        String context = request.getContextPath();
//
//        String path = uri.substring(context.length());
//
//        // ✅ Các URL KHÔNG cần login
//        boolean isPublic = path.equals("/login")
//                || path.equals("/logout")
//                || path.startsWith("/css/")
//                || path.startsWith("/js/")
//                || path.startsWith("/images/")
//                || path.startsWith("/fonts/")
//                || path.startsWith("/assets/");
//
//        if (isPublic) {
//            chain.doFilter(request, response);
//            return;
//        }
//
//        // ❗ Không tạo session mới
//        HttpSession session = request.getSession(false);
//
//        boolean loggedIn = (session != null && session.getAttribute("user") != null);
//
//        if (!loggedIn) {
//            response.sendRedirect(context + "/login");
//            return;
//        }
//
//        chain.doFilter(request, response);
//    }
//}