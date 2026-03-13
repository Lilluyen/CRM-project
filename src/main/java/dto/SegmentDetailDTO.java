package dto;

public class SegmentDetailDTO {
    private int segmentId;
    private String segmentName;
    private String criteriaLogic;
    private long customerCount;
    private double revenueThisMonth;
    private double avgLtv;
    private double churnRatePct;
    private double avgRfmScore;

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

    public double getRevenueThisMonth() {
        return revenueThisMonth;
    }

    public void setRevenueThisMonth(double v) {
        this.revenueThisMonth = v;
    }

    public double getAvgLtv() {
        return avgLtv;
    }

    public void setAvgLtv(double v) {
        this.avgLtv = v;
    }

    public double getChurnRatePct() {
        return churnRatePct;
    }

    public void setChurnRatePct(double v) {
        this.churnRatePct = v;
    }

    public double getAvgRfmScore() {
        return avgRfmScore;
    }

    public void setAvgRfmScore(double v) {
        this.avgRfmScore = v;
    }
}