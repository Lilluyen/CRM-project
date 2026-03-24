package listener;

import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import jakarta.servlet.annotation.WebListener;
import model.User;
import websocket.NotificationWebSocketEndpoint;

@WebListener
public class SessionListener implements HttpSessionListener {

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {

        User u = (User) se.getSession().getAttribute("user");

        if (u != null) {
            NotificationWebSocketEndpoint.disconnectUser(u.getUserId());
        }
    }
}