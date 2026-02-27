// controller/tasks/ViewTaskList.java
package controller.api;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import model.User;
import service.TaskService;
import util.DBContext;
import util.JsonUtility;

/**
 * REST Controller for Task List endpoint.
 * 
 * SOLE RESPONSIBILITY: Coordinate the HTTP request-response lifecycle.
 * 
 * This servlet:
 * - Extracts request parameters (page, sort, filters)
 * - Delegates to Service layer for business logic
 * - Delegates to JsonUtility for serialization
 * - Returns JSON response
 * 
 * This servlet DOES NOT:
 * - Access database directly (that's DAO's job)
 * - Execute business logic (that's Service's job)
 * - Format JSON (that's JsonUtility's job)
 * - Forward to JSP/HTML (client-side JavaScript handles rendering)
 */
@WebServlet(name = "ViewTaskListAPI", urlPatterns = { "/api/tasks/list" })
public class ViewTaskListAPI extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // STEP 1: Authenticate user (security concern)
            User currentUser = (User) request.getSession().getAttribute("user");
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Unauthorized: No user session")
                );
                return;
            }

            // STEP 2: Extract request parameters
            String sortParam = request.getParameter("sort");
            String pageParam = request.getParameter("page");
            
            int page = 1;
            try {
                if (pageParam != null) {
                    page = Integer.parseInt(pageParam);
                }
            } catch (NumberFormatException e) {
                page = 1; // Default to page 1 on invalid input
            }

            // STEP 3: Delegate to Service layer (coordinator pattern)
            Connection connection = DBContext.getConnection();
            try {
                TaskService taskService = new TaskService(connection);
                
                // Service returns domain objects (Task entities), not JSON
                List<Task> tasks = taskService.getTasksForUser(currentUser, sortParam, page);
                int totalTasks = taskService.getTotalTasksForUser(currentUser);

                // STEP 4: Delegate to JsonUtility for serialization (single responsibility)
                String jsonResponse = JsonUtility.createSuccessResponse(tasks);
                
                // STEP 5: Return JSON response (controller's final responsibility)
                response.getWriter().write(jsonResponse);
                response.setStatus(HttpServletResponse.SC_OK);

            } finally {
                if (connection != null) {
                    connection.close();
                }
            }

        } catch (Exception e) {
            // Log error (use proper logging framework, not System.err)
            e.printStackTrace();
            
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(
                JsonUtility.createErrorResponse("Server error: " + e.getMessage())
            );
        }
    }
}