package controller.manager;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import java.io.IOException;
import java.sql.SQLException;
import dto.CustomerPageResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;
import service.CustomerService;
import util.ControllerUltil;

@WebServlet(name = "CustomerListController", urlPatterns = {"/customers"})
public class CustomerListController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {

    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        int page = 1;
        int size = DEFAULT_SIZE;

        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
            if (request.getParameter("size") != null) {
                size = Integer.parseInt(request.getParameter("size"));
            }
            CustomerService customerService = new CustomerService();
            CustomerPageResult result = customerService.getCustomerList(page, size);

            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                Gson gson = new GsonBuilder()
                        .registerTypeAdapter(LocalDateTime.class,
                                (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context)
                                -> new JsonPrimitive(src.toString()))
                        .create();
                response.getWriter().write(gson.toJson(result));
                return;
            }
            request.setAttribute("customerList", result.getCustomers());
            request.setAttribute("totalPages", result.getTotalPages(size));
            request.setAttribute("currentPage", page);

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

}
