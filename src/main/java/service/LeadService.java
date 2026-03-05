package service;

import java.util.List;

import dao.CampaignLeadDAO;
import dao.LeadDAO;
import model.Lead;
import util.LeadScoringUtil;

public class LeadService {

    private LeadDAO leadDAO = new LeadDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

    // ==============================
    // SEARCH + PAGINATION
    // ==============================
    /**
     * Tìm kiếm leads theo keyword + status, có phân trang
     */
    public List<Lead> searchLeads(String keyword, String status, int campaignId, int page, int pageSize) {
        return leadDAO.searchLeads(keyword, status, campaignId, page, pageSize);
    }

    /**
     * Đếm tổng leads theo điều kiện lọc (dùng cho phân trang)
     */
    public int countLeads(String keyword, String status, int campaignId) {
        return leadDAO.countLeads(keyword, status, campaignId);
    }

    public List<Lead> searchLeadsForExport(String keyword, String status, int campaignId) {
        return leadDAO.searchLeadsForExport(keyword, status, campaignId);
    }

    // ==============================
    // CRUD
    // ==============================
    /**
     * Tạo mới Lead (validate + set defaults)
     */
    public int createLead(Lead lead) {
        if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }
        if (lead.getEmail() == null || lead.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        validateLeadUniqueness(lead);

        // Tạo Lead mới (mỗi campaign có Lead record riêng, cùng email OK)
        int score = LeadScoringUtil.calculateScore(
                lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId());
        lead.setScore(score);
        lead.setStatus(LeadScoringUtil.determineStatus(score));

        int newId = leadDAO.createLead(lead);

        // Nếu có campaign → thêm vào Campaign_Leads
        if (newId > 0 && lead.getCampaignId() > 0) {
            campaignLeadDAO.assignLeadToCampaign(
                    lead.getCampaignId(), newId, "NEW");
        }
        return newId;
    }

    /**
     * Cập nhật Lead
     */
    public boolean updateLead(Lead lead) {
        if (lead.getLeadId() <= 0) {
            throw new IllegalArgumentException("Lead ID không hợp lệ.");
        }
        if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }
        if (lead.getEmail() == null || lead.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        validateLeadUniqueness(lead, lead.getLeadId());

        // Auto re-score & auto-status dựa trên thông tin mới
        // Giữ nguyên DEAL_CREATED nếu sale đã tạo deal
        int newScore = LeadScoringUtil.calculateScore(
                lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId());
        lead.setScore(newScore);

        if (!"DEAL_CREATED".equals(lead.getStatus())) {
            lead.setStatus(LeadScoringUtil.determineStatus(newScore));
        }

        return leadDAO.updateLead(lead);
    }

    // ==============================
    // EXISTING METHODS
    // ==============================
    /**
     * Import danh sách Leads (tự động check duplicate)
     */
    public int importLeads(List<Lead> leads) {
        int importedCount = 0;
        for (Lead lead : leads) {
            try {
                validateLeadUniqueness(lead);
            } catch (IllegalArgumentException ex) {
                continue;
            }

            // Tạo Lead mới (mỗi campaign có record riêng)
            int score = LeadScoringUtil.calculateScore(
                    lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId());
            lead.setScore(score);
            lead.setStatus(LeadScoringUtil.determineStatus(score));
            int newId = leadDAO.createLead(lead);
            if (newId > 0) {
                if (lead.getCampaignId() > 0) {
                    campaignLeadDAO.assignLeadToCampaign(
                            lead.getCampaignId(), newId, "NEW");
                }
                importedCount++;
            }
        }
        return importedCount;
    }

    /**
     * Kiểm tra Lead trùng lặp
     */
    public boolean checkDuplicate(String email) {
        return leadDAO.findLeadByEmail(email) != null;
    }

    public boolean checkDuplicatePhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        return leadDAO.findLeadByPhone(phone.trim()) != null;
    }

    public void validateLeadUniqueness(Lead lead) {
        validateLeadUniqueness(lead, null);
    }

    public void validateLeadUniqueness(Lead lead, Integer excludedLeadId) {
        String phone = lead.getPhone() != null ? lead.getPhone().trim() : "";
        lead.setPhone(phone);

        boolean hasExcludeId = excludedLeadId != null && excludedLeadId > 0;

        if (lead.getCampaignId() > 0) {
            Lead dupEmail = hasExcludeId
                    ? leadDAO.findLeadByEmailAndCampaignExcludeLeadId(lead.getEmail(), lead.getCampaignId(), excludedLeadId)
                    : leadDAO.findLeadByEmailAndCampaign(lead.getEmail(), lead.getCampaignId());
            if (dupEmail != null) {
                throw new IllegalArgumentException(
                        "Email \"" + lead.getEmail() + "\" đã tồn tại trong campaign này.");
            }

            if (!phone.isEmpty()) {
                Lead dupPhone = hasExcludeId
                        ? leadDAO.findLeadByPhoneAndCampaignExcludeLeadId(phone, lead.getCampaignId(), excludedLeadId)
                        : leadDAO.findLeadByPhoneAndCampaign(phone, lead.getCampaignId());
                if (dupPhone != null) {
                    throw new IllegalArgumentException(
                            "Số điện thoại \"" + phone + "\" đã tồn tại trong campaign này.");
                }
            }
            return;
        }

        Lead dupEmail = hasExcludeId
                ? leadDAO.findLeadByEmailExcludeLeadId(lead.getEmail(), excludedLeadId)
                : leadDAO.findLeadByEmail(lead.getEmail());
        if (dupEmail != null) {
            throw new IllegalArgumentException(
                    "Email \"" + lead.getEmail() + "\" đã tồn tại. Vui lòng chọn Campaign để thêm vào chiến dịch.");
        }

        if (!phone.isEmpty()) {
            Lead dupPhone = hasExcludeId
                    ? leadDAO.findLeadByPhoneExcludeLeadId(phone, excludedLeadId)
                    : leadDAO.findLeadByPhone(phone);
            if (dupPhone != null) {
                throw new IllegalArgumentException(
                        "Số điện thoại \"" + phone + "\" đã tồn tại. Vui lòng chọn Campaign để thêm vào chiến dịch.");
            }
        }
    }

    /**
     * Chấm điểm Lead + auto-qualify nếu score >= 50
     */
    public boolean scoreLead(int leadId, int score) {
        if (score < 0 || score > 100) {
            throw new IllegalArgumentException("Score must be between 0-100");
        }
        Lead lead = leadDAO.getLeadById(leadId);
        if (lead == null) {
            return false;
        }
        lead.setScore(score);
        // Auto-status theo score mới (giữ DEAL_CREATED nếu sale đã tạo)
        if (!"DEAL_CREATED".equals(lead.getStatus())) {
            lead.setStatus(LeadScoringUtil.determineStatus(score));
        }
        return leadDAO.updateLead(lead);
    }

    /**
     * Cập nhật trạng thái Lead
     */
    public boolean updateLeadStatus(int leadId, String status) {
        Lead lead = leadDAO.getLeadById(leadId);
        if (lead == null) {
            return false;
        }
        lead.setStatus(status);
        return leadDAO.updateLead(lead);
    }

    public Lead getLeadById(int leadId) {
        return leadDAO.getLeadById(leadId);
    }

    public List<Lead> getAllLeads() {
        return leadDAO.getAllLeads();
    }

    public List<Lead> getLeadsByStatus(String status) {
        return leadDAO.getLeadByStatus(status);
    }
}
