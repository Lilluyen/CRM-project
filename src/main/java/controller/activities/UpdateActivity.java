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
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int activityId = Integer.parseInt(req.getParameter("id"));
        try {
            Connection connection = DBContext.getConnection();
            ActivityDAO activityDAO = new ActivityDAO(connection);
            Activity activity = activityDAO.getActivityById(activityId);
            req.setAttribute("activity", activity);
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/view/error/500.jsp").forward(req, resp);
            return;
        }
        req.getRequestDispatcher("/view/activities/ActivityForm.jsp").forward(req, resp);
    }
}
