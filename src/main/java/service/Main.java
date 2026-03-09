/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dto.KpiSummaryDTO;

/**
 *
 * @author tdgg
 */
public class Main {

    public static void main(String[] args) {
        CustomerService service = new CustomerService();

        try {
            KpiSummaryDTO summary = service.kpiSummarySegment();

            System.out.println("KPI");
            System.out.println(summary.getTotalCustomers());
            System.out.println(summary.getNewThisMonth());
            System.out.println(summary.getNewLastMonth());
            summary.setCustomerGrowthPct();
            System.out.println(summary.getCustomerGrowthPct());
            System.out.println(summary.getRevenueThisMonth());
            System.out.println(summary.getRevenueLastMonth());
            summary.setRevenueGrowthPct();
            System.out.println(summary.getRevenueGrowthPct());
            System.out.println(summary.getRetainedCustomers());
            summary.setRetentionRatePct();
            System.out.println(summary.getRetentionRatePct());
            System.out.println(summary.getAvgLtv());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}
