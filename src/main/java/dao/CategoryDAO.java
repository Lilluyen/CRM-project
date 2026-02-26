package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDAO {

    private final Connection conn;

    public CategoryDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Category> getCategoryList(String search) throws SQLException {

        List<Category> list = new ArrayList<>();

        String sql = "SELECT category_id, category_name, description, status, created_at "
                   + "FROM Categories "
                   + "WHERE category_name LIKE ? OR description LIKE ? "
                   + "ORDER BY created_at DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + search + "%");
            ps.setString(2, "%" + search + "%");

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Category c = new Category();
                    c.setCategoryId(rs.getInt("category_id"));
                    c.setCategoryName(rs.getString("category_name"));
                    c.setDescription(rs.getString("description"));
                    c.setStatus(rs.getString("status"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        c.setCreatedAt(ts.toLocalDateTime());
                    }

                    list.add(c);
                }
            }
        }

        return list;
    }
}