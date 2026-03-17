<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-box me-2"></i>Product Management</h4>
            <p class="text-muted mb-0">Manage products</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/sale/product/export?search=${param.search}&status=${param.status}"
               class="btn btn-outline-success">
                <i class="fas fa-file-excel me-1"></i> Export Excel
            </a>
            <a href="${pageContext.request.contextPath}/sale/product/create" class="btn btn-primary">
                <i class="fas fa-plus-circle me-1"></i> Add Product
            </a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-1"></i> ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
            <form method="get" action="${pageContext.request.contextPath}/sale/product/list" class="row g-3">

                <div class="col-md-5">
                    <label class="form-label">Search</label>
                    <input type="text" name="search" value="${param.search}" class="form-control"
                           placeholder="Search by name, SKU or description...">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="">-- All Status --</option>
                        <option value="ACTIVE" <c:if test="${param.status == 'ACTIVE'}">selected</c:if>>ACTIVE</option>
                        <option value="INACTIVE" <c:if test="${param.status == 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                    </select>
                </div>

                <div class="col-md-3 d-flex align-items-end gap-2">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-search me-1"></i> Search
                    </button>
                </div>

            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                    <tr>
                        <th>STT</th>
                        <th>Product Name</th>
                        <th>SKU</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Status</th>
                        <th>Updated At</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="p" items="${productList}" varStatus="loop">
                        <tr>
                            <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                            <td>${p.name}</td>
                            <td>${p.sku}</td>
                            <td>
                                <c:forEach var="cat" items="${p.categories}" varStatus="cLoop">
                                    ${cat.categoryName}<c:if test="${!cLoop.last}">, </c:if>
                                </c:forEach>
                            </td>
                            <td>${p.price}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.status == 'ACTIVE'}">
                                        <span class="badge bg-success">ACTIVE</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">INACTIVE</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${p.updatedAt}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/sale/product/edit?id=${p.productId}" class="btn btn-sm btn-warning">Edit</a>
                                <a href="${pageContext.request.contextPath}/sale/product/delete?id=${p.productId}"
                                   onclick="return confirm('Are you sure to delete this product?')"
                                   class="btn btn-sm btn-danger">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty productList}">
                        <tr>
                            <td colspan="8" class="text-center">No products found</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-center mt-3">
                <ul class="pagination">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                            <a class="page-link"
                               href="${pageContext.request.contextPath}/sale/product/list?page=${i}&search=${param.search}&status=${param.status}">
                                    ${i}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>

        </div>
    </div>

</div>
