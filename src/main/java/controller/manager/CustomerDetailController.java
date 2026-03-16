package controller.manager;

import dao.*;
import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.StyleTag;
import service.CustomerService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerDetailController", urlPatterns = {"/customers/detail"})
public class CustomerDetailController extends HttpServlet {

    CustomerDAO customerDAO = new CustomerDAO();
    CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();
    CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerMeasurementDAO,
            customerSegmentDAO);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String customerIdRaw = request.getParameter("customerId");

            if (customerIdRaw == null || customerIdRaw.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/customers");
                return;
            }
            int customerId;
            try {
                customerId = Integer.parseInt(customerIdRaw);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/customers");

                return;
            }

            // 🔥 GỌI SERVICE
            CustomerDetailDTO customerDetail = customerService.getCustomerDetail(customerId);
            List<StyleTag> styleTags = customerService.getListStyleTags();
            if (customerDetail == null) {
                response.sendRedirect(request.getContextPath() + "/customers");
                return;
            }

            // 🔥 Set data cho view
            request.setAttribute("customerDetail", customerDetail);
            request.setAttribute("allStyleTags", styleTags);

            // Layout attributes
            request.setAttribute("pageTitle", "Customer Detail | Clothes CRM");
            request.setAttribute("contentPage", "customer/customer_detail.jsp");
            request.setAttribute("pageCss", "customer_detail.css");
            // request.setAttribute("pageJs", "customer_detail.js");
            request.setAttribute("page", "customer-detail");

            request.getRequestDispatcher("/view/layout.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customers");

        } catch (Exception e) {

            log("Error while loading customer detail", e);
            response.sendRedirect(request.getContextPath() + "/customers");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/customers");
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}