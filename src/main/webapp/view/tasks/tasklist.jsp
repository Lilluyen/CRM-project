<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List, model.Task, model.TaskAssignee, java.util.ArrayList" %>

<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private String shorten(String s, int max) {
        if (s == null) return "";
        return s.length() > max ? s.substring(0, max) + "…" : s;
    }
%>
<%
    List<Task> tasks   = request.getAttribute("tasks") != null ? (List<Task>) request.getAttribute("tasks") : new ArrayList<>();
    int currentPage    = request.getAttribute("currentPage")  != null ? (Integer)request.getAttribute("currentPage")  : 1;
    int totalPages     = request.getAttribute("totalPages")   != null ? (Integer)request.getAttribute("totalPages")   : 1;
    int totalRecords   = request.getAttribute("totalRecords") != null ? (Integer)request.getAttribute("totalRecords") : 0;
    int pageSize       = request.getAttribute("pageSize")     != null ? (Integer)request.getAttribute("pageSize")     : 10;

    String p_title    = request.getParameter("title")    != null ? request.getParameter("title")    : "";
    String p_status   = request.getParameter("status")   != null ? request.getParameter("status")   : "";
    String p_priority = request.getParameter("priority") != null ? request.getParameter("priority") : "";
    String p_sortF    = request.getParameter("sortField")!= null ? request.getParameter("sortField"): "";
    String p_sortD    = request.getParameter("sortDir")  != null ? request.getParameter("sortDir")  : "";
%>

<div>
<style>
  .sortable-th { cursor:pointer; user-select:none; }
  .sortable-th:hover { background-color:rgba(0,0,0,.04); }
  .sort-badge { display:inline-block; font-size:.68rem; padding:1px 5px;
                border-radius:4px; background:#0d6efd; color:#fff; margin-left:4px; }
  .progress { height:8px; }

  @media (min-width: 992px){
    .card-body .table .badge.priority {
        display: inline-block !important;
    }
}
  
</style>

<div class="page-wrapper">
  <div class="content">

    <!-- Header -->
    <div class="page-header">
      <div class="page-title">
        <h4>Task List</h4>
        <h6>View and manage all tasks</h6>
      </div>
      <div class="page-btn">
        <a href="${pageContext.request.contextPath}/tasks/create" class="btn btn-added">
          <i class="fa fa-plus me-1"></i> Create Task
        </a>
      </div>
    </div>

    <!-- Search Card -->
    <div class="card">
      <div class="card-body">
        <form id="searchForm" method="get" action="${pageContext.request.contextPath}/tasks/list">
          <input type="hidden" name="page"      id="h_page"      value="<%= currentPage %>">
          <input type="hidden" name="sortField" id="h_sortField" value="<%= esc(p_sortF) %>">
          <input type="hidden" name="sortDir"   id="h_sortDir"   value="<%= esc(p_sortD) %>">

          <div class="row g-2 align-items-end">
            <div class="col-lg-4 col-md-6">
              <label class="form-label fw-semibold">Title</label>
              <input type="text" name="title" class="form-control"
                     placeholder="Search title…" value="<%= esc(p_title) %>">
            </div>
            <div class="col-lg-3 col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="">All Statuses</option>
                <% for (String s : new String[]{"Pending","In Progress","Done","Overdue","Cancelled"}) { %>
                <option value="<%= s %>" <%= s.equals(p_status) ? "selected" : "" %>><%= s %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-2 col-md-4">
              <label class="form-label fw-semibold">Priority</label>
              <select name="priority" class="form-select">
                <option value="">All</option>
                <% for (String s : new String[]{"Low","Medium","High"}) { %>
                <option value="<%= s %>" <%= s.equals(p_priority) ? "selected" : "" %>><%= s %></option>
                <% } %>
              </select>
            </div>
            <div class="col-auto d-flex gap-2">
              <button type="submit" class="btn btn-primary">
                <i class="fa fa-search me-1"></i> Search
              </button>
              <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
                <i class="fa fa-times me-1"></i> Reset
              </a>
              <span class="text-muted small align-self-center ms-2">
                <%= totalRecords %> record<%= totalRecords != 1 ? "s" : "" %>
              </span>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Table Card -->
    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead>
              <tr>
                <th>#</th>
                <th>Title</th>
                <% String[] sortCols = {"dueDate","Due Date","priority","Priority","status","Status","progress","Progress"}; %>
                <th class="sortable-th" onclick="toggleSort('dueDate')">
                  Due Date <%= "dueDate".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th class="sortable-th" onclick="toggleSort('priority')">
                  Priority <%= "priority".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th class="sortable-th" onclick="toggleSort('status')">
                  Status <%= "status".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Assignees</th>
                <th>Created By</th>
                <th class="sortable-th" onclick="toggleSort('progress')">
                  Progress <%= "progress".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%
              if (tasks.isEmpty()) { %>
              <tr>
                <td colspan="9" class="text-center text-muted py-4">
                  <i class="fa fa-inbox fa-2x d-block mb-2"></i>No tasks found.
                </td>
              </tr>
              <% } else {
                  int rowNum = (currentPage - 1) * pageSize + 1;
                  for (Task t : tasks) {
                      String priBadge = "bg-secondary";
                      String priLabel = t.getPriority() != null ? t.getPriority() : "-";
                      if ("High".equalsIgnoreCase(priLabel))   priBadge = "bg-danger";
                      else if ("Medium".equalsIgnoreCase(priLabel)) priBadge = "bg-warning text-dark";
                      else if ("Low".equalsIgnoreCase(priLabel))    priBadge = "bg-success";

                      String stBadge = "bg-secondary";
                      String stLabel = t.getStatus() != null ? t.getStatus() : "-";
                      if (stLabel.equalsIgnoreCase("Done"))        stBadge = "bg-success";
                      else if (stLabel.equalsIgnoreCase("In Progress")) stBadge = "bg-info text-dark";
                      else if (stLabel.equalsIgnoreCase("Pending"))     stBadge = "bg-warning text-dark";
                      else if (stLabel.equalsIgnoreCase("Overdue"))     stBadge = "bg-danger";
                      else if (stLabel.equalsIgnoreCase("Cancelled"))   stBadge = "bg-dark";

                      int prog = t.getProgress() != null ? t.getProgress() : 0;
                      String progBarClass = prog < 40 ? "bg-danger" : prog < 75 ? "bg-warning" : "bg-success";

                      // Assignee names
                      StringBuilder assigneeNames = new StringBuilder();
                      if (t.getassignees() != null) {
                          for (TaskAssignee ta : t.getassignees()) {
                              if (assigneeNames.length() > 0) assigneeNames.append(", ");
                              if (ta.getUser() != null && ta.getUser().getFullName() != null)
                                  assigneeNames.append(ta.getUser().getFullName());
                          }
                      }
                      String createdByName = t.getCreatedBy() != null
                              && t.getCreatedBy().getFullName() != null
                              ? t.getCreatedBy().getFullName() : "-";
              %>
              <tr>
                <td><%= rowNum++ %></td>
                <td>
                  <a href="${pageContext.request.contextPath}/tasks/details?id=<%= t.getTaskId() %>">
                    <strong><%= esc(t.getTitle()) %></strong>
                  </a>
                </td>
                <td><%= t.getDueDate() != null ? t.getDueDate().toString().replace("T"," ").substring(0,16) : "-" %></td>
                <td><span style="color:white;" class="badge priority <%= priBadge %>"><%= priLabel %></span></td>
                <td><span style="display:inline-block !important;" class="badge status <%= stBadge %>"><%= stLabel %></span></td>
                <td>
                  <% if (assigneeNames.length() == 0) { %><span class="text-muted">-</span>
                  <% } else { %><span title="<%= esc(assigneeNames.toString()) %>"><%= esc(shorten(assigneeNames.toString(), 30)) %></span><% } %>
                </td>
                <td><%= esc(createdByName) %></td>
                <td>
                  <div class="d-flex align-items-center gap-1" style="min-width:90px;">
                    <div class="progress flex-grow-1">
                      <div class="progress-bar <%= progBarClass %>" role="progressbar"
                           style="width:<%= prog %>%" aria-valuenow="<%= prog %>"
                           aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                    <small><%= prog %>%</small>
                  </div>
                </td>
                <td>
                  <div class="d-flex gap-1">
                    <a href="${pageContext.request.contextPath}/tasks/details?id=<%= t.getTaskId() %>"
                       class="btn btn-sm btn-outline-info" title="View"><i class="fa fa-eye"></i></a>
                    <a href="${pageContext.request.contextPath}/tasks/edit?id=<%= t.getTaskId() %>"
                       class="btn btn-sm btn-outline-warning" title="Edit"><i class="fa fa-edit"></i></a>
                    <button type="button" class="btn btn-sm btn-outline-danger"
                            onclick="deleteTask(<%= t.getTaskId() %>)" title="Delete">
                      <i class="fa fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <%  } } %>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div class="mt-3">
          <%@ include file="/view/components/paging.jsp" %>
        </div>

      </div>
    </div>

  </div>
</div><!-- /page-wrapper -->

<script>
function toggleSort(field) {
    var sf = document.getElementById('h_sortField');
    var sd = document.getElementById('h_sortDir');
    if (!sf) return;
    if (sf.value === field) {
        sd.value = sd.value === 'ASC' ? 'DESC' : 'ASC';
    } else {
        sf.value = field;
        sd.value = 'ASC';
    }
    document.getElementById('h_page').value = '1';
    document.getElementById('searchForm').submit();
}

function deleteTask(id) {
    var doIt = function() {
        fetch('${pageContext.request.contextPath}/tasks/delete', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'id=' + id
        })
        .then(r => r.json())
        .then(res => { if (res.success) location.reload();
                       else alert('Delete failed: ' + (res.message || '')); })
        .catch(e => alert('Error: ' + e.message));
    };
    if (typeof Swal !== 'undefined') {
        Swal.fire({ title:'Delete Task?', text:'This cannot be undone.',
                    icon:'warning', showCancelButton:true,
                    confirmButtonColor:'#d33', confirmButtonText:'Yes, delete!'
        }).then(r => { if (r.isConfirmed) doIt(); });
    } else if (confirm('Delete this task?')) {
        doIt();
    }
}
</script>
</div><%-- /col-10 --%>
