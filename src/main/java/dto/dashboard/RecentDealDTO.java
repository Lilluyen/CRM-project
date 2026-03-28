/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto.dashboard;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class RecentDealDTO {
    private int dealId, probability;
    private String dealName, stage, partyName;
    private BigDecimal expectedValue, actualValue;
    private LocalDateTime createdAt;

    public int getDealId() { return dealId; }
    public void setDealId(int v) { this.dealId = v; }
    public int getProbability() { return probability; }
    public void setProbability(int v) { this.probability = v; }
    public String getDealName() { return dealName; }
    public void setDealName(String v) { this.dealName = v; }
    public String getStage() { return stage; }
    public void setStage(String v) { this.stage = v; }
    public String getPartyName() { return partyName; }
    public void setPartyName(String v) { this.partyName = v; }
    public BigDecimal getExpectedValue() { return expectedValue; }
    public void setExpectedValue(BigDecimal v) { this.expectedValue = v; }
    public BigDecimal getActualValue() { return actualValue; }
    public void setActualValue(BigDecimal v) { this.actualValue = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
