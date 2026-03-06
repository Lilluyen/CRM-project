package websocket;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;
import jakarta.servlet.http.HttpSession;
import jakarta.websocket.CloseReason;
import jakarta.websocket.EndpointConfig;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import model.Notification;
import model.User;
import service.NotificationService;
import util.DBContext;

import java.sql.Connection;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

@ServerEndpoint(value = "/ws/notifications/{userId}", configurator = HttpSessionConfigurator.class)
public class NotificationWebSocketEndpoint {
    private static final Logger LOG = Logger.getLogger(NotificationWebSocketEndpoint.class.getName());
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM HH:mm");

    private static final ConcurrentHashMap<Integer, Set<Session>> USER_SESSIONS = new ConcurrentHashMap<>();

    private int userId;

    @OnOpen
    public void onOpen(Session session, EndpointConfig config, @PathParam("userId") int userId) {
        this.userId = userId;

        HttpSession httpSession = (HttpSession) config.getUserProperties().get(HttpSessionConfigurator.HTTP_SESSION);
        if (httpSession == null) {
            closeSilently(session, CloseReason.CloseCodes.VIOLATED_POLICY, "Missing HTTP session");
            return;
        }

        User u = (User) httpSession.getAttribute("user");
        if (u == null) {
            closeSilently(session, CloseReason.CloseCodes.VIOLATED_POLICY, "Unauthorized");
            return;
        }
        if (u.getUserId() != userId) {
            closeSilently(session, CloseReason.CloseCodes.VIOLATED_POLICY, "User mismatch");
            return;
        }

        USER_SESSIONS.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet()).add(session);

        // Send initial unread sync so header is accurate even without reload
        try (Connection conn = DBContext.getConnection()) {
            NotificationService ns = new NotificationService(conn);
            List<Notification> unread = ns.getUnreadForUser(userId);
            int count = unread.size();
            send(session, buildSyncPayload(count, unread));
        } catch (Exception e) {
            LOG.log(Level.WARNING, "WS initial sync error for user " + userId, e);
        }
    }

    @OnMessage
    public void onMessage(Session session, String message) {
        JsonObject obj;
        try {
            obj = GSON.fromJson(message, JsonObject.class);
        } catch (JsonSyntaxException e) {
            e.printStackTrace();
            return;
        }
        if (obj == null) return;

        String action = obj.has("action") ? safeString(obj.get("action").getAsString()) : "";
        if ("mark_all_read".equalsIgnoreCase(action)) {
            try (Connection conn = DBContext.getConnection()) {
                NotificationService ns = new NotificationService(conn);
                ns.markAllAsRead(this.userId);
                sendToUser(this.userId, buildResetPayload());
            } catch (Exception e) {
                LOG.log(Level.WARNING, "WS mark_all_read error for user " + userId, e);
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        Set<Session> set = USER_SESSIONS.get(userId);
        if (set != null) {
            set.remove(session);
            if (set.isEmpty()) USER_SESSIONS.remove(userId);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        LOG.log(Level.FINE, "WS error for user " + userId, throwable);
    }

    public static void pushNewUnread(int userId, Notification notification, int unreadCount) {
        JsonObject root = new JsonObject();
        root.addProperty("event", "new");
        root.addProperty("count", unreadCount);
        root.add("item", toItem(notification));
        sendToUser(userId, GSON.toJson(root));
    }

    public static void pushSync(int userId, List<Notification> unread) {
        sendToUser(userId, buildSyncPayload(unread != null ? unread.size() : 0, unread));
    }

    private static String buildResetPayload() {
        JsonObject root = new JsonObject();
        root.addProperty("event", "reset");
        root.addProperty("count", 0);
        root.add("items", new JsonArray());
        return GSON.toJson(root);
    }

    private static String buildSyncPayload(int count, List<Notification> unread) {
        JsonObject root = new JsonObject();
        root.addProperty("event", "sync");
        root.addProperty("count", count);
        JsonArray arr = new JsonArray();
        if (unread != null) {
            for (Notification n : unread) arr.add(toItem(n));
        }
        root.add("items", arr);
        return GSON.toJson(root);
    }

    private static JsonObject toItem(Notification n) {
        JsonObject o = new JsonObject();
        if (n == null) return o;
        o.addProperty("id", n.getNotificationId());
        o.addProperty("title", n.getTitle());
        o.addProperty("content", n.getContent());
        o.addProperty("type", n.getType());
        o.addProperty("relatedType", n.getRelatedType());
        if (n.getRelatedId() != null) o.addProperty("relatedId", n.getRelatedId());
        else o.add("relatedId", null);
        o.addProperty("createdAt", n.getCreatedAt() != null ? n.getCreatedAt().format(FMT) : "");
        return o;
    }

    private static void sendToUser(int userId, String payload) {
        Set<Session> set = USER_SESSIONS.get(userId);
        if (set == null || set.isEmpty()) return;
        for (Session s : set) {
            send(s, payload);
        }
    }

    private static void send(Session s, String payload) {
        if (s == null || !s.isOpen()) return;
        try {
            s.getAsyncRemote().sendText(payload);
        } catch (Exception ignored) {
        }
    }

    private static void closeSilently(Session s, CloseReason.CloseCode code, String reason) {
        try {
            s.close(new CloseReason(code, reason));
        } catch (Exception ignored) {
        }
    }

    private static String safeString(String s) {
        return s == null ? "" : s.trim();
    }
}

