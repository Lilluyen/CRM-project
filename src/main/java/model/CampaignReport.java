package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CampaignReport {

    private int reportId;
    private int campaignId;
    private int totalLead;
    private int qualifiedLead;
    private int convertedLead;
    private BigDecimal costPerLead;
    private BigDecimal roi;
    private LocalDateTime createdAt;

    public CampaignReport() {
    }

    public CampaignReport(int reportId, int campaignId, int totalLead, int qualifiedLead,
            int convertedLead, BigDecimal costPerLead, BigDecimal roi,
            LocalDateTime createdAt) {
        this.reportId = reportId;
        this.campaignId = campaignId;
        this.totalLead = totalLead;
        this.qualifiedLead = qualifiedLead;
        this.convertedLead = convertedLead;
        this.costPerLead = costPerLead;
        this.roi = roi;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public int getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(int campaignId) {
        this.campaignId = campaignId;
    }

    public int getTotalLead() {
        return totalLead;
    }

    public void setTotalLead(int totalLead) {
        this.totalLead = totalLead;
    }

    public int getQualifiedLead() {
        return qualifiedLead;
    }

    public void setQualifiedLead(int qualifiedLead) {
        this.qualifiedLead = qualifiedLead;
    }

    public int getConvertedLead() {
        return convertedLead;
    }

    public void setConvertedLead(int convertedLead) {
        this.convertedLead = convertedLead;
    }

    public BigDecimal getCostPerLead() {
        return costPerLead;
    }

    public void setCostPerLead(BigDecimal costPerLead) {
        this.costPerLead = costPerLead;
    }

    public BigDecimal getRoi() {
        return roi;
    }

    public void setRoi(BigDecimal roi) {
        this.roi = roi;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
