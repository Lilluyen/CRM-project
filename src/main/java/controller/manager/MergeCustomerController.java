package controller.manager;

import dao.*;
import dto.ConflictResult;
import dto.CustomerCreateDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.CustomerService;

import java.io.IOException;

@WebServlet(name = "MergeCustomerController", urlPatterns = {"/customers/resolve-conflict"})
public class MergeCustomerController extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();
    private final CustomerContactDAO contactDAO = new CustomerContactDAO();
    private final CustomerNoteDAO noteDAO = new CustomerNoteDAO();

    private final CustomerService customerService = new CustomerService(
            customerDAO,
            customerStyleDAO,
            customerQueryDAO,
            customerSegmentDAO,
            contactDAO,
            noteDAO);

    // ── GET: Hiển thị trang so sánh conflict ─────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);


        // Không có conflict trong session → ai đó vào URL trực tiếp
        ConflictResult conflict = (ConflictResult) session.getAttribute("pendingConflict");
        if (conflict == null) {
            resp.sendRedirect(req.getContextPath() + "/customers");
            return;
        }

        req.setAttribute("conflict", conflict);
        req.setAttribute("pageTitle", "Resolve Conflict | Clothes CRM");
        req.setAttribute("contentPage", "customer/resolve_conflict.jsp");
        req.setAttribute("pageCss", "customer-add.css");
        req.setAttribute("page", "customer-add");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    // ── POST: Xử lý quyết định merge hoặc ignore ─────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Không có session hoặc chưa login
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Lấy conflict từ session
        ConflictResult conflict = (ConflictResult) session.getAttribute("pendingConflict");
        if (conflict == null) {
            // Session hết hạn hoặc đã xử lý rồi
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
            return;
        }

        String action = req.getParameter("action"); // "merge" hoặc "ignore"
        String note = req.getParameter("note");   // lý do ignore (optional)

        if (action == null || (!action.equals("merge") && !action.equals("ignore"))) {
            // Giá trị action không hợp lệ → hiển thị lại trang
            req.setAttribute("conflict", conflict);
            req.setAttribute("errorMsg", "Vui lòng chọn một hành động hợp lệ.");
            req.setAttribute("pageTitle", "Resolve Conflict | Clothes CRM");
            req.setAttribute("contentPage", "customer/resolve_conflict.jsp");
            req.setAttribute("pageCss", "customer-add.css");
            req.setAttribute("page", "customer-add");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
            return;
        }

        try {
            int existingId = conflict.getExistingCustomer().getCustomerId();
            CustomerCreateDTO incoming = conflict.getIncomingData();

            if ("merge".equals(action)) {
                // ── Merge: gộp dữ liệu, lưu contact phụ ─────────────────
                customerService.mergeCustomer(existingId, incoming, user.getUserId(), conflict.getSource());

                // Cleanup session
                session.removeAttribute("pendingConflict");

                // Luôn redirect về existing vì đó là bản ghi được giữ lại
                resp.sendRedirect(req.getContextPath()
                        + "/customers/detail?customerId=" + existingId
                        + "&status=merged");

            } else {
                // ── Ignore: tạo mới hoặc update bình thường + ghi note ────
                String source = conflict.getSource();     // "create" hoặc "update"
                Integer incomingId = conflict.getIncomingId(); // chỉ có khi source=update

                if ("create".equals(source)) {
                    // Tạo mới bất chấp conflict, kèm note lý do
                    int newId = customerService.ignoreAndCreate(
                            incoming, user.getUserId(), existingId, note);

                    session.removeAttribute("pendingConflict");
                    resp.sendRedirect(req.getContextPath()
                            + "/customers/detail?customerId=" + newId
                            + "&status=created");

                } else {
                    // Update bất chấp conflict, kèm note lý do
                    customerService.ignoreAndUpdate(
                            incoming, incomingId, existingId, note, user.getUserId());

                    session.removeAttribute("pendingConflict");
                    resp.sendRedirect(req.getContextPath()
                            + "/customers/detail?customerId=" + incomingId
                            + "&status=updated");
                }
            }

        } catch (Exception e) {
            log("Resolve conflict error", e);
            session.removeAttribute("pendingConflict"); // cleanup dù lỗi
            resp.sendRedirect(req.getContextPath() + "/customers?status=failed");
        }
    }
}