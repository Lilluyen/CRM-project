package service;

import java.util.ArrayList;
import java.util.List;

import dao.CampaignLeadDAO;
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
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
    private LeadService leadService = new LeadService();

    /**
     * Import leads với validation và scoring
     *
     * @return ImportLeadResponse
     */
    /**
     * Overload cũ — gọi version mới với danh sách assign rỗng.
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId) {
        return importLeads(leads, source, campaignId, new ArrayList<>());
    }

    /**
     * Import leads với validation, scoring và round-robin assign cho danh sách
     * sale đã chọn.
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId, List<Integer> assignedToIds) {
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

            // Check duplicate dùng rule chung từ LeadService
            if (errors.isEmpty()) {
                if (campaignId != null) {
                    lead.setCampaignId(campaignId);
                }

                try {
                    leadService.validateLeadUniqueness(lead);
                } catch (IllegalArgumentException ex) {
                    errors.add("Row " + rowNumber + ": " + ex.getMessage());
                }
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
                    lead.getFullName(),
                    lead.getEmail(),
                    lead.getPhone(),
                    (campaignId != null) ? campaignId : 0
            );
            lead.setScore(score);
            lead.setStatus(LeadScoringUtil.determineStatus(score));
            if (source != null) {
                lead.setSource(source);
            }
            // Gắn campaign nếu có chọn
            if (campaignId != null) {
                lead.setCampaignId(campaignId);
            }
            // Round-robin assign sale staff
            if (assignedToIds != null && !assignedToIds.isEmpty()) {
                int idx = validLeads.indexOf(lead) % assignedToIds.size();
                lead.setAssignedTo(assignedToIds.get(idx));
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

            // Gắn lead mới vào Campaign_Leads nếu có campaign
            if (campaignId != null && campaignId > 0) {
                // importLeads dùng batch → cần lấy lại leads vừa tạo để gắn campaign
                // Vì importLeads không trả về IDs, ta gắn bằng cách query lại
                for (Lead lead : validLeads) {
                    Lead created = leadDAO.findLeadByEmailAndCampaign(lead.getEmail(), campaignId);
                    if (created != null) {
                        if (!campaignLeadDAO.isLeadInCampaign(campaignId, created.getLeadId())) {
                            campaignLeadDAO.assignLeadToCampaign(campaignId, created.getLeadId(), "NEW");
                        }
                    }
                }
            }

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
