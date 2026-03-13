package dto.report;

public class LeadSourceReportDTO {
    private String sourceName;
    private int leadCount;
    private double percent;

    public LeadSourceReportDTO() {}

    public LeadSourceReportDTO(String sourceName, int leadCount, double percent) {
        this.sourceName = sourceName;
        this.leadCount = leadCount;
        this.percent = percent;
    }

    public String getSourceName() { return sourceName; }
    public void setSourceName(String sourceName) { this.sourceName = sourceName; }

    public int getLeadCount() { return leadCount; }
    public void setLeadCount(int leadCount) { this.leadCount = leadCount; }

    public double getPercent() { return percent; }
    public void setPercent(double percent) { this.percent = percent; }
}
