package controller.manager;

import dao.CustomerDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import dto.Pagination;
import dto.TimeCondition;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.CustomerSegment;
import service.CustomerSegmentService;
import service.CustomerService;
import util.ControllerUltil;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "CustomerFilterController", urlPatterns = {"/customers/filter"})
public class CustomerFilterController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerSegmentService customerSegmentService = new CustomerSegmentService();
    private final CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int page = 1;
        int size = DEFAULT_SIZE;
        try {
            // ===== PAGINATION =====
            page = getPage(request, "page");
            size = getSize(request, "size");
            String keyword = trimToNull(request.getParameter("keyword"));
            List<String> loyaltyTiers = parseCSV(request.getParameterValues("loyaltyFilter"));
            List<String> source = parseCSV(request.getParameterValues("source"));
            String returnRate = (trimToNull(request.getParameter("returnRateFilter")));
            String gender = trimToNull(request.getParameter("gender"));
            List<TimeCondition> timeConditions = getTimeConditionDatas(request);

            int totalRecords = customerService.countTotalCustomer(keyword, loyaltyTiers, source, gender, timeConditions);
            Pagination pagination = new Pagination(page, size, totalRecords);
            List<Customer> customers = customerService.filterAdvanced(keyword, loyaltyTiers, source, gender, timeConditions, page, size);
            List<CustomerSegment> customerSegments = customerSegmentService.getStaticSegments();
            request.setAttribute("pagination", pagination);
            request.setAttribute("currentPage", page);
            request.setAttribute("customerList", customers);
            request.setAttribute("totalRecord", totalRecords);
            request.setAttribute("segments", customerSegments);
            request.setAttribute("keyword", keyword);
            request.setAttribute("loyaltyFilterSelected", loyaltyTiers != null ? loyaltyTiers.get(0) : null);
            request.setAttribute("sourceSelected", source != null ? source.get(0) : null);
            request.setAttribute("returnRateFilter", returnRate);
            request.setAttribute("pageTitle", "Customer List | Clothes CRM");
            request.setAttribute("contentPage", "customer/customerList.jsp");
            request.setAttribute("pageCss", "customerList.css");
            request.setAttribute("pageJs", "CustomerList.js");
            request.setAttribute("page", "customer-list");

            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (SQLException ex) {
            log("Filter DB error", ex);
            response.sendError(500, "Database error");
        }
    }

    // =========================
    // Helpers
    // =========================
    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private List<String> parseCSV(String[] raw) {
        if (raw == null || raw.length == 0) {
            return null;
        }
        return Arrays.stream(raw)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
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

    private List<TimeCondition> getTimeConditionDatas(HttpServletRequest request) {
        String[] fields = request.getParameterValues("time_conditions");
        String[] operators = request.getParameterValues("operators");
        String[] dates = request.getParameterValues("dates");
        String[] subConditions = request.getParameterValues("subconditions");

        List<TimeCondition> timeConditions = new ArrayList<>();
        if (dates != null) {
            for (int i = 0; i < dates.length; i++) {
                if (ControllerUltil.parseDate(dates[i]) != null && !dates[i].isBlank()) {
                    TimeCondition t = new TimeCondition(fields[i], operators[i], LocalDate.parse(dates[i]),
                            (i + 1 == dates.length) ? null : subConditions[i]);
                    timeConditions.add(t);
                }
            }
        }
        return timeConditions;
    }


}
