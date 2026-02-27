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
 * REST API Endpoint: POST /api/tasks/create
 * 
 * Responsibility: Create a new task and return JSON response
 * 
 * Request: POST /api/tasks/create
 * Body: title, description, related_type, related_id, priority, due_date, assigned_to (optional)
 * 
 * Response: {
 *   "success": true,
 *   "data": { taskId, title, ... },
 *   "message": "Task created successfully"
 * }
 * 
 * Layer: CONTROLLER
 * - Extracts form parameters from request
 * - Validates input
 * - Delegates to Service layer (which coordinates DAO and Notifications)
 * - Serializes response to JSON using JsonUtility
 */
@WebServlet(name = "CreateTaskAPI", urlPatterns = { "/api/tasks/create" })
public class CreateTaskController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set JSON response content type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // STEP 1: Extract and validate form parameters
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String relatedType = request.getParameter("relatedType");
            String relatedIdParam = request.getParameter("relatedId");
            String priority = request.getParameter("priority");
            String dueDateParam = request.getParameter("dueDate");
            String assignedToParam = request.getParameter("assignedTo");
            String status = request.getParameter("status");

            // Validate required fields
            if (title == null || title.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Title is required")
                );
                return;
            }

            if (description == null || description.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Description is required")
                );
                return;
            }

            if (relatedType == null || relatedType.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Related Type is required")
                );
                return;
            }

            if (dueDateParam == null || dueDateParam.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Due Date is required")
                );
                return;
            }

            // Parse numeric fields
            int relatedId;
            try {
                relatedId = Integer.parseInt(relatedIdParam);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Invalid Related ID")
                );
                return;
            }

            // Parse optional assigned_to
            Integer assignedTo = null;
            if (assignedToParam != null && !assignedToParam.trim().isEmpty()) {
                try {
                    assignedTo = Integer.parseInt(assignedToParam);
                } catch (NumberFormatException e) {
                    // Optional field, skip if invalid
                }
            }

            // Parse due date
            LocalDate dueDate;
            try {
                dueDate = LocalDate.parse(dueDateParam);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    JsonUtility.createErrorResponse("Invalid date format. Use YYYY-MM-DD")
                );
                return;
            }

            // STEP 2: Create Task domain object
            Task task = new Task();
            task.setTitle(title);
            task.setDescription(description);
            task.setRelatedType(relatedType);
            task.setRelatedId(relatedId);
            task.setPriority(priority != null && !priority.isEmpty() ? priority : "MEDIUM");
            task.setDueDate(dueDate);
            task.setAssignedTo(assignedTo != null ? assignedTo : 0);
            task.setStatus(status != null && !status.isEmpty() ? status : "PENDING");

            // STEP 3: Get database connection and Service
            Connection connection = DBContext.getConnection();
            try {
                TaskService taskService = new TaskService(connection);

                // STEP 4: Delegate to Service layer (creates task + sends notification)
                boolean success = taskService.createTask(task);

                if (!success) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write(
                        JsonUtility.createErrorResponse("Failed to create task")
                    );
                    return;
                }

                // STEP 5: Retrieve created task for response
                TaskDAO taskDAO = new TaskDAO(connection);
                Task createdTask = taskDAO.getTaskById(task.getTaskId());

                // STEP 6: Serialize to JSON and return
                String jsonResponse = JsonUtility.createSuccessResponse(createdTask);
                response.setStatus(HttpServletResponse.SC_CREATED);
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
