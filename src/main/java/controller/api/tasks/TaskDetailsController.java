package controller.api.tasks;

import java.io.IOException;
import java.sql.Connection;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import util.DBContext;
import util.JsonUtility;

/**
 * REST API Endpoint: GET /api/tasks/detail
 * 
 * Responsibility: Retrieve a single task by ID and return JSON
 * 
 * Request: GET /api/tasks/detail?id=1
 * Response: {
 *   "success": true,
 *   "data": { taskId, title, description, ... },
 *   "message": "OK"
 * }
 * 
 * Layer: CONTROLLER
 * - Extracts task ID from request parameters
 * - Delegates to DAO to retrieve task
 * - Serializes task to JSON using JsonUtility
 * - Returns JSON response
 */
@WebServlet(name = "TaskDetailsAPI", urlPatterns = { "/api/tasks/detail" })
public class TaskDetailsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set JSON response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // STEP 1: Extract and validate task ID from request parameter
            String taskIdParam = request.getParameter("id");
            if (taskIdParam == null || taskIdParam.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Task ID is required")
                );
                return;
            }

            int taskId;
            try {
                taskId = Integer.parseInt(taskIdParam);
                if (taskId <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Invalid task ID format")
                );
                return;
            }

            // STEP 2: Get database connection and DAO
            Connection connection = DBContext.getConnection();
            try {
                TaskDAO taskDAO = new TaskDAO(connection);

                // STEP 3: Retrieve task from DAO
                Task task = taskDAO.getTaskById(taskId);

                // STEP 4: Check if task exists
                if (task == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Task not found")
                    );
                    return;
                }

                // STEP 5: Serialize task to JSON using JsonUtility
                String jsonResponse = JsonUtility.createSuccessResponse(task);

                // STEP 6: Return JSON response
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write(jsonResponse);

            } finally {
                if (connection != null) {
                    connection.close();
                }
            }

        } catch (Exception e) {
            // Log the error
            e.printStackTrace();

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(
                JsonUtility.createErrorResponse("Server error: " + e.getMessage())
            );
        }
    }
}
