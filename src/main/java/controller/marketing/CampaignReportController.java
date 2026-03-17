package controller.marketing;

import java.io.IOException;
import java.util.List;

import dto.Pagination;
import dto.report.CampaignPerformanceReportDTO;
import dto.report.DealResultReportDTO;
import dto.report.LeadFunnelReportDTO;
import dto.report.LeadSourceReportDTO;
import dto.report.MarketingReportKpiDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.ReportService;

@WebServlet("/marketing/report")
public class CampaignReportController extends HttpServlet {

        private final ReportService reportService = new ReportService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Access control ──────────────────────────────────────────────────
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = user.getRole().getRoleName().toUpperCase();
        if (!role.equals("ADMIN") && !role.equals("MARKETING")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access this page.");
            return;
        }

        // ── Parse filter params ──────────────────────────────────────────────
        String campaignIdParam = request.getParameter("campaignId");
        String source          = request.getParameter("source");
        String fromDate        = request.getParameter("fromDate");
        String toDate          = request.getParameter("toDate");

        Integer campaignId = null;
        if (campaignIdParam != null && !campaignIdParam.isEmpty()) {
            try { campaignId = Integer.parseInt(campaignIdParam); } catch (NumberFormatException ignored) {}
        }

        // ── Pagination (Campaign Performance table) ───────────────────────────
        int page = 1;
        int pageSize = 10;
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
        } catch (NumberFormatException ignored) {}
        try {
            if (request.getParameter("pageSize") != null) {
                pageSize = Integer.parseInt(request.getParameter("pageSize"));
            }
        } catch (NumberFormatException ignored) {}
        if (pageSize != 5 && pageSize != 10 && pageSize != 20) {
            pageSize = 10;
        }
        if (page < 1) page = 1;

        int totalItems = reportService.getCampaignPerformanceCount(campaignId, fromDate, toDate);
        Pagination pagination = new Pagination(page, pageSize, totalItems);

        List<CampaignPerformanceReportDTO> campaignPerformance =
                reportService.getCampaignPerformancePaginated(
                        campaignId, fromDate, toDate,
                        pagination.getOffset(), pagination.getPageSize());

        // ── Load report data ─────────────────────────────────────────────────

        List<LeadSourceReportDTO> leadSources =
                reportService.getLeadSourceReport(campaignId, source, fromDate, toDate);

        LeadFunnelReportDTO leadFunnel =
                reportService.getLeadFunnelReport(campaignId, fromDate, toDate);

        DealResultReportDTO dealResult =
                reportService.getDealResultReport(campaignId, fromDate, toDate);

        MarketingReportKpiDTO reportKpi =
                reportService.getMarketingReportKpi(campaignId, fromDate, toDate);

        // ── Filter dropdown data ─────────────────────────────────────────────
        List<Object[]> allCampaigns = reportService.getAllCampaignsForFilter();
        List<String>   allSources   = reportService.getAllSourcesForFilter();

        // ── Set request attributes ───────────────────────────────────────────
        request.setAttribute("campaignPerformance", campaignPerformance);
        request.setAttribute("pagination",         pagination);
        request.setAttribute("leadSources",         leadSources);
        request.setAttribute("leadFunnel",          leadFunnel);
        request.setAttribute("dealResult",          dealResult);
        request.setAttribute("reportKpi",           reportKpi);
        request.setAttribute("allCampaigns",        allCampaigns);
        request.setAttribute("allSources",          allSources);

        // Filter echo-back so the form retains selected values
        request.setAttribute("filterCampaignId", campaignIdParam != null ? campaignIdParam : "");
        request.setAttribute("filterSource",     source     != null ? source     : "");
        request.setAttribute("filterFromDate",   fromDate   != null ? fromDate   : "");
        request.setAttribute("filterToDate",     toDate     != null ? toDate     : "");

        // ── Layout wiring (mirrors MarketingDashboardController pattern) ─────
        request.setAttribute("pageTitle",   "Marketing Reports - CRM");
        request.setAttribute("contentPage", "marketing/campaign/campaign_report.jsp");
        request.setAttribute("pageCss",     "marketing_report.css");
        request.setAttribute("pageJs",      "marketing_report.js");
        request.setAttribute("page",        "marketing-report");

        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }
}
