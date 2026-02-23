package controller.tasks;

import dao.TaskDAO;
import model.Task;
import util.DBContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

@WebServlet(name = "ViewTaskDetails", urlPatterns = {"/tasks/details"})
public class ViewTaskDetails extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get task ID from request parameter
            int taskId = Integer.parseInt(request.getParameter("id"));
            
            // Get task details from database
            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            
            Task task = taskDAO.getTaskById(taskId);
            
            if (task != null) {
                // Set task as request attribute
                request.setAttribute("task", task);
                
                // Forward to JSP for display
                request.getRequestDispatcher("/CRUD/TaskDetails.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Task not found!");
                request.getRequestDispatcher("/view/error/404.jsp").forward(request, response);
            }
            
            connection.close();
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid task ID!");
            try {
                request.getRequestDispatcher("/view/error/400.jsp").forward(request, response);
            } catch (ServletException | IOException ex) {
                ex.printStackTrace();
            }
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
