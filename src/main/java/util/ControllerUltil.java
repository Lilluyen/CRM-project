package ultil;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ControllerUltil {

    public static void forwardError(HttpServletRequest request,
            HttpServletResponse response,
            String message) {
        try {
            request.setAttribute("errorMessage", message);
            request.getRequestDispatcher("/view/error/error.jsp")
                    .forward(request, response);
        } catch (ServletException | IOException e) {
            e.printStackTrace();
        }
    }
}
