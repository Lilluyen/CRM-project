package service;

import java.util.ArrayList;
import java.util.List;

import dao.LeadDAO;
import model.ImportLeadResponse;
import model.Lead;
import util.EmailCheck;
import util.LeadScoringUtil;
import util.PhoneCheck;

/**
 * Service xử lý logic import leads
 */
public class LeadImportService {

    private LeadDAO leadDAO = new LeadDAO();

    /**
     * Import leads với validation và scoring
     * @return ImportLeadResponse
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source) {
        ImportLeadResponse response = new ImportLeadResponse();
        List<Lead> validLeads = new ArrayList<>();
        int rowNumber = 2; // Excel row (1-based + header)

        // ===== VALIDATION PHASE =====
        for (Lead lead : leads) {
            List<String> errors = new ArrayList<>();

            // Validate fullName
            if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
                errors.add("Row " + rowNumber + ": Tên không được để trống");
            }

            // Validate email
            if (lead.getEmail() == null || !EmailCheck.isValidEmail(lead.getEmail())) {
                errors.add("Row " + rowNumber + ": Email không hợp lệ: " + lead.getEmail());
            }

            // Validate phone (nếu có)
            if (lead.getPhone() != null && !lead.getPhone().isEmpty()) {
                if (!PhoneCheck.isValidPhone(lead.getPhone())) {
                    errors.add("Row " + rowNumber + ": Số điện thoại không hợp lệ: " + lead.getPhone());
                }
            }

            // Check duplicate
            if (leadDAO.isDuplicate(lead.getEmail(), lead.getPhone())) {
                errors.add("Row " + rowNumber + ": Email hoặc phone đã tồn tại");
            }

            rowNumber++;

            if (errors.isEmpty()) {
                validLeads.add(lead);
            } else {
                response.addError(String.join(" | ", errors));
            }
        }

        response.setTotalFailed(leads.size() - validLeads.size());

        // ===== SCORING PHASE =====
        for (Lead lead : validLeads) {
            int score = LeadScoringUtil.calculateScore(
                lead.getEmail(),
                lead.getPhone(),
                source != null ? source : lead.getSource()
            );
            lead.setScore(score);
            lead.setStatus("NEW_LEAD");
            if (source != null) {
                lead.setSource(source);
            }
        }

        // ===== IMPORT PHASE (Transaction) =====
        if (validLeads.isEmpty()) {
            response.setSuccess(false);
            response.setMessage("Không có lead nào hợp lệ!");
            return response;
        }

        try {
            int imported = leadDAO.importLeads(validLeads);
            response.setTotalImported(imported);
            response.setSuccess(true);
            response.setMessage("Import thành công " + imported + " leads!");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage("Lỗi import: " + e.getMessage());
            response.addError("Exception: " + e.toString());
            e.printStackTrace();
        }

        return response;
    }
}