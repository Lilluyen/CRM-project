package dto;

import java.util.List;

public class CustomerPageDTO {
    private int page;
    private int pageSize;
    private long totalRecords;
    private int totalPages;
    private List<CustomerRowDTO> data;

    public int getPage() {
        return page;
    }

    public void setPage(int v) {
        this.page = v;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int v) {
        this.pageSize = v;
    }

    public long getTotalRecords() {
        return totalRecords;
    }

    public void setTotalRecords(long v) {
        this.totalRecords = v;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int v) {
        this.totalPages = v;
    }

    public List<CustomerRowDTO> getData() {
        return data;
    }

    public void setData(List<CustomerRowDTO> v) {
        this.data = v;
    }
}