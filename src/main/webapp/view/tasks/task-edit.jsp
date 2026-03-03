<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Task, model.TaskAssignee, model.User, java.util.List, java.util.HashSet" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }

    // collect current assignee IDs for pre-checking
    java.util.Set<Integer> currentAssignees = new HashSet<>();
    if (task.getassignees() != null) {
        for (TaskAssignee ta : task.getassignees()) {
            if (ta.getUser() != null) currentAssignees.add(ta.getUser().getUserId());
        }
    }
    String dueDateVal = task.getDueDate() != null
            ? task.getDueDate().toString().substring(0, 16) : "";
%>
<div>
<div class="page-wrapper">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Edit Task</h4>
        <h6><%= task.getTitle() %></h6>
      </div>
      <a href="${pageContext.request.contextPath}/tasks/details?id=<%= task.getTaskId() %>"
         class="btn btn-outline-secondary">
        <i class="fa fa-arrow-left me-1"></i> Back to Details
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
      <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/tasks/edit">
          <input type="hidden" name="taskId" value="<%= task.getTaskId() %>">

          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" required
                     value="<%= task.getTitle() != null ? task.getTitle() : "" %>">
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Priority</label>
              <select name="priority" class="form-select">
                <% for (String p : new String[]{"Low","Medium","High"}) { %>
                <option value="<%= p %>" <%= p.equalsIgnoreCase(task.getPriority()) ? "selected" : "" %>><%= p %></option>
                <% } %>
              </select>
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="4"><%=
                  task.getDescription() != null ? task.getDescription() : "" %></textarea>
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <% for (String s : new String[]{"Pending","In Progress","Done","Overdue","Cancelled"}) { %>
                <option value="<%= s %>" <%= s.equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>><%= s %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Due Date</label>
              <input type="datetime-local" name="dueDate" class="form-control"
                     value="<%= dueDateVal %>">
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Progress (%)</label>
              <input type="number" name="progress" class="form-control" min="0" max="100"
                     value="<%= task.getProgress() != null ? task.getProgress() : 0 %>">
            </div>

            <!-- Assignees managed separately via assign API on detail page;
                 shown here as read-only for reference -->
            <div class="col-12">
              <label class="form-label fw-semibold">Current Assignees</label>
              <div class="d-flex flex-wrap gap-2">
                <% if (task.getassignees() == null || task.getassignees().isEmpty()) { %>
                  <span class="text-muted">None – manage from the detail page.</span>
                <% } else {
                    for (TaskAssignee ta : task.getassignees()) {
                        String n = ta.getUser() != null && ta.getUser().getFullName() != null
                                   ? ta.getUser().getFullName() : "Unknown"; %>
                  <span class="badge bg-light text-dark border"><%= n %></span>
                <% } } %>
              </div>
              <small class="text-muted">To add/remove assignees, use the Assign section on the Detail page.</small>
            </div>
          </div><!-- /row -->

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i> Save Changes
            </button>
            <a href="${pageContext.request.contextPath}/tasks/details?id=<%= task.getTaskId() %>"
               class="btn btn-outline-secondary">
              Cancel
            </a>
          </div>
        </form>
      </div>
    </div>

  </div>
</div>
</div>
