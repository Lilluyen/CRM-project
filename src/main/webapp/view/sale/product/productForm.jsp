<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-box me-2"></i>${product.productId > 0 ? "Edit Product" : "Add Product"}</h4>
            <p class="text-muted mb-0">${product.productId > 0 ? "Update product information" : "Create new product"}</p>
        </div>
        <a href="${pageContext.request.contextPath}/sale/product/list" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-1"></i> Back to List
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-1"></i> ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body">

            <form method="post">

                <c:if test="${product.productId > 0}">
                    <input type="hidden" name="id" value="${product.productId}" />
                </c:if>

                <div class="mb-3">
                    <label class="form-label">Product Name <span class="text-danger">*</span></label>
                    <input type="text" name="name" value="${product.name}" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">SKU <span class="text-danger">*</span></label>
                    <input type="text" name="sku" value="${product.sku}" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">Price</label>
                    <input type="number" step="0.01" name="price" value="${product.price}" class="form-control" />
                </div>

                <div class="mb-3">
                    <label class="form-label">Category</label>
                    <div class="row">
                        <c:forEach var="c" items="${categories}">
                            <div class="col-md-4 mb-2">
                                <c:set var="checked" value="false" />
                                <c:if test="${product != null}">
                                    <c:forEach var="pc" items="${product.categories}">
                                        <c:if test="${pc.categoryId == c.categoryId}">
                                            <c:set var="checked" value="true" />
                                        </c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="form-check-label">
                                    <input class="form-check-input" type="checkbox" name="categoryIds"
                                           value="${c.categoryId}" <c:if test="${checked}">checked</c:if> />
                                    ${c.categoryName}
                                </label>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE" <c:if test="${product.status == 'ACTIVE' || product == null}">selected</c:if>>ACTIVE</option>
                        <option value="INACTIVE" <c:if test="${product.status == 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                    </select>
                </div>

                <div class="mb-4">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="4">${product.description}</textarea>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-1"></i> Save
                    </button>
                    <a href="${pageContext.request.contextPath}/sale/product/list" class="btn btn-secondary">Cancel</a>
                </div>

            </form>

        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>
