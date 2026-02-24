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
import java.time.LocalDateTime;

@WebServlet(name = "UpdateActivity", urlPatterns = {"/activities/update"})
public class UpdateActivity extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from request
            int activityId = Integer.parseInt(request.getParameter("activityId"));
            String relatedType = request.getParameter("relatedType");
            int relatedId = Integer.parseInt(request.getParameter("relatedId"));
            String activityType = request.getParameter("activityType");
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");
            
            // Create Activity object
            Activity activity = new Activity();
            activity.setActivityId(activityId);
            activity.setRelatedType(relatedType);
            activity.setRelatedId(relatedId);
            activity.setActivityType(activityType);
            activity.setSubject(subject);
            activity.setDescription(description);
            activity.setActivityDate(LocalDateTime.now());
            
            // Update in database
            Connection connection = DBContext.getConnection();
            ActivityDAO activityDAO = new ActivityDAO(connection);
            
            boolean success = activityDAO.updateActivity(activity);
            
            if (success) {
                request.setAttribute("message", "Activity updated successfully!");
                request.getRequestDispatcher("/view/success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to update activity!");
                request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
            }
            
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
        }
    }
}
