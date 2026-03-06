package controller.sale;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.CustomerService;

@WebServlet("/add-tag")
public class AddTagController extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        try {
            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);
        } catch (Exception e) {
            log("Error redirecting to customer detail", e);

            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        try {

            List<Integer> styleTags = new ArrayList<>();
            String[] tagParams = request.getParameterValues("tagIds");

            if (tagParams != null) {
                for (String tagId : tagParams) {
                    styleTags.add(Integer.valueOf(tagId));
                }
            }
            customerService.addStyleTagsToCustomer(customerId, styleTags);

            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);

        } catch (Exception e) {
            log("Error adding tags to customer", e);
            request.setAttribute("errorMessage", "Failed to add tags to customer.");
            response.sendRedirect(request.getContextPath() + "/customers/detail?customerId=" + customerId);
        }

    }
}
