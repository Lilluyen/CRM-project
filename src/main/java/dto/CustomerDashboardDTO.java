package dto;

public class CustomerDashboardDTO {

    private int totalCustomers;
    private int goldCustomers;
    private int blacklistCustomers;
    private double avgRfmScore;
    private double avgReturnRate;

    public int getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(int totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public int getGoldCustomers() {
        return goldCustomers;
    }

    public void setGoldCustomers(int goldCustomers) {
        this.goldCustomers = goldCustomers;
    }

    public int getBlacklistCustomers() {
        return blacklistCustomers;
    }

    public void setBlacklistCustomers(int blacklistCustomers) {
        this.blacklistCustomers = blacklistCustomers;
    }

    public double getAvgRfmScore() {
        return avgRfmScore;
    }

    public void setAvgRfmScore(double avgRfmScore) {
        this.avgRfmScore = avgRfmScore;
    }

    public double getAvgReturnRate() {
        return avgReturnRate;
    }

    public void setAvgReturnRate(double avgReturnRate) {
        this.avgReturnRate = avgReturnRate;
    }

}
