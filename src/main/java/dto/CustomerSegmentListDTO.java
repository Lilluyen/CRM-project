package dto;

public class CustomerSegmentListDTO {
    private int customerId;
    private String name;
    private String phone;
    private int rfmScore;
    private int rfmR, rfmF, rfmM;   // tách từ rfmScore
    private String segmentName;         // "DIAMOND", "GOLD", ...
    private double totalSpent;
    private String lastPurchase;        // "yyyy-MM-dd"
    private int daysSince;           // để render "3 ngày trước"
    private String loyaltyTier;

    // Getters / Setters
    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int v) {
        this.customerId = v;
    }

    public String getName() {
        return name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String v) {
        this.phone = v;
    }

    /**
     * setter tự tách R, F, M
     */
    public int getRfmScore() {
        return rfmScore;
    }

    public void setRfmScore(int v) {
        rfmScore = v;
        rfmR = v / 100;
        rfmF = (v % 100) / 10;
        rfmM = v % 10;
    }

    public int getRfmR() {
        return rfmR;
    }

    public int getRfmF() {
        return rfmF;
    }

    public int getRfmM() {
        return rfmM;
    }

    public String getSegmentName() {
        return segmentName;
    }

    public void setSegmentName(String v) {
        this.segmentName = v;
    }

    public double getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(double v) {
        this.totalSpent = v;
    }

    public String getLastPurchase() {
        return lastPurchase;
    }

    public void setLastPurchase(String v) {
        this.lastPurchase = v;
    }

    public int getDaysSince() {
        return daysSince;
    }

    public void setDaysSince(int v) {
        this.daysSince = v;
    }

    public String getLoyaltyTier() {
        return loyaltyTier;
    }

    public void setLoyaltyTier(String v) {
        this.loyaltyTier = v;
    }
}
