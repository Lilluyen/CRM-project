package dto;

import java.math.BigDecimal;
import java.util.List;

public class CustomerDashboardDTO {

    // Basic Info
    private int customerId;
    private String name;
    private String status;
    private String loyaltyTier;
    private String ownerName;
    private String createdAt;

    // KPI
    private int totalOrders;
    private BigDecimal totalRevenue;
    private BigDecimal avgOrderValue;
    private String lastPurchase;

    // Lists
//    private List<RecentDealDTO> recentDeals;
//    private List<MonthlyRevenueDTO> monthlyRevenue;
    private List<String> segments;
    private List<String> styleTags;

    // getters & setters

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLoyaltyTier() {
        return loyaltyTier;
    }

    public void setLoyaltyTier(String loyaltyTier) {
        this.loyaltyTier = loyaltyTier;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public BigDecimal getAvgOrderValue() {
        return avgOrderValue;
    }

    public void setAvgOrderValue(BigDecimal avgOrderValue) {
        this.avgOrderValue = avgOrderValue;
    }

    public String getLastPurchase() {
        return lastPurchase;
    }

    public void setLastPurchase(String lastPurchase) {
        this.lastPurchase = lastPurchase;
    }

//    public List<RecentDealDTO> getRecentDeals() {
//        return recentDeals;
//    }
//
//    public void setRecentDeals(List<RecentDealDTO> recentDeals) {
//        this.recentDeals = recentDeals;
//    }
//
//    public List<MonthlyRevenueDTO> getMonthlyRevenue() {
//        return monthlyRevenue;
//    }
//
//    public void setMonthlyRevenue(List<MonthlyRevenueDTO> monthlyRevenue) {
//        this.monthlyRevenue = monthlyRevenue;
//    }

    public List<String> getSegments() {
        return segments;
    }

    public void setSegments(List<String> segments) {
        this.segments = segments;
    }

    public List<String> getStyleTags() {
        return styleTags;
    }

    public void setStyleTags(List<String> styleTags) {
        this.styleTags = styleTags;
    }
    
    
}