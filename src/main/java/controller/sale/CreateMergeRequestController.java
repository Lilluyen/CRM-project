package controller.sale;

import dao.*;
import dto.CustomerDetailDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.CustomerService;
import service.MergeRequestService;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(name = "CreateMergeRequestController",
        urlPatterns = {"/customers/merge-request/new"})
public class CreateMergeRequestController extends HttpServlet {

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

    // ── GET: Hiển thị trang preview so sánh 2 customer ───────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String sourceIdRaw = req.getParameter("sourceId");
        String targetIdRaw = req.getParameter("targetId");

        int sourceId, targetId;
        try {
            sourceId = Integer.parseInt(sourceIdRaw);
            targetId = Integer.parseInt(targetIdRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }

        if (sourceId == targetId) {
            resp.sendRedirect(req.getContextPath()
                    + "/customers?status=failed&reason=same-customer");
            return;
        }

        try {
            CustomerDetailDTO source = customerService.getCustomerDetail(sourceId);
            CustomerDetailDTO target = customerService.getCustomerDetail(targetId);

            if (source == null || target == null) {
                resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
                return;
            }

            // Cảnh báo nếu đã có request PENDING giữa 2 customer này
            boolean hasPending = mergeRequestService.hasPendingRequest(sourceId, targetId);

            req.setAttribute("source", source);
            req.setAttribute("target", target);
            req.setAttribute("hasPending", hasPending);
            req.setAttribute("pageTitle", "New Merge Request | Clothes CRM");
            req.setAttribute("contentPage", "customer/merge_request_preview.jsp");
            req.setAttribute("pageCss", "merge_request_preview.css");
            req.setAttribute("page", "customer-merge");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);

        } catch (Exception e) {
            log("Load merge preview error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }

    // ── POST: Submit tạo merge request ───────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String sourceIdRaw = req.getParameter("sourceId");
        String targetIdRaw = req.getParameter("targetId");
        String reason = req.getParameter("reason");

        int sourceId, targetId;
        try {
            sourceId = Integer.parseInt(sourceIdRaw);
            targetId = Integer.parseInt(targetIdRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }

        try {
            req.setCharacterEncoding("UTF-8");

            // ── Đọc fieldOverrides từ form ────────────────────────────────
            // Mỗi field có 1 radio group tên "field_<fieldName>" với value "source"/"target"
            Map<String, String> fieldOverrides = new LinkedHashMap<>();
            String[] fields = {"name", "phone", "email", "gender", "birthday", "address", "source"};
            for (String field : fields) {
                String choice = req.getParameter("field_" + field);
                if (choice != null && (choice.equals("source") || choice.equals("target"))) {
                    fieldOverrides.put(field, choice);
                } else {
                    fieldOverrides.put(field, "target"); // default giữ target
                }
            }

            // ── Validate reason ───────────────────────────────────────────
            if (reason == null || reason.isBlank()) {
                reason = null;
            } else {
                reason = reason.trim();
            }

            int newRequestId = mergeRequestService.createRequest(
                    sourceId, targetId, fieldOverrides, reason, user.getUserId());

            resp.sendRedirect(req.getContextPath()
                    + "/customers/merge-request/" + newRequestId
                    + "?status=created");

        } catch (IllegalStateException e) {
            // Đã có PENDING request → redirect về preview với warning
            resp.sendRedirect(req.getContextPath()
                    + "/customers/merge-request/new"
                    + "?sourceId=" + sourceId
                    + "&targetId=" + targetId
                    + "&status=already-pending");

        } catch (Exception e) {
            log("Create merge request error", e);
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }
}