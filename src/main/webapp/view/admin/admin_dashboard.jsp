<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page isELIgnored="false" %>
<%
    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    Integer newLeads = (Integer) request.getAttribute("newLeads");
    Integer openOpportunities = (Integer) request.getAttribute("openOpportunities");
    String revenue = (String) request.getAttribute("revenue");

    if (totalCustomers == null) totalCustomers = 0;
    if (newLeads == null) newLeads = 0;
    if (openOpportunities == null) openOpportunities = 0;
    if (revenue == null) revenue = "$0";
%>

<div class="content">
    <div class="page-header">
        <div class="page-title">
            <h4>Dashboard</h4>
            <h6>Welcome back, <c:out value="${sessionScope.user.fullName}" default="Admin"/>.</h6>
        </div>
        <div class="page-btn">
            <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-added">
                <i class="fas fa-user-plus me-1"></i> Add Customer
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-3 col-sm-6">
            <div class="card dash-widget">
                <div class="dash-widgetcontent">
                    <span class="dash-widgeticon bg-primary">
                        <i class="fas fa-users"></i>
                    </span>
                    <div class="dash-widgetinfo">
                        <h6>Total Customers</h6>
                        <h3><%= totalCustomers %></h3>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-sm-6">
            <div class="card dash-widget">
                <div class="dash-widgetcontent">
                    <span class="dash-widgeticon bg-success">
                        <i class="fas fa-arrow-up"></i>
                    </span>
                    <div class="dash-widgetinfo">
                        <h6>New Leads</h6>
                        <h3><%= newLeads %></h3>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-sm-6">
            <div class="card dash-widget">
                <div class="dash-widgetcontent">
                    <span class="dash-widgeticon bg-warning">
                        <i class="fas fa-lightbulb"></i>
                    </span>
                    <div class="dash-widgetinfo">
                        <h6>Open Opportunities</h6>
                        <h3><%= openOpportunities %></h3>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-sm-6">
            <div class="card dash-widget">
                <div class="dash-widgetcontent">
                    <span class="dash-widgeticon bg-info">
                        <i class="fas fa-dollar-sign"></i>
                    </span>
                    <div class="dash-widgetinfo">
                        <h6>Revenue (30d)</h6>
                        <h3><%= revenue %></h3>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-8 d-flex">
            <div class="card flex-fill">
                <div class="card-header">
                    <h5 class="card-title">Sales performance</h5>
                    <p class="card-text text-muted">Last 7 days</p>
                </div>
                <div class="card-body p-3">
                    <canvas id="salesChart" style="height: 290px;"></canvas>
                </div>
            </div>
        </div>

        <div class="col-xl-4 d-flex">
            <div class="card flex-fill">
                <div class="card-header">
                    <h5 class="card-title">Recent activity</h5>
                </div>
                <div class="card-body p-3">
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <div class="fw-bold">Sarah added a new lead</div>
                                <small class="text-muted">2 minutes ago</small>
                            </div>
                            <span class="badge bg-success rounded-pill">Lead</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <div class="fw-bold">Campaign Spring Sale was sent</div>
                                <small class="text-muted">30 minutes ago</small>
                            </div>
                            <span class="badge bg-warning rounded-pill">Campaign</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <div class="fw-bold">New customer account created</div>
                                <small class="text-muted">1 hour ago</small>
                            </div>
                            <span class="badge bg-primary rounded-pill">Customer</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chart.js (loaded here to avoid layout pull-in) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    (function () {
        const ctx = document.getElementById('salesChart');
        if (!ctx) return;

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Revenue',
                    data: [4200, 5300, 4800, 6100, 5800, 6700, 7200],
                    borderWidth: 3,
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13, 110, 253, 0.15)',
                    tension: 0.35,
                    pointRadius: 0,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { mode: 'index', intersect: false },
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#6c757d' },
                    },
                    y: {
                        grid: { color: 'rgba(0,0,0,0.06)' },
                        ticks: { color: '#6c757d' },
                    },
                },
            },
        });
    })();
</script>
