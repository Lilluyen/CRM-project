package model;

import java.math.BigDecimal;

public class MonthlyRevenuePoint {
    private final String month;
    private final BigDecimal revenue;

    public MonthlyRevenuePoint(String month, BigDecimal revenue) {
        this.month = month;
        this.revenue = revenue;
    }

    public String getMonth() {
        return month;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }
}
