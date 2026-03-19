package dto.report;

public class LeadFunnelReportDTO {
    private int newCount;
    private int contactedCount;
    private int qualifiedCount;
    private int convertedCount;
    private int lostCount;

    public LeadFunnelReportDTO() {}

    public LeadFunnelReportDTO(int newCount, int contactedCount, int qualifiedCount,
            int convertedCount, int lostCount) {
        this.newCount = newCount;
        this.contactedCount = contactedCount;
        this.qualifiedCount = qualifiedCount;
        this.convertedCount = convertedCount;
        this.lostCount = lostCount;
    }

    public int getNewCount() { return newCount; }
    public void setNewCount(int newCount) { this.newCount = newCount; }

    public int getContactedCount() { return contactedCount; }
    public void setContactedCount(int contactedCount) { this.contactedCount = contactedCount; }

    public int getQualifiedCount() { return qualifiedCount; }
    public void setQualifiedCount(int qualifiedCount) { this.qualifiedCount = qualifiedCount; }

    public int getConvertedCount() { return convertedCount; }
    public void setConvertedCount(int convertedCount) { this.convertedCount = convertedCount; }

    public int getLostCount() { return lostCount; }
    public void setLostCount(int lostCount) { this.lostCount = lostCount; }

    /**
     * Tổng số leads trong funnel
     */
    public int getTotal() {
        return newCount + contactedCount + qualifiedCount + convertedCount + lostCount;
    }

    /**
     * Tính phần trăm cho từng stage
     */
    public double getNewPercent() {
        return getTotal() > 0 ? Math.round(newCount * 10000.0 / getTotal()) / 100.0 : 0;
    }

    public double getContactedPercent() {
        return getTotal() > 0 ? Math.round(contactedCount * 10000.0 / getTotal()) / 100.0 : 0;
    }

    public double getQualifiedPercent() {
        return getTotal() > 0 ? Math.round(qualifiedCount * 10000.0 / getTotal()) / 100.0 : 0;
    }

    public double getConvertedPercent() {
        return getTotal() > 0 ? Math.round(convertedCount * 10000.0 / getTotal()) / 100.0 : 0;
    }

    public double getLostPercent() {
        return getTotal() > 0 ? Math.round(lostCount * 10000.0 / getTotal()) / 100.0 : 0;
    }
}
