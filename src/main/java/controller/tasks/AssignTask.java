package controller.tasks;

import dao.TaskDAO;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

@WebServlet(name = "AssignTask", urlPatterns = {"/tasks/assign"})
public class AssignTask extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from request
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            // Assign task in database
            Connection connection = new DBContext().getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            
            boolean success = taskDAO.assignTask(taskId, userId);
            
            if (success) {
                // Send notification to user about assigned task
                String title = "New Task Assigned";
                String content = "You have been assigned a new task. Task ID: " + taskId;
                taskDAO.announceAssignedTask(userId, title, content);
                
                request.setAttribute("message", "Task assigned successfully and notification sent!");
                request.getRequestDispatcher("/view/success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to assign task!");
                request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
            }
            
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            try {
                request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
            } catch (ServletException | IOException ex) {
                ex.printStackTrace();
            }
        }
    }
}
