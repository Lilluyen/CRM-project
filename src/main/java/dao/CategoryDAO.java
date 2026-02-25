package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Category;

public class CategoryDAO {

    private Connection conn;

    public CategoryDAO(Connection conn) {
        this.conn = conn;
    }

    // Get all categories with product count
    public List<Category> getAllCategories(String search) throws SQLException {
        List<Category> list = new ArrayList<>();

        String sql = "SELECT c.*, COUNT(p.product_id) AS product_count " +
                     "FROM categories c " +
                     "LEFT JOIN products p ON c.category_id = p.category_id " +
                     "WHERE c.category_name LIKE ? OR c.description LIKE ? " +
                     "GROUP BY c.category_id " +
                     "ORDER BY c.created_at DESC";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, "%" + search + "%");
        ps.setString(2, "%" + search + "%");

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Category c = new Category();
            c.setCategoryId(rs.getInt("category_id"));
            c.setCategoryName(rs.getString("category_name"));
            c.setDescription(rs.getString("description"));
            c.setStatus(rs.getString("status"));
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

            list.add(c);
        }

        return list;
    }

    // Delete category
    public void deleteCategory(int id) throws SQLException {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, id);
        ps.executeUpdate();
    }
}