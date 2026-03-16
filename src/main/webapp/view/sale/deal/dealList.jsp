<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Deal Management</title>

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
                            <span>Deals</span>
                        </a>
                        <ul>
                            <li>
                                <a href="list" class="active">Deal List</a>
                            </li>
                            <li>
                                <a href="create">Create Deal</a>
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
                    <h4>Deal Management</h4>
                    <h6>Manage sales deals</h6>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <form method="get" action="list">
                        <div class="row align-items-end">

                            <div class="col-lg-4">
                                <label>Search</label>
                                <input type="text" name="search" value="${param.search}" class="form-control"
                                       placeholder="Search deal..." />
                            </div>

                            <div class="col-lg-3">
                                <label>Stage</label>
                                <select name="stage" class="form-control">
                                    <option value="">All Stages</option>
                                    <c:forEach var="s" items="${stages}">
                                        <option value="${s}" <c:if test="${param.stage == s}">selected</c:if>>${s}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-lg-5 mt-2">
                                <button type="submit" class="btn btn-primary">Search</button>
                                <a href="export?search=${param.search}&stage=${param.stage}" class="btn btn-outline-secondary">Export</a>
                                <a href="create" class="btn btn-success">+ Add</a>
                            </div>

                        </div>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body">

                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                            <tr>
                                <th>STT</th>
                                <th>Deal Name</th>
                                <th>Stage</th>
                                <th>Probability</th>
                                <th>Expected Value</th>
                                <th>Actual Value</th>
                                <th>Close Date</th>
                                <th>Action</th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:forEach var="d" items="${dealList}" varStatus="loop">
                                <tr>
                                    <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                                    <td>
                                        <a href="detail?id=${d.dealId}">${d.dealName}</a>
                                    </td>
                                    <td>${d.stage}</td>
                                    <td>${d.probability}%</td>
                                    <td>${d.expectedValue}</td>
                                    <td>${d.actualValue}</td>
                                    <td>${d.expectedCloseDate}</td>
                                    <td>
                                        <a class="btn btn-sm btn-info" href="detail?id=${d.dealId}">View</a>
                                        <a class="btn btn-sm btn-warning" href="edit?id=${d.dealId}">Edit</a>
                                        <a class="btn btn-sm btn-danger" href="delete?id=${d.dealId}"
                                           onclick="return confirm('Delete this deal?')">Delete</a>

                                        <form method="post" action="stage" style="display:inline-block;">
                                            <input type="hidden" name="id" value="${d.dealId}" />
                                            <select name="stage" class="form-select form-select-sm" style="width:auto; display:inline-block;">
                                                <c:forEach var="s" items="${stages}">
                                                    <option value="${s}" <c:if test="${d.stage == s}">selected</c:if>>${s}</option>
                                                </c:forEach>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-outline-primary">Move</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty dealList}">
                                <tr>
                                    <td colspan="8" class="text-center">No deals found</td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>

                    <div class="d-flex justify-content-center mt-3">
                        <ul class="pagination">
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                                    <a class="page-link" href="list?page=${i}&search=${param.search}&stage=${param.stage}">${i}</a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>

                </div>
            </div>

        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>
