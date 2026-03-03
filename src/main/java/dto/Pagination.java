package dto;

/**
 * DTO phân trang – tái sử dụng cho mọi module (Campaign, Customer, Task, ...).
 *
 * Controller tạo: new Pagination(currentPage, pageSize, totalItems)
 *
 * JSP dùng:
 * <jsp:include page="/view/components/pagination.jsp" />
 * (yêu cầu request attribute "pagination")
 */
public class Pagination {

    private int currentPage;
    private int pageSize;
    private int totalItems;
    private int totalPages;

    public Pagination(int currentPage, int pageSize, int totalItems) {
        this.pageSize = pageSize > 0 ? pageSize : 10;
        this.totalItems = Math.max(totalItems, 0);
        this.totalPages = (int) Math.ceil((double) this.totalItems / this.pageSize);

        // Clamp currentPage
        if (currentPage < 1) {
            currentPage = 1;
        }
        if (currentPage > this.totalPages && this.totalPages > 0) {
            currentPage = this.totalPages;
        }
        this.currentPage = currentPage;
    }

    /* ---------- Getters cơ bản ---------- */
    public int getCurrentPage() {
        return currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public int getTotalItems() {
        return totalItems;
    }

    public int getTotalPages() {
        return totalPages;
    }

    /* ---------- Helpers hiển thị ---------- */
    /**
     * Số thứ tự bản ghi đầu tiên trên trang hiện tại (1-based).
     */
    public int getStartItemNumber() {
        if (totalItems == 0) {
            return 0;
        }
        return (currentPage - 1) * pageSize + 1;
    }

    /**
     * Số thứ tự bản ghi cuối cùng trên trang hiện tại.
     */
    public int getEndItemNumber() {
        return Math.min(currentPage * pageSize, totalItems);
    }

    /**
     * Offset dùng cho SQL: OFFSET ? ROWS
     */
    public int getOffset() {
        return (currentPage - 1) * pageSize;
    }

    /* ---------- Navigation ---------- */
    public boolean isHasPreviousPage() {
        return currentPage > 1;
    }

    public boolean isHasNextPage() {
        return currentPage < totalPages;
    }

    /**
     * Trang bắt đầu khi render danh sách số trang (hiển thị tối đa 5 trang).
     */
    public int getStartPage() {
        return Math.max(1, currentPage - 2);
    }

    /**
     * Trang kết thúc khi render danh sách số trang.
     */
    public int getEndPage() {
        return Math.min(totalPages, currentPage + 2);
    }
}
