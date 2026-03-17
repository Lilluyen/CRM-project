package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.DealItemDTO;

public class DealProductDAO {

    private final Connection conn;

    public DealProductDAO(Connection conn) {
        this.conn = conn;
    }

    public void replaceDealItems(int dealId, List<DealItemDTO> items) throws SQLException {
        deleteDealItems(dealId);

        if (items == null || items.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO Deal_Products(deal_id, product_id, quantity, unit_price, discount, total_price) VALUES(?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (DealItemDTO item : items) {
                if (item == null || item.getProductId() <= 0) {
                    continue;
                }

                ps.setInt(1, dealId);
                ps.setInt(2, item.getProductId());
                ps.setInt(3, item.getQuantity());
                ps.setBigDecimal(4, item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO);
                ps.setBigDecimal(5, item.getDiscount() != null ? item.getDiscount() : BigDecimal.ZERO);
                ps.setBigDecimal(6, item.getTotalPrice() != null ? item.getTotalPrice() : BigDecimal.ZERO);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public void deleteDealItems(int dealId) throws SQLException {
        String sql = "DELETE FROM Deal_Products WHERE deal_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dealId);
            ps.executeUpdate();
        }
    }

    public List<DealItemDTO> getDealItems(int dealId) throws SQLException {
        String sql =
            "SELECT dp.product_id, p.name AS product_name, p.sku, dp.quantity, dp.unit_price, dp.discount, dp.total_price " +
            "FROM Deal_Products dp " +
            "INNER JOIN Products p ON dp.product_id = p.product_id " +
            "WHERE dp.deal_id = ? " +
            "ORDER BY p.name";

        List<DealItemDTO> items = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dealId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DealItemDTO item = new DealItemDTO();
                    item.setProductId(rs.getInt("product_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSku(rs.getString("sku"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setDiscount(rs.getBigDecimal("discount"));
                    item.setTotalPrice(rs.getBigDecimal("total_price"));
                    items.add(item);
                }
            }
        }

        return items;
    }
}
