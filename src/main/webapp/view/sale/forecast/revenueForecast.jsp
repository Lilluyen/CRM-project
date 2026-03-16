<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Revenue Forecast</title>

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
                    <h4>Revenue Forecast</h4>
                    <h6>Forecasted revenue based on open deals (probability x expected value)</h6>
                </div>
            </div>

            <div class="card mb-3">
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/forecast" class="row align-items-end">
                        <div class="col-md-3">
                            <label class="form-label">Group By</label>
                            <select name="groupBy" class="form-control">
                                <option value="month" <c:if test="${groupBy == 'month'}">selected</c:if>>Month</option>
                                <option value="quarter" <c:if test="${groupBy == 'quarter'}">selected</c:if>>Quarter</option>
                                <option value="year" <c:if test="${groupBy == 'year'}">selected</c:if>>Year</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-primary">Apply</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Open Deals</div>
                            <div class="h4 mb-0">${totalDeals}</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Total Expected Value</div>
                            <div class="h4 mb-0">
                                <fmt:formatNumber value="${totalExpected}" type="number" groupingUsed="true" maxFractionDigits="2" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <div class="text-muted">Total Forecasted Revenue</div>
                            <div class="h4 mb-0">
                                <fmt:formatNumber value="${totalForecasted}" type="number" groupingUsed="true" maxFractionDigits="2" />
                            </div>
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
                                <th>Period</th>
                                <th>Open Deals</th>
                                <th>Expected Value</th>
                                <th>Forecasted Revenue</th>
                                <th>% of Total Forecast</th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:forEach var="r" items="${rows}">
                                <tr>
                                    <td>${r.period}</td>
                                    <td>${r.dealCount}</td>
                                    <td>
                                        <fmt:formatNumber value="${r.expectedSum}" type="number" groupingUsed="true" maxFractionDigits="2" />
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${r.forecastedRevenue}" type="number" groupingUsed="true" maxFractionDigits="2" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${totalForecasted > 0}">
                                                <fmt:formatNumber value="${r.forecastedRevenue / totalForecasted * 100}" maxFractionDigits="1" />%
                                            </c:when>
                                            <c:otherwise>0%</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty rows}">
                                <tr>
                                    <td colspan="5" class="text-center">No open deals with expected close date found</td>
                                </tr>
                            </c:if>
                            </tbody>

                            <c:if test="${not empty rows}">
                                <tfoot class="table-light">
                                <tr>
                                    <th>Total</th>
                                    <th>${totalDeals}</th>
                                    <th>
                                        <fmt:formatNumber value="${totalExpected}" type="number" groupingUsed="true" maxFractionDigits="2" />
                                    </th>
                                    <th>
                                        <fmt:formatNumber value="${totalForecasted}" type="number" groupingUsed="true" maxFractionDigits="2" />
                                    </th>
                                    <th>100%</th>
                                </tr>
                                </tfoot>
                            </c:if>
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
