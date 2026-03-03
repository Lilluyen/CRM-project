package dto;

import java.util.List;

public class CustomerPageResult {

    private List<CustomerListDTO> customers;
    private int totalRecords;

    public CustomerPageResult(List<CustomerListDTO> customers, int totalRecords) {
        this.customers = customers;
        this.totalRecords = totalRecords;
    }

    public List<CustomerListDTO> getCustomers() {
        return customers;
    }

    public int getTotalRecords() {
        return totalRecords;
    }

    public int getTotalPages(int pageSize) {
        return (int) Math.ceil((double) totalRecords / pageSize);
    }
}
