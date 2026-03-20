<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.LocalDate, java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.util.List, model.Task, model.TaskComment" %>
<%!
    private String e(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }

    private String getStatusBorderColor(String status) {
        if (status == null) return "#6c757d";
        return switch (status.toLowerCase()) {
            case "pending" -> "#ffc107";
            case "in progress" -> "#0dcaf0";
            case "done", "completed" -> "#198754";
            case "cancelled" -> "#dc3545";
            case "overdue" -> "#dc3545";
            case "reopened" -> "#0d6efd";
            default -> "#6c757d";
        };
    }

    private String getStatusBgColor(String status) {
        if (status == null) return "#f8f9fa";
        return switch (status.toLowerCase()) {
            case "pending" -> "#fff3cd";
            case "in progress" -> "#cff4fc";
            case "done", "completed" -> "#d1e7dd";
            case "cancelled" -> "#f8d7da";
            case "overdue" -> "#f8d7da";
            case "reopened" -> "#cfe2ff";
            default -> "#f8f9fa";
        };
    }

    private String formatTime(LocalDateTime dt) {
        if (dt == null) return "";
        return dt.format(DateTimeFormatter.ofPattern("HH:mm"));
    }

    private String formatDate(LocalDate d) {
        if (d == null) return "";
        return d.format(DateTimeFormatter.ofPattern("EEE, MMM d"));
    }
%>
<%
    List<LocalDate> weekDays = (List<LocalDate>) request.getAttribute("weekDays");
    List<Task> tasks = (List<Task>) request.getAttribute("tasks");
    List<TaskComment> subtasks = (List<TaskComment>) request.getAttribute("subtasks");
    Integer currentUserId = (Integer) request.getAttribute("currentUserId");
    Boolean isManager = (Boolean) request.getAttribute("isManager");

    if (tasks == null) tasks = java.util.Collections.emptyList();
    if (subtasks == null) subtasks = java.util.Collections.emptyList();

    // Organize tasks by day
    java.util.Map<LocalDate, List<Task>> tasksByDay = new java.util.HashMap<>();
    for (Task t : tasks) {
        LocalDate day = null;
        if (t.getStartDate() != null) {
            day = t.getStartDate().toLocalDate();
        } else if (t.getDueDate() != null) {
            day = t.getDueDate().toLocalDate();
        }
        if (day != null) {
            tasksByDay.computeIfAbsent(day, k -> new java.util.ArrayList<>()).add(t);
        }
    }

    // Organize subtasks by day
    java.util.Map<LocalDate, List<TaskComment>> subtasksByDay = new java.util.HashMap<>();
    for (TaskComment sc : subtasks) {
        if (sc.getCreatedAt() != null) {
            LocalDate day = sc.getCreatedAt().toLocalDate();
            subtasksByDay.computeIfAbsent(day, k -> new java.util.ArrayList<>()).add(sc);
        }
    }
%>

<style>
.task-schedule {
    display: grid;
    grid-template-columns: 80px repeat(7, 1fr);
    gap: 1px;
    background: #dee2e6;
    border: 1px solid #dee2e6;
    border-radius: 8px;
    overflow: hidden;
}
.schedule-header {
    background: #f8f9fa;
    padding: 12px 8px;
    text-align: center;
    font-weight: 600;
    font-size: 0.85rem;
    border-bottom: 2px solid #dee2e6;
}
.schedule-header.time-col {
    background: #e9ecef;
}
.schedule-cell {
    background: white;
    min-height: 120px;
    padding: 4px;
    position: relative;
}
.schedule-cell.today {
    background: #fff3cd;
}
.schedule-item {
    padding: 4px 6px;
    border-radius: 4px;
    font-size: 0.75rem;
    margin-bottom: 4px;
    cursor: pointer;
    border-left: 3px solid;
}
.schedule-item.task-item {
    background: #e3f2fd;
    border-left-color: #2196f3;
}
.schedule-item.subtask-item {
    background: #f3e5f5;
    border-left-color: #9c27b0;
}
.schedule-item .item-time {
    font-weight: 600;
    margin-right: 4px;
}
.schedule-item .item-title {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.week-nav {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
}
.week-nav select {
    min-width: 200px;
}
</style>

<div>
<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Task Schedule</h4>
        <h6>Weekly view of your tasks and subtasks</h6>
      </div>
    </div>

    <div class="week-nav">
        <a href="${pageContext.request.contextPath}/tasks/schedule?weekOffset=${weekOffset - 1}"
           class="btn btn-outline-secondary">
            <i class="fa fa-chevron-left"></i>
        </a>

        <select class="form-select" onchange="window.location.href='${pageContext.request.contextPath}/tasks/schedule?weekOffset=' + this.value">
            <c:forEach var="wo" items="${weekOptions}">
                <option value="${wo.offset}" ${wo.offset == weekOffset ? 'selected' : ''}>
                    ${wo.displayLabel} (${wo.dateLabel})
                </option>
            </c:forEach>
        </select>

        <a href="${pageContext.request.contextPath}/tasks/schedule?weekOffset=${weekOffset + 1}"
           class="btn btn-outline-secondary">
            <i class="fa fa-chevron-right"></i>
        </a>

        <span class="ms-3 fw-semibold">${weekRange}</span>

        <c:if test="${weekOffset != 0}">
            <a href="${pageContext.request.contextPath}/tasks/schedule" class="btn btn-outline-primary btn-sm">
                This Week
            </a>
        </c:if>
    </div>

    <div class="alert alert-info">
        <i class="fa fa-info-circle me-2"></i>
        <c:choose>
            <c:when test="${isManager}">
                Showing <strong>root tasks</strong> created by your subordinates.
                Task time = start date | Subtask time = tagged time
            </c:when>
            <c:otherwise>
                Showing <strong>your tasks</strong> (created or assigned) and <strong>subtasks</strong> (tagged work items).
                Task time = start date | Subtask time = tagged time
            </c:otherwise>
        </c:choose>
    </div>

    <div class="card">
        <div class="card-body p-0">
            <div class="task-schedule">
                <!-- Header row -->
                <div class="schedule-header time-col"></div>
                <% for (LocalDate day : weekDays) { %>
                    <div class="schedule-header <%= day.equals(LocalDate.now()) ? "bg-primary text-white" : "" %>">
                        <%= formatDate(day) %>
                    </div>
                <% } %>

                <!-- Time column + 7 day columns -->
                <div class="schedule-header time-col">
                    <div class="d-flex flex-column justify-content-center" style="height: 100%;">
                        <small class="text-muted">Tasks</small>
                        <small class="text-muted">Subtasks</small>
                    </div>
                </div>

                <% for (LocalDate day : weekDays) {
                    boolean isToday = day.equals(LocalDate.now());
                    List<Task> dayTasks = tasksByDay.getOrDefault(day, java.util.Collections.emptyList());
                    List<TaskComment> daySubtasks = subtasksByDay.getOrDefault(day, java.util.Collections.emptyList());
                %>
                <div class="schedule-cell <%= isToday ? "today" : "" %>">
                    <!-- Tasks for this day -->
                    <% for (Task t : dayTasks) { %>
                        <div class="schedule-item task-item"
                             style="background: <%= getStatusBgColor(t.getStatus()) %>; border-left-color: <%= getStatusBorderColor(t.getStatus()) %>;"
                             onclick="window.location.href='${pageContext.request.contextPath}/tasks/details?id=<%= t.getTaskId() %>'"
                             title="<%= e(t.getTitle()) %> [<%= t.getStatus() %>] &#10;Priority: <%= t.getPriority() %>">
                            <span class="item-time"><%= formatTime(t.getStartDate()) %></span>
                            <span class="item-title"><%= e(t.getTitle()) %></span>
                            <span class="badge bg-secondary" style="font-size: 0.6rem;"><%= t.getStatus() %></span>
                        </div>
                    <% } %>

                    <!-- Subtasks for this day -->
                    <% for (TaskComment sc : daySubtasks) { %>
                        <div class="schedule-item subtask-item"
                             title="<%= e(sc.getContent()) %> - <%= sc.isCompleted() ? "Done" : "Pending" %>">
                            <span class="item-time"><%= formatTime(sc.getCreatedAt()) %></span>
                            <span class="item-title"><%= e(sc.getContent().length() > 30 ? sc.getContent().substring(0, 30) + "..." : sc.getContent()) %></span>
                            <% if (sc.isCompleted()) { %>
                                <i class="fa fa-check-circle text-success ms-1"></i>
                            <% } %>
                        </div>
                    <% } %>

                    <% if (dayTasks.isEmpty() && daySubtasks.isEmpty()) { %>
                        <div class="text-muted text-center small py-4">-</div>
                    <% } %>
                </div>
                <% } %>
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
