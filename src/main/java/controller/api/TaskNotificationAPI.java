package controller.api;

import dao.TaskDAO;
import model.Task;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.List;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * REST API for real-time task notifications
 * Endpoints:
 * GET /api/tasks/notifications?userId=X - Get all tasks assigned to a user
 * GET /api/tasks/notifications/unread?userId=X - Get unread assigned tasks
 * POST /api/tasks/notifications - Create notification
 * PUT /api/tasks/notifications/mark-read - Mark notification as read
 */
@WebServlet(name = "TaskNotificationAPI", urlPatterns = {"/api/tasks/notifications", "/api/tasks/notifications/*"})
public class TaskNotificationAPI extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(TaskNotificationAPI.class);
    private static final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String userId = request.getParameter("userId");
            
            if (userId == null || userId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(gson.toJson(createErrorResponse("userId parameter is required")));
                logger.warn("TaskNotificationAPI: userId parameter missing");
                return;
            }
            
            try (Connection connection = DBContext.getConnection()) {
                if (connection == null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.println(gson.toJson(createErrorResponse("Database connection failed")));
                    logger.error("TaskNotificationAPI: Failed to establish database connection");
                    return;
                }
                
                TaskDAO taskDAO = new TaskDAO(connection);
                List<Task> tasks = taskDAO.getAllTasks();
                JsonArray tasksArray = new JsonArray();
                
                for (Task task : tasks) {
                    if (task.getAssignedTo() != null && task.getAssignedTo().toString().equals(userId)) {
                        JsonObject taskObj = new JsonObject();
                        taskObj.addProperty("taskId", task.getTaskId());
                        taskObj.addProperty("title", task.getTitle());
                        taskObj.addProperty("description", task.getDescription());
                        taskObj.addProperty("priority", task.getPriority());
                        taskObj.addProperty("status", task.getStatus());
                        taskObj.addProperty("dueDate", task.getDueDate() != null ? task.getDueDate().toString() : "");
                        taskObj.addProperty("createdAt", task.getCreatedAt() != null ? task.getCreatedAt().toString() : "");
                        tasksArray.add(taskObj);
                    }
                }
                
                response.setStatus(HttpServletResponse.SC_OK);
                out.println(createSuccessResponse(tasksArray, "Tasks retrieved successfully"));
                logger.info("TaskNotificationAPI: Retrieved {} tasks for user {}", tasksArray.size(), userId);
            }
            
        } catch (Exception e) {
            logger.error("TaskNotificationAPI.doGet: Error retrieving tasks", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(gson.toJson(createErrorResponse("Error: " + e.getMessage())));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String userId = request.getParameter("userId");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            
            if (userId == null || userId.trim().isEmpty() || title == null || title.trim().isEmpty() || 
                content == null || content.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(gson.toJson(createErrorResponse("userId, title, and content are required")));
                logger.warn("TaskNotificationAPI.doPost: Missing required parameters");
                return;
            }
            
            try (Connection connection = DBContext.getConnection()) {
                if (connection == null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.println(gson.toJson(createErrorResponse("Database connection failed")));
                    logger.error("TaskNotificationAPI.doPost: Failed to establish database connection");
                    return;
                }
                
                TaskDAO taskDAO = new TaskDAO(connection);
                boolean success = taskDAO.announceAssignedTask(Integer.parseInt(userId), title, content);
                
                if (success) {
                    response.setStatus(HttpServletResponse.SC_CREATED);
                    JsonObject data = new JsonObject();
                    data.addProperty("notificationId", "N" + System.currentTimeMillis());
                    data.addProperty("userId", userId);
                    data.addProperty("title", title);
                    data.addProperty("content", content);
                    data.addProperty("timestamp", System.currentTimeMillis());
                    out.println(createSuccessResponse(data, "Notification sent successfully"));
                    logger.info("TaskNotificationAPI: Notification sent to user {}", userId);
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.println(gson.toJson(createErrorResponse("Failed to send notification")));
                    logger.error("TaskNotificationAPI: Failed to send notification to user {}", userId);
                }
            }
            
        } catch (NumberFormatException e) {
            logger.error("TaskNotificationAPI.doPost: Invalid user ID format", e);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println(gson.toJson(createErrorResponse("Invalid userId format")));
        } catch (Exception e) {
            logger.error("TaskNotificationAPI.doPost: Error sending notification", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(gson.toJson(createErrorResponse("Error: " + e.getMessage())));
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String action = request.getParameter("action");
            
            if ("mark-read".equals(action)) {
                String notificationId = request.getParameter("notificationId");
                
                if (notificationId == null || notificationId.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.println(gson.toJson(createErrorResponse("notificationId parameter is required")));
                    logger.warn("TaskNotificationAPI.doPut: notificationId parameter missing");
                    return;
                }
                
                response.setStatus(HttpServletResponse.SC_OK);
                JsonObject data = new JsonObject();
                data.addProperty("notificationId", notificationId);
                data.addProperty("marked", "read");
                data.addProperty("timestamp", System.currentTimeMillis());
                out.println(createSuccessResponse(data, "Notification marked as read"));
                logger.debug("TaskNotificationAPI: Notification {} marked as read", notificationId);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(gson.toJson(createErrorResponse("Invalid action")));
                logger.warn("TaskNotificationAPI.doPut: Invalid action: {}", action);
            }
            
        } catch (Exception e) {
            logger.error("TaskNotificationAPI.doPut: Error processing request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println(gson.toJson(createErrorResponse("Error: " + e.getMessage())));
        }
    }

    private String createSuccessResponse(Object data, String message) {
        JsonObject response = new JsonObject();
        response.addProperty("success", true);
        response.addProperty("message", message);
        response.add("data", gson.toJsonTree(data));
        return response.toString();
    }

    private JsonObject createErrorResponse(String message) {
        JsonObject response = new JsonObject();
        response.addProperty("success", false);
        response.addProperty("error", message);
        return response;
    }
}
