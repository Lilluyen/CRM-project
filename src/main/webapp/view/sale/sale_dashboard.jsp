<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page isELIgnored="false" %>

<%-- JSTL function for status/CSS helpers --%>
<%!
    public static String stageClass(String stage) {
        if (stage == null) return "sd-stage-default";
        switch (stage.trim()) {
            case "Prospecting":  return "sd-stage-prospecting";
            case "Qualified":    return "sd-stage-qualified";
            case "Proposal":     return "sd-stage-proposal";
            case "Negotiation":  return "sd-stage-negotiation";
            case "Closed Won":   return "sd-stage-closed-won";
            case "Closed Lost":  return "sd-stage-closed-lost";
            default:             return "sd-stage-default";
        }
    }

    public static String taskStatusClass(String status) {
        if (status == null) return "sd-status-pending";
        switch (status.trim()) {
            case "Pending":      return "sd-status-pending";
            case "In Progress":  return "sd-status-in-progress";
            case "Done":         return "sd-status-done";
            case "Overdue":      return "sd-status-overdue";
            case "Cancelled":    return "sd-status-cancelled";
            default:             return "sd-status-pending";
        }
    }

    public static String priorityClass(String priority) {
        if (priority == null) return "sd-priority-medium";
        switch (priority.trim()) {
            case "High":   return "sd-priority-high";
            case "Medium": return "sd-priority-medium";
            case "Low":    return "sd-priority-low";
            default:       return "sd-priority-medium";
        }
    }

    public static String activityIconClass(String type) {
        if (type == null) return "sd-activity-icon note";
        switch (type.trim().toLowerCase()) {
            case "call":    return "sd-activity-icon call";
            case "email":   return "sd-activity-icon email";
            case "meeting": return "sd-activity-icon meeting";
            case "note":    return "sd-activity-icon note";
            case "task":    return "sd-activity-icon task";
            default:        return "sd-activity-icon update";
        }
    }

    public static String pipelineBarClass(String status) {
        if (status == null) return "sd-pipeline-bar default";
        switch (status.trim().toLowerCase()) {
            case "new lead":  return "sd-pipeline-bar new-lead";
            case "contacted": return "sd-pipeline-bar contacted";
            case "interested":return "sd-pipeline-bar interested";
            case "negotiation":return "sd-pipeline-bar negotiation";
            case "won":       return "sd-pipeline-bar won";
            case "lost":      return "sd-pipeline-bar lost";
            default:          return "sd-pipeline-bar default";
        }
    }
%>

<div class="sd-page">

    <%-- ── Header ─────────────────────────────────────────────────────────── --%>
    <div class="sd-header">
        <div class="sd-header-left">
            <h2>Sales Dashboard</h2>
            <p>Welcome back, <strong>${currentUser.fullName}</strong> &mdash; here&rsquo;s your performance for <strong>${kpis.month}</strong></p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/sale/deal/list" class="btn btn-sm btn-outline-primary">
                <i class="fas fa-chart-bar me-1"></i> View All Deals
            </a>
        </div>
    </div>

    <%-- ── 1. KPI Cards ─────────────────────────────────────────────────────── --%>
    <div class="sd-kpi-grid">

        <div class="sd-kpi-card revenue">
            <div class="sd-kpi-icon"><i class="fas fa-dollar-sign"></i></div>
            <div class="sd-kpi-label">Monthly Revenue</div>
            <div class="sd-kpi-value">
                <fmt:formatNumber value="${kpis.monthlyRevenue}" type="currency" currencySymbol="$" maxFractionDigits="0"/>
            </div>
            <div class="sd-kpi-sub">${kpis.month}</div>
        </div>

        <div class="sd-kpi-card deals">
            <div class="sd-kpi-icon"><i class="fas fa-handshake"></i></div>
            <div class="sd-kpi-label">Deals Closed</div>
            <div class="sd-kpi-value">${kpis.dealsClosed}</div>
            <div class="sd-kpi-sub">Won this month</div>
        </div>

        <div class="sd-kpi-card leads">
            <div class="sd-kpi-icon"><i class="fas fa-user-plus"></i></div>
            <div class="sd-kpi-label">New Leads</div>
            <div class="sd-kpi-value">${kpis.newLeads}</div>
            <div class="sd-kpi-sub">Assigned this month</div>
        </div>

        <div class="sd-kpi-card followup">
            <div class="sd-kpi-icon"><i class="fas fa-clock"></i></div>
            <div class="sd-kpi-label">Follow-ups Today</div>
            <div class="sd-kpi-value">${kpis.followUpsToday}</div>
            <div class="sd-kpi-sub">Due today</div>
        </div>

        <div class="sd-kpi-card conversion">
            <div class="sd-kpi-icon"><i class="fas fa-percentage"></i></div>
            <div class="sd-kpi-label">Conversion Rate</div>
            <div class="sd-kpi-value">
                <fmt:formatNumber value="${kpis.conversionRate}" maxFractionDigits="1"/>%
            </div>
            <div class="sd-kpi-sub">Won / (Won + Lost)</div>
        </div>

    </div>

    <%-- ── 2 & 3: Today's Tasks + Lead Pipeline (side-by-side) ─────────────── --%>
    <div class="sd-row">

        <%-- 2. Today&rsquo;s Follow-up Tasks --%>
        <div class="sd-panel">
            <div class="sd-panel-header">
                <h3 class="sd-panel-title">Today&rsquo;s Follow-ups</h3>
                <c:if test="${not empty kpis.todayTasks}">
                    <span class="sd-panel-badge">${kpis.todayTasks.size()} tasks</span>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty kpis.todayTasks}">
                    <div class="sd-empty">
                        <i class="fas fa-check-circle" style="font-size:1.5rem;display:block;margin-bottom:6px;color:#10b981"></i>
                        No follow-ups due today. Great work!
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="sd-table-wrap">
                        <table class="sd-table">
                            <thead>
                                <tr>
                                    <th>Time</th>
                                    <th>Customer / Lead</th>
                                    <th>Task</th>
                                    <th>Status</th>
                                    <th>Priority</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${kpis.todayTasks}" var="task">
                                    <tr>
                                        <td>
                                            <c:if test="${not empty task.dueDate}">
                                                <fmt:formatDate value="${task.dueDate}" pattern="HH:mm"/>
                                            </c:if>
                                        </td>
                                        <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                                            ${task.relatedName}
                                        </td>
                                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                                            title="${task.title}">${task.title}</td>
                                        <td>
                                            <span class="sd-status ${pageScope.taskStatusClass(task.status)}">
                                                    ${task.status}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="sd-priority ${pageScope.priorityClass(task.priority)}">
                                                    ${task.priority}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- 3. Lead Pipeline by Stage --%>
        <div class="sd-panel">
            <div class="sd-panel-header">
                <h3 class="sd-panel-title">My Leads Pipeline</h3>
            </div>

            <c:choose>
                <c:when test="${empty kpis.leadPipeline}">
                    <div class="sd-empty">No leads in your pipeline yet.</div>
                </c:when>
                <c:otherwise>
                    <c:set var="maxCount" value="0"/>
                    <c:forEach items="${kpis.leadPipeline}" var="lsc">
                        <c:if test="${lsc.count > maxCount}"><c:set var="maxCount" value="${lsc.count}"/></c:if>
                    </c:forEach>

                    <div class="sd-pipeline-chart">
                        <c:forEach items="${kpis.leadPipeline}" var="lsc">
                            <div class="sd-pipeline-row">
                                <div class="sd-pipeline-label">${lsc.status}</div>
                                <div class="sd-pipeline-bar-wrap">
                                    <div class="sd-pipeline-bar ${pageScope.pipelineBarClass(lsc.status)}"
                                         style="width: ${maxCount > 0 ? (lsc.count * 100 / maxCount) : 0}%">
                                            ${lsc.count}
                                    </div>
                                </div>
                                <div class="sd-pipeline-count">${lsc.count}</div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>

    <%-- ── 4: My Sales Pipeline ─────────────────────────────────────────────── --%>
    <div class="sd-row-full">
        <div class="sd-panel">
            <div class="sd-panel-header">
                <h3 class="sd-panel-title">My Sales Pipeline</h3>
                <c:if test="${not empty kpis.myDeals}">
                    <span class="sd-panel-badge">${kpis.myDeals.size()} open deals</span>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty kpis.myDeals}">
                    <div class="sd-empty">No open deals in your pipeline.</div>
                </c:when>
                <c:otherwise>
                    <div class="sd-table-wrap">
                        <table class="sd-table">
                            <thead>
                                <tr>
                                    <th>Deal Name</th>
                                    <th>Customer / Lead</th>
                                    <th>Deal Value</th>
                                    <th>Stage</th>
                                    <th>Expected Close</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${kpis.myDeals}" var="deal">
                                    <tr>
                                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                                            title="${deal.dealName}">
                                            <a href="${pageContext.request.contextPath}/sale/deal/detail?id=${deal.dealId}">
                                                    ${deal.dealName}
                                            </a>
                                        </td>
                                        <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                                                ${deal.customerName}
                                        </td>
                                        <td class="sd-money">
                                            <fmt:formatNumber value="${deal.expectedValue}" type="currency" currencySymbol="$"/>
                                        </td>
                                        <td>
                                            <span class="sd-stage ${pageScope.stageClass(deal.stage)}">
                                                    ${deal.stage}
                                            </span>
                                        </td>
                                        <td>
                                            <c:if test="${not empty deal.expectedCloseDate}">
                                                <fmt:formatDate value="${deal.expectedCloseDate}" pattern="dd MMM yyyy"/>
                                            </c:if>
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

    <%-- ── 5: Recent Activities ─────────────────────────────────────────────── --%>
    <div class="sd-row-full">
        <div class="sd-panel">
            <div class="sd-panel-header">
                <h3 class="sd-panel-title">Recent Activities</h3>
                <c:if test="${not empty kpis.recentActivities}">
                    <span class="sd-panel-badge">Last ${kpis.recentActivities.size()} actions</span>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty kpis.recentActivities}">
                    <div class="sd-empty">No recent activities recorded.</div>
                </c:when>
                <c:otherwise>
                    <div class="sd-activity-list">
                        <c:forEach items="${kpis.recentActivities}" var="act">
                            <div class="sd-activity-item">
                                <div class="${pageScope.activityIconClass(act.activityType)}">
                                    <i class="fas <c:choose>
                                        <c:when test='${act.activityType == "Call"}'>fa-phone</c:when>
                                        <c:when test='${act.activityType == "Email"}'>fa-envelope</c:when>
                                        <c:when test='${act.activityType == "Meeting"}'>fa-users</c:when>
                                        <c:when test='${act.activityType == "Task"}'>fa-tasks</c:when>
                                        <c:when test='${act.activityType == "Note"}'>fa-sticky-note</c:when>
                                        <c:otherwise>fa-sync-alt</c:otherwise>
                                    </c:choose>"></i>
                                </div>
                                <div class="sd-activity-body">
                                    <div class="sd-activity-subject">
                                            ${act.subject}
                                        <span class="sd-activity-type">${act.activityType}</span>
                                    </div>
                                    <div class="sd-activity-meta">
                                        <c:if test="${not empty act.performedBy}">
                                            ${act.performedBy.fullName} &bull;
                                        </c:if>
                                        <c:if test="${not empty act.relatedName}">
                                            on ${act.relatedName}
                                        </c:if>
                                        <c:if test="${not empty act.createdAt}">
                                            &bull; <fmt:formatDate value="${act.createdAt}" pattern="dd MMM yyyy, HH:mm"/>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>
