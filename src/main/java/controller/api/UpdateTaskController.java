package controller.api;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDate;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Task;
import service.TaskService;
import util.DBContext;
import util.JsonUtility;

/**
 * REST API Endpoint: POST /api/tasks/update
 * 
 * Responsibility: Update an existing task and return JSON response
 * 
 * Request: POST /api/tasks/update
 * Body: taskId, title, description, related_type, related_id, priority,
 * due_date, status
 * 
 * Response: {
 * "success": true,
 * "data": { taskId, title, ... },
 * "message": "Task updated successfully"
 * }
 * 
 * Layer: CONTROLLER
 * - Extracts form parameters from request
 * - Validates input and task existence
 * - Delegates to Service layer
 * - Serializes response to JSON using JsonUtility
 */
@WebServlet(name = "UpdateTaskAPI", urlPatterns = { "/api/tasks/update" })
public class UpdateTaskController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set JSON response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // STEP 1: Extract and validate form parameters
            String taskIdParam = request.getParameter("taskId");
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String relatedType = request.getParameter("relatedType");
            String relatedIdParam = request.getParameter("relatedId");
            String priority = request.getParameter("priority");
            String dueDateParam = request.getParameter("dueDate");
            String status = request.getParameter("status");

            // Validate required fields
            if (taskIdParam == null || taskIdParam.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Task ID is required"));
                return;
            }

            if (title == null || title.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Title is required"));
                return;
            }

            if (description == null || description.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Description is required"));
                return;
            }

            // Parse numeric fields
            int taskId;
            try {
                taskId = Integer.parseInt(taskIdParam);
                if (taskId <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Invalid Task ID"));
                return;
            }

            int relatedId;
            try {
                relatedId = Integer.parseInt(relatedIdParam);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Invalid Related ID"));
                return;
            }

            // Parse due date
            LocalDate dueDate;
            try {
                dueDate = LocalDate.parse(dueDateParam);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                        JsonUtility.createErrorResponse("Invalid date format. Use YYYY-MM-DD"));
                return;
            }

            // STEP 2: Get database connection
            Connection connection = DBContext.getConnection();
            try {
                TaskDAO taskDAO = new TaskDAO(connection);

                // Verify task exists
                Task existingTask = taskDAO.getTaskById(taskId);
                if (existingTask == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write(
                            JsonUtility.createErrorResponse("Task not found"));
                    return;
                }

                // STEP 3: Create updated Task object
                Task updatedTask = new Task();
                updatedTask.setTaskId(taskId);
                updatedTask.setTitle(title);
                updatedTask.setDescription(description);
                updatedTask.setRelatedType(relatedType);
                updatedTask.setRelatedId(relatedId);
                updatedTask.setPriority(priority != null && !priority.isEmpty() ? priority : "MEDIUM");
                updatedTask.setDueDate(dueDate);
                updatedTask.setStatus(status != null && !status.isEmpty() ? status : "PENDING");

                // STEP 4: Delegate to Service layer
                TaskService taskService = new TaskService(connection);
                boolean success = taskService.updateTask(updatedTask);

                if (!success) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write(
                            JsonUtility.createErrorResponse("Failed to update task"));
                    return;
                }

                // STEP 5: Retrieve updated task for response
                Task retrievedTask = taskDAO.getTaskById(taskId);

                // STEP 6: Serialize to JSON and return
                String jsonResponse = JsonUtility.createSuccessResponse(retrievedTask);
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
                    JsonUtility.createErrorResponse("Server error: " + e.getMessage()));
        }
    }
}
