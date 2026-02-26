package controller.activities;

import dao.ActivityDAO;
import model.Activity;
import model.User;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;

@WebServlet(name = "CreateActivity", urlPatterns = {"/activities/create"})
public class CreateActivity extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get parameters from request
            String relatedType = request.getParameter("relatedType");
            int relatedId = Integer.parseInt(request.getParameter("relatedId"));
            String activityType = request.getParameter("activityType");
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");
            // Determine current user from session instead of form input
            User currentUser = (User) request.getSession().getAttribute("user");
            if (currentUser == null) {
                request.setAttribute("error", "You must be logged in to create an activity.");
                request.getRequestDispatcher("/view/error/401.jsp").forward(request, response);
                return;
            }
            
            // Create Activity object
            Activity activity = new Activity();
            activity.setRelatedType(relatedType);
            activity.setRelatedId(relatedId);
            activity.setActivityType(activityType);
            activity.setSubject(subject);
            activity.setDescription(description);
            activity.setCreatedBy(currentUser);
            activity.setActivityDate(LocalDateTime.now());
            
            // Persist to database
            Connection connection = DBContext.getConnection();
            ActivityDAO activityDAO = new ActivityDAO(connection);
            
            boolean success = activityDAO.createActivity(activity);
            
            if (success) {
                request.setAttribute("message", "Activity created successfully!");
                request.getRequestDispatcher("/view/success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to create activity!");
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
        req.getRequestDispatcher("/view/activities/ActivityForm.jsp").forward(req, resp);
    }
    
}
