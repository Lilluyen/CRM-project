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
import java.util.Map;

@WebServlet(name = "MergeRequestDetailController",
        urlPatterns = {"/customers/merge-request/*"})
public class MergeRequestDetailController extends HttpServlet {

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

    // ── GET: Xem detail 1 merge request ──────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int requestId = extractRequestId(req);
        if (requestId < 0) {
            resp.sendRedirect(req.getContextPath() + "/customers/merge-request/list");
            return;
        }

        try {
            CustomerMergeRequest mergeReq = mergeRequestService.getById(requestId);
            if (mergeReq == null) {
                resp.sendRedirect(req.getContextPath()
                        + "/customers/merge-request/list?status=not-found");
                return;
            }

            CustomerDetailDTO source = customerService.getCustomerDetail(mergeReq.getSourceId());
            CustomerDetailDTO target = customerService.getCustomerDetail(mergeReq.getTargetId());
            Map<String, String> overrides = mergeRequestService.parseFieldOverrides(
                    mergeReq.getFieldOverrides());

            User user = (User) session.getAttribute("user");
            boolean isManager = "MANAGER".equalsIgnoreCase(user.getRole().getRoleName());

            req.setAttribute("mergeReq", mergeReq);
            req.setAttribute("source", source);
            req.setAttribute("target", target);
            req.setAttribute("overrides", overrides);
            req.setAttribute("isManager", isManager);
            req.setAttribute("pageTitle", "Merge Request #" + requestId + " | Clothes CRM");
            req.setAttribute("contentPage", "customer/merge_request_detail.jsp");
            req.setAttribute("pageCss", "merge_request_detail.css");
            req.setAttribute("page", "merge-customers");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Load merge request detail error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }

    // ── POST: Approve hoặc Reject (chỉ manager) ──────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Chỉ manager mới được approve/reject
        if (!"MANAGER".equalsIgnoreCase(user.getRole().getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=unauthorized");
            return;
        }

        int requestId = extractRequestId(req);
        if (requestId < 0) {
            resp.sendRedirect(req.getContextPath() + "/customers/merge-request/list");
            return;
        }

        String action = req.getParameter("action");       // "approve" hoặc "reject"
        String rejectReason = req.getParameter("rejectReason"); // chỉ dùng khi reject

        try {
            req.setCharacterEncoding("UTF-8");

            if ("approve".equals(action)) {
                mergeRequestService.approve(requestId, user.getUserId());
                resp.sendRedirect(req.getContextPath()
                        + "/customers/merge-request/list?status=approved");

            } else if ("reject".equals(action)) {
                if (rejectReason == null || rejectReason.isBlank()) {
                    // Reload trang với lỗi thiếu lý do
                    req.setAttribute("errorMsg", "Please provide a reason for rejection.");
                    doGet(req, resp);
                    return;
                }
                mergeRequestService.reject(requestId, user.getUserId(), rejectReason.trim());
                resp.sendRedirect(req.getContextPath()
                        + "/customers/merge-request/list?status=rejected");

            } else {
                resp.sendRedirect(req.getContextPath()
                        + "/customers/merge-request/" + requestId + "?status=failed");
            }

        } catch (IllegalStateException e) {
            // Request không còn ở trạng thái PENDING
            resp.sendRedirect(req.getContextPath()
                    + "/customers/merge-request/" + requestId + "?status=already-processed");
        } catch (Exception e) {
            log("Process merge request error", e);
            resp.sendRedirect(req.getContextPath()
                    + "/customers/merge-request/" + requestId + "?status=failed");
        }
    }

    // ── Helper: lấy requestId từ URL /merge-request/{id} ─────────────────
    private int extractRequestId(HttpServletRequest req) {
        String pathInfo = req.getPathInfo(); // "/123" hoặc null
        if (pathInfo == null || pathInfo.equals("/")) return -1;
        try {
            return Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
