package controller.customer;

import dao.TicketDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Customer;
import model.Ticket;

import java.io.IOException;
import java.util.List;

@WebServlet("/customer/my-tickets")
public class MyTicketsController extends HttpServlet {

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 1. Lấy parameter =====
        String subject = request.getParameter("subject");
        String status = request.getParameter("status");
        String pageParam = request.getParameter("page");
        String sort = request.getParameter("sort");

        if (subject == null) subject = "";
        if (status == null) status = "";
        if (sort == null || sort.isEmpty()) sort = "id_desc"; // mặc định

        int currentPage = 1;

        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (Exception e) {
            currentPage = 1;
        }

        // ===== 2. Lấy customer hiện tại =====
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");

        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        int customerId = customer.getCustomerId();

        TicketDAO ticketDAO = new TicketDAO();

        // ===== 3. Đếm tổng record =====
        int totalRecords = ticketDAO.countTickets(customerId, subject, status);

        // ===== 4. Tính totalPages =====
        int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

        if (totalPages == 0) totalPages = 1;

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        // ===== 5. Tính offset =====
        int offset = (currentPage - 1) * PAGE_SIZE;

        // ===== 6. Lấy danh sách theo page + sort =====
        List<Ticket> tickets =
                ticketDAO.getTicketsByPage(customerId, subject, status, sort, offset, PAGE_SIZE);

        // ===== 7. Tính showing x to y =====
        int startRecord = 0;
        int endRecord = 0;

        if (totalRecords > 0) {
            startRecord = offset + 1;
            endRecord = Math.min(offset + PAGE_SIZE, totalRecords);
        }

        // ===== 8. Set attribute =====
        request.setAttribute("tickets", tickets);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("startRecord", startRecord);
        request.setAttribute("endRecord", endRecord);

        request.setAttribute("subject", subject);
        request.setAttribute("status", status);
        request.setAttribute("sort", sort); // QUAN TRỌNG

        // ===== 9. Forward =====
        request.getRequestDispatcher("/view/customer/my-tickets.jsp")
                .forward(request, response);
    }
}