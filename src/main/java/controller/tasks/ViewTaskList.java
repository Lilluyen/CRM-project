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
import java.util.List;

@WebServlet(name = "ViewTaskList", urlPatterns = {"/tasks/view", "/tasks/list"})
public class ViewTaskList extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get all tasks from database
            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            
            List<Task> tasks = taskDAO.getAllTasks();
            
            // Set tasks as request attribute
            request.setAttribute("tasks", tasks);
            request.setAttribute("totalTasks", tasks.size());
            
            // Forward to JSP for display
            request.getRequestDispatcher("/CRUD/TaskList.jsp").forward(request, response);
            
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
