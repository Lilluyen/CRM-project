<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Category Management</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <!-- CSS giống My Tickets -->
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
                                <a href="list" class="active">Category List</a>
                            </li>
                            <li>
                                <a href="create">Create Category</a>
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
                    <h4>Category Management</h4>
                    <h6>Manage product categories</h6>
                </div>
            </div>

            <!-- FILTER CARD -->
            <div class="card">
                <div class="card-body">

                    <form method="get" action="list">
                        <div class="row align-items-end">

                            <div class="col-lg-4">
                                <label>Search</label>
                                <input type="text"
                                       name="search"
                                       value="${param.search}"
                                       class="form-control"
                                       placeholder="Search category...">
                            </div>

                            <div class="col-lg-3">
                                <label>Status</label>
                                <select name="status" class="form-control">
                                    <option value="">All Status</option>
                                    <option value="ACTIVE"
                                            <c:if test="${param.status == 'ACTIVE'}">selected</c:if>>
                                        ACTIVE
                                    </option>
                                    <option value="INACTIVE"
                                            <c:if test="${param.status == 'INACTIVE'}">selected</c:if>>
                                        INACTIVE
                                    </option>
                                </select>
                            </div>

                            <div class="col-lg-5 mt-2">
                                <button type="submit" class="btn btn-primary">
                                    Search
                                </button>

                                <a href="create" class="btn btn-success">
                                    + Add
                                </a>

                                <a href="export" class="btn btn-secondary">
                                    Export
                                </a>
                            </div>

                        </div>
                    </form>

                </div>
            </div>

            <!-- TABLE CARD -->
            <div class="card">
                <div class="card-body">

                    <div class="table-responsive">

                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                            <tr>
                                <th>STT</th>
                                <th>Category Name</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Created At</th>
                                <th>Action</th>
                            </tr>
                            </thead>

                            <tbody>

                            <c:forEach var="c" items="${categoryList}" varStatus="loop">
                                <tr>

                                    <td>
                                            ${(currentPage - 1) * 5 + loop.index + 1}
                                    </td>

                                    <td>${c.categoryName}</td>
                                    <td>${c.description}</td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'ACTIVE'}">
                                                <span class="badge bg-success">
                                                    ACTIVE
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">
                                                    INACTIVE
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>${c.createdAt}</td>

                                    <td>
                                        <a href="edit?id=${c.categoryId}"
                                           class="btn btn-sm btn-warning">
                                            Edit
                                        </a>

                                        <a href="delete?id=${c.categoryId}"
                                           onclick="return confirm('Are you sure to delete this category?')"
                                           class="btn btn-sm btn-danger">
                                            Delete
                                        </a>
                                    </td>

                                </tr>
                            </c:forEach>

                            <c:if test="${empty categoryList}">
                                <tr>
                                    <td colspan="6" class="text-center">
                                        No categories found
                                    </td>
                                </tr>
                            </c:if>

                            </tbody>
                        </table>

                    </div>

                    <!-- PAGINATION -->
                    <div class="d-flex justify-content-center mt-3">
                        <ul class="pagination">
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                                    <a class="page-link"
                                       href="list?page=${i}&search=${param.search}&status=${param.status}">
                                            ${i}
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>

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