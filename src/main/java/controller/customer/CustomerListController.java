package controller.customer;

import java.io.IOException;
import java.sql.SQLException;

import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CustomerListController", urlPatterns = { "/customers/list" })
public class CustomerListController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // Handle POST requests if needed
        try {
            doProcess(request, response);
        } catch (ServletException | IOException e) {
            log("CustomerListController - doPost failed", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        try {
            doProcess(request, response);
        } catch (ServletException | IOException e) {
            log("CustomerListController - doGet failed", e);
        }

    }

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle GET requests to display the customer list
        CustomerDAO customerDAO = new CustomerDAO();

        try {
            request.setAttribute("customers", customerDAO.getAllCustomers());
            request.getRequestDispatcher("/view/customer/customerList.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            log("DB error", e);
            request.setAttribute("errorMessage", "Error database.");
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);

        } catch (ServletException | IOException e) {
            log("CustomerListController - forward customerList.jsp failed", e);

            request.setAttribute("errorMessage", "Error retrieving customer list.");
            try {
                request.getRequestDispatcher("/view/error.jsp")
                        .forward(request, response);
            } catch (ServletException | IOException ex) {
                log("CustomerListController - forward error.jsp failed", ex);
            }
        }
    }
}
