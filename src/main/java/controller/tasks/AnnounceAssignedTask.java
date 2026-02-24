package controller.tasks;

import dao.TaskDAO;
import util.DBContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

@WebServlet(name = "AnnounceAssignedTask", urlPatterns = {"/tasks/announce"})
public class AnnounceAssignedTask extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from request
            int userId = Integer.parseInt(request.getParameter("userId"));
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            
            // Send notification to user
            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            
            boolean success = taskDAO.announceAssignedTask(userId, title, content);
            
            if (success) {
                // Check if it's an AJAX request
                String acceptHeader = request.getHeader("Accept");
                if (acceptHeader != null && acceptHeader.contains("application/json")) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\": true, \"message\": \"Notification sent successfully\"}");
                } else {
                    request.setAttribute("message", "Notification sent successfully!");
                    request.getRequestDispatcher("/view/success.jsp").forward(request, response);
                }
            } else {
                if (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json")) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\": false, \"error\": \"Failed to send notification\"}");
                } else {
                    request.setAttribute("error", "Failed to send notification!");
                    request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
                }
            }
            
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            if (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json")) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
            } else {
                request.setAttribute("error", "Error: " + e.getMessage());
                try {
                    request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
                } catch (ServletException | IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}
