package controller.manager;

import model.Activity;
import model.DealStagePoint;
import model.MonthlyRevenuePoint;
import service.ActivityService;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = "/manager/dashboard")
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String period = normalizePeriod(request.getParameter("period"));
        request.setAttribute("period", period);

        try (Connection conn = DBContext.getConnection()) {
            request.setAttribute("totalCustomers", queryInt(conn,
                    "SELECT COUNT(*) FROM Customers " + buildWhereByPeriod("created_at", period)));
            request.setAttribute("totalLeads", queryInt(conn,
                    "SELECT COUNT(*) FROM Leads " + buildWhereByPeriod("created_at", period)));
            request.setAttribute("openTasks", queryInt(conn,
                    "SELECT COUNT(*) FROM Tasks WHERE LOWER(status) NOT IN ('done', 'cancelled') "
                            + buildAndByPeriod("created_at", period)));
            request.setAttribute("wonDeals", queryInt(conn,
                    "SELECT COUNT(*) FROM Deals WHERE LOWER(REPLACE(stage, '_', ' ')) = 'closed won' "
                            + buildAndByPeriod("created_at", period)));

            request.setAttribute("monthlyRevenue", getMonthlyRevenue(conn, period));
            request.setAttribute("dealStageData", getDealStageData(conn, period));

            ActivityService activityService = new ActivityService(conn);
            List<Activity> recentActivities = activityService.getRecentActivities(8);
            request.setAttribute("recentActivities", recentActivities);
        } catch (Exception e) {
            log("Failed to load manager dashboard data", e);
            request.setAttribute("totalCustomers", 0);
            request.setAttribute("totalLeads", 0);
            request.setAttribute("openTasks", 0);
            request.setAttribute("wonDeals", 0);
            request.setAttribute("monthlyRevenue", new ArrayList<>());
            request.setAttribute("dealStageData", new ArrayList<>());
            request.setAttribute("recentActivities", new ArrayList<>());
        }

        request.setAttribute("pageTitle", "Manager Dashboard - CRM");
        request.setAttribute("contentPage", "manager/manager_dashboard.jsp");
        request.setAttribute("pageCss", "manager_dashboard.css");
        request.setAttribute("page", "manager-dashboard");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }

    private int queryInt(Connection conn, String sql) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private List<MonthlyRevenuePoint> getMonthlyRevenue(Connection conn, String period) throws Exception {
        String sql = """
                SELECT TOP 6
                       FORMAT(CAST(created_at AS date), 'yyyy-MM') AS month_key,
                       SUM(COALESCE(actual_value, 0)) AS total_revenue
                FROM Deals
                WHERE LOWER(REPLACE(stage, '_', ' ')) = 'closed won'
                """ + buildAndByPeriod("created_at", period) + """
                GROUP BY FORMAT(CAST(created_at AS date), 'yyyy-MM')
                ORDER BY month_key DESC
                """;

        List<MonthlyRevenuePoint> points = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                points.add(new MonthlyRevenuePoint(
                        rs.getString("month_key"),
                        rs.getBigDecimal("total_revenue") != null ? rs.getBigDecimal("total_revenue")
                                : BigDecimal.ZERO));
            }
        }
        // reverse to chronological order for chart readability
        List<MonthlyRevenuePoint> ordered = new ArrayList<>();
        for (int i = points.size() - 1; i >= 0; i--) {
            ordered.add(points.get(i));
        }
        return ordered;
    }

    private List<DealStagePoint> getDealStageData(Connection conn, String period) throws Exception {
        String sql = """
                SELECT TOP 6
                       stage,
                       COUNT(*) AS total
                FROM Deals
                """ + buildWhereByPeriod("created_at", period) + """
                GROUP BY stage
                ORDER BY total DESC
                """;

        List<DealStagePoint> points = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                points.add(new DealStagePoint(
                        rs.getString("stage"),
                        rs.getInt("total")));
            }
        }
        return points;
    }

    private String normalizePeriod(String periodRaw) {
        if (periodRaw == null || periodRaw.isBlank())
            return "30d";
        return switch (periodRaw) {
            case "7d", "30d", "quarter", "year", "all" -> periodRaw;
            default -> "30d";
        };
    }

    private String buildWhereByPeriod(String columnName, String period) {
        String condition = buildPeriodCondition(columnName, period);
        return condition.isEmpty() ? "" : "WHERE " + condition;
    }

    private String buildAndByPeriod(String columnName, String period) {
        String condition = buildPeriodCondition(columnName, period);
        return condition.isEmpty() ? "" : " AND " + condition;
    }

    private String buildPeriodCondition(String columnName, String period) {
        return switch (period) {
            case "7d" -> "CAST(" + columnName + " AS date) >= DATEADD(DAY, -7, CAST(GETDATE() AS date))";
            case "30d" -> "CAST(" + columnName + " AS date) >= DATEADD(DAY, -30, CAST(GETDATE() AS date))";
            case "quarter" -> "CAST(" + columnName + " AS date) >= DATEADD(MONTH, -3, CAST(GETDATE() AS date))";
            case "year" -> "CAST(" + columnName + " AS date) >= DATEADD(YEAR, -1, CAST(GETDATE() AS date))";
            default -> "";
        };
    }
}
