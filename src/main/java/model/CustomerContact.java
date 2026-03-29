package model;

import java.time.LocalDateTime;

public class CustomerContact {
    private Integer contactId;
    private Integer customerId;
    private String type;
    private String value;
    private Boolean isPrimary;
    private java.time.LocalDateTime createdAt;
    private java.time.LocalDateTime updatedAt;

    public CustomerContact() {

    }

    public CustomerContact(int customerId, Boolean isPrimary, String type, String value) {
        this.customerId = customerId;
        this.isPrimary = isPrimary;
        this.type = type;
        this.value = value;
    }

    public Integer getContactId() {
        return contactId;
    }

    public void setContactId(Integer contactId) {
        this.contactId = contactId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Boolean getPrimary() {
        return isPrimary;
    }

    public void setPrimary(Boolean primary) {
        isPrimary = primary;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}

