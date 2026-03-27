package controller.marketing;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import dao.CampaignDAO;
import dao.UserDAO;
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
import model.User;
import service.LeadImportService;
import util.ExcelUtil;
import util.JsonUtility;
import util.LeadActivityUtil;

@WebServlet(name = "LeadImportController", urlPatterns = {"/marketing/leads/import"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024)
public class LeadImportController extends HttpServlet {

    private LeadImportService importService = new LeadImportService();
    private CampaignDAO campaignDAO = new CampaignDAO();
    private UserDAO userDAO = new UserDAO();
    // Đã xóa: private Gson gson = new Gson();
    // Dùng JsonUtility thay thế để xử lý đúng LocalDateTime (Java 17+)

    // ===== GET: Show import form (qua layout) =====
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Load danh sách campaigns cho dropdown
        List<Campaign> campaigns = campaignDAO.getAllCampaign();
        request.setAttribute("campaigns", campaigns);

        // Load danh sách sale staffs cho checkbox assign
        List<User> saleStaffs = userDAO.getActiveSaleStaffs();
        request.setAttribute("saleStaffs", saleStaffs);

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
                errorResponse.setMessage("Please select a file");
                response.getWriter().write(JsonUtility.toJson(errorResponse));
                return;
            }

            // Check file type
            String fileName = filePart.getSubmittedFileName();
            if (!fileName.endsWith(".xlsx")) {
                ImportLeadResponse errorResponse = new ImportLeadResponse();
                errorResponse.setSuccess(false);
                errorResponse.setMessage("Only .xlsx files are supported. Please select a valid Excel file.");
                response.getWriter().write(JsonUtility.toJson(errorResponse));
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

            // Parse assignedToIds (checkbox multi-select)
            String[] assignedToArr = request.getParameterValues("assignedToIds");
            List<Integer> assignedToIds = new ArrayList<>();
            if (assignedToArr != null) {
                for (String idStr : assignedToArr) {
                    try {
                        assignedToIds.add(Integer.parseInt(idStr.trim()));
                    } catch (NumberFormatException ex) {
                        // ignore invalid id
                    }
                }
            }

            // ===== Read Excel =====
            List<String> parseErrors = new ArrayList<>();
            List<Lead> leads;
            try {
                leads = ExcelUtil.readLeadsFromExcel(filePart.getInputStream(), parseErrors);
            } catch (Exception e) {
                // File format error - can't read Excel
                ImportLeadResponse errorResponse = new ImportLeadResponse();
                errorResponse.setSuccess(false);
                errorResponse.setMessage("Please select a different file as the format is incorrect. The file must be a .xlsx file and not corrupted.");
                errorResponse.addError("Error reading file: " + e.getMessage());
                response.getWriter().write(JsonUtility.toJson(errorResponse));
                return;
            }

            // Check if file is empty or has no data rows
            if (leads == null || leads.isEmpty()) {
                ImportLeadResponse errorResponse = new ImportLeadResponse();
                errorResponse.setSuccess(false);
                errorResponse.setMessage("File does not contain data or is not in the correct format.");
                response.getWriter().write(JsonUtility.toJson(errorResponse));
                return;
            }

            // ===== Import =====
            ImportLeadResponse importResponse = importService.importLeads(leads, source, campaignId, assignedToIds);

            // Add parse errors to response
            if (!parseErrors.isEmpty()) {
                for (String err : parseErrors) {
                    importResponse.addError(err);
                }
                importResponse.setTotalFailed(importResponse.getTotalFailed() + parseErrors.size());
            }

            // ===== Log Activity for imported leads =====
            if (importResponse.isSuccess()) {
                User sessionUser = (User) request.getSession().getAttribute("user");
                if (sessionUser != null) {
                    for (Lead imported : importResponse.getImportedLeads()) {
                        LeadActivityUtil.logLeadActivity(
                                imported.getLeadId(),
                                imported.getFullName(),
                                "Lead Imported - " + imported.getFullName(),
                                "Lead imported from Excel file",
                                sessionUser
                        );
                    }
                }
            }

            // ===== Response =====
            response.getWriter().write(JsonUtility.toJson(importResponse));

        } catch (Exception e) {
            ImportLeadResponse errorResponse = new ImportLeadResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("Error: " + e.getMessage());
            errorResponse.addError(e.toString());
            response.getWriter().write(JsonUtility.toJson(errorResponse));
        }
    }
}