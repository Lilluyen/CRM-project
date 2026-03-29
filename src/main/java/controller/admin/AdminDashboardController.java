package controller.admin;

import dao.DashboardDAO;
import dto.dashboard.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * AdminDashboardServlet – Thu thập toàn bộ dữ liệu cần thiết cho
 * trang Admin Dashboard rồi forward sang adminDashboard.jsp.
 *
 * URL mapping: /admin/dashboard  (hoặc /dashboard tuỳ web.xml)
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardController extends HttpServlet {

    private DashboardDAO dashboardDAO;

    @Override
    public void init() {
        dashboardDAO = new DashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── 1. STAT CARDS ──────────────────────────────────────────────────
        req.setAttribute("totalCustomers",       dashboardDAO.getTotalCustomers());
        req.setAttribute("newCustomersThisMonth", dashboardDAO.getNewCustomersThisMonth());
        req.setAttribute("leadsPending",          dashboardDAO.getLeadsPending());
        req.setAttribute("dealsInProgress",       dashboardDAO.getDealsInProgress());
        req.setAttribute("tasksPending",          dashboardDAO.getTasksPending());
        req.setAttribute("followUpToday",         dashboardDAO.getFollowUpToday());
        req.setAttribute("closedDeals",           dashboardDAO.getClosedDeals());

        BigDecimal revenue = dashboardDAO.getRevenueThisMonth();
        req.setAttribute("revenueThisMonth", revenue);
        req.setAttribute("revenueThisMonthFormatted", formatCurrency(revenue));

        // ── 2. CHARTS – serialize to JSON strings for Chart.js ─────────────
        List<DashboardChartPointDTO> customerGrowth = dashboardDAO.getCustomerGrowthLast6Months();
        req.setAttribute("customerGrowthLabels", toJsonLabels(customerGrowth));
        req.setAttribute("customerGrowthData",   toJsonValues(customerGrowth));

        List<DashboardChartPointDTO> revenueChart = dashboardDAO.getRevenueLast6Months();
        req.setAttribute("revenueChartLabels", toJsonLabels(revenueChart));
        req.setAttribute("revenueChartData",   toJsonValues(revenueChart));

        List<DashboardChartPointDTO> funnel = dashboardDAO.getSalesFunnelData();
        req.setAttribute("funnelLabels", toJsonLabels(funnel));
        req.setAttribute("funnelData",   toJsonValues(funnel));

        List<DashboardChartPointDTO> taskStatus = dashboardDAO.getTaskStatusDistribution();
        req.setAttribute("taskStatusLabels", toJsonLabels(taskStatus));
        req.setAttribute("taskStatusData",   toJsonValues(taskStatus));

        // ── 3. RECENT TABLES ───────────────────────────────────────────────
        req.setAttribute("recentCustomers", dashboardDAO.getRecentCustomers());
        req.setAttribute("recentTasks",     dashboardDAO.getRecentTasks());
        req.setAttribute("recentDeals",     dashboardDAO.getRecentDeals());

        // ── 4. FOLLOW-UP PANEL ─────────────────────────────────────────────
        req.setAttribute("tasksDueToday",       dashboardDAO.getTasksDueToday());
        req.setAttribute("overdueTasks",        dashboardDAO.getOverdueTasks());
        req.setAttribute("dealsNeedFollowUp",   dashboardDAO.getDealsNeedingFollowUp());

        // ── 5. FORWARD ─────────────────────────────────────────────────────
            req.setAttribute("contentPage", "/view/admin/admin_dashboard.jsp");
            req.setAttribute("page",        "admin-dashboard");
            req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    /**
     * Chuyển danh sách điểm thành JSON mảng nhãn: ["Jan 2025","Feb 2025",...]
     * An toàn với JSP (không cần thư viện JSON phía JSP).
     */
    private String toJsonLabels(List<DashboardChartPointDTO> list) {
        if (list == null || list.isEmpty()) return "[]";
        return "[" + list.stream()
                .map(p -> "\"" + escapeJs(p.getLabel()) + "\"")
                .collect(Collectors.joining(",")) + "]";
    }

    /**
     * Chuyển danh sách điểm thành JSON mảng giá trị: [12,34,56,...]
     */
    private String toJsonValues(List<DashboardChartPointDTO> list) {
        if (list == null || list.isEmpty()) return "[]";
        return "[" + list.stream()
                .map(p -> {
                    double v = p.getValue();
                    // Nếu là giá trị tiền lớn (revenue) → giữ nguyên; Chart.js tự format
                    return String.valueOf((long) v);
                })
                .collect(Collectors.joining(",")) + "]";
    }

    /** Format VND đơn giản, ví dụ: 1,234,567,000 đ */
    private String formatCurrency(BigDecimal amount) {
        if (amount == null) return "0 đ";
        long val = amount.longValue();
        // Tách nhóm 3 chữ số
        String s = String.format("%,d", val).replace(',', '.');
        return s + " đ";
    }

    /** Escape ký tự đặc biệt trong chuỗi JSON nhúng vào JS */
    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
