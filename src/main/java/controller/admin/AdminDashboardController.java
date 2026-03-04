package controller.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
         req.setAttribute("pageTitle", "Admin Dashboard - CRM");
        req.setAttribute("contentPage", "admin/admin_dashboard.jsp");
        req.setAttribute("pageCss", "admin_dashboard.css");
        req.setAttribute("page", "admin_dashboard");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }
    
}
