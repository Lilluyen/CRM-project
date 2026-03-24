package dao;

import model.CustomerNote;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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


}
