<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="
        model.Task, model.TaskComment, model.TaskHistory, model.TaskHistoryDetail,
        controller.tasks.TaskViewHistoryController.HistoryView,
        java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }

    @SuppressWarnings("unchecked") List<TaskComment> rootWorkItems =
        (List<TaskComment>) request.getAttribute("rootWorkItems");
    if (rootWorkItems == null) rootWorkItems = new ArrayList<>();

    @SuppressWarnings("unchecked") Map<Integer, List<TaskComment>> repliesMap =
        (Map<Integer, List<TaskComment>>) request.getAttribute("repliesMap");
    if (repliesMap == null) repliesMap = new HashMap<>();

    @SuppressWarnings("unchecked") List<HistoryView> historyViews =
        (List<HistoryView>) request.getAttribute("historyViews");
    if (historyViews == null) historyViews = new ArrayList<>();

    @SuppressWarnings("unchecked") Map<Integer, String> assigneeNamesMap =
        (Map<Integer, String>) request.getAttribute("assigneeNames");
    if (assigneeNamesMap == null) assigneeNamesMap = new HashMap<>();

    Integer workItemCount = (Integer) request.getAttribute("workItemCount");
    Integer completedCount = (Integer) request.getAttribute("completedCount");

    String ctx = request.getContextPath();

    // Helper to format datetime
    java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // Helper to get status badge class
    java.util.function.Function<String, String> statusBadge = s -> {
        return switch (s != null ? s.toLowerCase() : "") {
            case "done", "completed" -> "bg-success";
            case "in progress" -> "bg-primary";
            case "pending" -> "bg-warning text-dark";
            case "cancelled", "overdue" -> "bg-danger";
            case "reopened" -> "bg-info text-dark";
            default -> "bg-secondary";
        };
    };

    // Helper to get priority badge class
    java.util.function.Function<String, String> priorityBadge = p -> {
        return switch (p != null ? p.toLowerCase() : "") {
            case "high" -> "bg-danger";
            case "medium" -> "bg-warning text-dark";
            case "low" -> "bg-info text-dark";
            default -> "bg-secondary";
        };
    };
%>
<style>
.handover-section { margin-bottom: 24px; }
.handover-section:last-child { margin-bottom: 0; }
.section-title { font-size: 1rem; font-weight: 600; color: #495057; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
.section-title i { color: #0d6efd; }

.task-info-table { width: 100%; font-size: .875rem; }
.task-info-table td { padding: 6px 12px; border-bottom: 1px solid #f0f0f0; }
.task-info-table td:first-child { width: 140px; font-weight: 600; color: #6c757d; background: #f8f9fa; }

.assignee-list { display: flex; flex-wrap: wrap; gap: 8px; }
.assignee-chip { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; background: #e9ecef; border-radius: 16px; font-size: .813rem; }
.assignee-chip .avatar { width: 22px; height: 22px; border-radius: 50%; background: #0d6efd; color: #fff; display: flex; align-items: center; justify-content: center; font-size: .65rem; font-weight: 600; }

.wi-item { display: flex; gap: 10px; padding: 10px 12px; border: 1px solid #e9ecef; border-radius: 6px; margin-bottom: 8px; background: #fff; }
.wi-item:last-child { margin-bottom: 0; }
.wi-item.wi-done { background: #f8fff8; border-color: #d4edda; }
.wi-checkbox { flex-shrink: 0; margin-top: 2px; }
.wi-checkbox input { width: 16px; height: 16px; cursor: pointer; }
.wi-content { flex-grow: 1; }
.wi-author { font-weight: 600; font-size: .813rem; color: #212529; }
.wi-meta { font-size: .75rem; color: #6c757d; margin-top: 2px; }
.wi-content-main { font-size: .875rem; color: #495057; margin-top: 4px; white-space: pre-wrap; }
.wi-assignee { font-size: .75rem; color: #6c757d; margin-top: 4px; }
.wi-assignee i { color: #0d6efd; }
.wi-replies { margin-left: 26px; padding-left: 12px; border-left: 2px solid #e9ecef; margin-top: 8px; }

.vh-timeline { position: relative; padding-left: 28px; }
.vh-timeline::before { content: ''; position: absolute; left: 12px; top: 0; bottom: 0; width: 2px; background: #dee2e6; }
.vh-item { position: relative; margin-bottom: 20px; }
.vh-item::before { content: ''; position: absolute; left: -20px; top: 6px; width: 10px; height: 10px; border-radius: 50%; background: #0d6efd; border: 2px solid #fff; box-shadow: 0 0 0 2px #0d6efd; }
.vh-time { font-size: .78rem; color: #6c757d; margin-bottom: 2px; }
.vh-sum { font-weight: 600; font-size: .9rem; margin-bottom: 4px; }
.vh-det { background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 6px; padding: 10px 14px; margin-top: 6px; }
.vh-det-row { display: flex; gap: 10px; align-items: center; padding: 4px 0; border-bottom: 1px solid #f1f3f5; font-size: .84rem; }
.vh-det-row:last-child { border-bottom: none; }
.vh-field { font-weight: 600; min-width: 120px; color: #495057; }
.vh-old { color: #dc3545; text-decoration: line-through; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.vh-new { color: #198754; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.vh-arrow { color: #adb5bd; }

.empty-state { padding: 30px; text-align: center; color: #6c757d; }
.empty-state i { font-size: 2rem; margin-bottom: 10px; display: block; opacity: 0.5; }
</style>

<div><div class="content">
    <div class="page-header">
        <div class="page-title">
            <h4>Task Handover / Acceptance</h4>
            <h6><%= task.getTitle() != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(task.getTitle()) : "#" + task.getTaskId() %></h6>
        </div>
        <div class="d-flex gap-2">
            <a href="<%= ctx %>/tasks/detail?id=<%= task.getTaskId() %>" class="btn btn-outline-primary">
                <i class="fa fa-edit me-1"></i>Edit Task</a>
            <a href="<%= ctx %>/tasks/list" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-1"></i>Back to List</a>
        </div>
    </div>

    <%-- 1. THONG TIN TASK --%>
    <div class="card handover-section">
        <div class="card-header">
            <div class="section-title mb-0"><i class="fa fa-info-circle"></i> Task Information</div>
        </div>
        <div class="card-body p-0">
            <table class="task-info-table">
                <thead class="visually-hidden"><tr><th>Field</th><th>Value</th></tr></thead>
                <tbody>
                    <td>Task ID</td>
                    <td>#<%= task.getTaskId() %></td>
                </tr>
                <tr>
                    <td>Title</td>
                    <td><strong><%= task.getTitle() != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(task.getTitle()) : "-" %></strong></td>
                </tr>
                <tr>
                    <td>Description</td>
                    <td><%= task.getDescription() != null && !task.getDescription().isBlank() ? org.apache.taglibs.standard.functions.Functions.escapeXml(task.getDescription()).replace("\n", "<br>") : "-" %></td>
                </tr>
                <tr>
                    <td>Status</td>
                    <td><span class="badge <%= statusBadge.apply(task.getStatus()) %>"><%= task.getStatus() != null ? task.getStatus() : "N/A" %></span></td>
                </tr>
                <tr>
                    <td>Priority</td>
                    <td><span class="badge <%= priorityBadge.apply(task.getPriority()) %>"><%= task.getPriority() != null ? task.getPriority() : "N/A" %></span></td>
                </tr>
                <tr>
                    <td>Progress</td>
                    <td>
                        <div class="d-flex align-items-center gap-2">
                            <div class="progress flex-grow-1" style="height: 8px; max-width: 200px;">
                                <div class="progress-bar bg-info" style="width: <%= task.getProgress() != null ? task.getProgress() : 0 %>%"></div>
                            </div>
                            <small><%= task.getProgress() != null ? task.getProgress() : 0 %>%</small>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Start Date</td>
                    <td><%= task.getStartDate() != null ? task.getStartDate().format(dtf) : "-" %></td>
                </tr>
                <tr>
                    <td>Due Date</td>
                    <td><%= task.getDueDate() != null ? task.getDueDate().format(dtf) : "-" %></td>
                </tr>
                <tr>
                    <td>Created By</td>
                    <td><%= task.getCreatedBy() != null && task.getCreatedBy().getFullName() != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(task.getCreatedBy().getFullName()) : (task.getCreatedBy() != null ? task.getCreatedBy().getUsername() : "-") %></td>
                </tr>
                <tr>
                    <td>Created At</td>
                    <td><%= task.getCreatedAt() != null ? task.getCreatedAt().format(dtf) : "-" %></td>
                </tr>
                <% if (task.getCompletedAt() != null) { %>
                <tr>
                    <td>Completed At</td>
                    <td><%= task.getCompletedAt().format(dtf) %></td>
                </tr>
                <% } %>
            </tbody>
            </table>
        </div>
    </div>

    <%-- 2. NGUOI DUOC GAN (ASSIGNEES) --%>
    <div class="card handover-section">
        <div class="card-header">
            <div class="section-title mb-0"><i class="fa fa-users"></i> Assignees</div>
        </div>
        <div class="card-body">
            <% if (task.getAssignees() != null && !task.getAssignees().isEmpty()) { %>
            <div class="assignee-list">
                <% for (model.TaskAssignee ta : task.getAssignees()) {
                    if (ta.isActive() && ta.getUser() != null) {
                        String name = ta.getUser().getFullName() != null && !ta.getUser().getFullName().isBlank()
                            ? ta.getUser().getFullName() : ta.getUser().getUsername();
                        String initial = name.substring(0, 1).toUpperCase();
                %>
                <div class="assignee-chip">
                    <span class="avatar"><%= initial %></span>
                    <span><%= org.apache.taglibs.standard.functions.Functions.escapeXml(name) %></span>
                    <% if (ta.isPrimary()) { %><span class="badge bg-primary" style="font-size: .65rem;">Lead</span><% } %>
                </div>
                <%  }
                   } %>
            </div>
            <% } else { %>
            <div class="empty-state"><i class="fa fa-user-slash"></i>No assignees</div>
            <% } %>
        </div>
    </div>

    <%-- 3. WORK ITEMS / SUBTASKS --%>
    <div class="card handover-section">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div class="section-title mb-0"><i class="fa fa-tasks"></i> Work Items / Subtasks</div>
            <% if (workItemCount != null && completedCount != null) { %>
            <span class="badge bg-<%= completedCount.equals(workItemCount) ? "success" : "secondary" %>">
                <%= completedCount %> / <%= workItemCount %> completed
            </span>
            <% } %>
        </div>
        <div class="card-body">
            <% if (rootWorkItems.isEmpty()) { %>
            <div class="empty-state"><i class="fa fa-tasks"></i>No work items yet</div>
            <% } else { %>
                <% for (TaskComment wi : rootWorkItems) {
                    List<TaskComment> replies = repliesMap.get(wi.getCommentId());
                    String authorName = wi.getAuthorName() != null ? wi.getAuthorName() : "Unknown";
                    String initial = authorName.substring(0, 1).toUpperCase();
                    boolean done = wi.isCompleted();
                %>
                <div class="wi-item <%= done ? "wi-done" : "" %>">
                    <div class="wi-checkbox">
                        <input type="checkbox" <%= done ? "checked disabled" : "disabled" %>>
                    </div>
                    <div class="wi-content">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="wi-author"><%= org.apache.taglibs.standard.functions.Functions.escapeXml(authorName) %></div>
                                <div class="wi-meta">
                                    <%= wi.getCreatedAt() != null ? wi.getCreatedAt().format(dtf) : "" %>
                                    <% if (done && wi.getCompletedAt() != null) { %>
                                    <span class="text-success ms-2"><i class="fa fa-check-circle"></i> Done: <%= wi.getCompletedAt().format(dtf) %></span>
                                    <% } %>
                                </div>
                            </div>
                            <span class="badge bg-<%= done ? "success" : "secondary" %>"><%= done ? "Done" : "Pending" %></span>
                        </div>
                        <div class="wi-content-main"><%= wi.getContent() != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(wi.getContent()) : "" %></div>
                        <% if (wi.getAssignedTo() != null) {
                            String assignedName = wi.getAssignedName();
                            if (assignedName == null) assignedName = "User #" + wi.getAssignedTo();
                        %>
                        <div class="wi-assignee"><i class="fa fa-user-tag"></i> Assigned to: <%= org.apache.taglibs.standard.functions.Functions.escapeXml(assignedName) %></div>
                        <% } %>

                        <%-- Replies --%>
                        <% if (replies != null && !replies.isEmpty()) { %>
                        <div class="wi-replies">
                            <% for (TaskComment reply : replies) {
                                String replyAuthor = reply.getAuthorName() != null ? reply.getAuthorName() : "Unknown";
                            %>
                            <div class="wi-item" style="padding: 6px 10px; margin-bottom: 4px;">
                                <div class="wi-content">
                                    <div class="wi-meta">
                                        <strong><%= org.apache.taglibs.standard.functions.Functions.escapeXml(replyAuthor) %></strong>
                                        <% if (reply.isCompleted()) { %><span class="badge bg-success ms-1" style="font-size: .65rem;">Done</span><% } %>
                                    </div>
                                    <div class="wi-content-main" style="font-size: .813rem;"><%= reply.getContent() != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(reply.getContent()) : "" %></div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <%-- 4. LICH SU THAY DOI (CHANGE HISTORY) --%>
    <div class="card handover-section">
        <div class="card-header">
            <div class="section-title mb-0"><i class="fa fa-history"></i> Change History</div>
        </div>
        <div class="card-body">
            <% if (historyViews.isEmpty()) { %>
            <div class="empty-state"><i class="fa fa-history"></i>No history yet</div>
            <% } else { %>
            <div class="vh-timeline">
                <% for (HistoryView hv : historyViews) {
                    TaskHistory h = hv.getHistory();
                    int hid = h != null ? h.getHistoryId() : 0;
                    List<TaskHistoryDetail> dets = h != null ? h.getDetails() : new ArrayList<>();
                    if (dets == null) dets = new ArrayList<>();

                    java.util.LinkedHashSet<String> lbls = new java.util.LinkedHashSet<>();
                    for (TaskHistoryDetail d : dets) {
                        String fname = d != null && d.getFieldName() != null ? d.getFieldName().trim().toLowerCase() : "";
                        switch (fname) {
                            case "progress"         -> lbls.add("Progress updated");
                            case "status"           -> lbls.add("Status changed");
                            case "priority"         -> lbls.add("Priority changed");
                            case "duedate"          -> lbls.add("Due date changed");
                            case "title"            -> lbls.add("Title changed");
                            case "description"      -> lbls.add("Description changed");
                            case "assignee_added"   -> lbls.add("Assignee added");
                            case "assignee_removed" -> lbls.add("Assignee removed");
                            case "created"          -> lbls.add("Task created");
                            default -> { if (!fname.isEmpty()) lbls.add(fname.replace('_', ' ')); }
                        }
                    }
                    String summary = lbls.isEmpty() ? "Updated" : String.join(" &middot; ", lbls);
                    String cid = "vh_" + hid;
                %>
                <div class="vh-item">
                    <div class="vh-time"><%= hv.getChangedAtDisplay() %></div>
                    <div class="vh-sum">
                        <%= summary %>
                        <% if (hv.getChangedByName() != null && !hv.getChangedByName().isBlank()) { %>
                        <span class="text-muted small fw-normal">
                            by <%= org.apache.taglibs.standard.functions.Functions.escapeXml(hv.getChangedByName()) %>
                        </span>
                        <% } %>
                    </div>
                    <% if (!dets.isEmpty()) { %>
                    <a class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size:.75rem"
                       data-bs-toggle="collapse" href="#<%= cid %>">
                        <i class="fa fa-caret-down me-1"></i>Details</a>
                    <div class="collapse" id="<%= cid %>">
                        <div class="vh-det">
                            <% for (TaskHistoryDetail d : dets) {
                                String fieldName = d.getFieldName() != null ? d.getFieldName().replace('_', ' ') : "";
                                String oldVal = d.getOldValue();
                                String newVal = d.getNewValue();

                                // Resolve assignee names
                                if (d.getFieldName() != null) {
                                    String fn = d.getFieldName().trim().toLowerCase();
                                    if ("assignee_added".equals(fn) && newVal != null) {
                                        try {
                                            int uid = Integer.parseInt(newVal.trim());
                                            String name = assigneeNamesMap.get(uid);
                                            if (name != null) newVal = name + " (#" + uid + ")";
                                        } catch (NumberFormatException ignored) {}
                                    } else if ("assignee_removed".equals(fn) && oldVal != null) {
                                        try {
                                            int uid = Integer.parseInt(oldVal.trim());
                                            String name = assigneeNamesMap.get(uid);
                                            if (name != null) oldVal = name + " (#" + uid + ")";
                                        } catch (NumberFormatException ignored) {}
                                    }
                                }
                            %>
                            <div class="vh-det-row">
                                <div class="vh-field"><%= org.apache.taglibs.standard.functions.Functions.escapeXml(fieldName) %></div>
                                <div class="vh-old" title="<%= oldVal != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(oldVal) : "" %>">
                                    <%= oldVal != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(oldVal) : "&mdash;" %>
                                </div>
                                <div class="vh-arrow">&rarr;</div>
                                <div class="vh-new" title="<%= newVal != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(newVal) : "" %>">
                                    <%= newVal != null ? org.apache.taglibs.standard.functions.Functions.escapeXml(newVal) : "&mdash;" %>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

</div></div>
