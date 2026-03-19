package controller.manager;

import dao.UserDAO;
import dto.Pagination;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CustomerSegment;
import model.User;
import service.CustomerSegmentService;
import util.ControllerUltil;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/customers/segments"})
public class CustomerSegmentController extends HttpServlet {
    private static final int DEFAULT_SIZE = 10;
    private final CustomerSegmentService service = new CustomerSegmentService();
    private final UserDAO userDAO = new UserDAO();

    // ── GET ───────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int page = 1;
        int size = DEFAULT_SIZE;
        try {


            page = getPage(req, "page");
            size = getSize(req, "pageSize");

            // Giới hạn size hợp lệ
            if (size != 5 && size != 10 && size != 20) {
                size = 10;
            }
            if (page < 1) {
                page = 1;
            }

            int totalRecords = service.countAllSegmentations(null, null, null, null, null, null);
            Pagination pagination = new Pagination(page, size, totalRecords);
            List<CustomerSegment> cs = service.getAllSegmentations(page, size);
            List<User> users = userDAO.getActiveUsers();

            req.setAttribute("customerSegments", cs);
            req.setAttribute("staffs", users);
            req.setAttribute("pagination", pagination);
            req.setAttribute("totalRecord", totalRecords);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageTitle", "Customer Segments | Clothes CRM");
            req.setAttribute("contentPage", "customer/segment_customer.jsp");
            req.setAttribute("pageCss", "segment_customer.css");
            req.setAttribute("pageJs", "SegmentCustomer.js");
            req.setAttribute("page", "customer-segments");

            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (Exception err) {
            resp.setStatus(500);
            System.out.print(("Lỗi server: " + err.getMessage()));
        }
    }

    // ── POST ──────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
    }

    // ── Helpers ───────────────────────────────────────────────────

    private Integer nullInt(String v) {
        if (v == null || v.isBlank()) return null;
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int intOr(String v, int def) {
        if (v == null || v.isBlank()) return def;
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    // ── Response wrapper ──────────────────────────────────────────
    private static class ApiResponse {
        public final boolean success;
        public final Object data;
        public final String message;

        ApiResponse(boolean success, Object data, String message) {
            this.success = success;
            this.data = data;
            this.message = message;
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