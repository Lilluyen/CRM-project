<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Task, model.TaskAssignee, model.TaskHistory, model.TaskHistoryDetail, controller.tasks.TaskViewHistoryController.HistoryView, java.util.List, java.util.Map" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }
    int prog = task.getProgress() != null ? task.getProgress() : 0;

    @SuppressWarnings("unchecked")
    List<HistoryView> historyViews = (List<HistoryView>) request.getAttribute("historyViews");
    if (historyViews == null) historyViews = new java.util.ArrayList<>();

    @SuppressWarnings("unchecked")
    Map<Integer, String> assigneeNames = (Map<Integer, String>) request.getAttribute("assigneeNames");
    if (assigneeNames == null) assigneeNames = new java.util.HashMap<>();

    String ctx = request.getContextPath();
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

  .timeline-item { padding:10px 12px; border:1px solid #e9ecef; border-radius:10px; margin-bottom:10px; background:#fff; }
  .timeline-line { display:flex; gap:8px; align-items:center; }
  .timeline-time { font-weight:700; color:#0d6efd; white-space:nowrap; }
  .timeline-summary { flex:1; }
  .dropdown-list { display:inline-flex; align-items:center; justify-content:center; width:26px; height:26px;
                   border-radius:8px; border:1px solid #dee2e6; color:#212529; text-decoration:none; }
  .dropdown-list:hover { background:#f8f9fa; }
  .detail-box { margin-top:10px; padding:10px 12px; background:#f8f9fa; border-radius:10px; border:1px dashed #dee2e6; }
  .detail-row { display:flex; gap:10px; font-size:.9rem; padding:4px 0; border-bottom:1px solid rgba(0,0,0,.04); }
  .detail-row:last-child { border-bottom:0; }
  .detail-field { width:160px; color:#6c757d; font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
  .detail-old { color:#dc3545; }
  .detail-new { color:#198754; }
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
              <tr><th>Start Date</th>
                  <td><%= task.getStartDate() != null ? task.getStartDate().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
              <tr><th>Completed At</th>
                  <td><%= task.getCompletedAt() != null ? task.getCompletedAt().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
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
<!--            <input type="range" class="form-range" id="prog-range" min="0" max="100" step="1"
                   value="<%= prog %>" oninput="previewProgress(this.value)">-->
            <div class="d-flex justify-content-between"><small>0%</small><small>100%</small></div>
<!--            <button class="btn btn-primary mt-3 w-100"
                    onclick="saveProgress(<%= task.getTaskId() %>)">
              <i class="fa fa-save me-1"></i> Update Progress
            </button>-->
          </div>
        </div>

        <!-- Quick Status Change -->
<!--        <div class="card">
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
        </div>-->

      </div><!-- /col-lg-4 -->
    </div><!-- /row -->

    <!-- History -->
    <div class="card mt-3">
      <div class="card-header"><h5 class="card-title mb-0">History</h5></div>
      <div class="card-body">
        <% if (historyViews.isEmpty()) { %>
          <div class="alert alert-light border">
            <i class="fa fa-inbox me-1"></i>No change history yet.
          </div>
        <% } else {
             for (HistoryView hv : historyViews) {
                 TaskHistory h = hv.getHistory();
                 int hid = h != null ? h.getHistoryId() : 0;
                 List<TaskHistoryDetail> details = h != null ? h.getDetails() : null;
                 if (details == null) details = new java.util.ArrayList<>();

                 // Build summary labels unique-in-order
                 java.util.LinkedHashSet<String> labels = new java.util.LinkedHashSet<>();
                 for (TaskHistoryDetail d : details) {
                     String fn = d != null ? d.getFieldName() : null;
                     if (fn == null) continue;
                     String key = fn.trim();
                     if ("progress".equalsIgnoreCase(key)) labels.add("Update Progress");
                     else if ("status".equalsIgnoreCase(key)) labels.add("Update Status");
                     else if ("priority".equalsIgnoreCase(key)) labels.add("Update Priority");
                     else if ("dueDate".equalsIgnoreCase(key)) labels.add("Update Due Date");
                     else if ("title".equalsIgnoreCase(key)) labels.add("Update Title");
                     else if ("description".equalsIgnoreCase(key)) labels.add("Update Description");
                     else if ("assignee_added".equalsIgnoreCase(key) || "assignee_removed".equalsIgnoreCase(key)) labels.add("Update Assignee");
                     else labels.add("Update " + key);
                 }
                 String summary = labels.isEmpty() ? "Update" : String.join(", ", labels);
                 String collapseId = "hist_" + hid;
        %>
        <div class="timeline-item">
          <div class="timeline-line">
            <div class="timeline-time"><%= hv.getChangedAtDisplay() %>:</div>
            <div class="timeline-summary">
              <%= summary %>
              <% if (hv.getChangedByName() != null && !hv.getChangedByName().isBlank()) { %>
                <span class="text-muted">by <%= hv.getChangedByName() %></span>
              <% } %>
            </div>
            <a class="dropdown-list" data-bs-toggle="collapse" href="#<%= collapseId %>" role="button"
               aria-expanded="false" aria-controls="<%= collapseId %>" title="View details">
              <i class="fa fa-caret-down"></i>
            </a>
          </div>

          <div class="collapse" id="<%= collapseId %>">
            <div class="detail-box">
              <% if (details.isEmpty()) { %>
                <div class="text-muted small fst-italic">No detail.</div>
              <% } else {
                   for (TaskHistoryDetail d : details) {
                       String fn = d.getFieldName() != null ? d.getFieldName() : "";
                       String ov = d.getOldValue() != null ? d.getOldValue() : "";
                       String nv = d.getNewValue() != null ? d.getNewValue() : "";

                       // Pretty print assignee changes
                       if ("assignee_added".equalsIgnoreCase(fn)) {
                          try {
                              int uid = Integer.parseInt(nv.trim());
                              String name = assigneeNames.getOrDefault(uid, "User#" + uid);
                              fn = "assignee_added";
                              ov = "";
                              nv = name;
                          } catch (Exception ignored) {}
                       } else if ("assignee_removed".equalsIgnoreCase(fn)) {
                          try {
                              int uid = Integer.parseInt(ov.trim());
                              String name = assigneeNames.getOrDefault(uid, "User#" + uid);
                              fn = "assignee_removed";
                              nv = "";
                              ov = name;
                          } catch (Exception ignored) {}
                       }
              %>
              <div class="detail-row">
                <div class="detail-field"><%= fn %></div>
                <div class="detail-old"><%= ov.isBlank() ? "-" : ov %></div>
                <div class="text-muted">→</div>
                <div class="detail-new"><%= nv.isBlank() ? "-" : nv %></div>
              </div>
              <%   } // end details loop
                 } %>
            </div>
          </div>
        </div>
        <% } } %>
      </div>
    </div>

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
