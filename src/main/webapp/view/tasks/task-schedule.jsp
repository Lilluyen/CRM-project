<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

            <%-- Day header labels (Mon=1..Sun=7) --%>
                <c:set var="dayNames" value="Mon,Tue,Wed,Thu,Fri,Sat,Sun" scope="page" />

                <style>
                    /* ── Navigation ─────────────────────────────────── */
                    .schedule-nav {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        margin-bottom: 16px;
                        flex-wrap: wrap;
                    }

                    .schedule-nav select {
                        min-width: 200px;
                    }

                    .schedule-nav .month-title {
                        font-size: 1.1rem;
                        font-weight: 700;
                        color: #495057;
                        margin: 0;
                    }

                    .schedule-nav .btn-this-month {
                        margin-left: 4px;
                    }

                    /* ── Calendar layout ─────────────────────────────── */
                    .calendar-wrap {
                        background: #fff;
                        border: 1px solid #dee2e6;
                        border-radius: 8px;
                        overflow: hidden;
                    }

                    /* Day-name header row */
                    .day-name-row {
                        display: grid;
                        grid-template-columns: repeat(7, 1fr);
                        background: #f1f3f5;
                        border-bottom: 2px solid #dee2e6;
                    }

                    .day-name-cell {
                        padding: 6px 4px;
                        text-align: center;
                        font-size: .72rem;
                        font-weight: 700;
                        color: #6c757d;
                        border-right: 1px solid #dee2e6;
                    }

                    .day-name-cell:last-child {
                        border-right: none;
                    }

                    .day-name-cell.is-today-col {
                        color: #0d6efd;
                        background: #e7f1ff;
                    }

                    /* Calendar grid */
                    .calendar-grid {
                        display: grid;
                        grid-template-columns: repeat(7, 1fr);
                        gap: 1px;
                        background: #dee2e6;
                    }

                    /* Day cell */
                    .cal-cell {
                        background: #fff;
                        min-height: 110px;
                        max-height: 180px;
                        padding: 4px;
                        overflow: hidden;
                        position: relative;
                    }

                    .cal-cell.is-empty {
                        background: #f8f9fa;
                    }

                    .cal-cell.is-today {
                        background: #fff3cd;
                    }

                    /* Day number */
                    .day-num {
                        font-size: .75rem;
                        font-weight: 700;
                        color: #495057;
                        display: inline-block;
                        width: 22px;
                        height: 22px;
                        line-height: 22px;
                        text-align: center;
                        margin-bottom: 3px;
                    }

                    .cal-cell.is-today .day-num {
                        background: #0d6efd;
                        color: #fff;
                        border-radius: 50%;
                    }

                    /* Task / subtask chips (use <a> for keyboard accessibility) */
                    .task-chip {
                        display: block;
                        font-size: .65rem;
                        padding: 2px 4px;
                        margin-bottom: 2px;
                        border-radius: 3px;
                        border-left: 3px solid;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        line-height: 1.3;
                        text-decoration: none;
                    }

                    a.task-chip:hover {
                        filter: brightness(.9);
                        cursor: pointer;
                    }

                    .task-chip.is-task {
                        background: #e3f2fd;
                    }

                    .task-chip.is-subtask {
                        background: #f3e5f5;
                        border-left-color: #9c27b0;
                    }

                    .more-link {
                        font-size: .62rem;
                        color: #6c757d;
                        display: block;
                        text-align: center;
                        text-decoration: none;
                    }

                    a.more-link:hover {
                        color: #0d6efd;
                        cursor: pointer;
                    }
                </style>

                <div>
                    <div class="content">

                        <%-- Page header --%>
                            <div class="page-header mb-3">
                                <div class="page-title">
                                    <h4>Task Timeline</h4>
                                    <h6 class="text-muted small">Monthly overview of your tasks and subtasks</h6>
                                </div>
                            </div>

                            <%-- Navigation bar --%>
                                <div class="schedule-nav">
                                    <%-- Prev month --%>
                                        <a href="${pageContext.request.contextPath}/tasks/schedule?monthOffset=${monthOffset - 1}"
                                            class="btn btn-outline-secondary btn-sm">
                                            <i class="fa fa-chevron-left"></i>
                                        </a>

                                        <%-- Month dropdown (max ±3) --%>
                                            <select class="form-select form-select-sm"
                                                onchange="window.location.href='${pageContext.request.contextPath}/tasks/schedule?monthOffset='+this.value">
                                                <c:forEach var="mo" items="${monthOptions}">
                                                    <option value="${mo.offset}" ${mo.offset==monthOffset ? 'selected'
                                                        : '' }>
                                                        ${mo.displayLabel} (${mo.monthLabel})
                                                    </option>
                                                </c:forEach>
                                            </select>

                                            <%-- Next month --%>
                                                <a href="${pageContext.request.contextPath}/tasks/schedule?monthOffset=${monthOffset + 1}"
                                                    class="btn btn-outline-secondary btn-sm">
                                                    <i class="fa fa-chevron-right"></i>
                                                </a>

                                                <%-- Current month label --%>
                                                    <p class="month-title mb-0">${targetMonthName}</p>

                                                    <%-- This Month button (only when offset !=0) --%>
                                                        <c:if test="${monthOffset != 0}">
                                                            <a href="${pageContext.request.contextPath}/tasks/schedule"
                                                                class="btn btn-outline-primary btn-sm btn-this-month">This
                                                                Month</a>
                                                        </c:if>
                                </div>

                                <%-- Role info banner --%>
                                    <div class="alert alert-info small mb-3">
                                        <i class="fa fa-info-circle me-2"></i>
                                        <c:choose>
                                            <c:when test="${isManager}">
                                                <strong>Manager View:</strong>
                                                Showing <strong>all root tasks</strong> of your subordinates.
                                            </c:when>
                                            <c:otherwise>
                                                <strong>Employee View:</strong>
                                                Showing tasks you <strong>created</strong>, are
                                                <strong>assigned to</strong>, or <strong>mentioned</strong> in comments.
                                            </c:otherwise>
                                        </c:choose>
                                        Click a task chip to view details.
                                    </div>

                                    <%-- Single-month calendar (monthStrips has exactly 1 item) --%>
                                        <c:forEach var="strip" items="${monthStrips}">

                                            <div class="calendar-wrap">

                                                <%-- Day-name header (Mon–Sun) --%>
                                                    <div class="day-name-row">
                                                        <c:forEach var="name" items="${dayNames}" varStatus="vs">
                                                            <div
                                                                class="day-name-cell ${vs.index == 3 && strip.currentMonth ? 'is-today-col' : ''}">
                                                                ${name}
                                                            </div>
                                                        </c:forEach>
                                                    </div>

                                                    <%-- Calendar grid --%>
                                                        <div class="calendar-grid">
                                                            <c:forEach var="day" items="${strip.days}">

                                                                <c:choose>

                                                                    <%-- Empty placeholder (padding before 1st / after
                                                                        last day) --%>
                                                                        <c:when
                                                                            test="${empty day || day.dayOfMonth == 0}">
                                                                            <div class="cal-cell is-empty"></div>
                                                                        </c:when>

                                                                        <%-- Real day --%>
                                                                            <c:otherwise>
                                                                                <div
                                                                                    class="cal-cell ${day.today ? 'is-today' : ''}">

                                                                                    <span
                                                                                        class="day-num">${day.dayOfMonth}</span>

                                                                                    <%-- Task chips (max 5) --%>
                                                                                        <c:forEach var="task"
                                                                                            items="${day.tasks}"
                                                                                            end="4">
                                                                                            <c:set var="borderColor">
                                                                                                <c:choose>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'pending'}">
                                                                                                        #ffc107</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'in progress'}">
                                                                                                        #0dcaf0</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'done' || fn:toLowerCase(task.status) == 'completed'}">
                                                                                                        #198754</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'cancelled' || fn:toLowerCase(task.status) == 'overdue'}">
                                                                                                        #dc3545</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'reopened'}">
                                                                                                        #0d6efd</c:when>
                                                                                                    <c:otherwise>#6c757d
                                                                                                    </c:otherwise>
                                                                                                </c:choose>
                                                                                            </c:set>
                                                                                            <c:set var="bgColor">
                                                                                                <c:choose>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'pending'}">
                                                                                                        #fff3cd</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'in progress'}">
                                                                                                        #cff4fc</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'done' || fn:toLowerCase(task.status) == 'completed'}">
                                                                                                        #d1e7dd</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'cancelled' || fn:toLowerCase(task.status) == 'overdue'}">
                                                                                                        #f8d7da</c:when>
                                                                                                    <c:when
                                                                                                        test="${fn:toLowerCase(task.status) == 'reopened'}">
                                                                                                        #cfe2ff</c:when>
                                                                                                    <c:otherwise>#f8f9fa
                                                                                                    </c:otherwise>
                                                                                                </c:choose>
                                                                                            </c:set>
                                                                                            <c:set var="timeStr"
                                                                                                value="${task.startDate != null ? fn:substring(task.startDate.toString(), 11, 16) : ''}" />
                                                                                            <c:set var="titleEsc">
                                                                                                ${fn:escapeXml(task.title)}
                                                                                            </c:set>
                                                                                            <c:set var="truncated">
                                                                                                ${fn:length(task.title)
                                                                                                > 18 ?
                                                                                                fn:substring(titleEsc,
                                                                                                0, 18) : titleEsc}
                                                                                                ${fn:length(task.title)
                                                                                                > 18 ? '...' : ''}
                                                                                            </c:set>
                                                                                            <a class="task-chip is-task"
                                                                                                style="border-left-color:${borderColor}; background:${bgColor};"
                                                                                                href="${pageContext.request.contextPath}/tasks/details?id=${task.taskId}"
                                                                                                title="${titleEsc} [${task.status}]&#10;Priority: ${task.priority}">
                                                                                                <span
                                                                                                    class="fw-semibold">${timeStr}</span>
                                                                                                ${truncated}
                                                                                            </a>
                                                                                        </c:forEach>

                                                                                        <%-- Subtask chips --%>
                                                                                            <c:forEach var="sc"
                                                                                                items="${day.subtasks}">
                                                                                                <c:set var="scTime"
                                                                                                    value="${sc.createdAt != null ? fn:substring(sc.createdAt.toString(), 11, 16) : ''}" />
                                                                                                <c:set var="scEsc">
                                                                                                    ${fn:escapeXml(sc.content)}
                                                                                                </c:set>
                                                                                                <c:set
                                                                                                    var="scTruncated">
                                                                                                    ${fn:length(sc.content)
                                                                                                    > 18 ?
                                                                                                    fn:substring(scEsc,
                                                                                                    0, 18) : scEsc}
                                                                                                    ${fn:length(sc.content)
                                                                                                    > 18 ? '...' : ''}
                                                                                                </c:set>
                                                                                                <div class="task-chip is-subtask"
                                                                                                    title="${scEsc} - ${sc.completed ? 'Done' : 'Pending'}">
                                                                                                    <span
                                                                                                        class="fw-semibold">${scTime}</span>
                                                                                                    ${scTruncated}
                                                                                                    <c:if
                                                                                                        test="${sc.completed}">
                                                                                                        <i
                                                                                                            class="fa fa-check-circle text-success ms-1"></i>
                                                                                                    </c:if>
                                                                                                </div>
                                                                                            </c:forEach>

                                                                                            <%-- Overflow --%>
                                                                                                <c:if
                                                                                                    test="${day.hiddenTaskCount > 0}">
                                                                                                    <a class="more-link"
                                                                                                        href="${pageContext.request.contextPath}/tasks/details"
                                                                                                        onclick="alert('+${day.hiddenTaskCount} more task(s) on this day'); return false;">
                                                                                                        +${day.hiddenTaskCount}
                                                                                                        more
                                                                                                    </a>
                                                                                                </c:if>
                                                                                </div>
                                                                            </c:otherwise>

                                                                </c:choose>
                                                            </c:forEach>
                                                        </div><%-- end .calendar-grid --%>

                                            </div><%-- end .calendar-wrap --%>
                                        </c:forEach>

                                        <%-- Legend --%>
                                            <div class="mt-3 d-flex gap-3 flex-wrap align-items-center">
                                                <span class="small fw-semibold">Task Colors:</span>
                                                <span class="badge bg-warning text-dark">Pending</span>
                                                <span class="badge bg-info text-dark">In Progress</span>
                                                <span class="badge bg-success">Done</span>
                                                <span class="badge bg-danger">Cancelled/Overdue</span>
                                                <span class="badge bg-primary">Reopened</span>
                                                <span class="mx-1 text-muted">|</span>
                                                <span class="small fw-semibold">Types:</span>
                                                <span class="badge"
                                                    style="background:#e3f2fd;color:#1976d2;">Task</span>
                                                <span class="badge"
                                                    style="background:#f3e5f5;color:#7b1fa2;">Subtask</span>
                                            </div>

                                            <%-- Stats --%>
                                                <div class="mt-3 row">
                                                    <div class="col-md-4">
                                                        <div class="card text-center">
                                                            <div class="card-body py-2">
                                                                <div class="text-muted small">Total Tasks</div>
                                                                <div class="fs-4 fw-bold text-primary">${totalTasks}
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="card text-center">
                                                            <div class="card-body py-2">
                                                                <div class="text-muted small">Total Subtasks</div>
                                                                <div class="fs-4 fw-bold" style="color:#9c27b0;">
                                                                    ${totalSubtasks}</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="card text-center">
                                                            <div class="card-body py-2">
                                                                <div class="text-muted small">Completed Subtasks</div>
                                                                <div class="fs-4 fw-bold text-success">
                                                                    ${completedSubtasks}</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                    </div>

                    <!-- Legend -->
                    <div class="mt-3 d-flex gap-3 flex-wrap">
                        <span class="small fw-semibold">Task Colors:</span>
                        <span class="badge bg-warning text-dark">Pending</span>
                        <span class="badge bg-info text-dark">In Progress</span>
                        <span class="badge bg-success">Done</span>
                        <span class="badge bg-danger">Cancelled/Overdue</span>
                        <span class="badge bg-primary">Reopened</span>
                        <span class="mx-2">|</span>
                        <span class="small fw-semibold">Item Types:</span>
                        <span class="badge" style="background: #e3f2fd; color: #1976d2;">Task</span>
                        <span class="badge" style="background: #f3e5f5; color: #7b1fa2;">Subtask</span>
                    </div>

                </div>
                </div>
                </div>