package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dto.report.SalesFunnelStageDTO;

public class SalesFunnelDAO {

    private final Connection conn;

    public SalesFunnelDAO(Connection conn) {
        this.conn = conn;
    }

    public List<SalesFunnelStageDTO> getSalesFunnelSummary() throws SQLException {
        String sql =
                "SELECT stage, " +
                "COUNT(*) AS deal_count, " +
                "SUM(COALESCE(expected_value, 0)) AS expected_sum, " +
                "SUM(COALESCE(actual_value, 0)) AS actual_sum, " +
                "SUM(COALESCE(expected_value, 0) * (COALESCE(probability, 0) / 100.0)) AS weighted_expected_sum " +
                "FROM Deals " +
                "GROUP BY stage";

        Map<String, SalesFunnelStageDTO> map = new HashMap<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SalesFunnelStageDTO dto = new SalesFunnelStageDTO();
                dto.setStage(rs.getString("stage"));
                dto.setDealCount(rs.getInt("deal_count"));
                dto.setExpectedSum(safeBigDecimal(rs.getBigDecimal("expected_sum")));
                dto.setActualSum(safeBigDecimal(rs.getBigDecimal("actual_sum")));
                dto.setWeightedExpectedSum(safeBigDecimal(rs.getBigDecimal("weighted_expected_sum")));
                map.put(dto.getStage(), dto);
            }
        }

        List<SalesFunnelStageDTO> ordered = new ArrayList<>();
        for (String stage : DealDAO.getDefaultStages()) {
            SalesFunnelStageDTO dto = map.get(stage);
            if (dto == null) {
                dto = new SalesFunnelStageDTO();
                dto.setStage(stage);
                dto.setDealCount(0);
                dto.setExpectedSum(BigDecimal.ZERO);
                dto.setActualSum(BigDecimal.ZERO);
                dto.setWeightedExpectedSum(BigDecimal.ZERO);
            }
            ordered.add(dto);
        }

        return ordered;
    }

    private BigDecimal safeBigDecimal(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }
}
