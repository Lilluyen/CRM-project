<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>My Tickets</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <!-- CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/animate.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/plugins/fontawesome/css/fontawesome.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/plugins/fontawesome/css/all.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">
</head>

<body>

<!-- LOADER -->
<div id="global-loader">
    <div class="whirly-loader"></div>
</div>

<div class="main-wrapper">

    <!-- HEADER -->
    <div class="header d-flex align-items-center">

        <div class="header-left">
            <a href="#" class="logo">
                CRM System
            </a>
        </div>

        <div class="d-flex align-items-center ms-3">

            <div class="me-3">
                Welcome, <strong>${sessionScope.customer.name}</strong>
            </div>

            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-sm btn-outline-danger">
                Logout
            </a>

        </div>

    </div>
    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-inner slimscroll">
            <div id="sidebar-menu" class="sidebar-menu">
                <ul>
                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <i data-feather="columns"></i>
                            <span> Ticket</span>
                            <span class="menu-arrow"></span>
                        </a>
                        <ul>
                            <li>
                                <a href="${pageContext.request.contextPath}/customer/my-tickets"
                                   class="active">My Tickets</a>
                            </li>
                            <li>
                                <a href="#">Create Ticket</a>
                            </li>
                        </ul>
                    </li>

                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <i data-feather="layout"></i>
                            <span> Feedback </span>
                            <span class="menu-arrow"></span>
                        </a>
                        <ul>
                            <li><a href="#">My Feedbacks</a></li>
                            <li><a href="#">Create Feedback</a></li>
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
                    <h4>My Tickets</h4>
                    <h6>Manage your support tickets</h6>
                </div>
            </div>

            <!-- FILTER -->
            <div class="card">
                <div class="card-body pb-0">

                    <form method="get"
                          action="${pageContext.request.contextPath}/customer/my-tickets">

                        <!-- giữ page = 1 khi filter -->
                        <input type="hidden" name="page" value="1"/>

                        <div class="row">

                            <div class="col-lg-4">
                                <div class="form-group">
                                    <input type="text"
                                           name="subject"
                                           value="${subject}"
                                           class="form-control"
                                           placeholder="Search by subject">
                                </div>
                            </div>

                            <div class="col-lg-3">
                                <div class="form-group">
                                    <select name="status" class="form-control">
                                        <option value="">All Status</option>
                                        <option value="OPEN"
                                                <c:if test="${status == 'OPEN'}">selected</c:if>>
                                            Open
                                        </option>
                                        <option value="IN_PROGRESS"
                                                <c:if test="${status == 'IN_PROGRESS'}">selected</c:if>>
                                            In Progress
                                        </option>
                                        <option value="RESOLVED"
                                                <c:if test="${status == 'RESOLVED'}">selected</c:if>>
                                            Resolved
                                        </option>
                                        <option value="CLOSED"
                                                <c:if test="${status == 'CLOSED'}">selected</c:if>>
                                            Closed
                                        </option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-lg-2">
                                <button type="submit" class="btn btn-primary">
                                    Filter
                                </button>

                                <a href="${pageContext.request.contextPath}/customer/my-tickets"
                                   class="btn btn-secondary">
                                    Clear
                                </a>
                            </div>

                        </div>
                    </form>

                </div>
            </div>

            <!-- TABLE -->
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">

                        <table class="table table-bordered">
                            <thead>
                            <tr>
                                <th>
                                    <form method="get" action="${pageContext.request.contextPath}/customer/my-tickets" style="display:inline;">

                                        <!-- giữ filter -->
                                        <input type="hidden" name="subject" value="${subject}" />
                                        <input type="hidden" name="status" value="${status}" />
                                        <input type="hidden" name="page" value="1" />

                                        <!-- toggle sort -->
                                        <input type="hidden" name="sort"
                                               value="${sort == 'id_asc' ? 'id_desc' : 'id_asc'}" />

                                        ID

                                        <button type="submit" class="btn btn-sm p-0 border-0 bg-transparent">
                                            <c:choose>
                                                <c:when test="${sort eq 'id_asc'}">↑</c:when>
                                                <c:when test="${sort eq 'id_desc'}">↓</c:when>
                                                <c:otherwise>↕</c:otherwise>
                                            </c:choose>
                                        </button>

                                    </form>
                                </th>
                                <th>Subject</th>
                                <th>Status</th>
                                <th>
                                    <form method="get" action="${pageContext.request.contextPath}/customer/my-tickets" style="display:inline;">

                                        <input type="hidden" name="subject" value="${subject}" />
                                        <input type="hidden" name="status" value="${status}" />
                                        <input type="hidden" name="page" value="1" />

                                        <input type="hidden" name="sort"
                                               value="${sort == 'created_asc' ? 'created_desc' : 'created_asc'}" />

                                        Created At

                                        <button type="submit" class="btn btn-sm p-0 border-0 bg-transparent">
                                            <c:choose>
                                                <c:when test="${sort eq 'created_asc'}">↑</c:when>
                                                <c:when test="${sort eq 'created_desc'}">↓</c:when>
                                                <c:otherwise>↕</c:otherwise>
                                            </c:choose>
                                        </button>

                                    </form>
                                </th>
                                <th>
                                    <form method="get" action="${pageContext.request.contextPath}/customer/my-tickets" style="display:inline;">

                                        <input type="hidden" name="subject" value="${subject}" />
                                        <input type="hidden" name="status" value="${status}" />
                                        <input type="hidden" name="page" value="1" />

                                        <input type="hidden" name="sort"
                                               value="${sort == 'updated_asc' ? 'updated_desc' : 'updated_asc'}" />

                                        Updated At

                                        <button type="submit" class="btn btn-sm p-0 border-0 bg-transparent">
                                            <c:choose>
                                                <c:when test="${sort eq 'updated_asc'}">↑</c:when>
                                                <c:when test="${sort eq 'updated_desc'}">↓</c:when>
                                                <c:otherwise>↕</c:otherwise>
                                            </c:choose>
                                        </button>

                                    </form>
                                </th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:choose>
                                <c:when test="${not empty tickets}">
                                    <c:forEach var="t" items="${tickets}">
                                        <tr>
                                            <td>${t.ticketId}</td>
                                            <td>${t.subject}</td>
                                            <td>
                                                <c:choose>

                                                    <c:when test="${t.status == 'OPEN'}">
                                                        <span class="badge bg-primary">Open</span>
                                                    </c:when>

                                                    <c:when test="${t.status == 'IN_PROGRESS'}">
                                                        <span class="badge bg-warning text-dark">In Progress</span>
                                                    </c:when>

                                                    <c:when test="${t.status == 'RESOLVED'}">
                                                        <span class="badge bg-success">Resolved</span>
                                                    </c:when>

                                                    <c:when test="${t.status == 'CLOSED'}">
                                                        <span class="badge bg-secondary">Closed</span>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <span class="badge bg-dark">${t.status}</span>
                                                    </c:otherwise>

                                                </c:choose>
                                            </td>
                                            <td>${t.createdAtFormatted}</td>
                                            <td>${t.updatedAtFormatted}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>

                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center">
                                            No tickets found
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>

                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <c:if test="${totalRecords > 0}">
                                <div class="mt-2">
                                    Showing ${startRecord} to ${endRecord} of ${totalRecords} tickets
                                </div>
                            </c:if>

                            <c:if test="${totalPages > 0}">
                                <!-- PAGINATION -->
                                <div class="d-flex justify-content-end mt-3">

                                    <ul class="pagination">

                                        <!-- Previous -->
                                        <c:choose>
                                            <c:when test="${currentPage > 1}">
                                                <li class="page-item">
                                                    <a class="page-link"
                                                       href="${pageContext.request.contextPath}/customer/my-tickets?page=${currentPage - 1}&subject=${subject}&status=${status}&sort=${sort}">
                                                        Previous
                                                    </a>
                                                </li>
                                            </c:when>
                                            <c:otherwise>
                                                <li class="page-item disabled">
                                                    <span class="page-link">Previous</span>
                                                </li>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Page Numbers -->
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                                                <a class="page-link"
                                                   href="${pageContext.request.contextPath}/customer/my-tickets?page=${i}&subject=${subject}&status=${status}&sort=${sort}">
                                                        ${i}
                                                </a>
                                            </li>
                                        </c:forEach>

                                        <!-- Next -->
                                        <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>">
                                            <a class="page-link"
                                               href="${pageContext.request.contextPath}/customer/my-tickets?page=${currentPage + 1}&subject=${subject}&status=${status}&sort=${sort}">
                                                Next
                                            </a>
                                        </li>

                                    </ul>

                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- JS -->
<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/feather.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/jquery.slimscroll.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dataTables.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>


</body>
</html>