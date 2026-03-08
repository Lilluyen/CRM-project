package dto.report;

public class DealResultReportDTO {
    private int totalDeals;
    private int dealsWon;
    private int dealsLost;

    public DealResultReportDTO() {}

    public DealResultReportDTO(int totalDeals, int dealsWon, int dealsLost) {
        this.totalDeals = totalDeals;
        this.dealsWon = dealsWon;
        this.dealsLost = dealsLost;
    }

    public int getTotalDeals() { return totalDeals; }
    public void setTotalDeals(int totalDeals) { this.totalDeals = totalDeals; }

    public int getDealsWon() { return dealsWon; }
    public void setDealsWon(int dealsWon) { this.dealsWon = dealsWon; }

    public int getDealsLost() { return dealsLost; }
    public void setDealsLost(int dealsLost) { this.dealsLost = dealsLost; }
}
