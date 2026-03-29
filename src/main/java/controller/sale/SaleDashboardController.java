package controller.sale;

import dao.ActivityDAO;
import dao.DealDAO;
import dao.LeadDAO;
import dao.TaskDAO;
import model.Activity;
import model.Deal;
import model.Task;
import model.User;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {"/sale/dashboard"})
public class SaleDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        int userId = currentUser.getUserId();
        boolean isManager = isManagerOrAdmin(currentUser);

        try (Connection conn = DBContext.getConnection()) {
            DealDAO dealDAO = new DealDAO(conn);
            LeadDAO leadDAO = new LeadDAO();           // manages its own connection
            ActivityDAO activityDAO = new ActivityDAO(conn);
            TaskDAO taskDAO = new TaskDAO(conn);

            LocalDate today = LocalDate.now();
            LocalDate startOfMonth = today.withDayOfMonth(1);
            LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());

            // ── 1. KPIs ────────────────────────────────────────────────
            DashboardKPIs kpis = new DashboardKPIs();
            kpis.setMonth(today.format(java.time.format.DateTimeFormatter.ofPattern("MMMM yyyy")));

            // Revenue: sum actual_value of Closed Won deals in current month
            kpis.setMonthlyRevenue(dealDAO.getMonthlyRevenue(userId, isManager, startOfMonth, endOfMonth));
            kpis.setDealsClosed(dealDAO.countDealsWonThisMonth(userId, isManager, startOfMonth, endOfMonth));
            kpis.setNewLeads(dealDAO.countNewLeadsThisMonth(userId, isManager, startOfMonth, endOfMonth));
            kpis.setFollowUpsToday(dealDAO.countFollowUpsToday(userId, today));

            // Conversion rate
            int total = kpis.getDealsClosed()
                       + dealDAO.countDealsLostThisMonth(userId, isManager, startOfMonth, endOfMonth);
            kpis.setConversionRate(total > 0 ? (kpis.getDealsClosed() * 100.0 / total) : 0);

            // ── 2. Follow-up tasks today ───────────────────────────────
            List<Task> todayTasks = taskDAO.getTodaysTasksForUser(userId, isManager, today);
            kpis.setTodayTasks(todayTasks);

            // ── 3. Lead pipeline by stage ────────────────────────────
            List<LeadStageCount> leadPipeline = leadDAO.getLeadStageDistribution(userId, isManager)
                .stream()
                .map(lsc -> new LeadStageCount(lsc.getStatus(), lsc.getCount()))
                .toList();
            kpis.setLeadPipeline(leadPipeline);

            // ── 4. My deals pipeline (open deals for this user) ───────
            List<Deal> myDeals = dealDAO.getOpenDealsForUser(userId, isManager);
            kpis.setMyDeals(myDeals);

            // ── 5. Recent activities ────────────────────────────────
            List<Activity> recentActivities = activityDAO.getRecentActivitiesForDashboard(userId, 10);
            kpis.setRecentActivities(recentActivities);

            req.setAttribute("kpis", kpis);
            req.setAttribute("isManager", isManager);
            req.setAttribute("currentUser", currentUser);

        } catch (SQLException e) {
            Logger.getLogger(SaleDashboardController.class.getName()).log(Level.SEVERE, null, e);
        }

        req.setAttribute("pageTitle", "Sale Dashboard");
        req.setAttribute("contentPage", "/view/sale/sale_dashboard.jsp");
        req.setAttribute("pageCss", "sale_dashboard.css");
        req.setAttribute("page", "sale_dashboard");
        req.getRequestDispatcher("/view/layout.jsp").forward(req, resp);
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRole() == null) return false;
        int roleId = user.getRole().getRoleId();
        String roleName = user.getRole().getRoleName();
        return roleId == 1 || roleId == 5
                || "ADMIN".equalsIgnoreCase(roleName)
                || "MANAGER".equalsIgnoreCase(roleName);
    }

    // ─────────────────────────────────────────────────────────────
    // DTO classes
    // ─────────────────────────────────────────────────────────────

    public static class DashboardKPIs {
        private String month = "";
        private double monthlyRevenue = 0;
        private int dealsClosed = 0;
        private int newLeads = 0;
        private int followUpsToday = 0;
        private double conversionRate = 0;
        private List<Task> todayTasks = Collections.emptyList();
        private List<LeadStageCount> leadPipeline = Collections.emptyList();
        private List<Deal> myDeals = Collections.emptyList();
        private List<Activity> recentActivities = Collections.emptyList();

        public String getMonth() { return month; }
        public void setMonth(String m) { this.month = m; }
        public double getMonthlyRevenue() { return monthlyRevenue; }
        public void setMonthlyRevenue(double r) { this.monthlyRevenue = r; }
        public int getDealsClosed() { return dealsClosed; }
        public void setDealsClosed(int d) { this.dealsClosed = d; }
        public int getNewLeads() { return newLeads; }
        public void setNewLeads(int l) { this.newLeads = l; }
        public int getFollowUpsToday() { return followUpsToday; }
        public void setFollowUpsToday(int f) { this.followUpsToday = f; }
        public double getConversionRate() { return conversionRate; }
        public void setConversionRate(double r) { this.conversionRate = r; }
        public List<Task> getTodayTasks() { return todayTasks; }
        public void setTodayTasks(List<Task> t) { this.todayTasks = t; }
        public List<LeadStageCount> getLeadPipeline() { return leadPipeline; }
        public void setLeadPipeline(List<LeadStageCount> p) { this.leadPipeline = p; }
        public List<Deal> getMyDeals() { return myDeals; }
        public void setMyDeals(List<Deal> d) { this.myDeals = d; }
        public List<Activity> getRecentActivities() { return recentActivities; }
        public void setRecentActivities(List<Activity> a) { this.recentActivities = a; }
    }

    /** DTO matching dao.LeadDAO.LeadStageCount for the JSP chart. */
    public static class LeadStageCount {
        private final String status;
        private final int count;
        public LeadStageCount(String status, int count) { this.status = status; this.count = count; }
        public String getStatus() { return status; }
        public int getCount() { return count; }
    }
}
