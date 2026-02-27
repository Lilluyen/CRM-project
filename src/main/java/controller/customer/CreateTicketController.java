package controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.Customer;
import model.Ticket;
import dao.TicketDAO;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/customer/create-ticket")
public class CreateTicketController extends HttpServlet {

    private TicketDAO ticketDAO;

    @Override
    public void init() {
        ticketDAO = new TicketDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/view/customer/create-ticket.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String subject = request.getParameter("subject");
        String description = request.getParameter("description");

        List<String> errors = new ArrayList<>();

        // ===== VALIDATE SUBJECT =====
        if (subject == null || subject.trim().isEmpty()) {
            errors.add("Subject is required.");
        } else {
            subject = normalizeWhitespace(subject);
            if (subject.length() > 100) {
                errors.add("Subject must not exceed 100 characters.");
            }
        }

        // ===== VALIDATE DESCRIPTION =====
        if (description == null || description.trim().isEmpty()) {
            errors.add("Description is required.");
        } else {
            description = normalizeWhitespace(description);
            if (description.length() > 5000) {
                errors.add("Description is too long.");
            }
        }

        // ===== CHECK LOGIN =====
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        Customer customer = (Customer) session.getAttribute("customer");

        // ===== IF ERROR =====
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("subject", subject);
            request.setAttribute("description", description);

            request.getRequestDispatcher("/view/customer/create-ticket.jsp")
                    .forward(request, response);
            return;
        }

        // ===== CREATE TICKET =====
        Ticket ticket = new Ticket();
        ticket.setCustomerId(customer.getCustomerId());
        ticket.setSubject(subject);
        ticket.setDescription(description);
        ticket.setStatus("OPEN");
        ticket.setCreatedAt(LocalDateTime.now());

        boolean inserted = ticketDAO.insert(ticket);

        if (inserted) {
            session.setAttribute("successMessage",
                    "Ticket created successfully.");
        } else {
            session.setAttribute("updateErrors",
                    List.of("Failed to create ticket. Please try again."));
        }

        response.sendRedirect(request.getContextPath() + "/customer/my-tickets");
    }

    private String normalizeWhitespace(String input) {
        return input.trim().replaceAll("\\s+", " ");
    }
}