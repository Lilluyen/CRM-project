<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Product Form</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">
</head>

<body>

<div class="main-wrapper">

    <div class="header d-flex align-items-center justify-content-between px-3">
        <div class="header-left">
            <a href="#" class="logo">CRM System</a>
        </div>

        <div class="d-flex align-items-center">
            <div class="me-3">
                Welcome, <strong>${sessionScope.user.fullName}</strong>
            </div>

            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-sm btn-outline-danger">
                Logout
            </a>
        </div>
    </div>

    <div class="sidebar" id="sidebar">
        <div class="sidebar-inner">
            <div id="sidebar-menu" class="sidebar-menu">
                <ul>
                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <span>Product</span>
                        </a>
                        <ul>
                            <li>
                                <a href="list">Product List</a>
                            </li>
                            <li>
                                <a href="#" class="active">
                                    ${product == null ? "Add Product" : "Edit Product"}
                                </a>
                            </li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <div class="page-wrapper">
        <div class="content">

            <div class="page-header">
                <div class="page-title">
                    <h4>${product == null ? "Add Product" : "Edit Product"}</h4>
                    <h6>${product == null ? "Create new product" : "Update product information"}</h6>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="card">
                <div class="card-body">

                    <form method="post">

                        <c:if test="${product != null}">
                            <input type="hidden" name="id" value="${product.productId}" />
                        </c:if>

                        <div class="mb-3">
                            <label class="form-label">Product Name</label>
                            <input type="text" name="name" value="${product.name}" class="form-control" required />
                        </div>

                        <div class="mb-3">
                            <label class="form-label">SKU</label>
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
                            <select name="status" class="form-control">
                                <option value="ACTIVE" <c:if test="${product.status == 'ACTIVE' || product == null}">selected</c:if>>ACTIVE</option>
                                <option value="INACTIVE" <c:if test="${product.status == 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                            </select>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control" rows="4">${product.description}</textarea>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">Save</button>
                            <a href="list" class="btn btn-secondary">Cancel</a>
                        </div>

                    </form>

                </div>
            </div>

        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>
