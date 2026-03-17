<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Task, model.TaskAssignee, model.User, java.util.HashSet, java.util.Set" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }

    boolean isManager = Boolean.TRUE.equals(request.getAttribute("isManager"));
    boolean canEditDuePriority = Boolean.TRUE.equals(request.getAttribute("canEditDuePriority"));

    String dueDateVal = task.getDueDate() != null ? task.getDueDate().toString().substring(0, 16) : "";
    String startDateVal = task.getStartDate() != null ? task.getStartDate().toString().substring(0, 16) : "";
    String completedAtVal = task.getCompletedAt() != null ? task.getCompletedAt().toString().substring(0, 16) : "";

    Set<Integer> currentAssigneeIds = new HashSet<>();
    if (task.getAssignees() != null) {
        for (TaskAssignee ta : task.getAssignees()) {
            if (ta.getUser() != null) currentAssigneeIds.add(ta.getUser().getUserId());
        }
    }
    int prog = task.getProgress() != null ? task.getProgress() : 0;
    String progBarCls = prog < 40 ? "bg-danger" : prog < 75 ? "bg-warning" : "bg-success";
%>
<style>
  .readonly-hint { font-size:.75rem; color:#6c757d; }
  .progress-big  { height:18px; border-radius:9px; }
  #prog-display  { font-size:2.4rem; font-weight:700; color:#0d6efd; line-height:1; }
  .assign-badge  { display:inline-flex; align-items:center; gap:4px;
                   background:#e9ecef; border-radius:20px; padding:3px 10px; font-size:.85rem; }
  .assign-badge .remove-btn { cursor:pointer; color:#dc3545; font-weight:700; }
  .history-table td, .history-table th { font-size:.82rem; vertical-align:middle; }
  #assignSearch  { border-radius:6px 6px 0 0; }
  #assignList    { max-height:240px; overflow-y:auto; border:1px solid #dee2e6;
                   border-top:0; border-radius:0 0 6px 6px; }
  #assignList .user-item { padding:8px 12px; cursor:pointer; border-bottom:1px solid #f1f3f5;
                            display:flex; align-items:center; gap:8px; }
  #assignList .user-item:hover { background:#f8f9fa; }
  #assignList .user-item.selected { background:#e7f5ff; }
  .tab-pane { padding-top:1.2rem; }
</style>

<div class="">
 <div class="content">

  <%-- ── Header ─────────────────────────────────────────────────────── --%>
  <div class="page-header">
    <div class="page-title">
      <h4>Edit Task</h4>
      <h6><%= task.getTitle() %></h6>
    </div>
    <div class="d-flex gap-2">
      <a href="${pageContext.request.contextPath}/tasks/view-history?id=<%= task.getTaskId() %>"
         class="btn btn-outline-dark btn-sm"><i class="fa fa-history me-1"></i>History</a>
      <a href="${pageContext.request.contextPath}/tasks/details?id=<%= task.getTaskId() %>"
         class="btn btn-outline-info btn-sm"><i class="fa fa-eye me-1"></i>View</a>
      <a href="${pageContext.request.contextPath}/tasks/list"
         class="btn btn-outline-secondary btn-sm"><i class="fa fa-arrow-left me-1"></i>List</a>
    </div>
  </div>

  <c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show">
      ${error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <%-- ── Tabs ──────────────────────────────────────────────────────────── --%>
  <ul class="nav nav-tabs mb-0" id="editTabs">
    <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#tabInfo">
      <i class="fa fa-edit me-1"></i>Task Info</a></li>
<!--    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#tabProgress">
      <i class="fa fa-tasks me-1"></i>Progress / Status</a></li>-->
    <% if (isManager) { %>
    <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#tabAssign">
      <i class="fa fa-users me-1"></i>Assignees</a></li>
    <% } %>
  </ul>

  <div class="card border-top-0" style="border-radius:0 0 .5rem .5rem">
   <div class="card-body">
    <div class="tab-content" id="editTabsContent">

      <%-- ══════════════════════════════════════════════════════════════════
           TAB 1 – TASK INFO
      ══════════════════════════════════════════════════════════════════ --%>
      <div class="tab-pane fade show active" id="tabInfo">
        <form method="post" action="${pageContext.request.contextPath}/tasks/edit" id="editForm">
          <input type="hidden" name="taskId" value="<%= task.getTaskId() %>">

          <div class="row g-3">
            <%-- Title – editable for everyone --%>
            <div class="col-md-8">
              <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" required maxlength="200"
                     value="<%= task.getTitle() != null ? task.getTitle() : "" %>">
            </div>

            <%-- Priority – manager only --%>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Priority</label>
              <% if (canEditDuePriority) { %>
              <select name="priority" class="form-select">
                <% for (String p : new String[]{"Low","Medium","High"}) { %>
                <option value="<%= p %>" <%= p.equalsIgnoreCase(task.getPriority()) ? "selected" : "" %>><%= p %></option>
                <% } %>
              </select>
              <% } else { %>
              <input type="text" class="form-control" value="<%= task.getPriority() %>" readonly>
              <small class="readonly-hint"><i class="fa fa-lock me-1"></i>Locked</small>
              <% } %>
            </div>

            <%-- Description – editable for everyone --%>
            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="4"><%=
                  task.getDescription() != null ? task.getDescription() : "" %></textarea>
            </div>

            <%-- Status – editable for everyone --%>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <% for (String s : new String[]{"Pending","In Progress","Done","Overdue","Cancelled"}) { %>
                <option value="<%= s %>" <%= s.equalsIgnoreCase(task.getStatus()) ? "selected" : "" %>><%= s %></option>
                <% } %>
              </select>
            </div>

            <%-- Due Date – manager only --%>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Due Date</label>
              <% if (canEditDuePriority) { %>
              <input type="datetime-local" name="dueDate" class="form-control" value="<%= dueDateVal %>">
              <% } else { %>
              <input type="text" class="form-control"
                     value="<%= task.getDueDate() != null ? task.getDueDate().toString().replace("T"," ").substring(0,16) : "-" %>"
                     readonly>
              <small class="readonly-hint"><i class="fa fa-lock me-1"></i>Locked</small>
              <% } %>
            </div>

            <%-- Progress (inline in form so it saves together) – everyone --%>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Progress (%)</label>
              <input type="number" name="progress" id="inlineProgress" readonly="readonly" class="form-control"
                     min="0" max="100" value="<%= prog %>"
                     oninput="syncProgressBar(this.value)">
              <div class="progress progress-big mt-2">
                <div class="progress-bar <%= progBarCls %>" id="inlineProgBar"
                     role="progressbar" style="width:<%= prog %>%"
                     aria-valuenow="<%= prog %>" aria-valuemin="0" aria-valuemax="100"></div>
              </div>
            </div>

            <%-- Start Date / Completed At (read-only for most users) --%>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Start Date</label>
              <% if (canEditDuePriority) { %>
              <input type="datetime-local" name="startDate" class="form-control" value="<%= startDateVal %>">
              <% } else { %>
              <input type="text" class="form-control" value="<%= startDateVal.isEmpty() ? "-" : startDateVal.replace("T"," ") %>" readonly>
              <small class="readonly-hint"><i class="fa fa-lock me-1"></i>Locked</small>
              <% } %>
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Completed At</label>
              <input type="text" class="form-control" value="<%= completedAtVal.isEmpty() ? "-" : completedAtVal.replace("T"," ") %>" readonly>
              <small class="readonly-hint"><i class="fa fa-info-circle me-1"></i>Auto-updated</small>
            </div>
          </div><%-- /row --%>

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i>Save Changes
            </button>
            <a href="${pageContext.request.contextPath}/tasks/details?id=<%= task.getTaskId() %>"
               class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div><%-- /tabInfo --%>

      <%-- ══════════════════════════════════════════════════════════════════
           TAB 2 – PROGRESS / STATUS (AJAX quick-update)
      ══════════════════════════════════════════════════════════════════ --%>
      <div class="tab-pane fade" id="tabProgress">
        <div class="row g-4">
          <%-- Progress slider --%>
          <div class="col-lg-6">
            <div class="card border">
              <div class="card-header fw-semibold"><i class="fa fa-chart-line me-1"></i>Progress</div>
              <div class="card-body text-center">
                <div id="prog-display"><%= prog %>%</div>
                <div class="progress progress-big my-3">
                  <div class="progress-bar <%= progBarCls %>" id="prog-bar"
                       role="progressbar" style="width:<%= prog %>%"></div>
                </div>
                <input type="range" class="form-range" id="prog-range"
                       min="0" max="100" step="1" value="<%= prog %>"
                       oninput="previewProgress(this.value)">
                <div class="d-flex justify-content-between mb-2"><small>0%</small><small>100%</small></div>
                <button class="btn btn-primary w-100"
                        onclick="ajaxProgress(<%= task.getTaskId() %>)">
                  <i class="fa fa-save me-1"></i>Update Progress
                </button>
              </div>
            </div>
          </div>

          <%-- Status quick-set --%>
          <div class="col-lg-6">
            <div class="card border">
              <div class="card-header fw-semibold"><i class="fa fa-flag me-1"></i>Change Status</div>
              <div class="card-body">
                <% String[] statuses = {"Pending","In Progress","Done","Overdue","Cancelled"};
                   String[] stColors = {"warning","info","success","danger","dark"};
                   for (int si = 0; si < statuses.length; si++) {
                       boolean active = statuses[si].equalsIgnoreCase(task.getStatus());
                %>
                <button type="button"
                        class="btn btn-outline-<%= stColors[si] %> w-100 mb-2 <%= active ? "active" : "" %>"
                        onclick="ajaxStatus(<%= task.getTaskId() %>, '<%= statuses[si] %>', this)">
                  <%= active ? "<i class='fa fa-check me-1'></i>" : "" %><%= statuses[si] %>
                </button>
                <% } %>
              </div>
            </div>
          </div>
        </div>
      </div><%-- /tabProgress --%>

      <%-- ══════════════════════════════════════════════════════════════════
           TAB 3 – ASSIGNEES (manager/admin only)
      ══════════════════════════════════════════════════════════════════ --%>
      <% if (isManager) { %>
      <div class="tab-pane fade" id="tabAssign">
        <div class="row g-4">

          <%-- Current assignees --%>
          <div class="col-lg-5">
            <h6 class="fw-semibold mb-3">Current Assignees</h6>
            <div id="currentAssignees" class="d-flex flex-wrap gap-2 mb-3">
              <% if (task.getAssignees() == null || task.getAssignees().isEmpty()) { %>
                <span class="text-muted small">No assignees yet.</span>
              <% } else {
                  for (TaskAssignee ta : task.getAssignees()) {
                      if (ta.getUser() == null) continue;
                      String name = ta.getUser().getFullName() != null ? ta.getUser().getFullName() : ta.getUser().getUsername();
              %>
                <span class="assign-badge" data-uid="<%= ta.getUser().getUserId() %>">
                  <i class="fa fa-user-circle"></i>
                  <%= name %>
                </span>
              <% } } %>
            </div>
          </div>

          <%-- Search + multi-select --%>
          <div class="col-lg-7">
            <h6 class="fw-semibold mb-3">Add / Remove Assignees</h6>

            <input type="text" id="assignSearch" class="form-control"
                   placeholder="Search by name or email…"
                   oninput="filterUsers(this.value)">
            <div id="assignList">
              <div class="text-center py-3 text-muted">
                <i class="fa fa-spinner fa-spin me-1"></i> Loading users...
              </div>
            </div>

            <div class="d-flex gap-2 mt-3">
              <button type="button" class="btn btn-success" onclick="saveAssignees(<%= task.getTaskId() %>)">
                <i class="fa fa-save me-1"></i>Save Assignees
              </button>
              <span id="assignMsg" class="align-self-center small text-success"></span>
            </div>
          </div>
        </div>
      </div><%-- /tabAssign --%>
      <% } %>

    </div><%-- /tab-content --%>
   </div><%-- /card-body --%>
  </div><%-- /card --%>

 </div><%-- /content --%>
</div><%-- /page-wrapper --%>

<script>
const CTX = '${pageContext.request.contextPath}';
const TASK_ID = <%= task.getTaskId() %>;

/* ── Inline progress bar sync ─────────────────────────────────────── */
function syncProgressBar(val) {
    const bar = document.getElementById('inlineProgBar');
    if (!bar) return;
    bar.style.width = val + '%';
    bar.className = 'progress-bar ' + (val < 40 ? 'bg-danger' : val < 75 ? 'bg-warning' : 'bg-success');
}

/* ── Progress tab preview ─────────────────────────────────────────── */
function previewProgress(val) {
    document.getElementById('prog-display').textContent = val + '%';
    const bar = document.getElementById('prog-bar');
    bar.style.width = val + '%';
    bar.className = 'progress-bar ' + (val < 40 ? 'bg-danger' : val < 75 ? 'bg-warning' : 'bg-success');
}

/* ── AJAX: save progress ──────────────────────────────────────────── */
function ajaxProgress(taskId) {
    const progress = document.getElementById('prog-range').value;
    fetch(CTX + '/tasks/edit', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'subAction=progress&taskId=' + taskId + '&progress=' + progress
    }).then(r => r.json()).then(res => {
        if (res.success) showToast('Progress updated!', 'success');
        else showToast(res.message || 'Failed', 'danger');
    }).catch(e => showToast('Error: ' + e.message, 'danger'));
}

/* ── AJAX: quick status change ────────────────────────────────────── */
function ajaxStatus(taskId, status, btn) {
    fetch(CTX + '/tasks/edit', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'subAction=status&taskId=' + taskId + '&status=' + encodeURIComponent(status)
    }).then(r => r.json()).then(res => {
        if (res.success) {
            document.querySelectorAll('#tabProgress .btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            showToast('Status changed to ' + status, 'success');
        } else showToast(res.message || 'Failed', 'danger');
    }).catch(e => showToast('Error', 'danger'));
}

/* ── Assignee AJAX load + live-search ─────────────────────────────── */
const CURRENT_ASSIGNEE_IDS = new Set([<%= String.join(",", currentAssigneeIds.stream().map(String::valueOf).toArray(String[]::new)) %>]);

function loadAssignUsers() {
    fetch(CTX + '/api/related-entities?type=user')
        .then(r => r.json())
        .then(users => {
            const box = document.getElementById('assignList');
            if (!users || !users.length) {
                box.innerHTML = '<div class="text-muted text-center py-3">No users found.</div>';
                return;
            }
            box.innerHTML = users.map(u => {
                const nm = esc(u.name || '?');
                const em = esc(u.email || '');
                const ini = (u.name || '?').charAt(0).toUpperCase();
                const sel = CURRENT_ASSIGNEE_IDS.has(u.id);
                const selClass = sel ? 'selected' : '';
                const iconClass = sel ? 'fa-check-circle text-success' : 'fa-circle text-muted';
                return '<div class="user-item ' + selClass + '"' +
                    ' data-uid="' + u.id + '"' +
                    ' data-name="' + (u.name || '').toLowerCase() + '"' +
                    ' data-email="' + (u.email || '').toLowerCase() + '"' +
                    ' onclick="toggleUser(this)">' +
                    '<div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"' +
                    ' style="width:32px;height:32px;flex-shrink:0;font-weight:600">' + ini + '</div>' +
                    '<div>' +
                    '<div class="fw-semibold" style="font-size:.88rem">' + nm + '</div>' +
                    '<div class="text-muted" style="font-size:.78rem">' + em + '</div>' +
                    '</div>' +
                    '<i class="fa ' + iconClass + ' ms-auto" id="check-' + u.id + '"></i>' +
                    '</div>';
            }).join('');
        })
        .catch(() => {
            document.getElementById('assignList').innerHTML =
                '<div class="text-danger text-center py-3"><i class="fa fa-exclamation-triangle me-1"></i>Failed to load users.</div>';
        });
}

function filterUsers(query) {
    const q = query.toLowerCase();
    document.querySelectorAll('#assignList .user-item').forEach(item => {
        const name  = item.dataset.name  || '';
        const email = item.dataset.email || '';
        item.style.display = (name.includes(q) || email.includes(q)) ? '' : 'none';
    });
}

/* ── Toggle user selection ────────────────────────────────────────── */
function toggleUser(el) {
    el.classList.toggle('selected');
    const uid = el.dataset.uid;
    const icon = document.getElementById('check-' + uid);
    if (icon) {
        icon.className = el.classList.contains('selected')
            ? 'fa fa-check-circle text-success ms-auto'
            : 'fa fa-circle text-muted ms-auto';
    }
}

/* ── Save assignees ───────────────────────────────────────────────── */
function saveAssignees(taskId) {
    const selected = [];
    document.querySelectorAll('#assignList .user-item.selected').forEach(el => {
        selected.push(el.dataset.uid);
    });
    let body = 'subAction=assign&taskId=' + taskId;
    selected.forEach(uid => body += '&assigneeIds=' + uid);

    fetch(CTX + '/tasks/edit', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body
    }).then(r => r.json()).then(res => {
        const msg = document.getElementById('assignMsg');
        if (res.success) {
            msg.textContent = '✓ Assignees saved!';
            msg.className = 'align-self-center small text-success';
            setTimeout(() => location.reload(), 1000);
        } else {
            msg.textContent = '✗ ' + (res.message || 'Failed');
            msg.className = 'align-self-center small text-danger';
        }
    }).catch(() => {
        document.getElementById('assignMsg').textContent = '✗ Network error';
    });
}

function esc(s) {
    const d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML;
}

/* ── Load users on page ready ──────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function() {
    loadAssignUsers();
});

/* ── Toast helper ─────────────────────────────────────────────────── */
function showToast(msg, type) {
    alert(msg);
//    const id = 'toast_' + Date.now();
//    const div = document.createElement('div');
//    div.id = id;
//    div.className = `alert alert-${type} alert-dismissible fade show`;
//    div.style.cssText = 'position:fixed;top:70px;right:20px;z-index:9999;min-width:260px;';
//    div.innerHTML = msg + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
//    document.body.appendChild(div);
//    setTimeout(() => { const el = document.getElementById(id); if (el) el.remove(); }, 3500);
}
</script>
