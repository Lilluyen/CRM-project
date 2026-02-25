package controller.activities;

import dao.ActivityDAO;
import model.Activity;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

@WebServlet(name = "ViewActivityDetails", urlPatterns = {"/activities/details"})
public class ViewActivityDetails extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get activity ID from request parameter
            int activityId = Integer.parseInt(request.getParameter("id"));
            
            // Get activity details from database
            Connection connection = DBContext.getConnection();
            ActivityDAO activityDAO = new ActivityDAO(connection);
            
            Activity activity = activityDAO.getActivityById(activityId);
            
            if (activity != null) {
                // Set activity as request attribute
                request.setAttribute("activity", activity);
                
                // Forward to JSP for display
                request.getRequestDispatcher("/activities/ActivityDetails.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Activity not found!");
                request.getRequestDispatcher("/view/error/404.jsp").forward(request, response);
            }
            
            connection.close();
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid activity ID!");
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
