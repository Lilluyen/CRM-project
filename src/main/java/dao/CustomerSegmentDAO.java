package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import dto.KpiSummaryDTO;
import dto.SegmentCardDTO;
import dto.SegmentDetailDTO;
import util.DBContext;

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

    public KpiSummaryDTO kpiSummarySegment(Connection conn, LocalDate monthA, LocalDate monthB)
            throws SQLException, Exception {
        String sql = """
                    SELECT
                (
                    SELECT COUNT(*)
                    FROM Customers
                ) AS total_customer,

                (
                    SELECT COUNT(*)
                    FROM Customers
                    WHERE created_at >= ?
                    AND created_at < DATEADD(MONTH,1,?)
                ) AS new_monthA,

                (
                    SELECT COUNT(*)
                    FROM Customers
                    WHERE created_at >= ?
                    AND created_at < DATEADD(MONTH,1,?)
                ) AS new_monthB,

                (
                    SELECT ISNULL(SUM(actual_value),0)
                    FROM Deals
                    WHERE stage = 'Closed Won'
                    AND updated_at >= ?
                    AND updated_at < DATEADD(MONTH,1,?)
                ) AS revenue_monthA,

                (
                    SELECT ISNULL(SUM(actual_value),0)
                    FROM Deals
                    WHERE stage = 'Closed Won'
                    AND updated_at >= ?
                    AND updated_at < DATEADD(MONTH,1,?)
                ) AS revenue_monthB,

                (
                    SELECT COUNT(*)
                    FROM Customers
                    WHERE last_purchase <= DATEADD(DAY,-180,?)
                ) AS retained_customers,

                (
                    SELECT ISNULL(AVG(t.ltv),0)
                    FROM (
                        SELECT SUM(actual_value) AS ltv
                        FROM Deals
                        WHERE stage='Closed Won'
                        GROUP BY customer_id
                    ) t
                ) AS avg_ltv
                                    """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(monthA));
            ps.setDate(2, Date.valueOf(monthA));

            ps.setDate(3, Date.valueOf(monthB));
            ps.setDate(4, Date.valueOf(monthB));

            ps.setDate(5, Date.valueOf(monthA));
            ps.setDate(6, Date.valueOf(monthA));

            ps.setDate(7, Date.valueOf(monthB));
            ps.setDate(8, Date.valueOf(monthB));

            ps.setDate(9, Date.valueOf(monthA));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                KpiSummaryDTO dto = new KpiSummaryDTO();

                long total = rs.getLong("total_customer");
                long cusMonthA = rs.getLong("new_monthA");
                long cusMonthB = rs.getLong("new_monthB");
                double revenueMonthA = rs.getDouble("revenue_monthA");
                double revenueMonthB = rs.getDouble("revenue_monthB");
                long retained = rs.getLong("retained_customers");

                dto.setTotalCustomers(total);
                dto.setNewMonthA(cusMonthA);
                dto.setNewMonthB(cusMonthB);
                dto.setCustomerGrowthPct(growthPct(cusMonthA, cusMonthB));
                dto.setRevenueMonthA(revenueMonthA);
                dto.setRevenueMonthB(revenueMonthB);
                dto.setRevenueGrowthPct(growthPct(revenueMonthA, revenueMonthB));
                dto.setRetainedCustomers(retained);
                dto.setRetentionRatePct(total > 0 ? round1(retained * 100.0 / total) : 0);
                dto.setAvgLtv(rs.getDouble("avg_ltv"));

                return dto;
            }
        }
        return null;
    }

    public List<SegmentCardDTO> getSegmentCards(Connection conn, LocalDate monthA, LocalDate monthB)
            throws SQLException {
        List<SegmentCardDTO> dtos = new ArrayList<SegmentCardDTO>();

        String sql = """
                WITH SegCount
                AS (
                    SELECT cs.segment_id
                    ,cs.segment_name
                    ,cs.criteria_logic
                    ,COUNT(*) customer_count
                FROM Customer_Segments cs
                    LEFT JOIN Customer_Segment_Map csm ON cs.segment_id = csm.segment_id
                GROUP BY cs.segment_id
                    ,cs.segment_name
                    ,cs.criteria_logic
                )
                ,Total
                AS (
                     SELECT COUNT(*) total
                    FROM Customers
                )
                ,Growth
                AS (
                    SELECT csm.segment_id
                    ,SUM(CASE
                        WHEN csm.assigned_at >= ?
                            AND csm.assigned_at < DATEADD(MONTH, 1, ?)
                            THEN 1
                            ELSE 0
                            END) AS this_month
                    ,SUM(CASE
                        WHEN csm.assigned_at >= ?
                            AND csm.assigned_at < DATEADD(MONTH, 1, ?)
                            THEN 1
                            ELSE 0
                            END) AS last_month
                FROM Customer_Segment_Map csm
                GROUP BY csm.segment_id
                )
                SELECT sc.segment_id
                    ,sc.segment_name
                    ,sc.criteria_logic
                    ,sc.customer_count
                    ,CAST((sc.customer_count) * 100.0 / NULLIF(t.total, 0) AS DECIMAL(5, 1)) AS pct_of_total
                     ,CAST((g.this_month - g.last_month) * 100.0 / NULLIF(g.last_month, 0) AS DECIMAL(5, 1)) AS growth_pct
                     ,CASE
                WHEN g.this_month <= g.last_month
                    THEN 0
                 ELSE 1
                 END AS is_growth_up
                 FROM SegCount AS sc
                CROSS JOIN Total AS t
                LEFT JOIN Growth AS g ON g.segment_id = sc.segment_id""";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(monthA));
            ps.setDate(2, Date.valueOf(monthA));
            ps.setDate(3, Date.valueOf(monthB));
            ps.setDate(4, Date.valueOf(monthB));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SegmentCardDTO dto = new SegmentCardDTO();

                double growthPct = rs.getDouble("growth_pct");
                if (rs.wasNull()) {
                    System.out.println("0");
                }

                dto.setSegmentId(rs.getInt("segment_id"));
                dto.setSegmentName(rs.getString("segment_name"));
                dto.setCriteriaLogic(rs.getString("criteria_logic"));
                dto.setCustomerCount(rs.getLong("customer_count"));
                dto.setPctOfTotal(rs.getDouble("pct_of_total"));
                dto.setGrowthPct(rs.getDouble("growth_pct"));
                dto.setGrowthUp(rs.getBoolean("is_growth_up"));

                dtos.add(dto);
            }
            return dtos;
        }
    }

    public static SegmentDetailDTO segmentDetail(Connection conn, int segmentId, LocalDate monthA) throws SQLException {
        String sql = """
                WITH SC
                AS (
                   SELECT csm.segment_id
                        ,csm.customer_id
                        ,csm.assigned_at
                    FROM Customer_Segment_Map csm
                    WHERE csm.segment_id = ?
                )
                SELECT cs.segment_id
                   ,cs.segment_name
                    ,cs.criteria_logic
                   ,COUNT(*) AS customer_count
                    ,ISNULL((
                        SELECT Sum(d.actual_value)
                       FROM Deals d
                       WHERE d.customer_id IN (
                           SELECT customer_id
                    FROM SC
                )
                   AND d.stage = 'Closed Won'
                    AND d.updated_at >= ?
                    AND d.updated_at < DATEADD(month, 1, ?)
                ), 0) AS revenue_this_month
                ,ISNULL((
                SELECT AVG(x.total)
                FROM (
                        SELECT d.customer_id
                       ,SUM(d.actual_value) AS total
                        FROM Deals d
                        WHERE d.customer_id IN (
                        SELECT customer_id
                       FROM SC
                )
                        AND d.stage = 'Closed Won'
                        GROUP BY d.customer_id
                    ) AS x
                ), 0) AS avg_ltv
                ,CAST(SUM(CASE
                       WHEN c.last_purchase < DATEADD(day, - 180, ?)
                        OR c.last_purchase IS NULL
                        THEN 1.0
                        ELSE 0.0
                       END) * 100.0 / NULLIF(count(sc.customer_id), 0) AS DECIMAL(5, 1)) AS churn_rate_pct
                FROM Customer_Segments cs
                JOIN SC ON 1 = 1
                JOIN Customers c ON c.customer_id = SC.customer_id
                WHERE cs.segment_id = ?
                GROUP BY cs.segment_id
                ,cs.segment_name
                ,cs.criteria_logic
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, segmentId);
            ps.setDate(2, Date.valueOf(monthA));
            ps.setDate(3, Date.valueOf(monthA));
            ps.setDate(4, Date.valueOf(monthA));
            ps.setInt(5, segmentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                SegmentDetailDTO d = new SegmentDetailDTO();
                d.setSegmentId(rs.getInt("segment_id"));
                d.setSegmentName(rs.getString("segment_name"));
                d.setCriteriaLogic(rs.getString("criteria_logic"));
                d.setCustomerCount(rs.getLong("customer_count"));
                d.setRevenueThisMonth(rs.getDouble("revenue_this_month"));
                d.setAvgLtv(rs.getDouble("avg_ltv"));
                d.setChurnRatePct(rs.getDouble("churn_rate_pct"));

                return d;
            }
        }
        return null;
    }

    private double growthPct(long cusThisMonth, long cusLastMonth) {
        if (cusLastMonth == 0) {
            return cusThisMonth > 0 ? 100 : 0;
        }
        return (cusThisMonth - cusLastMonth) * 0.1 / cusLastMonth * 100;

    }

    private double growthPct(double revenueThisMonth, double revenueLastMonth) {
        if (revenueLastMonth == 0) {
            return revenueThisMonth > 0 ? 100 : 0;
        }
        return (revenueThisMonth - revenueLastMonth) / revenueLastMonth * 100;

    }

    private double round1(double d) {
        return Math.round(d * 10.0) / 10;

    }

    public static void main(String[] args) throws SQLException, Exception {
        Connection conn = DBContext.getConnection();

        LocalDate monthA = LocalDate.now().withDayOfMonth(1);
        LocalDate monthB = monthA.minusMonths(1);
        SegmentDetailDTO dto = segmentDetail(conn, 1, monthA);
    }

}
