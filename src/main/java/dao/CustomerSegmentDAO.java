package dao;

import dto.CustomerSegmentListDTO;
import dto.KpiSummaryDTO;
import dto.SegmentCardDTO;
import dto.SegmentDetailDTO;
import model.CustomerSegment;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

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

    // [1] Đếm tổng — chỉ gọi ở page 1 hoặc khi filter đổi
    public int count(Integer segmentId, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT c.customer_id) FROM Customers c "
        );
        if (segmentId != null)
            sql.append("JOIN Customer_Segment_Map m ON m.customer_id = c.customer_id ");
        sql.append("WHERE 1=1 ");
        if (segmentId != null) sql.append("AND m.segment_id = ? ");
        if (ok(keyword)) sql.append("AND (c.name LIKE ? OR c.phone LIKE ?) ");

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int i = 1;
            if (segmentId != null) ps.setInt(i++, segmentId);
            if (ok(keyword)) {
                String k = "%" + keyword + "%";
                ps.setString(i++, k);
                ps.setString(i, k);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // [2] Lấy 1 trang
    //   anchorRfm = null  →  page 1 (không có WHERE keyset)
    //   anchorRfm != null →  tiếp từ anchor (keyset: rfm DESC, id DESC)
    public List<CustomerSegmentListDTO> getPage(
            Integer segmentId,
            String keyword,
            int pageSize,
            BigDecimal anchorRfm,
            Integer anchorId
    ) throws SQLException {

        boolean keyset = anchorRfm != null && anchorId != null;
        boolean filterSeg = segmentId != null;
        boolean filterKw = ok(keyword);

        // ── Query ────────────────────────────────────────────
        // SpentAgg   : tổng chi tiêu từ Deals won
        // SegFirst   : lấy segment đầu tiên theo segment_id nhỏ nhất
        //              (mỗi KH hiển thị 1 segment như trong ảnh)
        StringBuilder sql = new StringBuilder("""
                ;WITH SpentAgg AS (
                    SELECT customer_id,
                           ISNULL(SUM(actual_value), 0) AS total_spent
                    FROM   Deals
                    WHERE  stage = 'Closed Won'
                    GROUP  BY customer_id
                ),
                SegFirst AS (
                    SELECT csm.customer_id,
                           UPPER(cs.segment_name) AS segment_name
                    FROM   Customer_Segment_Map csm
                    JOIN   Customer_Segments cs ON cs.segment_id = csm.segment_id
                    WHERE  csm.segment_id = (
                        SELECT MIN(x.segment_id)
                        FROM   Customer_Segment_Map x
                        WHERE  x.customer_id = csm.customer_id
                    )
                )
                SELECT TOP (?)
                    c.customer_id,
                    c.name,
                    c.phone,
                    c.rfm_score,
                    sf.segment_name,
                    ISNULL(sp.total_spent, 0)                 AS total_spent,
                    c.last_purchase,
                    DATEDIFF(DAY, c.last_purchase, GETDATE())  AS days_since,
                    c.loyalty_tier
                FROM   Customers c
                LEFT JOIN SpentAgg sp  ON sp.customer_id = c.customer_id
                LEFT JOIN SegFirst sf  ON sf.customer_id = c.customer_id
                """);

        if (filterSeg)
            sql.append("JOIN Customer_Segment_Map f ON f.customer_id = c.customer_id\n");

        sql.append("WHERE 1=1\n");
        if (filterSeg) sql.append("AND f.segment_id = ?\n");
        if (filterKw) sql.append("AND (c.name LIKE ? OR c.phone LIKE ?)\n");
        if (keyset)
            sql.append("""
                    AND (
                        c.rfm_score < ?
                        OR (c.rfm_score = ? AND c.customer_id < ?)
                    )
                    """);
        sql.append("ORDER BY c.rfm_score DESC, c.customer_id DESC\n");

        // ── Bind ─────────────────────────────────────────────
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int i = 1;
            ps.setInt(i++, pageSize);
            if (filterSeg) ps.setInt(i++, segmentId);
            if (filterKw) {
                String k = "%" + keyword + "%";
                ps.setString(i++, k);
                ps.setString(i++, k);
            }
            if (keyset) {
                ps.setBigDecimal(i++, anchorRfm);
                ps.setBigDecimal(i++, anchorRfm);
                ps.setInt(i, anchorId);
            }

            List<CustomerSegmentListDTO> list = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
            return list;
        }
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
        return (double) Math.round(d * 10.0) / 10;

    }

    private boolean ok(String s) {
        return s != null && !s.isBlank();
    }

    private CustomerSegmentListDTO map(ResultSet rs) throws SQLException {
        CustomerSegmentListDTO d = new CustomerSegmentListDTO();
        d.setCustomerId(rs.getInt("customer_id"));
        d.setName(rs.getString("name"));
        d.setPhone(rs.getString("phone"));
        d.setRfmScore(rs.getInt("rfm_score"));   // tự tách R,F,M
        d.setSegmentName(rs.getString("segment_name"));
        d.setTotalSpent(rs.getDouble("total_spent"));
        Timestamp lp = rs.getTimestamp("last_purchase");
        d.setLastPurchase(lp != null ? lp.toLocalDateTime().toLocalDate().toString() : null);
        d.setDaysSince(rs.getInt("days_since"));
        d.setLoyaltyTier(rs.getString("loyalty_tier"));
        return d;
    }

//    public static void main(String[] args) throws SQLException, Exception {
//        Connection conn = DBContext.getConnection();
//
//        LocalDate monthA = LocalDate.now().withDayOfMonth(1);
//        LocalDate monthB = monthA.minusMonths(1);
//        SegmentDetailDTO dto = segmentDetail(conn, 1, monthA);
//    }

    public List<CustomerSegment> getAllSegmentations(Connection conn, int page, int size) throws SQLException {
        List<CustomerSegment> cs = new ArrayList<>();
        String sql = """
                    SELECT
                        s.segment_id,
                        s.segment_name,
                        s.criteria_logic,
                        s.segment_type,
                        s.[status],
                        s.created_at,
                        uc.email AS created_by,
                        s.updated_at,
                        uu.email AS updated_by,
                        s.customer_count
                
                    FROM Customer_Segments s
                
                    LEFT JOIN Users uc
                    ON s.created_by = uc.[user_id]
                
                    LEFT JOIN Users uu
                    ON s.updated_by = uu.[user_id]
                
                    GROUP BY
                        s.segment_id,
                        s.segment_name,
                        s.criteria_logic,
                        s.segment_type,
                        s.[status],
                        s.created_at,
                        s.updated_at,
                        uc.email,
                        uu.email,
                        s.customer_count
                
                    ORDER BY s.created_at DESC
                    OFFSET (? - 1) * ? Rows
                    FETCH NEXT ? ROWS only
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, page);
            ps.setInt(2, size);
            ps.setInt(3, size);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerSegment s = new CustomerSegment();

                s.setSegmentId(rs.getInt("segment_id"));
                s.setSegmentName(rs.getString("segment_name"));
                s.setCriteriaLogic(rs.getString("criteria_logic"));
                s.setSegmentType(rs.getString("segment_type"));
                s.setStatus(rs.getString("status"));
                Timestamp ts1 = rs.getTimestamp("created_at");
                if (ts1 != null) {
                    s.setCreatedAt(ts1.toLocalDateTime());
                }
                s.setCreatedBy(rs.getString("created_by"));

                Timestamp ts2 = rs.getTimestamp("updated_at");
                if (ts2 != null) {
                    s.setUpdatedAt(ts2.toLocalDateTime());
                }

                s.setUpdatedBy(rs.getString("updated_by"));
                s.setNumberData(rs.getInt("customer_count"));

                cs.add(s);
            }
            return cs;

        }
    }

    public int countAllSegmentations(Connection conn, String keyword, String segmentType, Integer creator,
                                     Integer updater, LocalDate fromDate, LocalDate toDate) throws SQLException {
        StringBuilder sql = new StringBuilder("""
                    SELECT COUNT(*) total
                    FROM Customer_Segments s 
                
                    LEFT JOIN Users uc
                    ON s.created_by = uc.[user_id]
                
                    LEFT JOIN Users uu
                    ON s.updated_by = uu.[user_id]
                
                    WHERE 1 = 1
                """);

        List<Object> params = new ArrayList<>();
        if (keyword != null) {
            sql.append(" AND s.segment_name LIKE ?");
            params.add(keyword);
        }
        if (segmentType != null) {
            sql.append(" AND s.[segment_type] = ?");
            params.add(segmentType);
        }
        if (creator != null) {
            sql.append(" AND uc.[user_id] = ?");
            params.add(creator);
        }
        if (updater != null) {
            sql.append(" AND uu.[user_id] = ?");
            params.add(updater);
        }
        if (fromDate != null) {
            sql.append(" AND s.created_at <= ?");
            params.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append(" AND s.created_at <= ?");
            params.add(Date.valueOf(toDate));
        }
        if (fromDate != null) {
            sql.append(" AND s.updated_at <= ?");
            params.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append(" AND s.updated_at <= ?");
            params.add(Date.valueOf(toDate));
        }
        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<CustomerSegment> filterCustomerSegment(Connection conn, String keyword, String segmentType, Integer creator,
                                                       Integer updater, LocalDate fromDate, LocalDate toDate, int page, int size) throws SQLException {

        StringBuilder sql = new StringBuilder(
                """
                        SELECT
                            s.segment_id,
                            s.segment_name,
                            s.criteria_logic,
                            s.segment_type,
                            s.[status],
                            s.created_at,
                            uc.email AS created_by,
                            s.updated_at,
                            uu.email AS updated_by,
                            s.customer_count
                        
                        FROM Customer_Segments s
                        
                        LEFT JOIN Users uc
                        ON s.created_by = uc.[user_id]
                        
                        LEFT JOIN Users uu
                        ON s.updated_by = uu.[user_id]
                        
                        WHERE 1 = 1
                        """
        );
        List<CustomerSegment> cs = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        if (keyword != null) {
            sql.append(" AND LOWER(s.segment_name) LIKE ?");
            params.add("%" + keyword.trim().toLowerCase() + "%");
        }
        if (segmentType != null) {
            sql.append(" AND s.[segment_type] = ?");
            params.add(segmentType);
        }
        if (creator != null) {
            sql.append(" AND uc.[user_id] = ?");
            params.add(creator);
        }
        if (updater != null) {
            sql.append(" AND uu.[user_id] = ?");
            params.add(updater);
        }
        if (fromDate != null) {
            sql.append(" AND s.created_at <= ?");
            params.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append(" AND s.created_at <= ?");
            params.add(Date.valueOf(toDate));
        }
        if (fromDate != null) {
            sql.append(" AND s.updated_at <= ?");
            params.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append(" AND s.updated_at <= ?");
            params.add(Date.valueOf(toDate));
        }

        sql.append("""
                GROUP BY
                        s.segment_id,
                        s.segment_name,
                        s.criteria_logic,
                        s.segment_type,
                        s.[status],
                        s.created_at,
                        s.updated_at,
                        uc.email,
                        uu.email,
                        s.customer_count
                
                    ORDER BY s.created_at DESC
                    OFFSET ? Rows
                    FETCH NEXT ? ROWS only
                """);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i;
            for (i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ps.setInt(i + 1, (page - 1) * size);
            ps.setInt(i + 2, size);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerSegment s = new CustomerSegment();

                s.setSegmentId(rs.getInt("segment_id"));
                s.setSegmentName(rs.getString("segment_name"));
                s.setCriteriaLogic(rs.getString("criteria_logic"));
                s.setSegmentType(rs.getString("segment_type"));
                s.setStatus(rs.getString("status"));
                Timestamp ts1 = rs.getTimestamp("created_at");
                if (ts1 != null) {
                    s.setCreatedAt(ts1.toLocalDateTime());
                }
                s.setCreatedBy(rs.getString("created_by"));

                Timestamp ts2 = rs.getTimestamp("updated_at");
                if (ts2 != null) {
                    s.setUpdatedAt(ts2.toLocalDateTime());
                }

                s.setUpdatedBy(rs.getString("updated_by"));
                s.setNumberData(rs.getInt("customer_count"));

                cs.add(s);
            }
        }
        return cs;
    }

    public void createSegmentation(Connection conn, String name, String logic, String type, int userId) throws SQLException {
        String sql = """
                INSERT INTO Customer_Segments
                (
                    segment_name,
                    criteria_logic,
                    segment_type,
                    status,
                    created_at,
                    created_by
                )
                VALUES
                (
                    ?,          -- segment_name
                    ?,          -- description
                    ?,          -- STATIC | DYNAMIC
                    'ACTIVE',
                    GETDATE(),
                    ?           -- user_id
                );
                
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, logic);
            ps.setString(3, type);
            ps.setInt(4, userId);

            ps.executeUpdate();

        }
    }

    public boolean isSegmentExisted(Connection conn, String name) throws SQLException {
        String sql = """
                SELECT COUNT(*) as count
                FROM Customer_Segments
                WHERE LOWER(segment_name) = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        }
        return false;
    }

    public boolean removeSegmentation(Connection conn, int segmentId) throws SQLException {
        String deleteCSM = """
                DELETE FROM Customer_Segment_Map
                WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(deleteCSM)) {
            ps.setInt(1, segmentId);
            ps.executeUpdate();
        }

        String deleteSegment = """
                    DELETE FROM Customer_Segments
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(deleteSegment)) {
            ps.setInt(1, segmentId);
            int rowAffected = ps.executeUpdate();
            return rowAffected > 0;
        }

    }
}
