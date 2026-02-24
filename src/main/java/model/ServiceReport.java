package model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class ServiceReport {
     private int reportId;
    private LocalDate reportDate;
    private int totalTicket;
    private int resolvedTicket;
    private BigDecimal avgResponseTime;
    private BigDecimal avgResolutionTime;
    private LocalDateTime createdAt;

    public ServiceReport() {
    }

    public ServiceReport(int reportId, LocalDate reportDate, int totalTicket,
                        int resolvedTicket, BigDecimal avgResponseTime,
                        BigDecimal avgResolutionTime, LocalDateTime createdAt) {
        this.reportId = reportId;
        this.reportDate = reportDate;
        this.totalTicket = totalTicket;
        this.resolvedTicket = resolvedTicket;
        this.avgResponseTime = avgResponseTime;
        this.avgResolutionTime = avgResolutionTime;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public LocalDate getReportDate() {
        return reportDate;
    }

    public void setReportDate(LocalDate reportDate) {
        this.reportDate = reportDate;
    }

    public int getTotalTicket() {
        return totalTicket;
    }

    public void setTotalTicket(int totalTicket) {
        this.totalTicket = totalTicket;
    }

    public int getResolvedTicket() {
        return resolvedTicket;
    }

    public void setResolvedTicket(int resolvedTicket) {
        this.resolvedTicket = resolvedTicket;
    }

    public BigDecimal getAvgResponseTime() {
        return avgResponseTime;
    }

    public void setAvgResponseTime(BigDecimal avgResponseTime) {
        this.avgResponseTime = avgResponseTime;
    }

    public BigDecimal getAvgResolutionTime() {
        return avgResolutionTime;
    }

    public void setAvgResolutionTime(BigDecimal avgResolutionTime) {
        this.avgResolutionTime = avgResolutionTime;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
