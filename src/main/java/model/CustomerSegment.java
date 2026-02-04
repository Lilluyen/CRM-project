/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Pham Minh Quan
 */
public class CustomerSegment {

    private Integer segmentId;
    private String segmentName;
    private String description;

    public CustomerSegment() {
    }

    public CustomerSegment(Integer segmentId, String segmentName, String description) {
        this.segmentId = segmentId;
        this.segmentName = segmentName;
        this.description = description;
    }

    public Integer getSegmentId() {
        return segmentId;
    }

    public void setSegmentId(Integer segmentId) {
        this.segmentId = segmentId;
    }

    public String getSegmentName() {
        return segmentName;
    }

    public void setSegmentName(String segmentName) {
        this.segmentName = segmentName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
}
