package model;

import java.time.LocalDateTime;
import java.math.BigDecimal;

public class CustomerMeasurement {

    private int measureId;
    private int customerId;

    private BigDecimal height;
    private BigDecimal weight;
    private BigDecimal bust;
    private BigDecimal waist;
    private BigDecimal hips;
    private BigDecimal shoulder;

    private String preferredSize;
    private String bodyShape;

    private LocalDateTime measuredAt;

    public CustomerMeasurement() {
    }

    // Getter & Setter
    public int getMeasureId() {
        return measureId;
    }

    public void setMeasureId(int measureId) {
        this.measureId = measureId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public BigDecimal getHeight() {
        return height;
    }

    public void setHeight(BigDecimal height) {
        this.height = height;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }

    public BigDecimal getBust() {
        return bust;
    }

    public void setBust(BigDecimal bust) {
        this.bust = bust;
    }

    public BigDecimal getWaist() {
        return waist;
    }

    public void setWaist(BigDecimal waist) {
        this.waist = waist;
    }

    public BigDecimal getHips() {
        return hips;
    }

    public void setHips(BigDecimal hips) {
        this.hips = hips;
    }

    public BigDecimal getShoulder() {
        return shoulder;
    }

    public void setShoulder(BigDecimal shoulder) {
        this.shoulder = shoulder;
    }

    public String getPreferredSize() {
        return preferredSize;
    }

    public void setPreferredSize(String preferredSize) {
        this.preferredSize = preferredSize;
    }

    public String getBodyShape() {
        return bodyShape;
    }

    public void setBodyShape(String bodyShape) {
        this.bodyShape = bodyShape;
    }

    public LocalDateTime getMeasuredAt() {
        return measuredAt;
    }

    public void setMeasuredAt(LocalDateTime measuredAt) {
        this.measuredAt = measuredAt;
    }
}