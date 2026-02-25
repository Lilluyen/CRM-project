package controller.api;

import jakarta.websocket.server.ServerEndpoint;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.OnOpen;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.Session;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import com.google.gson.JsonObject;
import com.google.gson.Gson;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * WebSocket endpoint for real-time task notifications
 * Client should connect to: ws://localhost:8080/CRM-project/ws/notifications/{userId}
 * Sends real-time updates when tasks are assigned or status changes
 */
@ServerEndpoint("/ws/notifications/{userId}")
public class TaskNotificationWebSocket {

    private static final Logger logger = LoggerFactory.getLogger(TaskNotificationWebSocket.class);
    private static final Set<Session> sessions = Collections.synchronizedSet(new HashSet<>());
    private static final Gson gson = new Gson();

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userId) {
        sessions.add(session);
        session.getUserProperties().put("userId", userId);
        
        try {
            JsonObject message = new JsonObject();
            message.addProperty("type", "connected");
            message.addProperty("message", "Connected as user: " + userId);
            message.addProperty("timestamp", System.currentTimeMillis());
            session.getBasicRemote().sendText(message.toString());
            
            logger.info("User {} connected to notifications. Total sessions: {}", userId, sessions.size());
        } catch (IOException e) {
            logger.error("Error sending connection message to user {}: {}", userId, e.getMessage(), e);
        }
    }

    @OnMessage
    public void onMessage(Session session, String message) {
        String userId = (String) session.getUserProperties().get("userId");
        
        try {
            JsonObject json = gson.fromJson(message, JsonObject.class);
            String action = json.get("action") != null ? json.get("action").getAsString() : "";
            
            if ("ping".equals(action)) {
                JsonObject pong = new JsonObject();
                pong.addProperty("type", "pong");
                pong.addProperty("timestamp", System.currentTimeMillis());
                session.getBasicRemote().sendText(pong.toString());
            } else if ("heartbeat".equals(action)) {
                JsonObject response = new JsonObject();
                response.addProperty("type", "heartbeat_ack");
                response.addProperty("timestamp", System.currentTimeMillis());
                session.getBasicRemote().sendText(response.toString());
            } else {
                logger.debug("Unknown action from user {}: {}", userId, action);
            }
        } catch (Exception e) {
            logger.error("Error processing message from user {}: {}", userId, e.getMessage(), e);
        }
    }

    @OnClose
    public void onClose(Session session) {
        String userId = (String) session.getUserProperties().get("userId");
        sessions.remove(session);
        logger.info("User {} disconnected from notifications. Total sessions: {}", userId, sessions.size());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        String userId = (String) session.getUserProperties().get("userId");
        System.out.println("Error for user " + userId + ": " + throwable.getMessage());
        throwable.printStackTrace();
    }

    /**
     * Broadcast task notification to a specific user
     */
    public static void notifyTaskAssigned(int userId, String taskTitle, int taskId) {
        broadcastToUser(userId, createTaskNotification("task_assigned", taskTitle, taskId));
    }

    /**
     * Broadcast task status change to a specific user
     */
    public static void notifyTaskStatusChanged(int userId, String taskTitle, String newStatus, int taskId) {
        JsonObject notification = createTaskNotification("task_status_changed", taskTitle, taskId);
        notification.addProperty("newStatus", newStatus);
        broadcastToUser(userId, notification);
    }

    /**
     * Broadcast notification to user
     */
    private static void broadcastToUser(int userId, JsonObject notification) {
        String userIdStr = String.valueOf(userId);
        synchronized (sessions) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    String sessionUserId = (String) session.getUserProperties().get("userId");
                    if (userIdStr.equals(sessionUserId)) {
                        try {
                            session.getBasicRemote().sendText(notification.toString());
                            System.out.println("Notification sent to user: " + userId);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }

    /**
     * Create a task notification JSON object
     */
    private static JsonObject createTaskNotification(String type, String title, int taskId) {
        JsonObject notification = new JsonObject();
        notification.addProperty("type", type);
        notification.addProperty("taskTitle", title);
        notification.addProperty("taskId", taskId);
        notification.addProperty("timestamp", System.currentTimeMillis());
        return notification;
    }

    /**
     * Get active sessions count
     */
    public static int getActiveSessionsCount() {
        return sessions.size();
    }
}
