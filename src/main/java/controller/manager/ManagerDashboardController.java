package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = "/manager/dashboard")
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.setAttribute("pageTitle", "Manager Dashboard - CRM");
        request.setAttribute("contentPage", "manager/manager_dashboard.jsp");
//        request.setAttribute("pageCss", "marketing_dashboard.css");
        request.setAttribute("page", "marketing-dashboard");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }


}
