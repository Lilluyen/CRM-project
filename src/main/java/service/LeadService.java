package service;

import java.util.List;

import dao.LeadDAO;
import model.Lead;

public class LeadService {

    private LeadDAO leadDAO = new LeadDAO();

    // ==============================
    // SEARCH + PAGINATION
    // ==============================
    /**
     * Tìm kiếm leads theo keyword + status, có phân trang
     */
    public List<Lead> searchLeads(String keyword, String status, int page, int pageSize) {
        return leadDAO.searchLeads(keyword, status, page, pageSize);
    }

    /**
     * Đếm tổng leads theo điều kiện lọc (dùng cho phân trang)
     */
    public int countLeads(String keyword, String status) {
        return leadDAO.countLeads(keyword, status);
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
        // Check duplicate email
        if (leadDAO.findLeadByEmail(lead.getEmail()) != null) {
            throw new IllegalArgumentException("Email đã tồn tại trong hệ thống.");
        }
        // Set defaults
        if (lead.getStatus() == null || lead.getStatus().trim().isEmpty()) {
            lead.setStatus("NEW_LEAD");
        }
        return leadDAO.createLead(lead);
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
                lead.setScore(0);
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
