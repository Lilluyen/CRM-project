package dto.report;

public class CampaignPerformanceReportDTO {

    private String campaignName;
    private int totalLeads;
    private int dealsCreated;
    private int dealsWon;
    private int dealsLost;
    private double conversionRate;

    public CampaignPerformanceReportDTO() {
    }

    public CampaignPerformanceReportDTO(String campaignName, int totalLeads, int dealsCreated,
            int dealsWon, int dealsLost, double conversionRate) {
        this.campaignName = campaignName;
        this.totalLeads = totalLeads;
        this.dealsCreated = dealsCreated;
        this.dealsWon = dealsWon;
        this.dealsLost = dealsLost;
        this.conversionRate = conversionRate;
    }

    public String getCampaignName() {
        return campaignName;
    }

    public void setCampaignName(String campaignName) {
        this.campaignName = campaignName;
    }

    public int getTotalLeads() {
        return totalLeads;
    }

    public void setTotalLeads(int totalLeads) {
        this.totalLeads = totalLeads;
    }

    public int getDealsCreated() {
        return dealsCreated;
    }

    public void setDealsCreated(int dealsCreated) {
        this.dealsCreated = dealsCreated;
    }

    public int getDealsWon() {
        return dealsWon;
    }

    public void setDealsWon(int dealsWon) {
        this.dealsWon = dealsWon;
    }

    public int getDealsLost() {
        return dealsLost;
    }

    public void setDealsLost(int dealsLost) {
        this.dealsLost = dealsLost;
    }

    public double getConversionRate() {
        return conversionRate;
    }

    public void setConversionRate(double conversionRate) {
        this.conversionRate = conversionRate;
    }
}
