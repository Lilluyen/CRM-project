package controller.customer;

import java.io.IOException;

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
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        // Handle GET requests to display the customer list
        CustomerDAO customerDAO = new CustomerDAO();
        request.setAttribute("customers", customerDAO.getAllCustomers());

        try {
            request.getRequestDispatcher("/view/customer/customerList.jsp")
                    .forward(request, response);

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
