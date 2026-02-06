package service;

import java.util.List;

import dao.LeadDAO;
import model.Lead;

public class LeadService {

    private LeadDAO leadDAO = new LeadDAO();

    /**
     * Import danh sách Leads (tự động check duplicate)
     */
    public int importLeads(List<Lead> leads) {
        int importedCount = 0;
        for (Lead lead : leads) {
            if (leadDAO.findByEmail(lead.getEmail()) == null) {
                lead.setStatus("NEW_LEAD");
                lead.setScore(0);
                if (leadDAO.insert(lead) > 0) {
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
        return leadDAO.findByEmail(email) != null;
    }

    /**
     * Chấm điểm Lead + auto-qualify nếu score >= 50
     */
    public boolean scoreLead(int leadId, int score) {
        if (score < 0 || score > 100) {
            throw new IllegalArgumentException("Score must be between 0-100");
        }
        Lead lead = leadDAO.getById(leadId);
        if (lead == null) {
            return false;
        }
        lead.setScore(score);
        // Auto-qualify nếu score >= 50
        if (score >= 50 && !lead.getStatus().equals("QUALIFIED")) {
            lead.setStatus("QUALIFIED");
        }
        return leadDAO.update(lead);
    }

    /**
     * Cập nhật trạng thái Lead
     */
    public boolean updateLeadStatus(int leadId, String status) {
        Lead lead = leadDAO.getById(leadId);
        if (lead == null) {
            return false;
        }
        lead.setStatus(status);
        return leadDAO.update(lead);
    }

    public Lead getLeadById(int leadId) {
        return leadDAO.getById(leadId);
    }

    public List<Lead> getAllLeads() {
        return leadDAO.getAll();
    }

    public List<Lead> getLeadsByStatus(String status) {
        return leadDAO.getByStatus(status);
    }
}
