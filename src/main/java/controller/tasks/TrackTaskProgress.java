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

@WebServlet(name = "TrackTaskProgress", urlPatterns = {"/tasks/track", "/tasks/updateStatus"})
public class TrackTaskProgress extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from request
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            String newStatus = request.getParameter("status");
            
            // Update task status in database
            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            
            boolean success = taskDAO.updateTaskStatus(taskId, newStatus);
            
            if (success) {
                request.setAttribute("message", "Task status updated to: " + newStatus);
                
                // Check if it's an AJAX request
                String acceptHeader = request.getHeader("Accept");
                if (acceptHeader != null && acceptHeader.contains("application/json")) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\": true, \"message\": \"Status updated to " + newStatus + "\"}");
                } else {
                    request.getRequestDispatcher("/view/success.jsp").forward(request, response);
                }
            } else {
                if (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json")) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\": false, \"error\": \"Failed to update task status\"}");
                } else {
                    request.setAttribute("error", "Failed to update task status!");
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
