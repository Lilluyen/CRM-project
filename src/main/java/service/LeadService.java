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

        // Check: email đã tồn tại?
        Lead existingLead = leadDAO.findLeadByEmail(lead.getEmail());
        if (existingLead != null) {
            // Nếu có chọn campaign mới → gắn lead cũ vào campaign đó
            if (lead.getCampaignId() > 0) {
                if (campaignLeadDAO.isLeadInCampaign(lead.getCampaignId(), existingLead.getLeadId())) {
                    throw new IllegalArgumentException(
                            "Lead \"" + existingLead.getFullName() + "\" đã thuộc campaign này rồi.");
                }
                // Gắn lead cũ vào campaign mới qua bảng Campaign_Leads
                campaignLeadDAO.assignLeadToCampaign(
                        lead.getCampaignId(), existingLead.getLeadId(), "NEW");
                // Cập nhật campaign_id chính của lead (latest campaign)
                existingLead.setCampaignId(lead.getCampaignId());
                leadDAO.updateLead(existingLead);
                return existingLead.getLeadId();
            }
            // Không chọn campaign → thật sự trùng
            throw new IllegalArgumentException(
                    "Email đã tồn tại. Nếu muốn gắn vào campaign khác, vui lòng chọn Campaign.");
        }

        // Lead mới hoàn toàn
        if (lead.getStatus() == null || lead.getStatus().trim().isEmpty()) {
            lead.setStatus("NEW_LEAD");
        }
        // Auto-score nếu chưa có điểm
        if (lead.getScore() <= 0) {
            lead.setScore(LeadScoringUtil.calculateScore(
                    lead.getEmail(), lead.getPhone(), lead.getSource()));
        }
        // Auto-qualify nếu score >= 50
        if (lead.getScore() >= 50 && "NEW_LEAD".equals(lead.getStatus())) {
            lead.setStatus("QUALIFIED");
        }
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
            if (leadDAO.findLeadByEmail(lead.getEmail()) == null) {
                lead.setStatus("NEW_LEAD");
                // Auto-score dựa trên dữ liệu có sẵn
                int score = LeadScoringUtil.calculateScore(
                        lead.getEmail(), lead.getPhone(), lead.getSource());
                lead.setScore(score);
                // Auto-qualify nếu score >= 50
                if (score >= 50) {
                    lead.setStatus("QUALIFIED");
                }
                if (leadDAO.createLead(lead) > 0) {
                    importedCount++;
                }
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
        // Auto-qualify nếu score >= 50
        if (score >= 50 && !lead.getStatus().equals("QUALIFIED")) {
            lead.setStatus("QUALIFIED");
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
