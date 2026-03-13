package dto;

public class CustomerRowDTO {
    private int customerId;
    private String name;
    private String email;
    private String phone;
    private String loyaltyTier;
    private int rfmScore;
    // Tách R, F, M từ rfm_score = R*100 + F*10 + M
    private int rfmR;
    private int rfmF;
    private int rfmM;
    private String status;
    private double returnRate;
    private String lastPurchase; // đã format sẵn "yyyy-MM-dd"
    private int daysSinceLastPurchase;
    private String uiStatus; // "active" | "warm" | "inactive" | "new"
    private String segmentNames;
    private String styleTags;
    private String fitProfile;
    private String bodyShape;

    // getters / setters
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String v) {
        this.email = v;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String v) {
        this.phone = v;
    }

    public String getLoyaltyTier() {
        return loyaltyTier;
    }

    public void setLoyaltyTier(String v) {
        this.loyaltyTier = v;
    }

    public int getRfmScore() {
        return rfmScore;
    }

    public void setRfmScore(int v) {
        this.rfmScore = v;
        // tự động tách R, F, M
        this.rfmR = v / 100;
        this.rfmF = (v % 100) / 10;
        this.rfmM = v % 10;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        this.status = v;
    }

    public double getReturnRate() {
        return returnRate;
    }

    public void setReturnRate(double v) {
        this.returnRate = v;
    }

    public String getLastPurchase() {
        return lastPurchase;
    }

    public void setLastPurchase(String v) {
        this.lastPurchase = v;
    }

    public int getDaysSinceLastPurchase() {
        return daysSinceLastPurchase;
    }

    public void setDaysSinceLastPurchase(int v) {
        this.daysSinceLastPurchase = v;
    }

    public String getUiStatus() {
        return uiStatus;
    }

    public void setUiStatus(String v) {
        this.uiStatus = v;
    }

    public String getSegmentNames() {
        return segmentNames;
    }

    public void setSegmentNames(String v) {
        this.segmentNames = v;
    }

    public String getStyleTags() {
        return styleTags;
    }

    public void setStyleTags(String v) {
        this.styleTags = v;
    }

    public String getFitProfile() {
        return fitProfile;
    }

    public void setFitProfile(String v) {
        this.fitProfile = v;
    }

    public String getBodyShape() {
        return bodyShape;
    }

    public void setBodyShape(String v) {
        this.bodyShape = v;
    }
}
