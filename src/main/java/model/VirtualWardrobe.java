package model;

import java.time.LocalDateTime;

public class VirtualWardrobe {

    private int wardrobeId;
    private int customerId;
    private int productId;
    private LocalDateTime boughtAt;
    private String photoFeedback;

    public VirtualWardrobe() {
    }

    public int getWardrobeId() {
        return wardrobeId;
    }

    public void setWardrobeId(int wardrobeId) {
        this.wardrobeId = wardrobeId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public LocalDateTime getBoughtAt() {
        return boughtAt;
    }

    public void setBoughtAt(LocalDateTime boughtAt) {
        this.boughtAt = boughtAt;
    }

    public String getPhotoFeedback() {
        return photoFeedback;
    }

    public void setPhotoFeedback(String photoFeedback) {
        this.photoFeedback = photoFeedback;
    }
}