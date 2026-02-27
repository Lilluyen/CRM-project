package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.StyleTag;

public class CustomerStyleDAO {

    public List<StyleTag> getAllStyleTags(Connection connection) throws SQLException {

        List<StyleTag> styletags = new ArrayList<>();
        String sql = """
                SELECT [tag_id]
                      ,[tag_name]
                      ,[category]
                  FROM [Style_Tags]""";

        try (PreparedStatement stm = connection.prepareStatement(sql); ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                StyleTag styleTag = new StyleTag();
                styleTag.setTagId(rs.getInt("tag_id"));
                styleTag.setTagName(rs.getString("tag_name"));
                styleTag.setCategory(rs.getString("category"));

                styletags.add(styleTag);
            }
        }
        return styletags;
    }

    public void insertCustomerStyles(Connection connection, int customerId, List<Integer> tagIds) throws SQLException {
        String sql = """
                INSERT INTO [Customer_Style_Map]
                           ([customer_id]
                           ,[tag_id])
                     VALUES
                           (?
                           ,?)""";

        try (PreparedStatement stm = connection.prepareStatement(sql);) {
            for (Integer tagId : tagIds) {
                stm.setInt(1, customerId);
                stm.setInt(2, tagId);
                stm.addBatch();
            }

            stm.executeBatch();

        }
    }

    public boolean isTagExisted(int customerId, int tagId, Connection conn) throws SQLException {
        String sql = "SELECT 1  FROM [Customer_Style_Map] WHERE customer_id = ? AND tag_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, tagId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void deleteByCustomerId(Connection conn, int customerId)
            throws SQLException {

        String sql = "DELETE FROM Customer_Style_Map WHERE customer_id = ?";

        try (PreparedStatement stm = conn.prepareStatement(sql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
        }
    }

    public List<StyleTag> getStyleTags(Connection conn, int id)
            throws Exception {

        String sql = """
                    SELECT t.*
                    FROM Customer_Style_Map csm
                    JOIN Style_Tags t ON csm.tag_id = t.tag_id
                    WHERE csm.customer_id = ?
                    ORDER BY t.category, t.tag_name
                """;

        List<StyleTag> tags = new ArrayList<>();

        try (var ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (var rs = ps.executeQuery()) {

                while (rs.next()) {
                    StyleTag tag = new StyleTag();
                    tag.setTagId(rs.getInt("tag_id"));
                    tag.setTagName(rs.getString("tag_name"));
                    tag.setCategory(rs.getString("category"));
                    tags.add(tag);
                }
            }
        }

        return tags;
    }

}
