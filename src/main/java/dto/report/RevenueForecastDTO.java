package dto.report;

import java.math.BigDecimal;

public class RevenueForecastDTO {

    private String period;
    private int dealCount;
    private BigDecimal expectedSum;
    private BigDecimal forecastedRevenue;

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public int getDealCount() {
        return dealCount;
    }

    public void setDealCount(int dealCount) {
        this.dealCount = dealCount;
    }

    public BigDecimal getExpectedSum() {
        return expectedSum;
    }

    public void setExpectedSum(BigDecimal expectedSum) {
        this.expectedSum = expectedSum;
    }

    public BigDecimal getForecastedRevenue() {
        return forecastedRevenue;
    }

    public void setForecastedRevenue(BigDecimal forecastedRevenue) {
        this.forecastedRevenue = forecastedRevenue;
    }
}
