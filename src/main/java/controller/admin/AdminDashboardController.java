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
        // TODO: Replace these with real dashboard metrics from services
        req.setAttribute("totalCustomers", 1245);
        req.setAttribute("newLeads", 328);
        req.setAttribute("openOpportunities", 76);
        req.setAttribute("revenue", "$18,420");

        req.setAttribute("pageTitle", "Admin Dashboard - CRM");
        req.setAttribute("contentPage", "/view/admin/admin_dashboard.jsp");
        req.setAttribute("pageCss", "admin_dashboard.css");
        req.setAttribute("pageJs", "admin_dashboard.js");
        req.setAttribute("page", "admin_dashboard");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }
}

