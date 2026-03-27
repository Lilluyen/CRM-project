<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page isELIgnored="false" %>

<div class="md-page">
    <div class="md-header">
        <div>
            <h2>Manager Dashboard</h2>
            <p>Overview of customers, leads, tasks, deals and team activities.</p>
        </div>
        <form method="get" action="${pageContext.request.contextPath}/manager/dashboard" class="md-filter">
            <label for="period">Period</label>
            <select id="period" name="period" onchange="this.form.submit()">
                <option value="7d" ${period eq '7d' ? 'selected' : ''}>Last 7 days</option>
                <option value="30d" ${period eq '30d' ? 'selected' : ''}>Last 30 days</option>
                <option value="quarter" ${period eq 'quarter' ? 'selected' : ''}>Last 3 months</option>
                <option value="year" ${period eq 'year' ? 'selected' : ''}>Last 1 year</option>
                <option value="all" ${period eq 'all' ? 'selected' : ''}>All time</option>
            </select>
        </form>
    </div>

    <div class="md-kpi-grid">
        <a class="md-kpi-card md-kpi-link" href="${pageContext.request.contextPath}/customers">
            <div class="md-kpi-label">Total Customers</div>
            <div class="md-kpi-value"><fmt:formatNumber value="${totalCustomers}" type="number"/></div>
        </a>
        <a class="md-kpi-card md-kpi-link" href="${pageContext.request.contextPath}/marketing/leads">
            <div class="md-kpi-label">Total Leads</div>
            <div class="md-kpi-value"><fmt:formatNumber value="${totalLeads}" type="number"/></div>
        </a>
        <a class="md-kpi-card md-kpi-link" href="${pageContext.request.contextPath}/tasks/list">
            <div class="md-kpi-label">Open Tasks</div>
            <div class="md-kpi-value"><fmt:formatNumber value="${openTasks}" type="number"/></div>
        </a>
        <a class="md-kpi-card md-kpi-link" href="${pageContext.request.contextPath}/sale/deal/list?stage=Closed Won">
            <div class="md-kpi-label">Won Deals</div>
            <div class="md-kpi-value"><fmt:formatNumber value="${wonDeals}" type="number"/></div>
        </a>
    </div>

    <div class="md-grid">
        <div class="md-panel">
            <div class="md-panel-title">Revenue (Closed Won)</div>
            <canvas id="revenueChart" height="120"></canvas>
        </div>

        <div class="md-panel">
            <div class="md-panel-title">Deal Stage Distribution</div>
            <canvas id="dealStageChart" height="120"></canvas>
        </div>
    </div>

    <div class="md-panel">
        <div class="md-panel-title">Recent Activities</div>
        <c:choose>
            <c:when test="${empty recentActivities}">
                <div class="md-empty">No recent activities.</div>
            </c:when>
            <c:otherwise>
                <div class="md-table-wrap">
                    <table class="md-table">
                        <thead>
                        <tr>
                            <th>Time</th>
                            <th>Subject</th>
                            <th>Type</th>
                            <th>Related</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${recentActivities}" var="a">
                            <tr>
                                <td>${a.createdAt}</td>
                                <td>${a.subject}</td>
                                <td>${a.activityType}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty a.relatedType}">
                                            ${a.relatedType} #${a.relatedId}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
    (function () {
        if (typeof Chart === 'undefined') return;

        var revenueLabels = [
            <c:forEach items="${monthlyRevenue}" var="p" varStatus="s">'${p.month}'<c:if test="${!s.last}">,</c:if></c:forEach>
        ];
        var revenueData = [
            <c:forEach items="${monthlyRevenue}" var="p" varStatus="s">${p.revenue}<c:if test="${!s.last}">,</c:if></c:forEach>
        ];

        var stageLabels = [
            <c:forEach items="${dealStageData}" var="d" varStatus="s">'${d.stage}'<c:if test="${!s.last}">,</c:if></c:forEach>
        ];
        var stageData = [
            <c:forEach items="${dealStageData}" var="d" varStatus="s">${d.total}<c:if test="${!s.last}">,</c:if></c:forEach>
        ];

        var revenueCtx = document.getElementById('revenueChart');
        if (revenueCtx) {
            new Chart(revenueCtx, {
                type: 'line',
                data: {
                    labels: revenueLabels,
                    datasets: [{
                        data: revenueData,
                        borderColor: '#0f62fe',
                        backgroundColor: 'rgba(15, 98, 254, 0.12)',
                        fill: true,
                        tension: 0.3
                    }]
                },
                options: {
                    plugins: {legend: {display: false}},
                    scales: {
                        y: {
                            ticks: {
                                callback: function (value) {
                                    return Number(value).toLocaleString('vi-VN');
                                }
                            }
                        }
                    }
                }
            });
        }

        var stageCtx = document.getElementById('dealStageChart');
        if (stageCtx) {
            new Chart(stageCtx, {
                type: 'doughnut',
                data: {
                    labels: stageLabels,
                    datasets: [{
                        data: stageData,
                        backgroundColor: ['#0f62fe', '#42be65', '#f1c21b', '#fa4d56', '#8a3ffc', '#007d79']
                    }]
                },
                options: {plugins: {legend: {position: 'bottom'}}}
            });
        }
    })();
</script>
