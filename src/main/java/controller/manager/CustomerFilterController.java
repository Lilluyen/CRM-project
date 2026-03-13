package controller.manager;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import dao.CustomerDAO;
import dao.CustomerMeasurementDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import dto.CustomerFilterRequest;
import dto.CustomerPageResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.CustomerService;
import util.ControllerUltil;

@WebServlet(name = "CustomerFilterController", urlPatterns = { "/customers/filter" })
public class CustomerFilterController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int page = 1;
        int size = DEFAULT_SIZE;

        try {
            // ===== PAGINATION =====
            if (request.getParameter("page") != null) {
                page = ControllerUltil.parsePage(request.getParameter("page"));
            }
            if (request.getParameter("size") != null) {
                size = ControllerUltil.parseSize(request.getParameter("size"));
            }

            // ===== SESSION ID (Keyset Pagination) =====
            HttpSession httpSession = request.getSession();
            String sessionId = request.getParameter("sessionId");

            // Nếu JS không gửi lên thì fallback lấy từ HttpSession
            if (sessionId == null || sessionId.isBlank()) {
                sessionId = (String) httpSession.getAttribute("customerFilterSession");
            }

            // Reset session nếu về trang 1
            if (page == 1) {
                sessionId = null;
                httpSession.removeAttribute("customerFilterSession");
            }

            // ===== BASIC FILTER =====
            String keyword = trimToNull(request.getParameter("keyword"));
            String returnRateMode = trimToNull(request.getParameter("returnRateMode"));

            // ===== MULTI SELECT FILTER =====
            List<String> loyaltyTiers = parseCSV(request.getParameter("tiers"));
            List<String> bodyShapes = parseCSV(request.getParameter("bodyShapes"));
            List<String> sizes = parseCSV(request.getParameter("sizes"));
            List<Integer> tagIds = parseIntCSV(request.getParameter("tags"));

            CustomerFilterRequest filterRequest = new CustomerFilterRequest();
            filterRequest.setPage(page);
            filterRequest.setPageSize(size);
            filterRequest.setKeyword(keyword);
            filterRequest.setBodyShapes(bodyShapes);
            filterRequest.setLoyaltyTiers(loyaltyTiers);
            filterRequest.setReturnRateMode(returnRateMode);
            filterRequest.setTagIds(tagIds);
            filterRequest.setSizes(sizes);

            // ===== CALL SERVICE =====
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
            CustomerPageResult result = customerService.filterAdvanced(filterRequest, sessionId);

            // Lưu sessionId mới vào HttpSession cho request tiếp theo
            if (result.getSessionId() != null) {
                httpSession.setAttribute("customerFilterSession", result.getSessionId());
            }

            // ===== RETURN JSON (AJAX) =====
            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                Gson gson = new GsonBuilder()
                        .registerTypeAdapter(LocalDateTime.class,
                                (JsonSerializer<LocalDateTime>) (src, typeOfSrc,
                                        context) -> new JsonPrimitive(src.format(formatter)))
                        .create();
                response.getWriter().write(gson.toJson(result));
                return;
            }

            request.setAttribute("customerList", result.getData());
            request.setAttribute("totalPages", result.getTotalPages());
            request.setAttribute("totalRecord", result.getTotalRecords());
            request.setAttribute("sessionId", result.getSessionId());
            request.setAttribute("currentPage", page);
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

    private List<String> parseCSV(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }

    private List<Integer> parseIntCSV(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .map(Integer::parseInt)
                .toList();
    }
}
