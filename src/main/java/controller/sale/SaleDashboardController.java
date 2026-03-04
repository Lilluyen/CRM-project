package controller.sale;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet( urlPatterns = {"/sale/dashboard"})

public class SaleDashboardController extends HttpServlet{

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
         req.setAttribute("pageTitle", "Sale Dashboard - CRM");
        req.setAttribute("contentPage", "sale/sale_dashboard.jsp");
        req.setAttribute("pageCss", "sale_dashboard.css");
        req.setAttribute("page", "sale_dashboard");

        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }
    
}
