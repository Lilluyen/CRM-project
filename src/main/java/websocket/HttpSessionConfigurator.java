package websocket;

import jakarta.servlet.http.HttpSession;
import jakarta.websocket.HandshakeResponse;
import jakarta.websocket.server.HandshakeRequest;
import jakarta.websocket.server.ServerEndpointConfig;

/**
 * Exposes HttpSession to WebSocket endpoints (via user properties).
 */
public class HttpSessionConfigurator extends ServerEndpointConfig.Configurator {
    public static final String HTTP_SESSION = "httpSession";

    @Override
    public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
        Object httpSession = request.getHttpSession();
        if (httpSession instanceof HttpSession) {
            sec.getUserProperties().put(HTTP_SESSION, httpSession);
        }
        super.modifyHandshake(sec, request, response);
    }
}

