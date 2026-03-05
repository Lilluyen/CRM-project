<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Task, model.TaskAssignee, java.util.List" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }
    int prog = task.getProgress() != null ? task.getProgress() : 0;
%>

<style>
  @media (min-width: 992px){
        .mini-sidebar .badge {
            display: inline-block !important;
        }

        .mini-sidebar.expand-menu .badge {
            display: inline-block !important;
        }
    }
</style>
<div >
<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Task Details</h4>
        <h6><%= task.getTitle() %></h6>
      </div>
      <div class="page-btn d-flex gap-2">
        <a href="${pageContext.request.contextPath}/tasks/edit?id=<%= task.getTaskId() %>"
           class="btn btn-warning">
          <i class="fa fa-edit me-1"></i> Edit
        </a>
        <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
          <i class="fa fa-arrow-left me-1"></i> Back
        </a>
      </div>
    </div>

    <div class="row">
      <!-- Main Info -->
      <div class="col-lg-8">
        <div class="card">
          <div class="card-header"><h5 class="card-title mb-0">Task Information</h5></div>
          <div class="card-body">
            <table class="table table-borderless">
              <tr><th style="width:140px">Title</th>
                  <td><strong><%= task.getTitle() %></strong></td></tr>
              <tr><th>Description</th>
                  <td><%= task.getDescription() != null ? task.getDescription() : "-" %></td></tr>
              <tr><th>Status</th>
                  <td>
                    <span class="badge <%= "Done".equalsIgnoreCase(task.getStatus()) ? "bg-success"
                                         : "In Progress".equalsIgnoreCase(task.getStatus()) ? "bg-info text-dark"
                                         : "Overdue".equalsIgnoreCase(task.getStatus()) ? "bg-danger"
                                         : "Cancelled".equalsIgnoreCase(task.getStatus()) ? "bg-dark"
                                         : "bg-warning text-dark" %>">
                      <%= task.getStatus() != null ? task.getStatus() : "-" %>
                    </span>
                  </td></tr>
              <tr><th>Priority</th>
                  <td>
                    <span class="badge <%= "High".equalsIgnoreCase(task.getPriority()) ? "bg-danger"
                                         : "Low".equalsIgnoreCase(task.getPriority()) ? "bg-success"
                                         : "bg-warning text-dark" %>">
                      <%= task.getPriority() != null ? task.getPriority() : "-" %>
                    </span>
                  </td></tr>
              <tr><th>Due Date</th>
                  <td><%= task.getDueDate() != null ? task.getDueDate().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
              <tr><th>Created By</th>
                  <td><%= task.getCreatedBy() != null && task.getCreatedBy().getFullName() != null
                           ? task.getCreatedBy().getFullName() : "-" %></td></tr>
              <tr><th>Created At</th>
                  <td><%= task.getCreatedAt() != null ? task.getCreatedAt().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
              <tr><th>Last Updated</th>
                  <td><%= task.getUpdatedAt() != null ? task.getUpdatedAt().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
            </table>
          </div>
        </div>

        <!-- Assignees -->
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="card-title mb-0">Assignees</h5>
          </div>
          <div class="card-body">
            <% List<TaskAssignee> assignees = task.getassignees();
               if (assignees == null || assignees.isEmpty()) { %>
              <p class="text-muted">No assignees yet.</p>
            <% } else {
                for (TaskAssignee ta : assignees) {
                    String name  = ta.getUser() != null && ta.getUser().getFullName() != null
                                   ? ta.getUser().getFullName() : "Unknown";
                    String email = ta.getUser() != null ? ta.getUser().getEmail() : "";
            %>
              <div class="d-flex align-items-center gap-3 py-2 border-bottom">
                <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"
                     style="width:36px;height:36px;font-weight:600">
                  <%= name.substring(0,1).toUpperCase() %>
                </div>
                <div>
                  <div class="fw-semibold"><%= name %></div>
                  <small class="text-muted"><%= email != null ? email : "" %></small>
                </div>
                <div class="ms-auto">
                  <small class="text-muted">
                    Assigned: <%= ta.getAssignedAt() != null
                                  ? ta.getAssignedAt().toString().replace("T"," ").substring(0,16) : "-" %>
                  </small>
                </div>
              </div>
            <% } } %>
          </div>
        </div>
      </div><!-- /col-lg-8 -->

      <!-- Progress Panel -->
      <div class="col-lg-4">
        <div class="card">
          <div class="card-header"><h5 class="card-title mb-0">Progress</h5></div>
          <div class="card-body text-center">
            <div style="font-size:2.5rem;font-weight:700;color:#0d6efd" id="prog-display"><%= prog %>%</div>
            <div class="progress my-3" style="height:14px;">
              <div class="progress-bar <%= prog < 40 ? "bg-danger" : prog < 75 ? "bg-warning" : "bg-success" %>"
                   id="prog-bar" role="progressbar" style="width:<%= prog %>%"
                   aria-valuenow="<%= prog %>" aria-valuemin="0" aria-valuemax="100"></div>
            </div>
            <input type="range" class="form-range" id="prog-range" min="0" max="100" step="5"
                   value="<%= prog %>" oninput="previewProgress(this.value)">
            <div class="d-flex justify-content-between"><small>0%</small><small>100%</small></div>
            <button class="btn btn-primary mt-3 w-100"
                    onclick="saveProgress(<%= task.getTaskId() %>)">
              <i class="fa fa-save me-1"></i> Update Progress
            </button>
          </div>
        </div>

        <!-- Quick Status Change -->
        <div class="card">
          <div class="card-header"><h5 class="card-title mb-0">Change Status</h5></div>
          <div class="card-body">
            <select id="status-select" class="form-select mb-2">
              <% for (String s : new String[]{"Pending","In Progress","Done","Overdue","Cancelled"}) { %>
              <option value="<%= s %>" <%= s.equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>><%= s %></option>
              <% } %>
            </select>
            <button class="btn btn-outline-primary w-100"
                    onclick="saveStatus(<%= task.getTaskId() %>)">
              <i class="fa fa-check me-1"></i> Apply Status
            </button>
          </div>
        </div>

      </div><!-- /col-lg-4 -->
    </div><!-- /row -->
  </div>
</div>
<script>
function previewProgress(val) {
    document.getElementById('prog-display').textContent = val + '%';
    var bar = document.getElementById('prog-bar');
    bar.style.width = val + '%';
    bar.className = 'progress-bar ' + (val < 40 ? 'bg-danger' : val < 75 ? 'bg-warning' : 'bg-success');
}
function saveProgress(taskId) {
    var progress = document.getElementById('prog-range').value;
    fetch('${pageContext.request.contextPath}/tasks/progress', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'taskId=' + taskId + '&progress=' + progress
    }).then(r=>r.json()).then(res=>{
        if (res.success) location.reload();
        else alert('Failed to update progress');
    });
}
function saveStatus(taskId) {
    var status = document.getElementById('status-select').value;
    fetch('${pageContext.request.contextPath}/tasks/status', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'taskId=' + taskId + '&status=' + encodeURIComponent(status)
    }).then(r=>r.json()).then(res=>{
        if (res.success) location.reload();
        else alert('Failed to update status');
    });
}
</script>
</div>
