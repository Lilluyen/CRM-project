package controller.manager;

import dao.*;
import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CustomerMergeRequest;
import model.User;
import service.CustomerService;
import service.MergeRequestService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "MergeRequestListController",
        urlPatterns = {"/customers/merge-request/list"})
public class MergeRequestListController extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();
    private final MergeRequestDAO mergeRequestDAO = new MergeRequestDAO();

    private final CustomerService customerService = new CustomerService(
            customerDAO, customerStyleDAO, customerQueryDAO,
            customerSegmentDAO, contactDAO, noteDAO);

    private final MergeRequestService mergeRequestService = new MergeRequestService(
            mergeRequestDAO, customerDAO, customerStyleDAO,
            contactDAO, noteDAO, customerQueryDAO);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        boolean isManager = "MANAGER".equalsIgnoreCase(user.getRole().getRoleName());

        // Manager thấy tất cả PENDING, user thường chỉ thấy requests của mình
        if (!isManager) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=unauthorized");
            return;
        }

        try {
            List<CustomerMergeRequest> requests = mergeRequestService.getPendingRequests();

            // Enrich với tên source/target để hiển thị trên list
            List<MergeRequestRow> rows = new ArrayList<>();
            for (CustomerMergeRequest r : requests) {
                CustomerDetailDTO source = customerService.getCustomerDetail(r.getSourceId());
                CustomerDetailDTO target = customerService.getCustomerDetail(r.getTargetId());
                rows.add(new MergeRequestRow(r, source, target));
            }

            req.setAttribute("rows", rows);
            req.setAttribute("pageTitle", "Merge Requests | Clothes CRM");
            req.setAttribute("contentPage", "customer/merge_request_list.jsp");
            req.setAttribute("pageCss", "merge_request_list.css");
            req.setAttribute("page", "customer-merge");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Load merge request list error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }

    // ── Inner class để truyền dữ liệu ra JSP gọn hơn ─────────────────────
    public static class MergeRequestRow {
        private final CustomerMergeRequest request;
        private final CustomerDetailDTO source;
        private final CustomerDetailDTO target;

        public MergeRequestRow(CustomerMergeRequest request,
                               CustomerDetailDTO source,
                               CustomerDetailDTO target) {
            this.request = request;
            this.source = source;
            this.target = target;
        }

        public CustomerMergeRequest getRequest() {
            return request;
        }

        public CustomerDetailDTO getSource() {
            return source;
        }

        public CustomerDetailDTO getTarget() {
            return target;
        }
    }
}