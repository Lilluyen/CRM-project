package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.KpiSummaryDTO;

public class CustomerSegmentDAO {

    public boolean upgradeToLoyaltyCustomer(Connection conn, int customerId) throws Exception {
        String sql = """
                UPDATE [Customers]
                SET
                    [loyalty_tier] = CASE [loyalty_tier]
                        WHEN 'BLACKLIST' THEN 'BRONZE'
                        WHEN 'BRONZE'    THEN 'SILVER'
                        WHEN 'SILVER'    THEN 'GOLD'
                        WHEN 'GOLD'      THEN 'PLATINUM'
                        WHEN 'PLATINUM'  THEN 'DIAMOND'
                        WHEN 'DIAMOND'   THEN 'DIAMOND'
                        ELSE [loyalty_tier]
                    END,
                    [updated_at] = GETDATE()
                WHERE [customer_id] = ? """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
            return true;
        }
    }

    public boolean downgradeToLoyaltyCustomer(Connection conn, int customerId) throws Exception {
        String sql = """
                     UPDATE [Customers]
                SET [loyalty_tier] = CASE [loyalty_tier]
                     WHEN 'BLACKLIST' THEN 'BLACKLIST'
                     WHEN 'BRONZE' THEN 'BLACKLIST'
                     WHEN 'SILVER' THEN 'BRONZE'
                     WHEN 'GOLD' THEN 'SILVER'
                     WHEN 'PLATINUM' THEN 'GOLD'
                     WHEN 'DIAMOND' THEN 'PLATINUM'
                     ELSE [loyalty_tier]
                 END,
                     [updated_at] = GETDATE()
                 WHERE [customer_id] = ?
                            """;

        try (PreparedStatement stm = conn.prepareStatement(sql)) {
            stm.setInt(1, customerId);
            stm.executeUpdate();
            return true;
        }
    }

    public KpiSummaryDTO kpiSummarySegment(Connection conn) throws SQLException, Exception {
        String sql = """
                                    SELECT (
                	SELECT COUNT(*)
                	FROM Customers
                	) AS total_customer
                ,(
                	SELECT COUNT(*)
                	FROM Customers
                	WHERE MONTH(created_at) = MONTH(GETDATE())
                		AND YEAR(created_at) = YEAR(GETDATE())
                	) AS new_this_month
                ,(
                	SELECT COUNT(*)
                	FROM Customers
                	WHERE MONTH(created_at) = MONTH(DATEADD(MONTH, - 1, GETDATE()))
                		AND YEAR(created_at) = YEAR(DATEADD(MONTH, - 1, GETDATE()))
                	) AS new_last_month
                ,(
                	SELECT ISNULL(SUM(actual_value), 0)
                	FROM Deals
                	WHERE stage = 'Closed Won'
                		AND MONTH(updated_at) = MONTH(GETDATE())
                		AND YEAR(updated_at) = YEAR(GETDATE())
                	) AS revenue_this_month
                ,(
                	SELECT ISNULL(SUM(actual_value), 0)
                	FROM Deals
                	WHERE stage = 'Closed Won'
                		AND MONTH(updated_at) = MONTH(DATEADD(MONTH, - 1, GETDATE()))
                		AND YEAR(updated_at) = YEAR(DATEADD(MONTH, - 1, GETDATE()))
                	) AS revenue_last_month
                ,(
                	SELECT COUNT(*)
                	FROM Customers
                	WHERE last_purchase <= DATEADD(DAY, - 180, GETDATE())
                	) AS retained_customers
                ,(
                	SELECT ISNULL(AVG(t.ltv), 0)
                	FROM (
                		SELECT ISNULL(SUM([actual_value]), 0) AS ltv
                			,customer_id
                		FROM Deals
                		WHERE stage = 'Closed Won'
                		GROUP BY customer_id
                		) AS t
                	) AS avg_ltv
                                    """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                KpiSummaryDTO summary = new KpiSummaryDTO();

                summary.setTotalCustomers(rs.getLong("total_customer"));
                summary.setNewThisMonth(rs.getLong("new_this_month"));
                summary.setNewLastMonth(rs.getLong("new_last_month"));
                summary.setRevenueThisMonth(rs.getLong("revenue_this_month"));
                summary.setRevenueLastMonth(rs.getLong("revenue_last_month"));
                summary.setRetainedCustomers(rs.getLong("retained_customers"));
                summary.setAvgLtv(rs.getLong("avg_ltv"));
                return summary;
            }
        }
        return null;
    }
    
    

}
