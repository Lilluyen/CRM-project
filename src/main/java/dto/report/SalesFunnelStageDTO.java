package dto.report;

import java.math.BigDecimal;

public class SalesFunnelStageDTO {

    private String stage;
    private int dealCount;
    private BigDecimal expectedSum;
    private BigDecimal actualSum;
    private BigDecimal weightedExpectedSum;

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
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

    public BigDecimal getActualSum() {
        return actualSum;
    }

    public void setActualSum(BigDecimal actualSum) {
        this.actualSum = actualSum;
    }

    public BigDecimal getWeightedExpectedSum() {
        return weightedExpectedSum;
    }

    public void setWeightedExpectedSum(BigDecimal weightedExpectedSum) {
        this.weightedExpectedSum = weightedExpectedSum;
    }
}
