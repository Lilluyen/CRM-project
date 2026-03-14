package controller.manager;

import dao.*;
import dto.Pagination;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import service.CustomerService;
import util.ControllerUltil;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "CustomerListController", urlPatterns = {"/customers"})
public class CustomerListController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    private final CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerMeasurementDAO,
            customerSegmentDAO);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {

    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int page = 1;
        int size = DEFAULT_SIZE;


        try {
            page = getPage(request, "page");
            size = getSize(request, "pageSize");

            // Giới hạn size hợp lệ
            if (size != 5 && size != 10 && size != 20) {
                size = 10;
            }
            if (page < 1) {
                page = 1;
            }
            int totalRecords = customerService.countTotalCustomer(null, null, null, null, null, null);
            List<Customer> customers;
            Pagination pagination = new Pagination(page, size, totalRecords);
            customers = customerService.getCustomerList(page, size);

            request.setAttribute("pagination", pagination);

            request.setAttribute("currentPage", page);
            request.setAttribute("customerList", customers);
            request.setAttribute("totalRecord", totalRecords);
            request.setAttribute("pageTitle", "Customer List | Clothes CRM");
            request.setAttribute("contentPage", "customer/customerList.jsp");
            request.setAttribute("pageCss", "customerList.css");
            request.setAttribute("pageJs", "CustomerList.js");
            request.setAttribute("page", "customer-list");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        } catch (SQLException ex) {
            log("DB error", ex);
            ControllerUltil.forwardError(request, response, "Database error.");
        }
    }

    private int getPage(HttpServletRequest request, String param) {
        String value = request.getParameter(param);
        if (value == null) return 1;
        return ControllerUltil.parsePage(value);
    }

    private int getSize(HttpServletRequest request, String param) {
        String value = request.getParameter(param);
        if (value == null) return DEFAULT_SIZE;
        return ControllerUltil.parseSize(value);
    }


}
