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

public class LeadImportService {

    private LeadDAO leadDAO = new LeadDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

    public ImportLeadResponse importLeads(List<Lead> leads, String source, Integer campaignId, List<Integer> assignedToIds) {

        ImportLeadResponse response = new ImportLeadResponse();

        // ===== INIT SAFE =====
        if (response.getImportedLeads() == null) {
            response.setImportedLeads(new ArrayList<>());
        }

        if (leads == null || leads.isEmpty()) {
            response.setSuccess(false);
            response.setTotalImported(0);
            response.setTotalFailed(0);
            response.setMessage("File không có dữ liệu.");
            return response;
        }

        Map<String, Lead> allExistingByEmail = leadDAO.findLeadsByEmailMap();
        if (allExistingByEmail == null) {
            allExistingByEmail = new HashMap<>();
        }

        // ===== LOAD EMAIL TRONG CAMPAIGN (ĐÃ FIX LOWER + TRIM) =====
        Set<String> emailsInCampaign = new HashSet<>();
        if (campaignId != null && campaignId > 0) {
            Set<String> temp = leadDAO.getExistingEmailsByCampaign(campaignId);
            if (temp != null) {
                for (String e : temp) {
                    if (e != null) {
                        emailsInCampaign.add(e.trim().toLowerCase());
                    }
                }
            }
        }

        Set<String> emailsInBatch = new HashSet<>();

        List<Lead> newLeads = new ArrayList<>();
        List<Lead> existingLeadsToAdd = new ArrayList<>();

        int totalFailed = 0;
        int assignIndex = 0;

        // ===== VALIDATE =====
        for (int i = 0; i < leads.size(); i++) {
            Lead lead = leads.get(i);
            int row = i + 2;

            List<String> errors = new ArrayList<>();

            String name = lead.getFullName() != null ? lead.getFullName().trim() : "";
            String rawEmail = lead.getEmail() != null ? lead.getEmail().trim() : "";
            String email = rawEmail.toLowerCase();

            String displayName = name.isEmpty() ? "Không có tên" : name;
            String displayEmail = rawEmail.isEmpty() ? "Không có email" : rawEmail;

            // ===== VALIDATE BASIC =====
            if (name.isEmpty()) {
                errors.add("thiếu họ tên");
            }

            if (rawEmail.isEmpty()) {
                errors.add("thiếu email");
            } else if (!EmailCheck.isValidEmail(rawEmail)) {
                errors.add("email không đúng định dạng (ví dụ: ten@congty.com)");
            }

            if (!errors.isEmpty()) {
                totalFailed++;
                response.addError("Dòng " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Dữ liệu không hợp lệ: " + String.join(", ", errors) + ". "
                        + "Vui lòng kiểm tra và sửa lại.");
                continue;
            }

            // ===== DUPLICATE TRONG FILE =====
            if (emailsInBatch.contains(email)) {
                totalFailed++;
                response.addError("Dòng " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Email này đã xuất hiện ở dòng trước trong file. "
                        + "Mỗi khách hàng chỉ được dùng một email duy nhất.");
                continue;
            }

            // ===== DUPLICATE TRONG CAMPAIGN =====
            if (emailsInCampaign.contains(email)) {
                totalFailed++;
                response.addError("Dòng " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Khách hàng này đã tồn tại trong chiến dịch. "
                        + "Không thể import trùng.");
                continue;
            }

            emailsInBatch.add(email);

            // ===== CHECK DB =====
            Lead existing = allExistingByEmail.get(email);

            if (existing != null) {
                existingLeadsToAdd.add(existing);
            } else {
                int score = LeadScoringUtil.calculateScore(
                        name, email, null,
                        campaignId != null ? campaignId : 0,
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

                // assign round-robin
                if (assignedToIds != null && !assignedToIds.isEmpty()) {
                    lead.setAssignedTo(assignedToIds.get(assignIndex % assignedToIds.size()));
                    assignIndex++;
                }

                newLeads.add(lead);
            }
        }

        // ===== NO VALID DATA =====
        if (newLeads.isEmpty() && existingLeadsToAdd.isEmpty()) {
            response.setSuccess(false);
            response.setTotalImported(0);
            response.setTotalFailed(totalFailed);
            response.setMessage("Import thất bại: tất cả dữ liệu đều không hợp lệ.");
            return response;
        }

        try {
            int inserted = 0;

            if (!newLeads.isEmpty()) {
                inserted = leadDAO.importLeads(newLeads);
            }

            Map<String, Lead> createdMap = new HashMap<>();

            if (!newLeads.isEmpty()) {
                List<String> emails = new ArrayList<>();
                for (Lead l : newLeads) {
                    emails.add(l.getEmail());
                }

                Map<String, Lead> temp = leadDAO.findLeadsByEmails(emails);
                if (temp != null) {
                    createdMap = temp;
                }
            }

            int totalSuccess = 0;

            if (campaignId != null && campaignId > 0) {

                // NEW LEADS
                for (Lead l : newLeads) {
                    Lead created = createdMap.get(l.getEmail().toLowerCase());
                    if (created != null) {
                        campaignLeadDAO.assignLeadToCampaign(campaignId, created.getLeadId(), "NEW");
                        response.addImportedLead(created);
                        totalSuccess++;
                    }
                }

                // EXISTING LEADS
                for (Lead l : existingLeadsToAdd) {
                    campaignLeadDAO.assignLeadToCampaign(campaignId, l.getLeadId(), "NEW");
                    response.addImportedLead(l);
                    totalSuccess++;
                }
            }

            // ===== FINAL RESULT =====
            response.setSuccess(totalSuccess > 0);
            response.setTotalImported(totalSuccess);
            response.setTotalFailed(totalFailed);

            if (totalFailed == 0) {
                response.setMessage("🎉 Import thành công! Đã thêm "
                        + totalSuccess + " khách hàng vào chiến dịch.");
            } else {
                response.setMessage("⚠️ Import hoàn tất: "
                        + totalSuccess + " khách hàng được thêm thành công, "
                        + totalFailed + " dòng bị lỗi. "
                        + "Vui lòng kiểm tra chi tiết bên dưới để sửa lại file.");
            }

        } catch (Exception e) {
            response.setSuccess(false);
            response.setTotalImported(0);
            response.setTotalFailed(totalFailed);
            response.setMessage("❌ Đã xảy ra lỗi hệ thống khi import.");
            response.addError("Chi tiết kỹ thuật: " + e.toString());
        }

        return response;
    }
}
