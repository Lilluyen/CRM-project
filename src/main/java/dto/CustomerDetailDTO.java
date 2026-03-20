package dto;

import model.CustomerMeasurement;
import model.StyleTag;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CustomerDetailDTO {

    private int customerId;
    private String name;
    private String phone;
    private String email;
    private LocalDate birthday;
    private String gender;
    private String address;
    private String source;

    private String status;
    private String loyaltyTier;

    private BigDecimal totalSpent;
    private double returnRate;
    private LocalDateTime lastPurchase;

    private String ownerName;

    private CustomerMeasurement latestMeasurement;
    private List<StyleTag> styleTags;

    // Getter & Setter ...
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

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getBirthday() {
        return birthday;
    }

    public void setBirthday(LocalDate birthday) {
        this.birthday = birthday;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
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

    public BigDecimal getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(BigDecimal totalSpent) {
        this.totalSpent = totalSpent;
    }

    public double getReturnRate() {
        return returnRate;
    }

    public void setReturnRate(double returnRate) {
        this.returnRate = returnRate;
    }

    public LocalDateTime getLastPurchase() {
        return lastPurchase;
    }

    public void setLastPurchase(LocalDateTime lastPurchase) {
        this.lastPurchase = lastPurchase;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public CustomerMeasurement getLatestMeasurement() {
        return latestMeasurement;
    }

    public void setLatestMeasurement(CustomerMeasurement latestMeasurement) {
        this.latestMeasurement = latestMeasurement;
    }

    public List<StyleTag> getStyleTags() {
        return styleTags;
    }

    public void setStyleTags(List<StyleTag> styleTags) {
        this.styleTags = styleTags;
    }

    public String getLastPurchaseDate() {
        if (lastPurchase == null) {
            return "";
        }
        return lastPurchase.toLocalDate().toString();
    }

}
