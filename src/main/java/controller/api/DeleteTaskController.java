package controller.api;

import java.io.IOException;
import java.sql.Connection;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBContext;
import util.JsonUtility;

/**
 * REST API Endpoint: POST /api/tasks/delete
 * 
 * Responsibility: Delete a task by ID and return JSON response
 * 
 * Request: POST /api/tasks/delete?id=1
 * 
 * Response: {
 *   "success": true,
 *   "data": {},
 *   "message": "Task deleted successfully"
 * }
 * 
 * Layer: CONTROLLER
 * - Extracts task ID from request parameters
 * - Validates task existence
 * - Delegates to DAO to delete task
 * - Serializes response to JSON using JsonUtility
 * 
 * Note: If DAO doesn't have delete method, add it following the pattern of other methods
 */
@WebServlet(name = "DeleteTaskAPI", urlPatterns = { "/api/tasks/delete" })
public class DeleteTaskController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set JSON response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // STEP 1: Extract and validate task ID
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

                // Verify task exists before deleting
                if (taskDAO.getTaskById(taskId) == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Task not found")
                    );
                    return;
                }

                // STEP 3: Delete task via DAO
                boolean success = taskDAO.deleteTask(taskId);

                if (!success) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Failed to delete task")
                    );
                    return;
                }

                // STEP 4: Return success response
                String jsonResponse = JsonUtility.createSuccessResponse(
                    new java.util.HashMap<String, Object>()
                );
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
