package controller.manager;

import dao.CustomerDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import dto.CustomerListDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CustomerSegment;
import model.SegmentConfig;
import model.SegmentHistory;
import model.User;
import service.CustomerSegmentService;
import service.CustomerService;
import service.SegmentDetailService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = "/customers/segment-detail")
public class SegmentDetailController extends HttpServlet {

    private final SegmentDetailService service = new SegmentDetailService();
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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String segmentIdRaw = req.getParameter("segment_id");
        try {
            int segmentId = Integer.parseInt(segmentIdRaw);

            CustomerSegment segmentInfo = service.getSegmentDetailById(segmentId);
            List<SegmentHistory> segmentHistories = service.getSegmentHistory(segmentId);
            List<CustomerListDTO> listCustomer = service.getListInDetailSegment(segmentId);
            List<SegmentConfig> filterConfigs = service.getFilters(segmentId);
            List<String> sources = customerService.getSources();
            List<String> ranks = customerService.getRanks();
            List<User> staffs = customerSegmentService.getActiveStaffsUnderManagerLevel();

            req.setAttribute("staffs", staffs);
            req.setAttribute("sources", sources);
            req.setAttribute("ranks", ranks);
            req.setAttribute("segmentInfo", segmentInfo);
            req.setAttribute("history", segmentHistories);
            req.setAttribute("listCustomer", listCustomer);
            req.setAttribute("configs", filterConfigs);
            req.setAttribute("pageTitle", "Segment Detail | Clothes CRM");
            req.setAttribute("contentPage", "customer/segment_detail.jsp");
            req.setAttribute("pageCss", "segment_detail.css");
            req.setAttribute("pageJs", "SegmentDetail.js");
            req.setAttribute("page", "customer-segments");

            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments");
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/customers/segments");
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    }
}
