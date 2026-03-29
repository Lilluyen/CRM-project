<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- ═══════════════════════════════════════════════════════════════════════════
     adminDashboard.jsp – MAIN CONTENT ONLY
     Header và Sidebar được include từ layout chung bên ngoài file này.
     ═══════════════════════════════════════════════════════════════════════════ --%>

<!-- ════════════════════════════════════════════════════════════════════════
     DASHBOARD STYLES
     ════════════════════════════════════════════════════════════════════════ -->
<style>
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700&family=Sora:wght@400;600;700&display=swap');

    :root {
        --primary:      #2563eb;
        --primary-soft: #eff6ff;
        --primary-mid:  #bfdbfe;
        --success:      #10b981;
        --success-soft: #ecfdf5;
        --warning:      #f59e0b;
        --warning-soft: #fffbeb;
        --danger:       #ef4444;
        --danger-soft:  #fef2f2;
        --purple:       #8b5cf6;
        --purple-soft:  #f5f3ff;
        --indigo:       #6366f1;
        --cyan:         #06b6d4;
        --cyan-soft:    #ecfeff;
        --orange:       #f97316;
        --orange-soft:  #fff7ed;
        --text-main:    #111827;
        --text-muted:   #6b7280;
        --text-light:   #9ca3af;
        --border:       #e5e7eb;
        --bg-page:      #f8fafc;
        --bg-card:      #ffffff;
        --radius-sm:    8px;
        --radius-md:    12px;
        --radius-lg:    16px;
        --shadow-sm:    0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
        --shadow-md:    0 4px 16px rgba(0,0,0,.07), 0 1px 4px rgba(0,0,0,.04);
        --shadow-lg:    0 8px 32px rgba(0,0,0,.09), 0 2px 8px rgba(0,0,0,.05);
        --font-body:    'DM Sans', system-ui, sans-serif;
        --font-head:    'Sora', system-ui, sans-serif;
    }

    /* ── Base ── */
    #dashboardMain {
        font-family: var(--font-body);
        background: var(--bg-page);
        min-height: 100vh;
        padding: 28px 28px 48px;
        color: var(--text-main);
    }

    /* ── Page Header ── */
    .dash-page-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 28px;
        flex-wrap: wrap;
        gap: 12px;
    }
    .dash-page-header h1 {
        font-family: var(--font-head);
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
        letter-spacing: -0.02em;
    }
    .dash-page-header p {
        font-size: .875rem;
        color: var(--text-muted);
        margin: 2px 0 0;
    }
    .dash-date-badge {
        display: flex;
        align-items: center;
        gap: 8px;
        background: var(--bg-card);
        border: 1px solid var(--border);
        border-radius: var(--radius-sm);
        padding: 8px 14px;
        font-size: .813rem;
        font-weight: 500;
        color: var(--text-muted);
        box-shadow: var(--shadow-sm);
    }
    .dash-date-badge i {
        color: var(--primary);
    }

    /* ── Stat Cards ── */
    .stat-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 28px;
    }
    @media (max-width: 1200px) {
        .stat-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    @media (max-width: 640px)  {
        .stat-grid {
            grid-template-columns: 1fr;
        }
    }

    .stat-card {
        background: var(--bg-card);
        border-radius: var(--radius-md);
        padding: 20px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border);
        display: flex;
        align-items: center;
        gap: 16px;
        transition: box-shadow .2s, transform .2s;
        position: relative;
        overflow: hidden;
    }
    .stat-card::after {
        content: '';
        position: absolute;
        top: 0;
        right: 0;
        width: 80px;
        height: 80px;
        border-radius: 50%;
        opacity: .06;
        transform: translate(20px, -20px);
    }
    .stat-card:hover {
        box-shadow: var(--shadow-md);
        transform: translateY(-2px);
    }
    .stat-icon {
        width: 52px;
        height: 52px;
        border-radius: var(--radius-sm);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        flex-shrink: 0;
    }
    .stat-body {
        flex: 1;
        min-width: 0;
    }
    .stat-value {
        font-family: var(--font-head);
        font-size: 1.625rem;
        font-weight: 700;
        line-height: 1.1;
        letter-spacing: -0.03em;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .stat-label {
        font-size: .75rem;
        font-weight: 500;
        color: var(--text-muted);
        margin-top: 4px;
        text-transform: uppercase;
        letter-spacing: .05em;
    }
    .stat-trend {
        font-size: .75rem;
        font-weight: 600;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 3px;
    }

    /* colour themes */
    .sc-blue   .stat-icon {
        background: var(--primary-soft);
        color: var(--primary);
    }
    .sc-blue   .stat-value {
        color: var(--primary);
    }
    .sc-blue::after {
        background: var(--primary);
    }

    .sc-green  .stat-icon {
        background: var(--success-soft);
        color: var(--success);
    }
    .sc-green  .stat-value {
        color: var(--success);
    }
    .sc-green::after {
        background: var(--success);
    }

    .sc-yellow .stat-icon {
        background: var(--warning-soft);
        color: var(--warning);
    }
    .sc-yellow .stat-value {
        color: var(--warning);
    }
    .sc-yellow::after {
        background: var(--warning);
    }

    .sc-red    .stat-icon {
        background: var(--danger-soft);
        color: var(--danger);
    }
    .sc-red    .stat-value {
        color: var(--danger);
    }
    .sc-red::after {
        background: var(--danger);
    }

    .sc-purple .stat-icon {
        background: var(--purple-soft);
        color: var(--purple);
    }
    .sc-purple .stat-value {
        color: var(--purple);
    }
    .sc-purple::after {
        background: var(--purple);
    }

    .sc-indigo .stat-icon {
        background: #eef2ff;
        color: var(--indigo);
    }
    .sc-indigo .stat-value {
        color: var(--indigo);
    }
    .sc-indigo::after {
        background: var(--indigo);
    }

    .sc-cyan   .stat-icon {
        background: var(--cyan-soft);
        color: var(--cyan);
    }
    .sc-cyan   .stat-value {
        color: var(--cyan);
    }
    .sc-cyan::after {
        background: var(--cyan);
    }

    .sc-orange .stat-icon {
        background: var(--orange-soft);
        color: var(--orange);
    }
    .sc-orange .stat-value {
        color: var(--orange);
    }
    .sc-orange::after {
        background: var(--orange);
    }

    /* ── Section heading ── */
    .section-title {
        font-family: var(--font-head);
        font-size: 1rem;
        font-weight: 700;
        color: var(--text-main);
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .section-title i {
        color: var(--primary);
        font-size: .9rem;
    }

    /* ── Chart cards ── */
    .chart-card {
        background: var(--bg-card);
        border-radius: var(--radius-md);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        padding: 20px;
    }
    .chart-card-title {
        font-family: var(--font-head);
        font-size: .875rem;
        font-weight: 600;
        color: var(--text-main);
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .chart-card-title .dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        display: inline-block;
    }
    .chart-wrap {
        position: relative;
    }

    /* ── Analytics layout ── */
    .analytics-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 16px;
    }
    .analytics-row-3 {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 28px;
    }
    @media (max-width: 900px) {
        .analytics-row, .analytics-row-3 {
            grid-template-columns: 1fr;
        }
    }

    /* ── Table card ── */
    .table-card {
        background: var(--bg-card);
        border-radius: var(--radius-md);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        overflow: hidden;
        margin-bottom: 16px;
    }
    .table-card-header {
        padding: 16px 20px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .table-card-header h3 {
        font-family: var(--font-head);
        font-size: .9rem;
        font-weight: 700;
        margin: 0;
        color: var(--text-main);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .table-card-header h3 i {
        color: var(--primary);
    }
    .btn-view-all {
        font-size: .75rem;
        font-weight: 600;
        color: var(--primary);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 4px;
        transition: gap .15s;
    }
    .btn-view-all:hover {
        gap: 6px;
        color: var(--primary);
    }

    .crm-table {
        width: 100%;
        border-collapse: collapse;
        font-size: .8125rem;
    }
    .crm-table thead tr th {
        background: #f9fafb;
        color: var(--text-muted);
        font-weight: 600;
        font-size: .7rem;
        text-transform: uppercase;
        letter-spacing: .07em;
        padding: 10px 16px;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
        text-align: left;
    }
    .crm-table tbody tr td {
        padding: 11px 16px;
        border-bottom: 1px solid #f3f4f6;
        vertical-align: middle;
        color: var(--text-main);
    }
    .crm-table tbody tr:last-child td {
        border-bottom: none;
    }
    .crm-table tbody tr:hover td {
        background: #fafafa;
    }

    /* avatar + name cell */
    .cell-name {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .avatar-xs {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: .75rem;
        font-weight: 700;
        flex-shrink: 0;
        text-transform: uppercase;
    }
    .cell-sub {
        font-size: .72rem;
        color: var(--text-muted);
        margin-top: 1px;
    }

    /* badges */
    .badge-crm {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 10px;
        border-radius: 999px;
        font-size: .7rem;
        font-weight: 600;
        white-space: nowrap;
    }
    .badge-crm.status-active,   .badge-crm.status-ACTIVE   {
        background:#dcfce7;
        color:#15803d;
    }
    .badge-crm.status-inactive, .badge-crm.status-INACTIVE {
        background:#f3f4f6;
        color:#6b7280;
    }
    .badge-crm.status-pending,  .badge-crm.status-Pending  {
        background:#fef3c7;
        color:#92400e;
    }
    .badge-crm.status-done,     .badge-crm.status-Done     {
        background:#dcfce7;
        color:#15803d;
    }
    .badge-crm.status-progress, .badge-crm.status-in-progress,
    .badge-crm.status-inprogress {
        background:#dbeafe;
        color:#1d4ed8;
    }
    .badge-crm.status-overdue   {
        background:#fee2e2;
        color:#b91c1c;
    }
    .badge-crm.status-cancelled {
        background:#f3f4f6;
        color:#6b7280;
    }

    .stage-badge {
        display: inline-block;
        padding: 2px 9px;
        border-radius: 999px;
        font-size: .68rem;
        font-weight: 600;
    }
    .stage-Prospecting {
        background:#eff6ff;
        color:#1d4ed8;
    }
    .stage-Qualified   {
        background:#f5f3ff;
        color:#6d28d9;
    }
    .stage-Proposal    {
        background:#ecfeff;
        color:#0e7490;
    }
    .stage-Negotiation {
        background:#fffbeb;
        color:#b45309;
    }
    .stage-ClosedWon, .stage-Closed-Won {
        background:#dcfce7;
        color:#15803d;
    }
    .stage-ClosedLost, .stage-Closed-Lost {
        background:#fee2e2;
        color:#b91c1c;
    }

    .priority-High   {
        color: var(--danger);
        font-weight: 600;
    }
    .priority-Medium {
        color: var(--warning);
        font-weight: 600;
    }
    .priority-Low    {
        color: var(--success);
        font-weight: 600;
    }

    /* ── Main layout: content + right panel ── */
    .dash-layout {
        display: grid;
        grid-template-columns: 1fr 320px;
        gap: 20px;
        align-items: start;
    }
    @media (max-width: 1100px) {
        .dash-layout {
            grid-template-columns: 1fr;
        }
    }

    /* ── Follow-up Panel ── */
    .followup-panel {
        position: sticky;
        top: 20px;
    }
    .followup-card {
        background: var(--bg-card);
        border-radius: var(--radius-md);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        overflow: hidden;
        margin-bottom: 16px;
    }
    .followup-card-header {
        padding: 14px 16px;
        border-bottom: 1px solid var(--border);
        font-family: var(--font-head);
        font-size: .85rem;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .followup-item {
        padding: 11px 16px;
        border-bottom: 1px solid #f3f4f6;
        display: flex;
        flex-direction: column;
        gap: 3px;
        transition: background .15s;
    }
    .followup-item:last-child {
        border-bottom: none;
    }
    .followup-item:hover {
        background: #fafafa;
    }
    .followup-item-name {
        font-size: .8125rem;
        font-weight: 600;
        color: var(--text-main);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .followup-item-meta {
        font-size: .72rem;
        color: var(--text-muted);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .followup-empty {
        padding: 20px 16px;
        text-align: center;
        color: var(--text-light);
        font-size: .8rem;
    }

    .header-icon-blue   {
        background: var(--primary-soft);
        color: var(--primary);
    }
    .header-icon-red    {
        background: var(--danger-soft);
        color: var(--danger);
    }
    .header-icon-yellow {
        background: var(--warning-soft);
        color: var(--warning);
    }
    .header-icon-green  {
        background: var(--success-soft);
        color: var(--success);
    }

    .followup-icon-wrap {
        width: 26px;
        height: 26px;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: .7rem;
        flex-shrink: 0;
    }

    /* ── Scrollbar ── */
    .followup-scroll {
        max-height: 280px;
        overflow-y: auto;
    }
    .followup-scroll::-webkit-scrollbar {
        width: 4px;
    }
    .followup-scroll::-webkit-scrollbar-track {
        background: transparent;
    }
    .followup-scroll::-webkit-scrollbar-thumb {
        background: #d1d5db;
        border-radius: 2px;
    }

    /* ── Utilities ── */
    .text-money {
        font-family: var(--font-head);
        font-weight: 600;
    }
    .text-xs    {
        font-size: .72rem;
    }
    .fw-600     {
        font-weight: 600;
    }
    .gap-8      {
        gap: 8px;
    }
    .d-flex     {
        display: flex;
    }
    .align-items-center {
        align-items: center;
    }

    /* loading skeleton pulse */
    @keyframes pulse {
        0%,100%{
            opacity:1
        }
        50%{
            opacity:.5
        }
    }

    /* ── Responsive table wrapper ── */
    .table-responsive {
        overflow-x: auto;
    }
</style>

<!-- ════════════════════════════════════════════════════════════════════════
     MAIN CONTENT
     ════════════════════════════════════════════════════════════════════════ -->
<div id="dashboardMain">

    <!-- Page Header -->
    <div class="dash-page-header">
        <div>
            <h1>Dashboard</h1>
            <p>Overview of today's activities</p>
        </div>
        <div class="dash-date-badge">
            <i class="bi bi-calendar3"></i>
            <span id="dashToday"></span>
        </div>
    </div>

    <!-- ══ STAT CARDS ════════════════════════════════════════════════════════ -->
    <div class="stat-grid">

        <!-- Total Customers -->
        <div class="stat-card sc-blue">
            <div class="stat-icon"><i class="bi bi-people-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">${totalCustomers}</div>
                <div class="stat-label">Total customers</div>
            </div>
        </div>

        <!-- New Customers This Month -->
        <div class="stat-card sc-green">
            <div class="stat-icon"><i class="bi bi-person-plus-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">+${newCustomersThisMonth}</div>
                <div class="stat-label">New customers this month</div>
            </div>
        </div>

        <!-- Leads Pending -->
        <div class="stat-card sc-yellow">
            <div class="stat-icon"><i class="bi bi-funnel-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">${leadsPending}</div>
                <div class="stat-label">Lead pending</div>
            </div>
        </div>

        <!-- Deals In Progress -->
        <div class="stat-card sc-indigo">
            <div class="stat-icon"><i class="bi bi-briefcase-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">${dealsInProgress}</div>
                <div class="stat-label">The deal is in progress</div>
            </div>
        </div>

        <!-- Tasks Pending -->
        <div class="stat-card sc-purple">
            <div class="stat-icon"><i class="bi bi-check2-square"></i></div>
            <div class="stat-body">
                <div class="stat-value">${tasksPending}</div>
                <div class="stat-label">Task Pending</div>
            </div>
        </div>

        <!-- Follow-up Today -->
        <div class="stat-card sc-orange">
            <div class="stat-icon"><i class="bi bi-telephone-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">${followUpToday}</div>
                <div class="stat-label">Follow-up Today</div>
            </div>
        </div>

        <!-- Closed Deals -->
        <div class="stat-card sc-cyan">
            <div class="stat-icon"><i class="bi bi-trophy-fill"></i></div>
            <div class="stat-body">
                <div class="stat-value">${closedDeals}</div>
                <div class="stat-label">Closed Deals</div>
            </div>
        </div>

        <!-- Revenue This Month -->
        <div class="stat-card sc-red">
            <div class="stat-icon"><i class="bi bi-currency-dollar"></i></div>
            <div class="stat-body">
                <div class="stat-value" style="font-size:1.2rem;">${revenueThisMonthFormatted}</div>
                <div class="stat-label">Revenue This Month</div>
            </div>
        </div>

    </div>
    <%-- end stat-grid --%>

    <!-- ══ ANALYTICS CHARTS ══════════════════════════════════════════════════ -->
    <div class="section-title"><i class="bi bi-graph-up-arrow"></i> Phân tích CRM</div>

    <!-- Row 1: Customer Growth + Sales Funnel -->
    <div class="analytics-row">
        <div class="chart-card">
            <div class="chart-card-title">
                <span class="dot" style="background:var(--primary)"></span>
                Customer growth (6 months)
            </div>
            <div class="chart-wrap"><canvas id="chartCustomerGrowth" height="220"></canvas></div>
        </div>
        <div class="chart-card">
            <div class="chart-card-title">
                <span class="dot" style="background:var(--purple)"></span>
                Sales Funnel
            </div>
            <div class="chart-wrap"><canvas id="chartSalesFunnel" height="220"></canvas></div>
        </div>
    </div>

    <!-- Row 2: Task Status + Revenue -->
    <div class="analytics-row-3">
        <div class="chart-card">
            <div class="chart-card-title">
                <span class="dot" style="background:var(--warning)"></span>
                Task Status
            </div>
            <div class="chart-wrap" style="max-width:320px;margin:0 auto;">
                <canvas id="chartTaskStatus" height="220"></canvas>
            </div>
        </div>
        <div class="chart-card">
            <div class="chart-card-title">
                <span class="dot" style="background:var(--success)"></span>
                Actual revenue (6 months)
            </div>
            <div class="chart-wrap"><canvas id="chartRevenue" height="220"></canvas></div>
        </div>
    </div>

    <!-- ══ TABLES + FOLLOW-UP PANEL ═════════════════════════════════════════ -->
    <div class="dash-layout">

        <!-- LEFT: Tables -->
        <div>

            <!-- Table 1: Recent Customers -->
            <div class="table-card">
                <div class="table-card-header">
                    <h3><i class="bi bi-people"></i> Newest customers</h3>
                    <a href="${pageContext.request.contextPath}/customers" class="btn-view-all">
                        View All Customers <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="crm-table">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Phone Number</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th>Create Day</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty recentCustomers}">
                                    <tr><td colspan="5" style="text-align:center;color:var(--text-light);padding:24px;">No data available</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${recentCustomers}">
                                        <tr>
                                            <td>
                                                <div class="cell-name">
                                                    <div class="avatar-xs" style="background:var(--primary-soft);color:var(--primary);">
                                                        ${fn:substring(c.name,0,1)}
                                                    </div>
                                                    <div>
                                                        <div class="fw-600">${c.name}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>${c.phone}</td>
                                            <td style="color:var(--text-muted);font-size:.75rem;">${c.email}</td>
                                            <td>
                                                <span class="badge-crm status-${c.status}">
                                                    <c:choose>
                                                        <c:when test="${c.status eq 'ACTIVE'}">Active</c:when>
                                                        <c:when test="${c.status eq 'INACTIVE'}">Inactive</c:when>
                                                        <c:otherwise>${c.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td style="color:var(--text-muted);font-size:.75rem;">
                                                <${c.createdAt != null ? c.createdAt.toLocalDate() : ''}
                                                <%-- LocalDateTime fallback --%>
                                                ${c.createdAt != null ? c.createdAt.toLocalDate() : ''}
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Table 2: Recent Tasks -->
            <div class="table-card">
                <div class="table-card-header">
                    <h3><i class="bi bi-check2-all"></i> Recent work</h3>
                    <a href="${pageContext.request.contextPath}/tasks/list" class="btn-view-all">
                        View All Tasks <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="crm-table">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Assign To</th>
                                <th>Relate To</th>
                                <th>Status</th>
                                <th>Due Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty recentTasks}">
                                    <tr><td colspan="5" style="text-align:center;color:var(--text-light);padding:24px;">No data available</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="t" items="${recentTasks}">
                                        <tr>
                                            <td>
                                                <div class="fw-600" style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                    ${t.title}
                                                </div>
                                                <c:if test="${not empty t.priority}">
                                                    <div class="text-xs priority-${t.priority}">${t.priority}</div>
                                                </c:if>
                                            </td>
                                            <td style="font-size:.8rem;">${t.assigneeName != null ? t.assigneeName : '—'}</td>
                                            <td style="font-size:.75rem;color:var(--text-muted);">${t.relatedName != null ? t.relatedName : '—'}</td>
                                            <td>
                                                <span class="badge-crm status-${t.status}">
                                                    <c:choose>
                                                        <c:when test="${t.status eq 'Pending'}">In Progress</c:when>
                                                        <c:when test="${t.status eq 'In Progress'}">In Progress</c:when>
                                                        <c:when test="${t.status eq 'Done'}">Done</c:when>
                                                        <c:when test="${t.status eq 'Cancelled'}">Cancelled</c:when>
                                                        <c:when test="${t.status eq 'Overdue'}">Overdue</c:when>
                                                        <c:otherwise>${t.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td style="font-size:.75rem;color:var(--text-muted);">
                                                ${t.dueDate != null ? t.dueDate.toLocalDate() : '—'}
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Table 3: Recent Deals -->
            <div class="table-card">
                <div class="table-card-header">
                    <h3><i class="bi bi-briefcase"></i> Recent Deals</h3>
                    <a href="${pageContext.request.contextPath}/deal/list" class="btn-view-all">
                        View All Deals <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="crm-table">
                        <thead>
                            <tr>
                                <th>Lead</th>
                                <th>Deal Name</th>
                                <th>Expected Value</th>
                                <th>Stage</th>
                                <th>Create At</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty recentDeals}">
                                    <tr><td colspan="5" style="text-align:center;color:var(--text-light);padding:24px;">No data avaiable</td></tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="d" items="${recentDeals}">
                                        <tr>
                                            <td style="font-size:.8rem;">${d.partyName != null ? d.partyName : '—'}</td>
                                            <td>
                                                <div class="fw-600" style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                    ${d.dealName}
                                                </div>
                                                <div class="text-xs" style="color:var(--text-light);">${d.probability}% probability</div>
                                            </td>
                                            <td class="text-money">
                                                <c:choose>
                                                    <c:when test="${d.actualValue != null && d.actualValue > 0}">
                                                        <fmt:formatNumber value="${d.actualValue}" type="number" maxFractionDigits="0"/> $
                                                    </c:when>
                                                    <c:when test="${d.expectedValue != null}">
                                                        ~<fmt:formatNumber value="${d.expectedValue}" type="number" maxFractionDigits="0"/> $
                                                    </c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:set var="stageKey" value="${fn:replace(d.stage,' ','')}"/>
                                                <span class="stage-badge stage-${stageKey}">${d.stage}</span>
                                            </td>
                                            <td style="font-size:.75rem;color:var(--text-muted);">
                                                ${d.createdAt != null ? d.createdAt.toLocalDate() : '—'}
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
        <%-- end left column --%>

        <!-- RIGHT: Follow-up Panel -->
        <div class="followup-panel">

            <!-- Tasks Due Today -->
            <div class="followup-card">
                <div class="followup-card-header header-icon-blue">
                    <span style="background:var(--primary-soft);color:var(--primary);padding:4px 8px;border-radius:6px;font-size:.75rem;">
                        <i class="bi bi-clock"></i>
                    </span>
                    Follow-up Today
                    <span class="ms-auto badge rounded-pill" style="background:var(--primary);color:#fff;font-size:.7rem;">
                        ${followUpToday}
                    </span>
                </div>
                <div class="followup-scroll">
                    <c:choose>
                        <c:when test="${empty tasksDueToday}">
                            <div class="followup-empty"><i class="bi bi-check-circle" style="color:var(--success);font-size:1.5rem;display:block;margin-bottom:6px;"></i>No follow-up today!</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${tasksDueToday}">
                                <div class="followup-item">
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="followup-icon-wrap header-icon-blue"><i class="bi bi-check2-square"></i></div>
                                        <div class="followup-item-name">${item.name}</div>
                                    </div>
                                    <div class="followup-item-meta">
                                        <c:if test="${not empty item.relatedName}"><i class="bi bi-person"></i>${item.relatedName}</c:if>
                                        <span class="badge-crm status-${item.status}" style="font-size:.65rem;">${item.status}</span>
                                        <c:if test="${not empty item.priority}">
                                            <span class="priority-${item.priority}" style="font-size:.7rem;">${item.priority}</span>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Deals Needing Follow-up -->
            <div class="followup-card">
                <div class="followup-card-header header-icon-yellow">
                    <span style="background:var(--warning-soft);color:var(--warning);padding:4px 8px;border-radius:6px;font-size:.75rem;">
                        <i class="bi bi-briefcase"></i>
                    </span>
                    Deal needs follow-up
                </div>
                <div class="followup-scroll">
                    <c:choose>
                        <c:when test="${empty dealsNeedFollowUp}">
                            <div class="followup-empty"><i class="bi bi-emoji-smile" style="color:var(--success);font-size:1.5rem;display:block;margin-bottom:6px;"></i>Tất cả deal đang cập nhật!</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${dealsNeedFollowUp}">
                                <div class="followup-item">
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="followup-icon-wrap header-icon-yellow"><i class="bi bi-briefcase"></i></div>
                                        <div class="followup-item-name">${item.name}</div>
                                    </div>
                                    <div class="followup-item-meta">
                                        <c:if test="${not empty item.relatedName}"><i class="bi bi-person"></i>${item.relatedName}</c:if>
                                        <c:if test="${item.due != null}">
                                            <i class="bi bi-calendar-x"></i>${item.due.toLocalDate()}
                                        </c:if>
                                        <span class="stage-badge stage-${fn:replace(item.status,' ','')}" style="font-size:.65rem;">${item.status}</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Overdue Tasks -->
            <div class="followup-card">
                <div class="followup-card-header header-icon-red">
                    <span style="background:var(--danger-soft);color:var(--danger);padding:4px 8px;border-radius:6px;font-size:.75rem;">
                        <i class="bi bi-exclamation-triangle"></i>
                    </span>
                    Overdue Tasks
                    <c:if test="${not empty overdueTasks}">
                        <span class="ms-auto badge rounded-pill" style="background:var(--danger);color:#fff;font-size:.7rem;">
                            ${fn:length(overdueTasks)}
                        </span>
                    </c:if>
                </div>
                <div class="followup-scroll">
                    <c:choose>
                        <c:when test="${empty overdueTasks}">
                            <div class="followup-empty"><i class="bi bi-shield-check" style="color:var(--success);font-size:1.5rem;display:block;margin-bottom:6px;"></i>No tasks are overdue!</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${overdueTasks}">
                                <div class="followup-item">
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="followup-icon-wrap header-icon-red"><i class="bi bi-exclamation-circle"></i></div>
                                        <div class="followup-item-name">${item.name}</div>
                                    </div>
                                    <div class="followup-item-meta">
                                        <c:if test="${not empty item.relatedName}"><i class="bi bi-person"></i>${item.relatedName}</c:if>
                                        <c:if test="${item.due != null}">
                                            <span style="color:var(--danger);font-weight:600;font-size:.7rem;">
                                                <i class="bi bi-calendar-x"></i> ${item.due.toLocalDate()}
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
        <%-- end followup-panel --%>

    </div>
    <%-- end dash-layout --%>

</div>
<%-- end dashboardMain --%>

<!-- ════════════════════════════════════════════════════════════════════════
     CHART.JS
     ════════════════════════════════════════════════════════════════════════ -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script>
    (function () {
        'use strict';

        // ── Ngày hôm nay ──────────────────────────────────────────────────────
        const el = document.getElementById('dashToday');
        if (el) {
            const now = new Date();
            el.textContent = now.toLocaleDateString('vi-VN', {
                weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric'
            });
        }

        // ── Global Chart.js defaults ──────────────────────────────────────────
        Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
        Chart.defaults.font.size = 11;
        Chart.defaults.color = '#9ca3af';

        // ── Data from server ──────────────────────────────────────────────────
        const customerGrowthLabels = ${customerGrowthLabels};
        const customerGrowthData = ${customerGrowthData};
        const funnelLabels = ${funnelLabels};
        const funnelData = ${funnelData};
        const taskStatusLabels = ${taskStatusLabels};
        const taskStatusData = ${taskStatusData};
        const revenueLabels = ${revenueChartLabels};
        const revenueData = ${revenueChartData};

        // ── Palette ──────────────────────────────────────────────────────────
        const palette = {
            blue: '#2563eb',
            green: '#10b981',
            yellow: '#f59e0b',
            red: '#ef4444',
            purple: '#8b5cf6',
            indigo: '#6366f1',
            cyan: '#06b6d4',
            orange: '#f97316',
            teal: '#14b8a6',
            pink: '#ec4899'
        };
        const funnelColors = [
            palette.blue, palette.indigo, palette.purple,
            palette.yellow, palette.green, palette.red
        ];
        const taskColors = [
            palette.yellow, palette.blue, palette.green,
            palette.red, palette.orange, palette.purple
        ];

        function alphaHex(hex, a) {

            // ép về string và loại bỏ tất cả ký tự rác
            hex = String(hex).trim().replace('#','');
            const r = parseInt(hex.substring(0, 2), 16);
            const g = parseInt(hex.substring(2, 4), 16);
            const b = parseInt(hex.substring(4, 6), 16);
            return `rgba(${r}, ${g}, ${b}, ${a})`;
        }

        // ── 1. Customer Growth Line Chart ────────────────────────────────────
        const ctxCG = document.getElementById('chartCustomerGrowth');
        if (ctxCG) {
            new Chart(ctxCG, {
                type: 'line',
                data: {
                    labels: customerGrowthLabels,
                    datasets: [{
                            label: 'Khách hàng mới',
                            data: customerGrowthData,
                            borderColor: palette.blue,
                            backgroundColor: alphaHex(palette.blue, 0.08),
                            borderWidth: 2.5,
                            pointBackgroundColor: palette.blue,
                            pointRadius: 4,
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {mode: 'index', intersect: false},
                    plugins: {
                        legend: {display: false},
                        tooltip: {
                            backgroundColor: '#1f2937',
                            titleColor: '#f9fafb',
                            bodyColor: '#d1d5db',
                            padding: 10,
                            cornerRadius: 8
                        }
                    },
                    scales: {
                        x: {grid: {display: false}, border: {display: false}},
                        y: {
                            grid: {color: '#f3f4f6'},
                            border: {display: false},
                            ticks: {precision: 0}
                        }
                    }
                }
            });
        }

        // ── 2. Sales Funnel Horizontal Bar ───────────────────────────────────
        const ctxFunnel = document.getElementById('chartSalesFunnel');
        if (ctxFunnel) {
            new Chart(ctxFunnel, {
                type: 'bar',
                data: {
                    labels: funnelLabels,
                    datasets: [{
                            label: 'Số deal',
                            data: funnelData,
                            backgroundColor: funnelColors.map(c => alphaHex(c, 0.85)),
                            borderColor: funnelColors,
                            borderWidth: 1.5,
                            borderRadius: 6,
                            borderSkipped: false
                        }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {display: false},
                        tooltip: {
                            backgroundColor: '#1f2937',
                            titleColor: '#f9fafb',
                            bodyColor: '#d1d5db',
                            padding: 10,
                            cornerRadius: 8
                        }
                    },
                    scales: {
                        x: {
                            grid: {color: '#f3f4f6'},
                            border: {display: false},
                            ticks: {precision: 0}
                        },
                        y: {grid: {display: false}, border: {display: false}}
                    }
                }
            });
        }

        // ── 3. Task Status Doughnut ───────────────────────────────────────────
        const ctxTask = document.getElementById('chartTaskStatus');
        if (ctxTask) {
            console.log(alphaHex('#f59e0b', 0.85));
            new Chart(ctxTask, {
                type: 'doughnut',
                data: {
                    labels: taskStatusLabels,
                    datasets: [{
                            data: taskStatusData,
                            backgroundColor: taskColors,
                            borderColor: '#fff',
                            borderWidth: 3,
                            hoverOffset: 6
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '65%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {boxWidth: 10, padding: 14, font: {size: 11}}
                        },
                        tooltip: {
                            backgroundColor: '#1f2937',
                            titleColor: '#f9fafb',
                            bodyColor: '#d1d5db',
                            padding: 10,
                            cornerRadius: 8
                        }
                    }
                }
            });
        }

        // ── 4. Revenue Bar Chart ──────────────────────────────────────────────
        const ctxRev = document.getElementById('chartRevenue');
        if (ctxRev) {
            new Chart(ctxRev, {
                type: 'bar',
                data: {
                    labels: revenueLabels,
                    datasets: [{
                            label: 'Doanh thu (đ)',
                            data: revenueData,
                            backgroundColor: alphaHex(palette.green, 0.75),
                            borderColor: palette.green,
                            borderWidth: 1.5,
                            borderRadius: 6,
                            borderSkipped: false
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {mode: 'index', intersect: false},
                    plugins: {
                        legend: {display: false},
                        tooltip: {
                            backgroundColor: '#1f2937',
                            titleColor: '#f9fafb',
                            bodyColor: '#d1d5db',
                            padding: 10,
                            cornerRadius: 8,
                            callbacks: {
                                label: ctx => ' ' + Number(ctx.raw).toLocaleString('vi-VN') + ' đ'
                            }
                        }
                    },
                    scales: {
                        x: {grid: {display: false}, border: {display: false}},
                        y: {
                            grid: {color: '#f3f4f6'},
                            border: {display: false},
                            ticks: {
                                callback: v => {
                                    if (v >= 1_000_000_000)
                                        return (v / 1_000_000_000).toFixed(1) + 'B';
                                    if (v >= 1_000_000)
                                        return (v / 1_000_000).toFixed(0) + 'M';
                                    return v;
                                }
                            }
                        }
                    }
                }
            });
        }

    })();
</script>
