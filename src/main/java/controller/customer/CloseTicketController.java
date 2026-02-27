package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import dao.TicketDAO;
import model.Customer;
import model.Ticket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet("/customer/close-ticket")
public class CloseTicketController extends HttpServlet {

    private TicketDAO ticketDAO;

    @Override
    public void init() {
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ===== 1️⃣ CHECK SESSION =====
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Customer customer = (Customer) session.getAttribute("customer");
        List<String> errors = new ArrayList<>();

        // ===== 2️⃣ GET & VALIDATE TICKET ID =====
        int ticketId = 0;
        try {
            ticketId = Integer.parseInt(request.getParameter("ticketId"));
        } catch (Exception e) {
            errors.add("Invalid ticket ID.");
        }

        // ===== 3️⃣ CHECK TICKET EXISTS =====
        Ticket ticket = ticketDAO.getTicketById(ticketId);

        if (ticket == null) {
            errors.add("Ticket does not exist.");
        } else {

            // ===== 4️⃣ CHECK OWNERSHIP =====
            if (ticket.getCustomerId() != customer.getCustomerId()) {
                errors.add("You do not have permission to close this ticket.");
            }

            // ===== 5️⃣ CHECK STATUS =====
            if (!"OPEN".equals(ticket.getStatus())) {
                errors.add("Only OPEN tickets can be closed.");
            }
        }

        // ===== 6️⃣ IF ERROR =====
        if (!errors.isEmpty()) {
            session.setAttribute("updateErrors", errors);
            response.sendRedirect(request.getContextPath() + "/customer/my-tickets");
            return;
        }

        // ===== 7️⃣ CLOSE TICKET =====
        boolean closed = ticketDAO.closeTicket(ticketId);

        if (closed) {
            session.setAttribute("successMessage",
                    "Ticket closed successfully.");
        } else {
            session.setAttribute("updateErrors",
                    Collections.singletonList("Failed to close ticket. Please try again."));
        }

        response.sendRedirect(request.getContextPath() + "/customer/my-tickets");
    }
}