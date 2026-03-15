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
import java.time.LocalDate;
import java.util.List;

@WebServlet(urlPatterns = "/customers/segments/filter")
public class CustomerSegmentFilterController extends HttpServlet {

    private static final int DEFAULT_SIZE = 10;
    private final CustomerSegmentService service = new CustomerSegmentService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int size = DEFAULT_SIZE;
        try {


            page = getPage(req, "page");
            size = getSize(req, "pageSize");
            String keyword = trimToNull(req.getParameter("keyword"));
            String segmentType = trimToNull(req.getParameter("segment_type"));
            String creatorParam = req.getParameter("created_by");
            Integer creator = null;

            if (creatorParam != null && !creatorParam.isBlank()) {
                try {
                    creator = Integer.valueOf(creatorParam);
                } catch (NumberFormatException e) {
                    creator = null;
                }
            }

            String updaterParam = req.getParameter("updated_by");
            Integer updater = null;

            if (updaterParam != null && !updaterParam.isBlank()) {
                try {
                    updater = Integer.valueOf(updaterParam);
                } catch (NumberFormatException e) {
                    updater = null;
                }

            }

            String fromDateRaw = trimToNull(req.getParameter("from_date"));
            LocalDate fromDate = null;
            if (fromDateRaw != null) {
                fromDate = ControllerUltil.parseDate(fromDateRaw);
            }

            String toDateRaw = trimToNull(req.getParameter("to_date"));
            LocalDate toDate = null;
            if (toDateRaw != null) {
                toDate = ControllerUltil.parseDate(toDateRaw);
            }
            // Giới hạn size hợp lệ
            if (size != 5 && size != 10 && size != 20) {
                size = 10;
            }
            if (page < 1) {
                page = 1;
            }

            int totalRecords = service.countAllSegmentations(keyword, segmentType, creator, updater, fromDate, toDate);
            Pagination pagination = new Pagination(page, size, totalRecords);
            List<CustomerSegment> cs = service.filterCustomerSegment(keyword, segmentType, creator, updater, fromDate, toDate, page, size);
            List<User> users = userDAO.getActiveUsers();
            req.setAttribute("keyword", keyword);
            req.setAttribute("segmentType", segmentType);
            req.setAttribute("creator", creator);
            req.setAttribute("updater", updater);
            req.setAttribute("fromDate", fromDate);
            req.setAttribute("toDate", toDate);
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

    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
