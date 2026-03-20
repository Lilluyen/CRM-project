package service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import dao.CampaignLeadDAO;
import dao.LeadDAO;
import model.ImportLeadResponse;
import model.Lead;
import util.EmailCheck;
import util.LeadScoringUtil;
import util.PhoneCheck;

/**
 * Service xử lý logic import leads.
 *
 * Tối ưu performance cho batch lớn (1000+ bản ghi):
 * - Thay vì query DB từng lead một (N×4 queries), load toàn bộ
 *   email/phone đã tồn tại 1 lần duy nhất rồi check trong memory.
 * - Sau khi import xong, load toàn bộ lead vừa tạo bằng 1 query
 *   thay vì query từng email một.
 *
 * Logic duplicate giữ nguyên như LeadService.validateLeadUniqueness():
 * - Có campaignId: trùng email HOẶC phone trong cùng campaign → lỗi
 * - Không campaignId: trùng email HOẶC phone trong toàn bộ Leads → lỗi
 */
public class LeadImportService {

    private LeadDAO leadDAO = new LeadDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

    /**
     * Overload cũ — gọi version mới với danh sách assign rỗng.
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId) {
        return importLeads(leads, source, campaignId, new ArrayList<>());
    }

    /**
     * Import leads với validation, scoring và round-robin assign.
     *
     * Logic duplicate (giữ nguyên):
     * - Cùng email + cùng campaign → lỗi "đã tồn tại trong campaign"
     * - Cùng email + khác campaign → OK
     * - File có mix dữ liệu mới + cũ → import mới, báo lỗi cũ
     */
    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId, List<Integer> assignedToIds) {
        ImportLeadResponse response = new ImportLeadResponse();
        List<Lead> validLeads = new ArrayList<>();

        // ===== LOAD EXISTING DATA — 1 lần duy nhất thay vì N queries =====
        // Giống logic validateLeadUniqueness() nhưng bulk thay vì từng cái
        Set<String> existingEmails;
        Set<String> existingPhones;

        if (campaignId != null && campaignId > 0) {
            // Có campaign → chỉ check trùng trong campaign đó
            existingEmails = leadDAO.getExistingEmailsByCampaign(campaignId);
            existingPhones = leadDAO.getExistingPhonesByCampaign(campaignId);
        } else {
            // Không có campaign → check trùng toàn bộ Leads
            existingEmails = leadDAO.getAllExistingEmails();
            existingPhones = leadDAO.getAllExistingPhones();
        }

        // ===== VALIDATION PHASE =====
        // Track email/phone trong chính file để phát hiện trùng nội bộ
        Set<String> emailsInBatch = new HashSet<>();
        Set<String> phonesInBatch = new HashSet<>();

        for (int i = 0; i < leads.size(); i++) {
            Lead lead = leads.get(i);
            int excelRow = i + 2; // Row 1 là header, data từ row 2
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
            String phone = (lead.getPhone() != null) ? lead.getPhone().trim() : "";
            lead.setPhone(phone);
            if (!phone.isEmpty() && !PhoneCheck.isValidPhone(phone)) {
                errors.add("Số điện thoại không hợp lệ: " + phone);
            }

            // Check duplicate — chỉ khi không có lỗi validation khác
            // Message giữ nguyên giống validateLeadUniqueness()
            if (errors.isEmpty()) {
                if (campaignId != null) {
                    lead.setCampaignId(campaignId);
                }

                String emailKey = lead.getEmail().toLowerCase();

                // 1. Check trùng với DB (in-memory, không query)
                if (existingEmails.contains(emailKey)) {
                    if (campaignId != null && campaignId > 0) {
                        errors.add("Email \"" + lead.getEmail() + "\" đã tồn tại trong campaign này.");
                    } else {
                        errors.add("Email \"" + lead.getEmail() + "\" đã tồn tại. Vui lòng chọn Campaign để thêm vào chiến dịch.");
                    }
                }

                // 2. Check trùng phone với DB
                if (errors.isEmpty() && !phone.isEmpty() && existingPhones.contains(phone)) {
                    if (campaignId != null && campaignId > 0) {
                        errors.add("Số điện thoại \"" + phone + "\" đã tồn tại trong campaign này.");
                    } else {
                        errors.add("Số điện thoại \"" + phone + "\" đã tồn tại. Vui lòng chọn Campaign để thêm vào chiến dịch.");
                    }
                }

                // 3. Check trùng trong chính file (2 row cùng email/phone)
                if (errors.isEmpty()) {
                    if (emailsInBatch.contains(emailKey)) {
                        errors.add("Email \"" + lead.getEmail() + "\" bị trùng trong file import.");
                    } else if (!phone.isEmpty() && phonesInBatch.contains(phone)) {
                        errors.add("Số điện thoại \"" + phone + "\" bị trùng trong file import.");
                    } else {
                        // Hợp lệ → đăng ký vào batch set để check các row sau
                        emailsInBatch.add(emailKey);
                        if (!phone.isEmpty()) phonesInBatch.add(phone);
                    }
                }
            }

            if (errors.isEmpty()) {
                validLeads.add(lead);
            } else {
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

            if (campaignId != null) {
                lead.setCampaignId(campaignId);
            }

            // Round-robin assign sale staff
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
            // Batch insert tất cả valid leads (1 transaction)
            int imported = leadDAO.importLeads(validLeads);
            response.setTotalImported(imported);

            // Load toàn bộ lead vừa tạo bằng 1 query (thay vì N queries)
            List<String> importedEmails = new ArrayList<>();
            for (Lead lead : validLeads) {
                importedEmails.add(lead.getEmail());
            }

            Map<String, Lead> createdLeadMap;
            if (campaignId != null && campaignId > 0) {
                createdLeadMap = leadDAO.findLeadsByEmailsAndCampaign(importedEmails, campaignId);
            } else {
                createdLeadMap = leadDAO.findLeadsByEmails(importedEmails);
            }

            // Gắn vào Campaign_Leads + collect cho activity logging
            for (Lead lead : validLeads) {
                Lead created = createdLeadMap.get(lead.getEmail().toLowerCase());
                if (created != null) {
                    if (campaignId != null && campaignId > 0) {
                        if (!campaignLeadDAO.isLeadInCampaign(campaignId, created.getLeadId())) {
                            campaignLeadDAO.assignLeadToCampaign(campaignId, created.getLeadId(), "NEW");
                        }
                    }
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