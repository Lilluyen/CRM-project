package controller.marketing;

import java.io.IOException;
import java.util.List;

import com.google.gson.Gson;

import dao.CampaignDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Campaign;
import model.ImportLeadResponse;
import model.Lead;
import service.LeadImportService;
import util.ExcelUtil;

@WebServlet(name = "LeadImportController", urlPatterns = {"/marketing/leads/import"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024)
public class LeadImportController extends HttpServlet {

    private LeadImportService importService = new LeadImportService();
    private CampaignDAO campaignDAO = new CampaignDAO();
    private Gson gson = new Gson();

    // ===== GET: Show import form (qua layout) =====
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Load danh sách campaigns cho dropdown
        List<Campaign> campaigns = campaignDAO.getAllCampaign();
        request.setAttribute("campaigns", campaigns);

        request.setAttribute("pageTitle", "Import Leads - CRM");
        request.setAttribute("contentPage", "marketing/lead/lead_import.jsp");
        request.setAttribute("pageCss", "lead_import.css");
        request.setAttribute("page", "lead-import");
        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
    }

    // ===== POST: Handle file upload =====
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // Get file from request
            Part filePart = request.getPart("file");
            String source = request.getParameter("source");
            String campaignIdStr = request.getParameter("campaignId");

            // Validate file
            if (filePart == null || filePart.getSize() == 0) {
                ImportLeadResponse errorResponse = new ImportLeadResponse();
                errorResponse.setSuccess(false);
                errorResponse.setMessage("Vui lòng chọn file");
                response.getWriter().write(gson.toJson(errorResponse));
                return;
            }

            // Check file type
            String fileName = filePart.getSubmittedFileName();
            if (!fileName.endsWith(".xlsx")) {
                ImportLeadResponse errorResponse = new ImportLeadResponse();
                errorResponse.setSuccess(false);
                errorResponse.setMessage("Chỉ hỗ trợ file .xlsx");
                response.getWriter().write(gson.toJson(errorResponse));
                return;
            }

            // Parse campaignId
            Integer campaignId = null;
            if (campaignIdStr != null && !campaignIdStr.trim().isEmpty()) {
                try {
                    campaignId = Integer.parseInt(campaignIdStr.trim());
                } catch (NumberFormatException ex) {
                    // ignore invalid campaignId
                }
            }

            // ===== Read Excel =====
            List<Lead> leads = ExcelUtil.readLeadsFromExcel(filePart.getInputStream());

            // ===== Import =====
            ImportLeadResponse importResponse = importService.importLeads(leads, source, campaignId);

            // ===== Response =====
            response.getWriter().write(gson.toJson(importResponse));

        } catch (Exception e) {
            ImportLeadResponse errorResponse = new ImportLeadResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("Lỗi: " + e.getMessage());
            errorResponse.addError(e.toString());
            response.getWriter().write(gson.toJson(errorResponse));
        }
    }
}
