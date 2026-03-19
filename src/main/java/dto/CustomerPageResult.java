package dto;

import java.util.List;

public class CustomerPageResult {

    private final List<CustomerListDTO> data;

    // Pagination meta
    private final int  totalRecords;
    private final int  totalPages;
    private final int  currentPage;
    private final int  pageSize;

    // Session-based keyset state
    private final String sessionId;      // ← Frontend giữ lại, gửi lên mỗi request
    private final String nextAnchorRfm;
    private final int    nextAnchorId;

    public CustomerPageResult(List<CustomerListDTO> data, int totalRecords, int totalPages, int currentPage, int pageSize, String sessionId, String nextAnchorRfm, int nextAnchorId) {
        this.data = data;
        this.totalRecords = totalRecords;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.sessionId = sessionId;
        this.nextAnchorRfm = nextAnchorRfm;
        this.nextAnchorId = nextAnchorId;
    }

    public List<CustomerListDTO> getData() {
        return data;
    }

    public int getTotalRecords() {
        return totalRecords;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getNextAnchorRfm() {
        return nextAnchorRfm;
    }

    public int getNextAnchorId() {
        return nextAnchorId;
    }
    
    

    // Helpers
    public boolean hasNextPage() {
        return currentPage < totalPages;
    }

    public boolean hasPreviousPage() {
        return currentPage > 1;
    }
}
