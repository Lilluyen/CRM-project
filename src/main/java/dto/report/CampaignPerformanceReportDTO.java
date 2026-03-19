package dto.report;

public class CampaignPerformanceReportDTO {

    private String campaignName;
    private int totalLeads;
    private int dealsCreated;
    private int dealsWon;
    private int dealsLost;
    private double conversionRate;
    private double roi;
    private double revenue;
    private double cost;
    private double profitLoss; // Revenue - Cost

    public CampaignPerformanceReportDTO() {
    }

    public CampaignPerformanceReportDTO(String campaignName, int totalLeads, int dealsCreated,
            int dealsWon, int dealsLost, double conversionRate, double roi) {
        this.campaignName = campaignName;
        this.totalLeads = totalLeads;
        this.dealsCreated = dealsCreated;
        this.dealsWon = dealsWon;
        this.dealsLost = dealsLost;
        this.conversionRate = conversionRate;
        this.roi = roi;
    }

    public CampaignPerformanceReportDTO(String campaignName, int totalLeads, int dealsCreated,
            int dealsWon, int dealsLost, double conversionRate, double roi, double revenue, double cost) {
        this.campaignName = campaignName;
        this.totalLeads = totalLeads;
        this.dealsCreated = dealsCreated;
        this.dealsWon = dealsWon;
        this.dealsLost = dealsLost;
        this.conversionRate = conversionRate;
        this.roi = roi;
        this.revenue = revenue;
        this.cost = cost;
        this.profitLoss = revenue - cost;
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

    public double getRoi() {
        return roi;
    }

    public void setRoi(double roi) {
        this.roi = roi;
    }

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public double getProfitLoss() {
        return profitLoss;
    }

    public void setProfitLoss(double profitLoss) {
        this.profitLoss = profitLoss;
    }

    /**
     * Trả về true nếu campaign có lãi (revenue > cost)
     */
    public boolean isProfitable() {
        return profitLoss > 0;
    }
}
