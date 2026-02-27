package controller.customer;

import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Ticket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet("/customer/update-ticket")
public class UpdateTicketController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1️⃣ Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/request-otp");
            return;
        }

        Customer customer = (Customer) session.getAttribute("customer");

        List<String> errors = new ArrayList<>();

        // 2️⃣ Get parameters safely
        String idRaw = request.getParameter("ticketId");
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");

        int ticketId = 0;

        try {
            ticketId = Integer.parseInt(idRaw);
        } catch (Exception e) {
            errors.add("Invalid ticket ID.");
        }

        // 3️⃣ Validate subject & description
        if (subject == null || subject.trim().isEmpty()) {
            errors.add("Subject cannot be empty.");
        }

        if (description == null || description.trim().isEmpty()) {
            errors.add("Description cannot be empty.");
        }

        TicketDAO dao = new TicketDAO();

        // 4️⃣ Check ticket exists & belongs to customer
        Ticket ticket = dao.getTicketById(ticketId);

        if (ticket == null) {
            errors.add("Ticket does not exist.");
        } else {

            // Check ownership
            if (ticket.getCustomerId() != customer.getCustomerId()) {
                errors.add("You do not have permission to edit this ticket.");
            }

            // Check status OPEN
            if (!"OPEN".equals(ticket.getStatus())) {
                errors.add("Only OPEN tickets can be edited.");
            }
        }

        // 5️⃣ If has errors
        if (!errors.isEmpty()) {

            session.setAttribute("updateErrors", errors);
            response.sendRedirect(request.getContextPath() + "/customer/my-tickets");
            return;
        }

        // 6️⃣ Update ticket
        boolean updated = dao.updateTicket(
                ticketId,
                subject.trim(),
                description.trim()
        );

        if (updated) {
            session.setAttribute("successMessage", "Ticket updated successfully.");
        } else {
            session.setAttribute("updateErrors",
                    Collections.singletonList("Update failed. Please try again."));
        }

        response.sendRedirect(request.getContextPath() + "/customer/my-tickets");
    }
}