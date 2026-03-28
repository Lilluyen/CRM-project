package dao;

import dto.dashboard.*;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DashboardDAO – Cung cấp toàn bộ dữ liệu cho Admin Dashboard.
 * Mỗi method tương ứng một widget/section trên trang dashboard.
 */
public class DashboardDAO {

    // ─────────────────────────────────────────────────────────────────────────
    // STAT CARDS
    // ─────────────────────────────────────────────────────────────────────────

    /** Tổng số khách hàng */
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM Customers";
        return queryInt(sql);
    }

    /** Khách hàng mới trong tháng hiện tại */
    public int getNewCustomersThisMonth() {
        String sql = "SELECT COUNT(*) FROM Customers "
                   + "WHERE MONTH(created_at) = MONTH(GETDATE()) "
                   + "  AND YEAR(created_at)  = YEAR(GETDATE())";
        return queryInt(sql);
    }

    /** Lead đang chờ xử lý (status = 'NEW' hoặc 'CONTACTED') */
    public int getLeadsPending() {
        String sql = "SELECT COUNT(*) FROM Leads WHERE status IN ('NEW','CONTACTED','new','contacted')";
        return queryInt(sql);
    }

    /** Deal đang tiến hành (không phải Closed Won / Closed Lost) */
    public int getDealsInProgress() {
        String sql = "SELECT COUNT(*) FROM Deals "
                   + "WHERE stage NOT IN ('Closed Won','Closed Lost')";
        return queryInt(sql);
    }

    /** Task đang chờ (Pending / In Progress) */
    public int getTasksPending() {
        String sql = "SELECT COUNT(*) FROM Tasks "
                   + "WHERE status IN ('Pending','In Progress')";
        return queryInt(sql);
    }

    /** Follow-up hôm nay: task due hôm nay chưa xong */
    public int getFollowUpToday() {
        String sql = "SELECT COUNT(*) FROM Tasks "
                   + "WHERE CAST(due_date AS DATE) = CAST(GETDATE() AS DATE) "
                   + "  AND status NOT IN ('Done','Cancelled')";
        return queryInt(sql);
    }

    /** Tổng deal đã đóng thắng */
    public int getClosedDeals() {
        String sql = "SELECT COUNT(*) FROM Deals WHERE stage = 'Closed Won'";
        return queryInt(sql);
    }

    /** Doanh thu tháng này: tổng actual_value của Closed Won trong tháng */
    public BigDecimal getRevenueThisMonth() {
        String sql = "SELECT ISNULL(SUM(actual_value), 0) FROM Deals "
                   + "WHERE stage = 'Closed Won' "
                   + "  AND MONTH(updated_at) = MONTH(GETDATE()) "
                   + "  AND YEAR(updated_at)  = YEAR(GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getBigDecimal(1);
        } catch (Exception e) { e.printStackTrace(); }
        return BigDecimal.ZERO;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CHARTS
    // ─────────────────────────────────────────────────────────────────────────

    /** Customer growth: số khách hàng mới theo 6 tháng gần nhất */
    public List<DashboardChartPointDTO> getCustomerGrowthLast6Months() {
        String sql =
            "SELECT FORMAT(created_at, 'MMM yyyy') AS label, "
          + "       COUNT(*) AS value "
          + "FROM Customers "
          + "WHERE created_at >= DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) "
          + "GROUP BY FORMAT(created_at, 'MMM yyyy'), "
          + "         YEAR(created_at)*100 + MONTH(created_at) "
          + "ORDER BY YEAR(created_at)*100 + MONTH(created_at)";
        return queryChartPoints(sql);
    }

    /** Revenue chart: doanh thu thực tế theo 6 tháng gần nhất */
    public List<DashboardChartPointDTO> getRevenueLast6Months() {
        String sql =
            "SELECT FORMAT(updated_at, 'MMM yyyy') AS label, "
          + "       ISNULL(SUM(actual_value), 0) AS value "
          + "FROM Deals "
          + "WHERE stage = 'Closed Won' "
          + "  AND updated_at >= DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) "
          + "GROUP BY FORMAT(updated_at, 'MMM yyyy'), "
          + "         YEAR(updated_at)*100 + MONTH(updated_at) "
          + "ORDER BY YEAR(updated_at)*100 + MONTH(updated_at)";
        return queryChartPoints(sql);
    }

    /** Sales funnel: số deal theo từng stage theo thứ tự chuẩn */
    public List<DashboardChartPointDTO> getSalesFunnelData() {
        String sql =
            "SELECT stage AS label, COUNT(*) AS value "
          + "FROM Deals "
          + "GROUP BY stage";
        List<DashboardChartPointDTO> raw = queryChartPoints(sql);

        // Sắp xếp theo thứ tự stage chuẩn
        String[] order = {"Prospecting","Qualified","Proposal","Negotiation","Closed Won","Closed Lost"};
        List<DashboardChartPointDTO> sorted = new ArrayList<>();
        for (String stage : order) {
            boolean found = false;
            for (DashboardChartPointDTO p : raw) {
                if (stage.equals(p.getLabel())) { sorted.add(p); found = true; break; }
            }
            if (!found) sorted.add(new DashboardChartPointDTO(stage, 0));
        }
        return sorted;
    }

    /** Task status distribution */
    public List<DashboardChartPointDTO> getTaskStatusDistribution() {
        String sql =
            "SELECT status AS label, COUNT(*) AS value "
          + "FROM Tasks GROUP BY status";
        return queryChartPoints(sql);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // RECENT DATA TABLES
    // ─────────────────────────────────────────────────────────────────────────

    /** 5 khách hàng mới nhất */
    public List<RecentCustomerDTO> getRecentCustomers() {
        String sql =
            "SELECT TOP 5 customer_id, name, phone, email, status, created_at "
          + "FROM Customers ORDER BY created_at DESC";
        List<RecentCustomerDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RecentCustomerDTO dto = new RecentCustomerDTO();
                dto.setCustomerId(rs.getInt("customer_id"));
                dto.setName(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setEmail(rs.getString("email"));
                dto.setStatus(rs.getString("status"));
                Timestamp ca = rs.getTimestamp("created_at");
                dto.setCreatedAt(ca != null ? ca.toLocalDateTime() : null);
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** 5 task gần nhất */
    public List<RecentTaskDTO> getRecentTasks() {
        String sql =
            "SELECT TOP 5 t.task_id, t.title, t.status, t.priority, t.due_date, "
          + "  COALESCE(u.full_name, u.username) AS assignee_name, "
          + "  COALESCE(c.name, l.full_name) AS related_name "
          + "FROM Tasks t "
          + "LEFT JOIN Task_Assignees ta ON t.task_id = ta.task_id "
          + "LEFT JOIN Users u ON ta.user_id = u.user_id "
          + "LEFT JOIN Customers c ON t.related_type = 'Customer' AND t.related_id = c.customer_id "
          + "LEFT JOIN Leads l ON t.related_type = 'Lead' AND t.related_id = l.lead_id "
          + "ORDER BY t.created_at DESC";
        List<RecentTaskDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RecentTaskDTO dto = new RecentTaskDTO();
                dto.setTaskId(rs.getInt("task_id"));
                dto.setTitle(rs.getString("title"));
                dto.setStatus(rs.getString("status"));
                dto.setPriority(rs.getString("priority"));
                Timestamp dd = rs.getTimestamp("due_date");
                dto.setDueDate(dd != null ? dd.toLocalDateTime() : null);
                dto.setAssigneeName(rs.getString("assignee_name"));
                dto.setRelatedName(rs.getString("related_name"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** 5 deal gần nhất */
    public List<RecentDealDTO> getRecentDeals() {
        String sql =
            "SELECT TOP 5 d.deal_id, d.deal_name, d.expected_value, d.actual_value, "
          + "  d.stage, d.probability, d.created_at, "
          + "  COALESCE(c.name, l.full_name) AS party_name "
          + "FROM Deals d "
          + "LEFT JOIN Customers c ON d.customer_id = c.customer_id "
          + "LEFT JOIN Leads l ON d.lead_id = l.lead_id "
          + "ORDER BY d.created_at DESC";
        List<RecentDealDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RecentDealDTO dto = new RecentDealDTO();
                dto.setDealId(rs.getInt("deal_id"));
                dto.setDealName(rs.getString("deal_name"));
                dto.setExpectedValue(rs.getBigDecimal("expected_value"));
                dto.setActualValue(rs.getBigDecimal("actual_value"));
                dto.setStage(rs.getString("stage"));
                dto.setProbability(rs.getInt("probability"));
                Timestamp ca = rs.getTimestamp("created_at");
                dto.setCreatedAt(ca != null ? ca.toLocalDateTime() : null);
                dto.setPartyName(rs.getString("party_name"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FOLLOW-UP TODAY PANEL
    // ─────────────────────────────────────────────────────────────────────────

    /** Task due hôm nay chưa hoàn thành */
    public List<FollowUpItemDTO> getTasksDueToday() {
        String sql =
            "SELECT TOP 10 t.task_id AS id, t.title AS name, t.status, t.priority, "
          + "  t.due_date AS due, "
          + "  COALESCE(c.name, l.full_name, '') AS related_name, "
          + "  'task' AS item_type "
          + "FROM Tasks t "
          + "LEFT JOIN Customers c ON t.related_type='Customer' AND t.related_id=c.customer_id "
          + "LEFT JOIN Leads l     ON t.related_type='Lead'     AND t.related_id=l.lead_id "
          + "WHERE CAST(t.due_date AS DATE) = CAST(GETDATE() AS DATE) "
          + "  AND t.status NOT IN ('Done','Cancelled') "
          + "ORDER BY t.priority DESC, t.due_date ASC";
        return queryFollowUpItems(sql);
    }

    /** Task quá hạn */
    public List<FollowUpItemDTO> getOverdueTasks() {
        String sql =
            "SELECT TOP 10 t.task_id AS id, t.title AS name, t.status, t.priority, "
          + "  t.due_date AS due, "
          + "  COALESCE(c.name, l.full_name, '') AS related_name, "
          + "  'overdue' AS item_type "
          + "FROM Tasks t "
          + "LEFT JOIN Customers c ON t.related_type='Customer' AND t.related_id=c.customer_id "
          + "LEFT JOIN Leads l     ON t.related_type='Lead'     AND t.related_id=l.lead_id "
          + "WHERE CAST(t.due_date AS DATE) < CAST(GETDATE() AS DATE) "
          + "  AND t.status NOT IN ('Done','Cancelled') "
          + "ORDER BY t.due_date ASC";
        return queryFollowUpItems(sql);
    }

    /** Deal cần follow-up: deal đang trong pipeline không cập nhật quá 7 ngày */
    public List<FollowUpItemDTO> getDealsNeedingFollowUp() {
        String sql =
            "SELECT TOP 10 d.deal_id AS id, d.deal_name AS name, d.stage AS status, "
          + "  CAST(d.probability AS VARCHAR) AS priority, "
          + "  d.expected_close_date AS due, "
          + "  COALESCE(c.name, l.full_name, '') AS related_name, "
          + "  'deal' AS item_type "
          + "FROM Deals d "
          + "LEFT JOIN Customers c ON d.customer_id = c.customer_id "
          + "LEFT JOIN Leads l     ON d.lead_id = l.lead_id "
          + "WHERE d.stage NOT IN ('Closed Won','Closed Lost') "
          + "  AND DATEDIFF(DAY, d.updated_at, GETDATE()) >= 7 "
          + "ORDER BY d.expected_close_date ASC";
        return queryFollowUpItems(sql);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    private int queryInt(String sql) {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    private List<DashboardChartPointDTO> queryChartPoints(String sql) {
        List<DashboardChartPointDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DashboardChartPointDTO(
                    rs.getString("label"),
                    rs.getDouble("value")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<FollowUpItemDTO> queryFollowUpItems(String sql) {
        List<FollowUpItemDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FollowUpItemDTO dto = new FollowUpItemDTO();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                dto.setStatus(rs.getString("status"));
                dto.setPriority(rs.getString("priority"));
                Timestamp due = rs.getTimestamp("due");
                dto.setDue(due != null ? due.toLocalDateTime() : null);
                dto.setRelatedName(rs.getString("related_name"));
                dto.setItemType(rs.getString("item_type"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
