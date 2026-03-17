<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-filter me-2"></i>Sales Funnel</h4>
            <p class="text-muted mb-0">Overview deals by stage</p>
        </div>
    </div>

    <div class="row g-3 mb-3">
        <div class="col-md-3">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="text-muted">Total Deals</div>
                    <div class="h4 mb-0">${totalDeals}</div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="text-muted">Total Expected</div>
                    <div class="h4 mb-0">
                        <fmt:formatNumber value="${totalExpected}" type="number" groupingUsed="true" maxFractionDigits="2" />
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="text-muted">Weighted Expected</div>
                    <div class="h4 mb-0">
                        <fmt:formatNumber value="${totalWeighted}" type="number" groupingUsed="true" maxFractionDigits="2" />
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="text-muted">Total Actual</div>
                    <div class="h4 mb-0">
                        <fmt:formatNumber value="${totalActual}" type="number" groupingUsed="true" maxFractionDigits="2" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm">
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
                                        <fmt:formatNumber value="${(s.dealCount * 100.0) / totalDeals}" maxFractionDigits="1" />%
                                    </c:when>
                                    <c:otherwise>0%</c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatNumber value="${s.expectedSum}" type="number" groupingUsed="true" maxFractionDigits="2" /></td>
                            <td><fmt:formatNumber value="${s.weightedExpectedSum}" type="number" groupingUsed="true" maxFractionDigits="2" /></td>
                            <td><fmt:formatNumber value="${s.actualSum}" type="number" groupingUsed="true" maxFractionDigits="2" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${loop.index == 0}">
                                        -
                                    </c:when>
                                    <c:when test="${prevCount > 0}">
                                        <fmt:formatNumber value="${(s.dealCount * 100.0) / prevCount}" maxFractionDigits="1" />%
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

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>
