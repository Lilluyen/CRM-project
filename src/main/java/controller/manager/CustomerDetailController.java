package controller.manager;

import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.CustomerService;
import util.ControllerUltil;

import java.io.IOException;

@WebServlet(name = "CustomerDetailController", urlPatterns = { "/customers/detail" })
public class CustomerDetailController extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdRaw = request.getParameter("customerId");

        if (customerIdRaw == null || customerIdRaw.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "customerId is required");
            return;
        }

        try {

            int customerId = Integer.parseInt(customerIdRaw);

            // 🔥 GỌI SERVICE
            CustomerDetailDTO customerDetail = customerService.getCustomerDetail(customerId);

            if (customerDetail == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
                return;
            }

            // 🔥 Set data cho view
            request.setAttribute("customerDetail", customerDetail);

            // Layout attributes
            request.setAttribute("pageTitle", "Customer Detail | Clothes CRM");
            request.setAttribute("contentPage", "customer/customer_detail.jsp");
            request.setAttribute("pageCss", "customer_detail.css");
            request.setAttribute("page", "customer-detail");

            request.getRequestDispatcher("/view/layout.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customerId");

        } catch (Exception e) {

            log("Error while loading customer detail", e);

            ControllerUltil.forwardError(
                    request,
                    response,
                    "Internal server error occurred while processing your request.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}