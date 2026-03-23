package controller.manager;

import com.fasterxml.jackson.databind.ObjectMapper;
import dao.*;
import dto.CustomerSearchResultDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.CustomerService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerSearchController", urlPatterns = {"/customers/search"})
public class CustomerSearchController extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();

    private final CustomerService customerService = new CustomerService(
            customerDAO, customerStyleDAO, customerQueryDAO,
            customerSegmentDAO, contactDAO, noteDAO);

    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final int MAX_RESULTS = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("[]");
            return;
        }

        String keyword = req.getParameter("keyword");
        String excludeRaw = req.getParameter("exclude");

        // Keyword phải có ít nhất 2 ký tự
        if (keyword == null || keyword.trim().length() < 2) {
            resp.getWriter().write("[]");
            return;
        }

        int excludeId = -1;
        try {
            if (excludeRaw != null) excludeId = Integer.parseInt(excludeRaw);
        } catch (NumberFormatException ignored) {
        }

        try {
            List<CustomerSearchResultDTO> results =
                    customerService.searchForMerge(keyword.trim(), excludeId, MAX_RESULTS);

            resp.getWriter().write(MAPPER.writeValueAsString(results));

        } catch (Exception e) {
            log("Customer search error", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("[]");
        }
    }
}