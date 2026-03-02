package controller.api.tasks;

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
 * REST API Endpoint: POST /api/tasks/updateStatus
 * 
 * Responsibility: Update a task's status (quick status update)
 * 
 * Request: POST /api/tasks/updateStatus
 * Body: taskId, status (PENDING, IN_PROGRESS, COMPLETED)
 * 
 * Response: {
 *   "success": true,
 *   "data": {},
 *   "message": "Status updated successfully"
 * }
 * 
 * Layer: CONTROLLER
 * - Extracts task ID and status from request
 * - Validates input
 * - Delegates to DAO to update status
 * - Serializes response to JSON using JsonUtility
 * 
 * Use Case: Progress tracking page quick status updates
 */
@WebServlet(name = "UpdateTaskStatusAPI", urlPatterns = { "/api/tasks/updateStatus" })
public class UpdateTaskStatusController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set JSON response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // STEP 1: Extract and validate parameters
            String taskIdParam = request.getParameter("taskId");
            String status = request.getParameter("status");

            if (taskIdParam == null || taskIdParam.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Task ID is required")
                );
                return;
            }

            if (status == null || status.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Status is required")
                );
                return;
            }

            // Parse task ID
            int taskId;
            try {
                taskId = Integer.parseInt(taskIdParam);
                if (taskId <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Invalid Task ID")
                );
                return;
            }

            // Validate status value
            status = status.toUpperCase();
            if (!isValidStatus(status)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Invalid status. Valid values: PENDING, IN_PROGRESS, COMPLETED")
                );
                return;
            }

            // STEP 2: Get database connection and DAO
            Connection connection = DBContext.getConnection();
            try {
                TaskDAO taskDAO = new TaskDAO(connection);

                // Verify task exists
                if (taskDAO.getTaskById(taskId) == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Task not found")
                    );
                    return;
                }

                // STEP 3: Update task status via DAO
                boolean success = taskDAO.updateTaskStatus(taskId, status);

                if (!success) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Failed to update task status")
                    );
                    return;
                }

                // STEP 4: Return success response
                String jsonResponse = JsonUtility.createSuccessResponse(
                    new StatusUpdateResponse(taskId, status)
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

    /**
     * Validate if status is one of the allowed values
     */
    private boolean isValidStatus(String status) {
        return status.equals("PENDING") ||
               status.equals("IN_PROGRESS") ||
               status.equals("COMPLETED") ||
               status.equals("TODO") ||
               status.equals("DONE");
    }

    /**
     * Simple response object for status updates
     */
    public static class StatusUpdateResponse {
        public int taskId;
        public String status;

        public StatusUpdateResponse(int taskId, String status) {
            this.taskId = taskId;
            this.status = status;
        }

        public int getTaskId() {
            return taskId;
        }

        public String getStatus() {
            return status;
        }
    }
}
