package dto;

public class SegmentCardDTO {
    private int segmentId;
    private String segmentName;
    private String criteriaLogic; // từ Customer_Segments.criteria_logic
    private long customerCount;
    private double pctOfTotal; // % so với tổng KH trong segment map
    private double growthPct; // % tăng/giảm so tháng trước
    private boolean growthUp;

    // getters / setters
    public int getSegmentId() {
        return segmentId;
    }

    public void setSegmentId(int v) {
        this.segmentId = v;
    }

    public String getSegmentName() {
        return segmentName;
    }

    public void setSegmentName(String v) {
        this.segmentName = v;
    }

    public String getCriteriaLogic() {
        return criteriaLogic;
    }

    public void setCriteriaLogic(String v) {
        this.criteriaLogic = v;
    }

    public long getCustomerCount() {
        return customerCount;
    }

    public void setCustomerCount(long v) {
        this.customerCount = v;
    }

    public double getPctOfTotal() {
        return pctOfTotal;
    }

    public void setPctOfTotal(double v) {
        this.pctOfTotal = v;
    }

    public double getGrowthPct() {
        return growthPct;
    }

    public void setGrowthPct(double v) {
        this.growthPct = v;
    }

    public boolean isGrowthUp() {
        return growthUp;
    }

    public void setGrowthUp(boolean v) {
        this.growthUp = v;
    }
}