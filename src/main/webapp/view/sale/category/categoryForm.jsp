<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-tags me-2"></i>${category != null ? "Edit Category" : "Add Category"}</h4>
            <p class="text-muted mb-0">${category != null ? "Update category information" : "Create new category"}</p>
        </div>
        <a href="${pageContext.request.contextPath}/sale/category/list" class="btn btn-outline-secondary">
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

                <c:if test="${category != null}">
                    <input type="hidden" name="id" value="${category.categoryId}" />
                </c:if>

                <div class="mb-3">
                    <label class="form-label">Category Name <span class="text-danger">*</span></label>
                    <input type="text" name="categoryName" value="${category.categoryName}"
                           class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control"
                              rows="3">${category.description}</textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE" <c:if test="${category.status == 'ACTIVE' || category == null}">selected</c:if>>ACTIVE</option>
                        <option value="INACTIVE" <c:if test="${category.status == 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                    </select>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-1"></i> Save
                    </button>
                    <a href="${pageContext.request.contextPath}/sale/category/list" class="btn btn-secondary">Cancel</a>
                </div>

            </form>

        </div>
    </div>

</div>