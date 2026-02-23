package controller.activities;

import dao.ActivityDAO;
import model.Activity;
import util.DBContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet(name = "ViewActivities", urlPatterns = {"/activities/list"})
public class ViewActivities extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get all activities from database
            Connection connection = DBContext.getConnection();
            ActivityDAO activityDAO = new ActivityDAO(connection);
            
            List<Activity> activities = activityDAO.getAllActivities();
            
            // Set activities as request attribute
            request.setAttribute("activities", activities);
            request.setAttribute("totalActivities", activities.size());
            
            // Forward to JSP for display
            request.getRequestDispatcher("/CRUD/ActivityList.jsp").forward(request, response);
            
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
        }
    }
}
