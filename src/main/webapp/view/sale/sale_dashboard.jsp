<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<%@ page import="java.time.LocalDate, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>

<%!
    /** Format a LocalDate or LocalDateTime value to a display string. Returns "" for null. */
    public static String fmtDate(Object val, String pattern) {
        if (val == null) return "";
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern(pattern);
        if (val instanceof LocalDateTime) return ((LocalDateTime) val).format(dtf);
        if (val instanceof LocalDate) return ((LocalDate) val).format(dtf);
        return val.toString();
    }
%>

<div class="sd-page">

    <%-- ── Header ─────────────────────────────────────────────────────────── --%>
    <div class="sd-header">
        <div class="sd-header-left">
            <h2>Sales Dashboard</h2>
            <p>Welcome back, <strong>${currentUser.fullName}</strong> &mdash; here&rsquo;s your performance for
                <strong>${kpis.month}</strong></p>
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
                <fmt:formatNumber value="${kpis.monthlyRevenue}" type="currency" currencySymbol="$"
                                  maxFractionDigits="0"/>
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

        <%-- 2. Today's Follow-up Tasks --%>
        <div class="sd-panel">
            <div class="sd-panel-header">
                <h3 class="sd-panel-title">Today&rsquo;s Follow-ups</h3>
                <c:if test="${not empty kpis.todayTasks}">
                    <%-- FIX 1: fn:length() thay vì .size() --%>
                    <span class="sd-panel-badge">${fn:length(kpis.todayTasks)} tasks</span>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty kpis.todayTasks}">
                    <div class="sd-empty">
                        <i class="fas fa-check-circle"
                           style="font-size:1.5rem;display:block;margin-bottom:6px;color:#10b981"></i>
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
                                            <%= fmtDate(pageContext.findAttribute("task") != null ? ((model.Task) pageContext.findAttribute("task")).getDueDate() : null, "HH:mm") %>
                                        </c:if>
                                    </td>
                                    <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                                            ${task.relatedName}
                                    </td>
                                    <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                                        title="${task.title}">${task.title}</td>
                                    <td>
                                            <%-- FIX 2: c:set + c:choose thay vì pageScope.taskStatusClass() --%>
                                        <c:set var="taskStatusCss" value="sd-status-pending"/>
                                        <c:choose>
                                            <c:when test="${task.status == 'Pending'}"> <c:set var="taskStatusCss"
                                                                                               value="sd-status-pending"/></c:when>
                                            <c:when test="${task.status == 'In Progress'}"> <c:set var="taskStatusCss"
                                                                                                   value="sd-status-in-progress"/></c:when>
                                            <c:when test="${task.status == 'Done'}"> <c:set var="taskStatusCss"
                                                                                            value="sd-status-done"/></c:when>
                                            <c:when test="${task.status == 'Overdue'}"> <c:set var="taskStatusCss"
                                                                                               value="sd-status-overdue"/></c:when>
                                            <c:when test="${task.status == 'Cancelled'}"> <c:set var="taskStatusCss"
                                                                                                 value="sd-status-cancelled"/></c:when>
                                        </c:choose>
                                        <span class="sd-status ${taskStatusCss}">
                                                ${task.status}
                                        </span>
                                    </td>
                                    <td>
                                            <%-- FIX 2: c:set + c:choose thay vì pageScope.priorityClass() --%>
                                        <c:set var="priorityCss" value="sd-priority-medium"/>
                                        <c:choose>
                                            <c:when test="${task.priority == 'High'}"> <c:set var="priorityCss"
                                                                                              value="sd-priority-high"/></c:when>
                                            <c:when test="${task.priority == 'Medium'}"> <c:set var="priorityCss"
                                                                                                value="sd-priority-medium"/></c:when>
                                            <c:when test="${task.priority == 'Low'}"> <c:set var="priorityCss"
                                                                                             value="sd-priority-low"/></c:when>
                                        </c:choose>
                                        <span class="sd-priority ${priorityCss}">
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
                                        <%-- FIX 2: c:set + c:choose thay vì pageScope.pipelineBarClass() --%>
                                    <c:set var="pipelineBarCss" value="sd-pipeline-bar default"/>
                                    <c:choose>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'new lead'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar new-lead"/></c:when>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'contacted'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar contacted"/></c:when>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'interested'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar interested"/></c:when>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'negotiation'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar negotiation"/></c:when>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'won'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar won"/></c:when>
                                        <c:when test="${fn:toLowerCase(lsc.status) == 'lost'}"> <c:set
                                                var="pipelineBarCss" value="sd-pipeline-bar lost"/></c:when>
                                    </c:choose>
                                    <div class="${pipelineBarCss}"
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
                    <%-- FIX 1: fn:length() thay vì .size() --%>
                    <span class="sd-panel-badge">${fn:length(kpis.myDeals)} open deals</span>
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
                                        <fmt:formatNumber value="${deal.expectedValue}" type="currency"
                                                          currencySymbol="$"/>
                                    </td>
                                    <td>
                                            <%-- FIX 2: c:set + c:choose thay vì pageScope.stageClass() --%>
                                        <c:set var="stageCss" value="sd-stage-default"/>
                                        <c:choose>
                                            <c:when test="${deal.stage == 'Prospecting'}"> <c:set var="stageCss"
                                                                                                  value="sd-stage-prospecting"/></c:when>
                                            <c:when test="${deal.stage == 'Qualified'}"> <c:set var="stageCss"
                                                                                                value="sd-stage-qualified"/></c:when>
                                            <c:when test="${deal.stage == 'Proposal'}"> <c:set var="stageCss"
                                                                                               value="sd-stage-proposal"/></c:when>
                                            <c:when test="${deal.stage == 'Negotiation'}"> <c:set var="stageCss"
                                                                                                  value="sd-stage-negotiation"/></c:when>
                                            <c:when test="${deal.stage == 'Closed Won'}"> <c:set var="stageCss"
                                                                                                 value="sd-stage-closed-won"/></c:when>
                                            <c:when test="${deal.stage == 'Closed Lost'}"> <c:set var="stageCss"
                                                                                                  value="sd-stage-closed-lost"/></c:when>
                                        </c:choose>
                                        <span class="sd-stage ${stageCss}">
                                                ${deal.stage}
                                        </span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty deal.expectedCloseDate}">
                                            <%= fmtDate(pageContext.findAttribute("deal") != null ? ((model.Deal) pageContext.findAttribute("deal")).getExpectedCloseDate() : null, "dd MMM yyyy") %>
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
                    <%-- FIX 1: fn:length() thay vì .size() --%>
                    <span class="sd-panel-badge">Last ${fn:length(kpis.recentActivities)} actions</span>
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
                                    <%-- FIX 2: c:set + c:choose thay vì pageScope.activityIconClass() --%>
                                <c:set var="activityIconCss" value="sd-activity-icon update"/>
                                <c:choose>
                                    <c:when test="${fn:toLowerCase(act.activityType) == 'call'}"> <c:set
                                            var="activityIconCss" value="sd-activity-icon call"/></c:when>
                                    <c:when test="${fn:toLowerCase(act.activityType) == 'email'}"> <c:set
                                            var="activityIconCss" value="sd-activity-icon email"/></c:when>
                                    <c:when test="${fn:toLowerCase(act.activityType) == 'meeting'}"> <c:set
                                            var="activityIconCss" value="sd-activity-icon meeting"/></c:when>
                                    <c:when test="${fn:toLowerCase(act.activityType) == 'note'}"> <c:set
                                            var="activityIconCss" value="sd-activity-icon note"/></c:when>
                                    <c:when test="${fn:toLowerCase(act.activityType) == 'task'}"> <c:set
                                            var="activityIconCss" value="sd-activity-icon task"/></c:when>
                                </c:choose>
                                    <%-- FIX 3: tách c:choose ra ngoài attribute class của thẻ <i> --%>
                                <c:set var="activityFaIcon" value="fa-sync-alt"/>
                                <c:choose>
                                    <c:when test="${act.activityType == 'Call'}"> <c:set var="activityFaIcon"
                                                                                         value="fa-phone"/></c:when>
                                    <c:when test="${act.activityType == 'Email'}"> <c:set var="activityFaIcon"
                                                                                          value="fa-envelope"/></c:when>
                                    <c:when test="${act.activityType == 'Meeting'}"> <c:set var="activityFaIcon"
                                                                                            value="fa-users"/></c:when>
                                    <c:when test="${act.activityType == 'Task'}"> <c:set var="activityFaIcon"
                                                                                         value="fa-tasks"/></c:when>
                                    <c:when test="${act.activityType == 'Note'}"> <c:set var="activityFaIcon"
                                                                                         value="fa-sticky-note"/></c:when>
                                </c:choose>
                                <div class="${activityIconCss}">
                                    <i class="fas ${activityFaIcon}"></i>
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
                                            &bull; <%= fmtDate(pageContext.findAttribute("act") != null ? ((model.Activity) pageContext.findAttribute("act")).getCreatedAt() : null, "dd MMM yyyy, HH:mm") %>
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
