package controller.manager;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.CustomerQueryDAO;
import dao.CustomerStyleDAO;
import dto.CustomerListDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StyleTag;
import util.ControllerUltil;

@WebServlet(name = "CustomerListController", urlPatterns = { "/customer/list-customer" })
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
        CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
        CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
        try {
            List<CustomerListDTO> customerList = customerQueryDAO.getCustomerList();
            List<StyleTag> styleTagList = customerStyleDAO.getAllStyleTags();
            request.setAttribute("styleTagList", styleTagList);
            request.setAttribute("customerList", customerList);
            request.getRequestDispatcher("/view/customer/customerList.jsp")
                    .forward(request, response);

            return;

        } catch (SQLException e) {
            log("DB error", e);
            ControllerUltil.forwardError(request, response,
                    "Database error occurred while retrieving customer list.");
            return;

        } catch (ServletException | IOException e) {
            log("View error", e);
            ControllerUltil.forwardError(request, response,
                    "Internal server error occurred while processing your request.");
            return;
        }
    }
}
