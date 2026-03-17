package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Product;

public class ProductLookupDAO {

    private final Connection conn;

    public ProductLookupDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Product> getAllActiveProductsBasic() throws SQLException {
        String sql = "SELECT product_id, name, sku, price, status FROM Products WHERE status = 'ACTIVE' ORDER BY name ASC";

        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setSku(rs.getString("sku"));
                p.setPrice(rs.getBigDecimal("price") != null ? rs.getBigDecimal("price") : BigDecimal.ZERO);
                p.setStatus(rs.getString("status"));
                list.add(p);
            }
        }

        return list;
    }
}
