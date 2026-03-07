package dto;

public class KpiSummaryDTO {
    private long totalCustomers;
    private long newThisMonth;
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

    public double getCustomerGrowthPct() {
        return customerGrowthPct;
    }

    public void setCustomerGrowthPct(double v) {
        this.customerGrowthPct = v;
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

    public void setRevenueGrowthPct(double v) {
        this.revenueGrowthPct = v;
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

    public void setRetentionRatePct(double v) {
        this.retentionRatePct = v;
    }

    public double getAvgLtv() {
        return avgLtv;
    }

    public void setAvgLtv(double v) {
        this.avgLtv = v;
    }
}