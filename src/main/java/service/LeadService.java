package service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import dao.CampaignLeadDAO;
import dao.LeadDAO;
import model.Campaign;
import model.Lead;
import util.LeadScoringUtil;

public class LeadService {

    private LeadDAO leadDAO = new LeadDAO();
    private CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();

    // ==============================
    // SEARCH + PAGINATION
    // ==============================
    public List<Lead> searchLeads(String keyword, String status, int campaignId, String interest, int page, int pageSize) {
        return leadDAO.searchLeads(keyword, status, campaignId, interest, page, pageSize);
    }

    public int countLeads(String keyword, String status, int campaignId, String interest) {
        return leadDAO.countLeads(keyword, status, campaignId, interest);
    }

    public List<Lead> searchLeadsForExport(String keyword, String status, int campaignId, String interest) {
        return leadDAO.searchLeadsForExport(keyword, status, campaignId, interest);
    }

    // ==============================
    // CRUD
    // ==============================

    /**
     * Tạo mới Lead (validate + set defaults)
     */
    public int createLead(Lead lead, boolean autoScore) {
        if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Full name is required.");
        }
        if (lead.getEmail() == null || lead.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required.");
        }
        validateLeadUniqueness(lead);

        if (autoScore || lead.getScore() <= 0) {
            int score = LeadScoringUtil.calculateScore(
                    lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId(), lead.getInterest());
            lead.setScore(score);
            lead.setStatus(LeadScoringUtil.determineStatus(score));
        }

        int newId = leadDAO.createLead(lead);
//        if (newId > 0 && lead.getCampaignId() > 0) {
//            campaignLeadDAO.assignLeadToCampaign(lead.getCampaignId(), newId, "NEW");
//        }
        return newId;
    }

    public int createLead(Lead lead) {
        return createLead(lead, true);
    }

    /**
     * Cập nhật thông tin Lead.
     * Nếu form không gửi campaignId (= 0), restore từ DB để validate đúng phạm vi.
     */
    public boolean updateLead(Lead lead, boolean autoScore) {
        if (lead.getLeadId() <= 0) {
            throw new IllegalArgumentException("Invalid Lead ID.");
        }
        if (lead.getFullName() == null || lead.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Full name is required.");
        }
        if (lead.getEmail() == null || lead.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required.");
        }

        // Restore campaignId gốc từ DB nếu form không gửi lên
        if (lead.getCampaignId() <= 0) {
            Lead existing = leadDAO.getLeadById(lead.getLeadId());
            if (existing != null && existing.getCampaignId() > 0) {
                lead.setCampaignId(existing.getCampaignId());
            }
        }

        validateLeadUniqueness(lead, lead.getLeadId());

        if (autoScore || lead.getScore() <= 0) {
            int newScore = LeadScoringUtil.calculateScore(
                    lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId(), lead.getInterest());
            lead.setScore(newScore);
            if (!"DEAL_CREATED".equals(lead.getStatus())) {
                lead.setStatus(LeadScoringUtil.determineStatus(newScore));
            }
        }

        return leadDAO.updateLead(lead);
    }

    public boolean updateLead(Lead lead) {
        return updateLead(lead, true);
    }

    /**
     * Cập nhật campaign membership của Lead theo danh sách checkbox từ form.
     * - Có trong newCampaignIds nhưng chưa có trong DB  → thêm vào Campaign_Leads
     * - Đang có trong DB nhưng không có trong newCampaignIds → xóa khỏi Campaign_Leads
     * - Cập nhật lead.campaignId = campaign đầu tiên còn lại (hoặc 0 nếu bỏ hết)
     *
     * @param leadId         ID của lead
     * @param newCampaignIds Danh sách campaignId được tích trên form (có thể rỗng)
     */
    public void updateLeadCampaigns(int leadId, List<Integer> newCampaignIds) {
        if (newCampaignIds == null) {
            newCampaignIds = new ArrayList<>();
        }

        // Campaign đang có trong Campaign_Leads
        List<Campaign> currentCampaigns = campaignLeadDAO.getCampaignsByLeadId(leadId);
        List<Integer> currentIds = currentCampaigns.stream()
                .map(Campaign::getCampaignId)
                .collect(Collectors.toList());

        // Thêm campaign mới được tích
        for (int campaignId : newCampaignIds) {
            if (!currentIds.contains(campaignId)) {
                campaignLeadDAO.assignLeadToCampaign(campaignId, leadId, "NEW");
            }
        }

        // Xóa campaign bị bỏ tích
        for (int campaignId : currentIds) {
            if (!newCampaignIds.contains(campaignId)) {
                campaignLeadDAO.removeLeadFromCampaign(campaignId, leadId);
            }
        }

        // Đồng bộ lead.campaignId trong bảng Leads
        int primaryCampaignId = newCampaignIds.isEmpty() ? 0 : newCampaignIds.get(0);
        Lead lead = leadDAO.getLeadById(leadId);
        if (lead != null) {
            lead.setCampaignId(primaryCampaignId);
            leadDAO.updateLead(lead);
        }
    }

    // ==============================
    // EXISTING METHODS
    // ==============================

    public int importLeads(List<Lead> leads) {
        int importedCount = 0;
        for (Lead lead : leads) {
            try {
                validateLeadUniqueness(lead);
            } catch (IllegalArgumentException ex) {
                continue;
            }
            int score = LeadScoringUtil.calculateScore(
                    lead.getFullName(), lead.getEmail(), lead.getPhone(), lead.getCampaignId(), lead.getInterest());
            lead.setScore(score);
            lead.setStatus(LeadScoringUtil.determineStatus(score));
            int newId = leadDAO.createLead(lead);
            if (newId > 0) {
                if (lead.getCampaignId() > 0) {
                    campaignLeadDAO.assignLeadToCampaign(lead.getCampaignId(), newId, "NEW");
                }
                importedCount++;
            }
        }
        return importedCount;
    }

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

    public boolean scoreLead(int leadId, int score) {
        if (score < 0 || score > 100) {
            throw new IllegalArgumentException("Score must be between 0-100");
        }
        Lead lead = leadDAO.getLeadById(leadId);
        if (lead == null) return false;
        lead.setScore(score);
        if (!"DEAL_CREATED".equals(lead.getStatus())) {
            lead.setStatus(LeadScoringUtil.determineStatus(score));
        }
        return leadDAO.updateLead(lead);
    }

    public boolean updateLeadStatus(int leadId, String status) {
        Lead lead = leadDAO.getLeadById(leadId);
        if (lead == null) return false;
        lead.setStatus(status);
        return leadDAO.updateLead(lead);
    }

    public List<Campaign> getCampaignsByLeadId(int leadId) {
        return campaignLeadDAO.getCampaignsByLeadId(leadId);
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