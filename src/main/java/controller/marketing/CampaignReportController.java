package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CampaignReport;
import service.CampaignReportService;

@WebServlet("/marketing/report")
public class CampaignReportController extends HttpServlet {

    private CampaignReportService reportService = new CampaignReportService();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int campaignId = Integer.parseInt(request.getParameter("campaignId"));

        CampaignReport report = reportService.generateReport(campaignId);
        request.setAttribute("report", report);
        request.getRequestDispatcher("/marketing/campaign_report.jsp").forward(request, response);
    }
}
