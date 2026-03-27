/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto.dashboard;

import java.time.LocalDateTime;

public class FollowUpItemDTO {
    private int id;
    private String name, status, priority, relatedName, itemType;
    private LocalDateTime due;

    public int getId() { return id; }
    public void setId(int v) { this.id = v; }
    public String getName() { return name; }
    public void setName(String v) { this.name = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public String getPriority() { return priority; }
    public void setPriority(String v) { this.priority = v; }
    public String getRelatedName() { return relatedName; }
    public void setRelatedName(String v) { this.relatedName = v; }
    public String getItemType() { return itemType; }
    public void setItemType(String v) { this.itemType = v; }
    public LocalDateTime getDue() { return due; }
    public void setDue(LocalDateTime v) { this.due = v; }
}
