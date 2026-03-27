<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%--
    ╔══════════════════════════════════════════════════════════════╗
    ║  REUSABLE PAGINATION COMPONENT                              ║
    ║                                                              ║
    ║  Yêu cầu: request attribute "pagination" (dto.Pagination)   ║
    ║                                                              ║
    ║  Cách dùng trong JSP:                                        ║
    ║    <jsp:include page="/view/components/pagination.jsp" />    ║
    ║                                                              ║
    ║  Hỗ trợ:                                                     ║
    ║    • Chuyển trang (Previous / 1 2 3 ... / Next)              ║
    ║    • Chọn số bản ghi mỗi trang (5 / 10 / 20)                ║
    ║    • Giữ nguyên query params hiện tại (search, status, ...)  ║
    ╚══════════════════════════════════════════════════════════════╝
--%>

<c:if test="${not empty pagination and pagination.totalItems > 0}">
    <div class="card-footer d-flex justify-content-between align-items-center flex-wrap gap-2 py-3">

        <%-- LEFT: Thông tin hiển thị --%>
        <small class="text-muted">
            Showing <strong>${pagination.startItemNumber}</strong> –
            <strong>${pagination.endItemNumber}</strong>
            / <strong>${pagination.totalItems}</strong> records
        </small>

        <%-- CENTER: Điều hướng trang --%>
        <c:if test="${pagination.totalPages > 1}">
            <nav aria-label="Pagination">
                <ul class="pagination pagination-sm mb-0">

                    <%-- Nút Previous --%>
                    <li class="page-item ${!pagination.hasPreviousPage ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)"
                           onclick="paginationGoToPage(${pagination.currentPage - 1})"
                           aria-label="Previous">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    </li>

                    <%-- Trang đầu + dấu ... --%>
                    <c:if test="${pagination.startPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="javascript:void(0)"
                               onclick="paginationGoToPage(1)">1</a>
                        </li>
                        <c:if test="${pagination.startPage > 2}">
                            <li class="page-item disabled">
                                <span class="page-link">…</span>
                            </li>
                        </c:if>
                    </c:if>

                    <%-- Các trang lân cận --%>
                    <c:forEach begin="${pagination.startPage}" end="${pagination.endPage}" var="i">
                        <li class="page-item ${i == pagination.currentPage ? 'active' : ''}">
                            <a class="page-link" href="javascript:void(0)"
                               onclick="paginationGoToPage(${i})">${i}</a>
                        </li>
                    </c:forEach>

                    <%-- ... + Trang cuối --%>
                    <c:if test="${pagination.endPage < pagination.totalPages}">
                        <c:if test="${pagination.endPage < pagination.totalPages - 1}">
                            <li class="page-item disabled">
                                <span class="page-link">…</span>
                            </li>
                        </c:if>
                        <li class="page-item">
                            <a class="page-link" href="javascript:void(0)"
                               onclick="paginationGoToPage(${pagination.totalPages})">${pagination.totalPages}</a>
                        </li>
                    </c:if>

                    <%-- Nút Next --%>
                    <li class="page-item ${!pagination.hasNextPage ? 'disabled' : ''}">
                        <a class="page-link" href="javascript:void(0)"
                           onclick="paginationGoToPage(${pagination.currentPage + 1})"
                           aria-label="Next">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>

        <%-- RIGHT: Chọn số bản ghi / trang --%>
        <div class="d-flex align-items-center gap-2">
            <small class="text-muted">Showing</small>
            <select class="form-select form-select-sm" style="width: auto;"
                    onchange="paginationChangePageSize(this.value)"
                    aria-label="Number of records per page">
                <option value="5"  ${pagination.pageSize == 5  ? 'selected' : ''}>5</option>
                <option value="10" ${pagination.pageSize == 10 ? 'selected' : ''}>10</option>
                <option value="20" ${pagination.pageSize == 20 ? 'selected' : ''}>20</option>
            </select>
            <small class="text-muted">/ page</small>
        </div>
    </div>

    <%-- JavaScript: giữ nguyên mọi query params hiện tại, chỉ đổi page / pageSize --%>
    <script>
        function paginationGoToPage(page) {
            var url = new URL(window.location.href);
            url.searchParams.set('page', page);
            if (!url.searchParams.has('pageSize')) {
                url.searchParams.set('pageSize', '${pagination.pageSize}');
            }
            window.location.href = url.toString();
        }

        function paginationChangePageSize(size) {
            var url = new URL(window.location.href);
            url.searchParams.set('pageSize', size);
            url.searchParams.set('page', '1');   // reset về trang 1
            window.location.href = url.toString();
        }
    </script>
</c:if>
