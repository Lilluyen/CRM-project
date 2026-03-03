<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Category Form</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <!-- Bootstrap giống trang trước -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">
</head>

<body>

<div class="main-wrapper">

    <!-- HEADER -->
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

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-inner">
            <div id="sidebar-menu" class="sidebar-menu">
                <ul>

                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <span>Category</span>
                        </a>
                        <ul>
                            <li>
                                <a href="list">Category List</a>
                            </li>
                            <li>
                                <a href="#" class="active">
                                    ${category == null ? "Add Category" : "Edit Category"}
                                </a>
                            </li>
                        </ul>
                    </li>

                </ul>
            </div>
        </div>
    </div>

    <!-- PAGE CONTENT -->
    <div class="page-wrapper">
        <div class="content">

            <div class="page-header">
                <div class="page-title">
                    <h4>
                        ${category == null ? "Add Category" : "Edit Category"}
                    </h4>
                    <h6>
                        ${category == null ? "Create new category" : "Update category information"}
                    </h6>
                </div>
            </div>

            <!-- FORM CARD -->
            <div class="card">
                <div class="card-body">

                    <form method="post">

                        <c:if test="${category != null}">
                            <input type="hidden" name="id"
                                   value="${category.categoryId}" />
                        </c:if>

                        <!-- NAME -->
                        <div class="mb-3">
                            <label class="form-label">Category Name</label>
                            <input type="text"
                                   name="name"
                                   value="${category.categoryName}"
                                   class="form-control"
                                   required />
                        </div>

                        <!-- DESCRIPTION -->
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea name="description"
                                      class="form-control"
                                      rows="3">${category.description}</textarea>
                        </div>

                        <!-- STATUS -->
                        <div class="mb-4">
                            <label class="form-label">Status</label>
                            <select name="status" class="form-control">

                                <option value="ACTIVE"
                                        <c:if test="${category.status == 'ACTIVE'}">
                                            selected
                                        </c:if>>
                                    ACTIVE
                                </option>

                                <option value="INACTIVE"
                                        <c:if test="${category.status == 'INACTIVE'}">
                                            selected
                                        </c:if>>
                                    INACTIVE
                                </option>

                            </select>
                        </div>

                        <!-- BUTTONS -->
                        <div class="d-flex gap-2">

                            <button type="submit"
                                    class="btn btn-primary">
                                Save
                            </button>

                            <a href="list"
                               class="btn btn-secondary">
                                Cancel
                            </a>

                        </div>

                    </form>

                </div>
            </div>

        </div>
    </div>

</div>

<!-- JS -->
<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>