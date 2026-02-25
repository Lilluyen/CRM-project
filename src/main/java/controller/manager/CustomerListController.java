package controller.manager;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dto.CustomerListDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StyleTag;
import service.CustomerService;
import util.ControllerUltil;

@WebServlet(name = "CustomerListController", urlPatterns = { "/customers" })
public class CustomerListController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // Handle POST requests if needed
        try {
            doProcess(request, response);
        } catch (ServletException | IOException e) {
            log("CustomerListController - doPost failed", e);
            ControllerUltil.forwardError(request, response, "Failed to retrieve customer list.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        try {
            doProcess(request, response);
        } catch (ServletException | IOException e) {
            log("CustomerListController - doGet failed", e);
            ControllerUltil.forwardError(request, response, "Failed to retrieve customer list.");
        }

    }

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle GET requests to display the customer list
        CustomerService customerService = new CustomerService();
        try {
            List<CustomerListDTO> customerList = customerService.getCustomerList();
            List<StyleTag> styleTagList = customerService.getListStyleTags();
            request.setAttribute("styleTagList", styleTagList);
            request.setAttribute("customerList", customerList);
            request.getRequestDispatcher("/view/customer/customerList.jsp")
                    .forward(request, response);


        } catch (SQLException e) {
            log("DB error", e);
            ControllerUltil.forwardError(request, response,
                    "Database error occurred while retrieving customer list.");

        } catch (ServletException | IOException e) {
            log("View error", e);
            ControllerUltil.forwardError(request, response,
                    "Internal server error occurred while processing your request.");
        }
    }
}
