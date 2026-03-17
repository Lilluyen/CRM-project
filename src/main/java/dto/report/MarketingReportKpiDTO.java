package dto.report;

public class MarketingReportKpiDTO {
    private int totalLeads;
    private int dealsCreated;
    private int dealsWon;
    private double revenue;
    private double cost;
    private double conversionRate;
    private double roi;

    public MarketingReportKpiDTO() {
    }

    public MarketingReportKpiDTO(int totalLeads, int dealsCreated, int dealsWon,
            double revenue, double cost, double conversionRate, double roi) {
        this.totalLeads = totalLeads;
        this.dealsCreated = dealsCreated;
        this.dealsWon = dealsWon;
        this.revenue = revenue;
        this.cost = cost;
        this.conversionRate = conversionRate;
        this.roi = roi;
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

    /**
     * Lãi/Lỗ = Revenue - Cost
     */
    public double getProfitLoss() {
        return revenue - cost;
    }

    /**
     * Trả về true nếu có lãi
     */
    public boolean isProfitable() {
        return revenue > cost;
    }
}

