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

/**
 * REST API for tracking task progress with real-time notifications
 * Endpoints:
 * POST /api/tasks/update-status - Update task status and notify
 * GET /api/tasks/{taskId}/status - Get current task status
 */
@WebServlet(name = "TaskProgressAPI", urlPatterns = {"/api/tasks/update-status", "/api/tasks/progress"})
public class TaskProgressAPI extends HttpServlet {

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

            if (taskIdStr == null || newStatus == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("taskId and status parameters are required").toString());
                return;
            }

            int taskId = Integer.parseInt(taskIdStr);
            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);

            // Get task details to find assigned user
            Task task = taskDAO.getTaskById(taskId);

            if (task == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.println(createErrorResponse("Task not found").toString());
                connection.close();
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
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.println(createErrorResponse("Failed to update task status").toString());
            }

            connection.close();

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println(createErrorResponse("Invalid taskId format").toString());
        } catch (Exception e) {
            e.printStackTrace();
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
                return;
            }

            // Extract task ID from path: /api/tasks/{taskId}/status
            String[] parts = pathInfo.split("/");
            if (parts.length < 2) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.println(createErrorResponse("Invalid URL format").toString());
                return;
            }

            int taskId = Integer.parseInt(parts[1]);

            Connection connection = DBContext.getConnection();
            TaskDAO taskDAO = new TaskDAO(connection);
            Task task = taskDAO.getTaskById(taskId);

            if (task == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.println(createErrorResponse("Task not found").toString());
                connection.close();
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
            out.println(createSuccessResponse(data, "Task status retrieved").toString());

            connection.close();

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println(createErrorResponse("Invalid task ID format").toString());
        } catch (Exception e) {
            e.printStackTrace();
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
