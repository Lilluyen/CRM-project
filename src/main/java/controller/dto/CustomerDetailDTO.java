package controller.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import model.CustomerMeasurement;
import model.StyleTag;

public class CustomerDetailDTO {

    private int customerId;
    private String name;
    private String phone;
    private String email;
    private LocalDate birthday;
    private String gender;
    private String address;
    private String socialLink;

    private String customerType;
    private String status;
    private String loyaltyTier;

    private int rfmScore;
    private double returnRate;
    private LocalDateTime lastPurchase;

    private String ownerName;

    private List<CustomerMeasurement> measurements;
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

    public String getSocialLink() {
        return socialLink;
    }

    public void setSocialLink(String socialLink) {
        this.socialLink = socialLink;
    }

    public String getCustomerType() {
        return customerType;
    }

    public void setCustomerType(String customerType) {
        this.customerType = customerType;
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

    public int getRfmScore() {
        return rfmScore;
    }

    public void setRfmScore(int rfmScore) {
        this.rfmScore = rfmScore;
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

    public List<CustomerMeasurement> getMeasurements() {
        return measurements;
    }

    public void setMeasurements(List<CustomerMeasurement> measurements) {
        this.measurements = measurements;
    }

    public List<StyleTag> getStyleTags() {
        return styleTags;
    }

    public void setStyleTags(List<StyleTag> styleTags) {
        this.styleTags = styleTags;
    }

}