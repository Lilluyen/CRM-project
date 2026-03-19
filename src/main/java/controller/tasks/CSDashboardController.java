package controller.tasks;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/cs/dashboard"})
public class CSDashboardController extends HttpServlet{

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Customer Service Dashboard - CRM");
        req.setAttribute("contentPage", "cs/cs_dashboard.jsp");
        req.setAttribute("pageCss", "cs_dashboard.css");
        req.setAttribute("page", "cs_dashboard");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp); // resp.getWriter().print("oarhgesiurg");
    }
}
