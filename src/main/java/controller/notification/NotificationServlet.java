package controller.notification;

import dao.NotificationDAO;
import model.User;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications"})
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try (Connection conn = DBContext.getConnection()) {
            User current = (User) request.getSession().getAttribute("currentUser");
            if (current == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            NotificationDAO dao = new NotificationDAO(conn);
            request.setAttribute("notifications", dao.findByUser(current.getUserId()));
            request.getRequestDispatcher("/view/notification/list.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
