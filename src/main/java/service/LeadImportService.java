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
            response.setMessage("File does not contain data.");
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

            String displayName = name.isEmpty() ? "No Name" : name;
            String displayEmail = rawEmail.isEmpty() ? "No Email" : rawEmail;

            // ===== VALIDATE BASIC =====
            if (name.isEmpty()) {
                errors.add("missing full name");
            }

            if (rawEmail.isEmpty()) {
                errors.add("missing email");
            } else if (!EmailCheck.isValidEmail(rawEmail)) {
                errors.add("email is not in the correct format (e.g., name@company.com)");
            }

            if (!errors.isEmpty()) {
                totalFailed++;
                response.addError("Row " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Invalid data: " + String.join(", ", errors) + ". "
                        + "Please check and correct the data.");
                continue;
            }

            // ===== DUPLICATE TRONG FILE =====
            if (emailsInBatch.contains(email)) {
                totalFailed++;
                response.addError("Row " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Duplicate email in the file. Each customer must have a unique email address. "
                        + "Each customer must have a unique email address.");
                continue;
            }

            // ===== DUPLICATE TRONG CAMPAIGN =====
            if (emailsInCampaign.contains(email)) {
                totalFailed++;
                response.addError("Row " + row + " — " + displayName + " (" + displayEmail + "): "
                        + "Customer already exists in the campaign. "
                        + "Cannot import duplicates.");
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
            response.setMessage("Import failed: all data is invalid.");
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
                response.setMessage("🎉 Import successful! Added "
                        + totalSuccess + " customers to the campaign.");
            } else {
                response.setMessage("⚠️ Import completed: "
                        + totalSuccess + " customers added successfully, "
                        + totalFailed + " rows failed. "
                        + "Please check the details below to correct the file.");
            }

        } catch (Exception e) {
            response.setSuccess(false);
            response.setTotalImported(0);
            response.setTotalFailed(totalFailed);
            response.setMessage("❌ An error occurred while importing.");
            response.addError("Technical details: " + e.toString());
        }

        return response;
    }
}
