package dto;

public class KpiSummaryDTO {
    private long totalCustomers;
    private long newMonthA;
    private long newMonthB;

    private double customerGrowthPct; // % tăng trưởng so tháng trước

    private double revenueMonthA;
    private double revenueMonthB;
    private double revenueGrowthPct;

    private long retainedCustomers;
    private double retentionRatePct; // % khách mua trong 180 ngày

    private double avgLtv; // avg LTV từ Deals won

    // ── getters / setters ──

    public long getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(long totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public long getNewMonthA() {
        return newMonthA;
    }

    public void setNewMonthA(long newMonthA) {
        this.newMonthA = newMonthA;
    }

    public long getNewMonthB() {
        return newMonthB;
    }

    public void setNewMonthB(long newMonthB) {
        this.newMonthB = newMonthB;
    }

    public double getCustomerGrowthPct() {
        return customerGrowthPct;
    }

    public void setCustomerGrowthPct(double customerGrowthPct) {
        this.customerGrowthPct = customerGrowthPct;
    }

    public double getRevenueMonthA() {
        return revenueMonthA;
    }

    public void setRevenueMonthA(double revenueMonthA) {
        this.revenueMonthA = revenueMonthA;
    }

    public double getRevenueMonthB() {
        return revenueMonthB;
    }

    public void setRevenueMonthB(double revenueMonthB) {
        this.revenueMonthB = revenueMonthB;
    }

    public double getRevenueGrowthPct() {
        return revenueGrowthPct;
    }

    public void setRevenueGrowthPct(double revenueGrowthPct) {
        this.revenueGrowthPct = revenueGrowthPct;
    }

    public long getRetainedCustomers() {
        return retainedCustomers;
    }

    public void setRetainedCustomers(long retainedCustomers) {
        this.retainedCustomers = retainedCustomers;
    }

    public double getRetentionRatePct() {
        return retentionRatePct;
    }

    public void setRetentionRatePct(double retentionRatePct) {
        this.retentionRatePct = retentionRatePct;
    }

    public double getAvgLtv() {
        return avgLtv;
    }

    public void setAvgLtv(double avgLtv) {
        this.avgLtv = avgLtv;
    }
    
}