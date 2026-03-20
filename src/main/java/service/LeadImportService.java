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
     * Overload cũ — gọi version mới với danh sách assign rỗng.
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId) {
        return importLeads(leads, source, campaignId, new ArrayList<>());
    }

    /**
     * Import leads với validation, scoring và round-robin assign cho danh sách
     * sale đã chọn.
     *
     * Logic:
     * - Cùng email + cùng campaign → lỗi "đã tồn tại trong campaign"
     * - Cùng email + khác campaign → OK (1 người có thể ở nhiều campaign)
     * - File có mix dữ liệu mới + cũ → import dữ liệu mới, báo lỗi dữ liệu cũ
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId, List<Integer> assignedToIds) {
        ImportLeadResponse response = new ImportLeadResponse();
        List<Lead> validLeads = new ArrayList<>();

        // ===== VALIDATION PHASE =====
        for (int i = 0; i < leads.size(); i++) {
            Lead lead = leads.get(i);
            int excelRow = i + 2; // Row 1 là header, data bắt đầu từ row 2
            List<String> errors = new ArrayList<>();

            // Validate fullName
            if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
                errors.add("Tên không được để trống");
            }

            // Validate email
            if (lead.getEmail() == null || !EmailCheck.isValidEmail(lead.getEmail())) {
                errors.add("Email không hợp lệ: " + lead.getEmail());
            }

            // Validate phone (nếu có)
            if (lead.getPhone() != null && !lead.getPhone().isEmpty()) {
                if (!PhoneCheck.isValidPhone(lead.getPhone())) {
                    errors.add("Số điện thoại không hợp lệ: " + lead.getPhone());
                }
            }

            // Check duplicate — chỉ khi không có lỗi validation khác
            if (errors.isEmpty()) {
                if (campaignId != null) {
                    lead.setCampaignId(campaignId);
                }

                try {
                    leadService.validateLeadUniqueness(lead);
                } catch (IllegalArgumentException ex) {
                    // Duplicate in same campaign → báo lỗi rõ ràng
                    errors.add(ex.getMessage());
                }
            }

            if (errors.isEmpty()) {
                validLeads.add(lead);
            } else {
                // Format: "Row X - Nguyễn Văn A (email@...) : lý do lỗi"
                String leadInfo = (lead.getFullName() != null ? lead.getFullName() : "N/A")
                        + " (" + (lead.getEmail() != null ? lead.getEmail() : "N/A") + ")";
                response.addError("Row " + excelRow + " - " + leadInfo + ": " + String.join(", ", errors));
            }
        }

        response.setTotalFailed(leads.size() - validLeads.size());

        // ===== SCORING PHASE =====
        for (int i = 0; i < validLeads.size(); i++) {
            Lead lead = validLeads.get(i);

            int score = LeadScoringUtil.calculateScore(
                    lead.getFullName(),
                    lead.getEmail(),
                    lead.getPhone(),
                    (campaignId != null) ? campaignId : 0,
                    lead.getInterest()
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

            // Round-robin assign sale staff — dùng index i thay vì indexOf()
            if (assignedToIds != null && !assignedToIds.isEmpty()) {
                lead.setAssignedTo(assignedToIds.get(i % assignedToIds.size()));
            }
        }

        // ===== IMPORT PHASE (Transaction) =====
        if (validLeads.isEmpty()) {
            response.setSuccess(false);
            int totalFailed = leads.size();
            response.setTotalFailed(totalFailed);
            if (totalFailed == 1) {
                response.setMessage("Không có lead nào hợp lệ để import.");
            } else {
                response.setMessage("Không có lead nào hợp lệ để import. Tất cả " + totalFailed + " leads đều bị lỗi.");
            }
            return response;
        }

        try {
            int imported = leadDAO.importLeads(validLeads);
            response.setTotalImported(imported);

            // Gắn lead mới vào Campaign_Leads nếu có campaign
            // Đồng thời query lại để lấy danh sách lead đã import (cho activity logging)
            for (Lead lead : validLeads) {
                Lead created;
                if (campaignId != null && campaignId > 0) {
                    // Query by email + campaign
                    created = leadDAO.findLeadByEmailAndCampaign(lead.getEmail(), campaignId);
                    if (created != null) {
                        if (!campaignLeadDAO.isLeadInCampaign(campaignId, created.getLeadId())) {
                            campaignLeadDAO.assignLeadToCampaign(campaignId, created.getLeadId(), "NEW");
                        }
                    }
                } else {
                    // Query by email only (no campaign)
                    created = leadDAO.findLeadByEmail(lead.getEmail());
                }

                // Add to response for activity logging
                if (created != null) {
                    response.addImportedLead(created);
                }
            }

            // Build success message
            String campaignInfo = (campaignId != null) ? " vào campaign" : "";
            if (response.getTotalFailed() > 0) {
                response.setSuccess(true);
                response.setMessage("Import thành công " + imported + " leads" + campaignInfo + ". "
                        + response.getTotalFailed() + " leads bị lỗi (trùng lặp hoặc dữ liệu không hợp lệ).");
            } else {
                response.setSuccess(true);
                response.setMessage("Import thành công " + imported + " leads" + campaignInfo + "!");
            }
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage("Lỗi import: " + e.getMessage());
            response.addError("Exception: " + e.toString());
            e.printStackTrace();
        }

        return response;
    }
}