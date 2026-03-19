package dao;

import util.DBContext;
import model.Ticket;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TicketDAO {

    // ==================================
    // 1. COUNT
    // ==================================
    public int countTickets(int customerId, String subject, String status) {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Tickets WHERE customer_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (subject != null && !subject.trim().isEmpty()) {
            sql.append(" AND subject LIKE ? ESCAPE '\\' ");
            params.add("%" + escapeLike(subject.trim()) + "%");
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ? ");
            params.add(status.trim());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            setParams(ps, params);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // ==================================
// 2. PAGINATION + SORT (SQL SERVER)
// ==================================
    public List<Ticket> getTicketsByPage(int customerId,
                                         String subject,
                                         String status,
                                         String sort,
                                         int offset,
                                         int pageSize) {

        List<Ticket> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT * FROM Tickets WHERE customer_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (subject != null && !subject.trim().isEmpty()) {
            sql.append(" AND subject LIKE ? ESCAPE '\\' ");
            params.add("%" + escapeLike(subject.trim()) + "%");
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ? ");
            params.add(status.trim());
        }

        // ============================
        // SORT LOGIC (ANTI SQL INJECTION)
        // ============================
        String orderBy = "ticket_id DESC"; // default

        if (sort != null) {
            switch (sort) {
                case "id_asc":
                    orderBy = "ticket_id ASC";
                    break;
                case "id_desc":
                    orderBy = "ticket_id DESC";
                    break;
                case "created_asc":
                    orderBy = "created_at ASC";
                    break;
                case "created_desc":
                    orderBy = "created_at DESC";
                    break;
                case "updated_asc":
                    orderBy = "updated_at ASC";
                    break;
                case "updated_desc":
                    orderBy = "updated_at DESC";
                    break;
            }
        }

        // ============================
        // PAGINATION
        // ============================
        sql.append(" ORDER BY ").append(orderBy);
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");

        params.add(offset);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            setParams(ps, params);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Ticket ticket = new Ticket();

                ticket.setTicketId(rs.getInt("ticket_id"));
                ticket.setCustomerId(rs.getInt("customer_id"));
                ticket.setSubject(rs.getString("subject"));
                ticket.setDescription(rs.getString("description"));
                ticket.setPriority(rs.getString("priority"));
                ticket.setStatus(rs.getString("status"));
                ticket.setAssignedTo(rs.getInt("assigned_to"));

                Timestamp createdTs = rs.getTimestamp("created_at");
                Timestamp updatedTs = rs.getTimestamp("updated_at");

                if (createdTs != null) {
                    ticket.setCreatedAt(createdTs.toLocalDateTime());
                }

                if (updatedTs != null) {
                    ticket.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                list.add(ticket);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ==================================
    // ESCAPE LIKE (% _ \)
    // ==================================
    private String escapeLike(String keyword) {
        return keyword
                .replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
    }

    // ==================================
    // SET PARAM
    // ==================================
    private void setParams(PreparedStatement ps, List<Object> params)
            throws SQLException {

        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    public boolean insert(Ticket ticket) {

        String sql = "INSERT INTO Tickets (customer_id, subject, description, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setInt(1, ticket.getCustomerId());
            ps.setString(2, ticket.getSubject());
            ps.setString(3, ticket.getDescription());
            ps.setString(4, ticket.getStatus());
            ps.setObject(5, ticket.getCreatedAt());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Ticket getTicketById(int id) {
        String sql = "SELECT * FROM Tickets WHERE ticket_id = ?";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Ticket t = new Ticket();
                t.setTicketId(rs.getInt("ticket_id"));
                t.setCustomerId(rs.getInt("customer_id"));
                t.setSubject(rs.getString("subject"));
                t.setDescription(rs.getString("description"));
                t.setStatus(rs.getString("status"));
                return t;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateTicket(int id, String subject, String description) {

        String sql = "UPDATE Tickets SET subject = ?, description = ?, updated_at = GETDATE() "
                + "WHERE ticket_id = ? AND status = 'OPEN'";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setString(1, subject);
            ps.setString(2, description);
            ps.setInt(3, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean closeTicket(int ticketId) {

        String sql = "UPDATE Tickets "
                + "SET status = 'CLOSED', updated_at = GETDATE() "
                + "WHERE ticket_id = ? AND status = 'OPEN'";

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setInt(1, ticketId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}