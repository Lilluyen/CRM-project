<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Sales Funnel</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
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

            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger">Logout</a>
        </div>
    </div>

    <jsp:include page="/view/components/sidebar.jsp" />

    <div class="page-wrapper">
        <div class="content">

            <div class="page-header">
                <div class="page-title">
                    <h4>Sales Funnel</h4>
                    <h6>Overview deals by stage</h6>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Total Deals</div>
                            <div class="h4 mb-0">${totalDeals}</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Total Expected</div>
                            <div class="h4 mb-0">${totalExpected}</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Weighted Expected</div>
                            <div class="h4 mb-0">${totalWeighted}</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Total Actual</div>
                            <div class="h4 mb-0">${totalActual}</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-body">

                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                            <tr>
                                <th>Stage</th>
                                <th>Deals</th>
                                <th>% Deals</th>
                                <th>Expected Sum</th>
                                <th>Weighted Expected</th>
                                <th>Actual Sum</th>
                                <th>Conversion vs Previous</th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:set var="prevCount" value="0" />
                            <c:forEach var="s" items="${stages}" varStatus="loop">
                                <tr>
                                    <td>${s.stage}</td>
                                    <td>${s.dealCount}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${totalDeals > 0}">
                                                ${ (s.dealCount * 100.0) / totalDeals }%
                                            </c:when>
                                            <c:otherwise>0%</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${s.expectedSum}</td>
                                    <td>${s.weightedExpectedSum}</td>
                                    <td>${s.actualSum}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${loop.index == 0}">
                                                -
                                            </c:when>
                                            <c:when test="${prevCount > 0}">
                                                ${ (s.dealCount * 100.0) / prevCount }%
                                            </c:when>
                                            <c:otherwise>0%</c:otherwise>
                                        </c:choose>
                                        <c:set var="prevCount" value="${s.dealCount}" />
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
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
