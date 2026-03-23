package controller.sale;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/add-tag")
public class AddTagController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();

    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();
    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO,
            contactDAO, noteDAO);

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        int customerId;
        try {
            customerId = Integer.parseInt(request.getParameter("customerId"));
            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customers");
        } catch (Exception e) {
            log("Error redirecting to customer detail", e);

            response.sendRedirect(request.getContextPath() + "/customers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {
        int customerId;
        try {
            customerId = Integer.parseInt(request.getParameter("customerId"));
            List<Integer> styleTags = new ArrayList<>();
            String[] tagParams = request.getParameterValues("tagIds");

            if (tagParams != null) {
                for (String tagId : tagParams) {
                    styleTags.add(Integer.valueOf(tagId));
                }
            }
            customerService.addStyleTagsToCustomer(customerId, styleTags);

            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        } catch (Exception e) {
            log("Error adding tags to customer", e);
            request.setAttribute("errorMessage", "Failed to add tags to customer.");
            response.sendRedirect(request.getContextPath() + "/customers?status=failed");
        }

    }
}
