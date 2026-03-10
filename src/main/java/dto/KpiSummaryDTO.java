package dto;

public class KpiSummaryDTO {
    private long totalCustomers;
    private long newThisMonth;
    private long newLastMonth;

    
    private double customerGrowthPct; // % tăng trưởng so tháng trước

    private double revenueThisMonth;
    private double revenueLastMonth;
    private double revenueGrowthPct;

    private long retainedCustomers;
    private double retentionRatePct; // % khách mua trong 180 ngày

    private double avgLtv; // avg LTV từ Deals won

    // ── getters / setters ──
    public long getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(long v) {
        this.totalCustomers = v;
    }

    public long getNewThisMonth() {
        return newThisMonth;
    }

    public void setNewThisMonth(long v) {
        this.newThisMonth = v;
    }
    
    public long getNewLastMonth() {
        return newLastMonth;
    }

    public void setNewLastMonth(long newLastMonth) {
        this.newLastMonth = newLastMonth;
    }

    public double getCustomerGrowthPct() {
        return customerGrowthPct;
    }

    public void setCustomerGrowthPct() {
        this.customerGrowthPct = (this.newThisMonth - this.newLastMonth) / this.newLastMonth * 100.0;
    }

    public double getRevenueThisMonth() {
        return revenueThisMonth;
    }

    public void setRevenueThisMonth(double v) {
        this.revenueThisMonth = v;
    }

    public double getRevenueLastMonth() {
        return revenueLastMonth;
    }

    public void setRevenueLastMonth(double v) {
        this.revenueLastMonth = v;
    }

    public double getRevenueGrowthPct() {
        return revenueGrowthPct;
    }

    public void setRevenueGrowthPct() {
        this.revenueGrowthPct = ((this.revenueThisMonth - this.revenueLastMonth) / this.revenueLastMonth * 100.0) ;
    }

    public long getRetainedCustomers() {
        return retainedCustomers;
    }

    public void setRetainedCustomers(long v) {
        this.retainedCustomers = v;
    }

    public double getRetentionRatePct() {
        return retentionRatePct;
    }

    public void setRetentionRatePct() {
        this.retentionRatePct =  (this.retainedCustomers * 1.0 / this.totalCustomers) * 100;
    }

    public double getAvgLtv() {
        return avgLtv;
    }

    public void setAvgLtv(double v) {
        this.avgLtv = v;
    }
}