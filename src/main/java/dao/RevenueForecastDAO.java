package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.report.RevenueForecastDTO;

public class RevenueForecastDAO {

    private final Connection conn;

    public RevenueForecastDAO(Connection conn) {
        this.conn = conn;
    }

    public List<RevenueForecastDTO> getForecastByMonth() throws SQLException {
        String sql =
                "SELECT FORMAT(expected_close_date, 'yyyy-MM') AS period, " +
                "COUNT(*) AS deal_count, " +
                "SUM(COALESCE(expected_value, 0)) AS expected_sum, " +
                "SUM(COALESCE(expected_value, 0) * (COALESCE(probability, 0) / 100.0)) AS forecasted_revenue " +
                "FROM Deals " +
                "WHERE stage NOT IN ('Closed Won', 'Closed Lost') " +
                "AND expected_close_date IS NOT NULL " +
                "GROUP BY FORMAT(expected_close_date, 'yyyy-MM') " +
                "ORDER BY period";

        return executeQuery(sql);
    }

    public List<RevenueForecastDTO> getForecastByQuarter() throws SQLException {
        String sql =
                "SELECT CONCAT(YEAR(expected_close_date), '-Q', DATEPART(QUARTER, expected_close_date)) AS period, " +
                "COUNT(*) AS deal_count, " +
                "SUM(COALESCE(expected_value, 0)) AS expected_sum, " +
                "SUM(COALESCE(expected_value, 0) * (COALESCE(probability, 0) / 100.0)) AS forecasted_revenue " +
                "FROM Deals " +
                "WHERE stage NOT IN ('Closed Won', 'Closed Lost') " +
                "AND expected_close_date IS NOT NULL " +
                "GROUP BY YEAR(expected_close_date), DATEPART(QUARTER, expected_close_date) " +
                "ORDER BY YEAR(expected_close_date), DATEPART(QUARTER, expected_close_date)";

        return executeQuery(sql);
    }

    public List<RevenueForecastDTO> getForecastByYear() throws SQLException {
        String sql =
                "SELECT CAST(YEAR(expected_close_date) AS VARCHAR) AS period, " +
                "COUNT(*) AS deal_count, " +
                "SUM(COALESCE(expected_value, 0)) AS expected_sum, " +
                "SUM(COALESCE(expected_value, 0) * (COALESCE(probability, 0) / 100.0)) AS forecasted_revenue " +
                "FROM Deals " +
                "WHERE stage NOT IN ('Closed Won', 'Closed Lost') " +
                "AND expected_close_date IS NOT NULL " +
                "GROUP BY YEAR(expected_close_date) " +
                "ORDER BY YEAR(expected_close_date)";

        return executeQuery(sql);
    }

    private List<RevenueForecastDTO> executeQuery(String sql) throws SQLException {
        List<RevenueForecastDTO> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RevenueForecastDTO dto = new RevenueForecastDTO();
                dto.setPeriod(rs.getString("period"));
                dto.setDealCount(rs.getInt("deal_count"));
                dto.setExpectedSum(safe(rs.getBigDecimal("expected_sum")));
                dto.setForecastedRevenue(safe(rs.getBigDecimal("forecasted_revenue")));
                list.add(dto);
            }
        }
        return list;
    }

    private BigDecimal safe(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }
}
