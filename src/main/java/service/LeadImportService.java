package service;

import java.util.ArrayList;
import java.util.HashMap;
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
 * Service xử lý logic import leads — Hướng A.
 *
 * DB có UNIQUE constraint trên cả email lẫn phone trong bảng Leads. → Mỗi
 * email/phone chỉ được có 1 row duy nhất trong Leads. → Quan hệ lead ↔ campaign
 * quản lý qua bảng Campaign_Leads.
 *
 * Logic import: 1. Email/phone chưa tồn tại trong DB → INSERT lead mới + thêm
 * Campaign_Leads 2. Email đã tồn tại + chưa trong campaign → dùng lại lead cũ +
 * thêm Campaign_Leads (KHÔNG INSERT) 3. Email đã tồn tại + đã trong campaign →
 * báo lỗi trùng 4. Email/phone trùng trong chính file → báo lỗi
 *
 * Performance: load bulk email/phone 1 lần, không query từng lead.
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

    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId, List<Integer> assignedToIds) {
        ImportLeadResponse response = new ImportLeadResponse();

        // ===== LOAD EXISTING DATA — bulk 1 lần =====
        // Map email_lower → Lead: toàn bộ leads đã có trong DB
        Map<String, Lead> allExistingByEmail = leadDAO.findLeadsByEmailMap();

        // Map phone → Lead: toàn bộ leads đã có trong DB (để check UNIQUE phone)
        Map<String, Lead> allExistingByPhone = leadDAO.findLeadsByPhoneMap();

        // Set email đã có trong campaign này (để phát hiện duplicate trong campaign)
        Set<String> emailsAlreadyInCampaign = new HashSet<>();
        if (campaignId != null && campaignId > 0) {
            emailsAlreadyInCampaign = leadDAO.getExistingEmailsByCampaign(campaignId);
        }

        // ===== VALIDATION PHASE =====
        // Check trùng trong chính file
        Set<String> emailsInBatch = new HashSet<>();
        Set<String> phonesInBatch = new HashSet<>();

        // newLeads: cần INSERT vào Leads
        List<Lead> newLeads = new ArrayList<>();
        // existingLeads: đã có trong DB, chỉ cần thêm Campaign_Leads
        // Map email_lower → Lead (lead cũ trong DB)
        Map<String, Lead> existingToLink = new HashMap<>();

        int assignIndex = 0;
        int totalFailed = 0;

        for (int i = 0; i < leads.size(); i++) {
            Lead lead = leads.get(i);
            int excelRow = i + 2;
            List<String> errors = new ArrayList<>();

            // --- Validate fullName ---
            if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
                errors.add("Tên không được để trống");
            }

            // --- Validate email ---
            if (lead.getEmail() == null || !EmailCheck.isValidEmail(lead.getEmail())) {
                errors.add("Email không hợp lệ: " + lead.getEmail());
            }

            // --- Validate phone ---
            // Normalize: null hoặc empty → null (tránh vi phạm UNIQUE constraint)
            String phone = (lead.getPhone() != null && !lead.getPhone().trim().isEmpty())
                    ? lead.getPhone().trim() : null;
            lead.setPhone(phone); // null nếu không có SĐT
            if (phone != null && !PhoneCheck.isValidPhone(phone)) {
                errors.add("Số điện thoại không hợp lệ: " + phone);
            }
            // Dùng empty string cho logic check phía dưới
            if (phone == null) {
                phone = "";
            }

            if (!errors.isEmpty()) {
                totalFailed++;
                String leadInfo = (lead.getFullName() != null ? lead.getFullName() : "N/A")
                        + " (" + (lead.getEmail() != null ? lead.getEmail() : "N/A") + ")";
                response.addError("Row " + excelRow + " - " + leadInfo + ": " + String.join(", ", errors));
                continue;
            }

            String emailKey = lead.getEmail().toLowerCase();

            // --- Check trùng email trong file ---
            if (emailsInBatch.contains(emailKey)) {
                totalFailed++;
                response.addError("Row " + excelRow + " - " + lead.getFullName()
                        + " (" + lead.getEmail() + "): Email bị trùng trong file import.");
                continue;
            }

            // --- Check trùng phone trong file ---
            if (!phone.isEmpty() && phonesInBatch.contains(phone)) {
                totalFailed++;
                response.addError("Row " + excelRow + " - " + lead.getFullName()
                        + " (" + lead.getEmail() + "): Số điện thoại \"" + phone + "\" bị trùng trong file import.");
                continue;
            }

            // --- Xác định lead này là NEW hay EXISTING ---
            Lead existingLead = allExistingByEmail.get(emailKey);

            if (existingLead != null) {
                // Email đã có trong DB

                if (campaignId != null && campaignId > 0) {
                    // Check đã có trong campaign chưa
                    if (emailsAlreadyInCampaign.contains(emailKey)) {
                        totalFailed++;
                        response.addError("Row " + excelRow + " - " + lead.getFullName()
                                + " (" + lead.getEmail() + "): Email đã tồn tại trong campaign này.");
                        continue;
                    }
                    // Chưa có trong campaign → sẽ link vào Campaign_Leads
                    existingToLink.put(emailKey, existingLead);
                } else {
                    // Không có campaign → email đã tồn tại = lỗi trùng
                    totalFailed++;
                    response.addError("Row " + excelRow + " - " + lead.getFullName()
                            + " (" + lead.getEmail() + "): Email \"" + lead.getEmail()
                            + "\" đã tồn tại. Vui lòng chọn Campaign để thêm vào chiến dịch.");
                    continue;
                }

            } else {
                // Email chưa có → check phone có bị trùng với DB không
                if (!phone.isEmpty() && allExistingByPhone.containsKey(phone)) {
                    totalFailed++;
                    response.addError("Row " + excelRow + " - " + lead.getFullName()
                            + " (" + lead.getEmail() + "): Số điện thoại \"" + phone
                            + "\" đã tồn tại trong hệ thống.");
                    continue;
                }
                // Hợp lệ → cần INSERT mới
                newLeads.add(lead);
            }

            // Đăng ký vào batch set
            emailsInBatch.add(emailKey);
            if (!phone.isEmpty()) {
                phonesInBatch.add(phone);
            }

            // Scoring + set source/campaign/assign
            int score = LeadScoringUtil.calculateScore(
                    lead.getFullName(), lead.getEmail(), phone,
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

            // Round-robin assign
            if (assignedToIds != null && !assignedToIds.isEmpty()) {
                lead.setAssignedTo(assignedToIds.get(assignIndex % assignedToIds.size()));
                assignIndex++;
            }
        }

        response.setTotalFailed(totalFailed);

        // ===== IMPORT PHASE =====
        int totalValid = newLeads.size() + existingToLink.size();

        if (totalValid == 0) {
            response.setSuccess(false);
            response.setTotalFailed(leads.size());
            response.setMessage(leads.size() == 1
                    ? "Không có lead nào hợp lệ để import."
                    : "Không có lead nào hợp lệ để import. Tất cả " + leads.size() + " leads đều bị lỗi.");
            return response;
        }

        try {
            int inserted = 0;

            // 1. Batch INSERT các lead mới (email chưa có trong DB)
            if (!newLeads.isEmpty()) {
                inserted = leadDAO.importLeads(newLeads);
            }

            int totalImported = inserted + existingToLink.size();
            response.setTotalImported(totalImported);

            // 2. Load lại lead vừa INSERT để lấy lead_id (1 query bulk)
            Map<String, Lead> newlyCreatedMap = new HashMap<>();
            if (!newLeads.isEmpty()) {
                List<String> newEmails = new ArrayList<>();
                for (Lead l : newLeads) {
                    newEmails.add(l.getEmail());
                }
                newlyCreatedMap = leadDAO.findLeadsByEmails(newEmails);
            }

            // 3. Gắn tất cả vào Campaign_Leads + collect cho activity log
            if (campaignId != null && campaignId > 0) {

                // 3a. Lead mới INSERT
                for (Lead lead : newLeads) {
                    String emailKey = lead.getEmail().toLowerCase();
                    Lead created = newlyCreatedMap.get(emailKey);
                    if (created != null) {
                        if (!campaignLeadDAO.isLeadInCampaign(campaignId, created.getLeadId())) {
                            campaignLeadDAO.assignLeadToCampaign(campaignId, created.getLeadId(), "NEW");
                        }
                        response.addImportedLead(created);
                    }
                }

                // 3b. Lead cũ đã tồn tại → chỉ link Campaign_Leads
                for (Map.Entry<String, Lead> entry : existingToLink.entrySet()) {
                    Lead existing = entry.getValue();
                    if (!campaignLeadDAO.isLeadInCampaign(campaignId, existing.getLeadId())) {
                        campaignLeadDAO.assignLeadToCampaign(campaignId, existing.getLeadId(), "NEW");
                    }
                    response.addImportedLead(existing);
                }

            } else {
                // Không có campaign → chỉ có lead mới
                for (Lead lead : newLeads) {
                    Lead created = newlyCreatedMap.get(lead.getEmail().toLowerCase());
                    if (created != null) {
                        response.addImportedLead(created);
                    }
                }
            }

            // Build success message
            String campaignInfo = (campaignId != null) ? " vào campaign" : "";
            if (response.getTotalFailed() > 0) {
                response.setSuccess(true);
                response.setMessage("Import thành công " + totalImported + " leads" + campaignInfo + ". "
                        + response.getTotalFailed() + " leads bị lỗi (trùng lặp hoặc dữ liệu không hợp lệ).");
            } else {
                response.setSuccess(true);
                response.setMessage("Import thành công " + totalImported + " leads" + campaignInfo + "!");
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
