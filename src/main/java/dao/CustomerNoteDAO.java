package dao;

import model.CustomerNote;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class CustomerNoteDAO {

    public void insertCustomerNote(Connection conn, CustomerNote note) throws SQLException {
        String sql = """
                
                INSERT INTO [customer_note]
                           ([customer_id]
                           ,[note]
                           ,[created_by]
                           ,[created_at])
                     VALUES
                           (?
                           ,?
                           ,?
                           ,GETDATE())
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, note.getCustomerId());
            ps.setString(2, note.getNote());
            ps.setInt(3, note.getCreatedBy());

            ps.executeUpdate();
        }
    }

    public List<CustomerNote> getByCustomerId(Connection conn, int customerId) throws SQLException {
        String sql = """
                SELECT id, customer_id, note, created_by, created_at
                FROM customer_note
                WHERE customer_id = ?
                ORDER BY created_at DESC
                """;
        List<CustomerNote> notes = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerNote n = new CustomerNote(
                            rs.getInt("customer_id"),
                            rs.getString("note"),
                            rs.getInt("created_by")
                    );
                    n.setNoteId(rs.getInt("id"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) n.setCreatedAt(ts.toLocalDateTime());
                    notes.add(n);
                }
            }
        }
        return notes;
    }

}
