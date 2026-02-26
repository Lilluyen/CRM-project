package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import model.Category;

public class CategoryDAO {

    private final Connection conn;

    public CategoryDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Category> getCategoryList(String search,
                                          String status,
                                          int page,
                                          int pageSize) throws SQLException {

        List<Category> list = new ArrayList<>();

        if (search == null) search = "";
        if (status == null) status = "";

        int offset = (page - 1) * pageSize;

        String sql =
            "SELECT category_id, category_name, description, status, created_at " +
            "FROM Categories " +
            "WHERE (category_name LIKE ? OR description LIKE ?) " +
            "AND (? = '' OR status = ?) " +
            "ORDER BY created_at DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + search + "%");
            ps.setString(2, "%" + search + "%");
            ps.setString(3, status);
            ps.setString(4, status);
            ps.setInt(5, offset);
            ps.setInt(6, pageSize);

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

    public int countCategories(String search, String status) throws SQLException {

        if (search == null) search = "";
        if (status == null) status = "";

        String sql =
            "SELECT COUNT(*) FROM Categories " +
            "WHERE (category_name LIKE ? OR description LIKE ?) " +
            "AND (? = '' OR status = ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + search + "%");
            ps.setString(2, "%" + search + "%");
            ps.setString(3, status);
            ps.setString(4, status);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }

        return 0;
    }
}