package controller.api;

import dao.TaskDAO;
import model.Task;
import service.TaskNotificationService;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.JsonObject;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * REST API for tracking task progress with real-time notifications
 * Endpoints:
 * POST /api/tasks/update-status - Update task status and notify
 * GET /api/tasks/{taskId}/status - Get current task status
 */
@WebServlet(name = "TaskProgressAPI", urlPatterns = {"/api/tasks/update-status", "/api/tasks/progress"})
public class TaskProgressAPI extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(TaskProgressAPI.class);
    private static final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String taskIdStr = request.getParameter("taskId");
            String newStatus = request.getParameter("status");

            if (taskIdStr == null || taskIdStr.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("taskId and status parameters are required").toString());
                logger.warn("TaskProgressAPI.doPost: Missing required parameters");
                return;
            }

            try {
                int taskId = Integer.parseInt(taskIdStr);
                
                try (Connection connection = new DBContext().getConnection()) {
                    if (connection == null) {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.println(createErrorResponse("Database connection failed").toString());
                        logger.error("TaskProgressAPI.doPost: Failed to establish database connection");
                        return;
                    }
                    
                    TaskDAO taskDAO = new TaskDAO(connection);
                    Task task = taskDAO.getTaskById(taskId);

                    if (task == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.println(createErrorResponse("Task not found").toString());
                        logger.warn("TaskProgressAPI.doPost: Task {} not found", taskId);
                        return;
                    }

                    // Update status with real-time notification
                    TaskNotificationService notificationService = new TaskNotificationService(connection);
                    boolean success = notificationService.updateTaskStatusWithNotification(
                            taskId, newStatus, task.getAssignedTo() != null ? task.getAssignedTo() : 0, task.getTitle()
                    );

                    if (success) {
                        response.setStatus(HttpServletResponse.SC_OK);
                        JsonObject data = new JsonObject();
                        data.addProperty("taskId", taskId);
                        data.addProperty("previousStatus", task.getStatus());
                        data.addProperty("newStatus", newStatus);
                        data.addProperty("taskTitle", task.getTitle());
                        data.addProperty("timestamp", System.currentTimeMillis());
                        out.println(createSuccessResponse(data, "Task status updated and notification sent").toString());
                        logger.info("TaskProgressAPI: Task {} status updated to {}", taskId, newStatus);
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.println(createErrorResponse("Failed to update task status").toString());
                        logger.error("TaskProgressAPI: Failed to update task {} status", taskId);
                    }
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("Invalid taskId format").toString());
                logger.error("TaskProgressAPI.doPost: Invalid taskId format", e);
            }

        } catch (Exception e) {
            logger.error("TaskProgressAPI.doPost: Error updating task status", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(createErrorResponse("Error: " + e.getMessage()).toString());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("Task ID is required in URL path").toString());
                logger.warn("TaskProgressAPI.doGet: Task ID missing from URL path");
                return;
            }

            // Extract task ID from path: /api/tasks/{taskId}/status
            String[] parts = pathInfo.split("/");
            if (parts.length < 2) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("Invalid URL format").toString());
                logger.warn("TaskProgressAPI.doGet: Invalid URL format");
                return;
            }

            try {
                int taskId = Integer.parseInt(parts[1]);

                try (Connection connection = new DBContext().getConnection()) {
                    if (connection == null) {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.println(createErrorResponse("Database connection failed").toString());
                        logger.error("TaskProgressAPI.doGet: Failed to establish database connection");
                        return;
                    }
                    
                    TaskDAO taskDAO = new TaskDAO(connection);
                    Task task = taskDAO.getTaskById(taskId);

                    if (task == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.println(createErrorResponse("Task not found").toString());
                        logger.warn("TaskProgressAPI.doGet: Task {} not found", taskId);
                        return;
                    }

                    response.setStatus(HttpServletResponse.SC_OK);
                    JsonObject data = new JsonObject();
                    data.addProperty("taskId", task.getTaskId());
                    data.addProperty("title", task.getTitle());
                    data.addProperty("status", task.getStatus());
                    data.addProperty("priority", task.getPriority());
                    data.addProperty("assignedTo", task.getAssignedTo());
                    data.addProperty("dueDate", task.getDueDate() != null ? task.getDueDate().toString() : "");
                    data.addProperty("timestamp", System.currentTimeMillis());
                    out.println(createSuccessResponse(data, "Task status retrieved").toString());
                    logger.debug("TaskProgressAPI: Retrieved status for task {}", taskId);
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("Invalid task ID format").toString());
                logger.error("TaskProgressAPI.doGet: Invalid task ID format", e);
            }

        } catch (Exception e) {
            logger.error("TaskProgressAPI.doGet: Error retrieving task status", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(createErrorResponse("Error: " + e.getMessage()).toString());
        }
    }

    private JsonObject createSuccessResponse(JsonObject data, String message) {
        JsonObject response = new JsonObject();
        response.addProperty("success", true);
        response.addProperty("message", message);
        response.add("data", data);
        return response;
    }

    private JsonObject createErrorResponse(String message) {
        JsonObject response = new JsonObject();
        response.addProperty("success", false);
        response.addProperty("error", message);
        return response;
    }
}
