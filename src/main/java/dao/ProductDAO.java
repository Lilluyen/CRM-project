package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import model.Category;
import model.Product;

public class ProductDAO {

    private final Connection conn;

    public ProductDAO(Connection conn) {
        this.conn = conn;
    }

    public boolean skuExists(String sku, Integer excludeProductId) throws SQLException {
        if (sku == null || sku.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM Products WHERE sku = ?";
        if (excludeProductId != null && excludeProductId > 0) {
            sql += " AND product_id <> ?";
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku.trim());
            if (excludeProductId != null && excludeProductId > 0) {
                ps.setInt(2, excludeProductId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public int createProduct(Product product, List<Integer> categoryIds) throws SQLException {
        String sql = "INSERT INTO Products(name, sku, price, description, status, created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?)";

        int newId = 0;
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getSku());
            ps.setBigDecimal(3, product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO);
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getStatus());
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newId = rs.getInt(1);
                    }
                }
            }
        }

        if (newId > 0) {
            upsertCategories(newId, categoryIds);
        }

        return newId;
    }

    public boolean updateProduct(Product product, List<Integer> categoryIds) throws SQLException {
        String sql = "UPDATE Products SET name = ?, sku = ?, price = ?, description = ?, status = ?, updated_at = ? WHERE product_id = ?";

        boolean ok;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getSku());
            ps.setBigDecimal(3, product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO);
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getStatus());
            ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(7, product.getProductId());
            ok = ps.executeUpdate() > 0;
        }

        if (ok) {
            upsertCategories(product.getProductId(), categoryIds);
        }

        return ok;
    }

    public boolean deleteProduct(int productId) throws SQLException {
        deleteCategories(productId);

        String sql = "DELETE FROM Products WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        }
    }

    public Product getById(int productId) throws SQLException {
        String sql = "SELECT product_id, name, sku, price, description, status, created_at, updated_at FROM Products WHERE product_id = ?";

        Product p = null;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = mapProduct(rs);
                }
            }
        }

        if (p != null) {
            p.setCategories(getCategoriesByProductId(productId));
        }

        return p;
    }

    public List<Product> getProductList(String search, String status, int page, int pageSize) throws SQLException {
        if (search == null) search = "";
        if (status == null) status = "";

        int offset = (page - 1) * pageSize;

        String sql =
            "SELECT product_id, name, sku, price, description, status, created_at, updated_at " +
            "FROM Products " +
            "WHERE (name LIKE ? OR sku LIKE ? OR description LIKE ?) " +
            "AND (? = '' OR status = ?) " +
            "ORDER BY updated_at DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String kw = "%" + search + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, status);
            ps.setString(5, status);
            ps.setInt(6, offset);
            ps.setInt(7, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        }

        Map<Integer, List<Category>> categoryMap = getCategoriesForProducts(list);
        for (Product p : list) {
            List<Category> cats = categoryMap.get(p.getProductId());
            if (cats != null) {
                p.setCategories(cats);
            }
        }

        return list;
    }

    public int countProducts(String search, String status) throws SQLException {
        if (search == null) search = "";
        if (status == null) status = "";

        String sql =
            "SELECT COUNT(*) FROM Products " +
            "WHERE (name LIKE ? OR sku LIKE ? OR description LIKE ?) " +
            "AND (? = '' OR status = ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String kw = "%" + search + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, status);
            ps.setString(5, status);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public List<Product> searchProductsForExport(String search, String status) throws SQLException {
        if (search == null) search = "";
        if (status == null) status = "";

        String sql =
            "SELECT product_id, name, sku, price, description, status, created_at, updated_at " +
            "FROM Products " +
            "WHERE (name LIKE ? OR sku LIKE ? OR description LIKE ?) " +
            "AND (? = '' OR status = ?) " +
            "ORDER BY updated_at DESC";

        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            String kw = "%" + search + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, status);
            ps.setString(5, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        }

        Map<Integer, List<Category>> categoryMap = getCategoriesForProducts(list);
        for (Product p : list) {
            List<Category> cats = categoryMap.get(p.getProductId());
            if (cats != null) {
                p.setCategories(cats);
            }
        }

        return list;
    }

    private void upsertCategories(int productId, List<Integer> categoryIds) throws SQLException {
        deleteCategories(productId);

        if (categoryIds == null || categoryIds.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO Category_Products(category_id, product_id) VALUES(?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Integer categoryId : categoryIds) {
                if (categoryId == null || categoryId <= 0) {
                    continue;
                }
                ps.setInt(1, categoryId);
                ps.setInt(2, productId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void deleteCategories(int productId) throws SQLException {
        String sql = "DELETE FROM Category_Products WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    private List<Category> getCategoriesByProductId(int productId) throws SQLException {
        String sql =
            "SELECT c.category_id, c.category_name, c.description, c.status, c.created_at " +
            "FROM Categories c " +
            "INNER JOIN Category_Products cp ON c.category_id = cp.category_id " +
            "WHERE cp.product_id = ? " +
            "ORDER BY c.category_name";

        List<Category> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
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

    private Map<Integer, List<Category>> getCategoriesForProducts(List<Product> products) throws SQLException {
        Map<Integer, List<Category>> map = new HashMap<>();
        if (products == null || products.isEmpty()) {
            return map;
        }

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < products.size(); i++) {
            if (i > 0) inClause.append(',');
            inClause.append('?');
        }

        String sql =
            "SELECT cp.product_id, c.category_id, c.category_name, c.description, c.status, c.created_at " +
            "FROM Category_Products cp " +
            "INNER JOIN Categories c ON cp.category_id = c.category_id " +
            "WHERE cp.product_id IN (" + inClause + ") " +
            "ORDER BY c.category_name";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < products.size(); i++) {
                ps.setInt(i + 1, products.get(i).getProductId());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int productId = rs.getInt("product_id");

                    Category c = new Category();
                    c.setCategoryId(rs.getInt("category_id"));
                    c.setCategoryName(rs.getString("category_name"));
                    c.setDescription(rs.getString("description"));
                    c.setStatus(rs.getString("status"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        c.setCreatedAt(ts.toLocalDateTime());
                    }

                    map.computeIfAbsent(productId, k -> new ArrayList<>()).add(c);
                }
            }
        }

        return map;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setName(rs.getString("name"));
        p.setSku(rs.getString("sku"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setDescription(rs.getString("description"));
        p.setStatus(rs.getString("status"));

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            p.setCreatedAt(createdTs.toLocalDateTime());
        }

        Timestamp updatedTs = rs.getTimestamp("updated_at");
        if (updatedTs != null) {
            p.setUpdatedAt(updatedTs.toLocalDateTime());
        }

        return p;
    }
}
