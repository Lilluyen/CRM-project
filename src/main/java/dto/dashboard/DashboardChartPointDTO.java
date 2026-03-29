/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto.dashboard;

public class DashboardChartPointDTO {
    private String label;
    private double value;

    public DashboardChartPointDTO() {}
    public DashboardChartPointDTO(String label, double value) {
        this.label = label; this.value = value;
    }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public double getValue() { return value; }
    public void setValue(double value) { this.value = value; }
}
