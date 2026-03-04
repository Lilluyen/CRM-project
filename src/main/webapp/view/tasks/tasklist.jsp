<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.Task, model.TaskAssignee" %>
<%
    @SuppressWarnings("unchecked")
    List<Task> tasks  = request.getAttribute("tasks") != null ? (List<Task>) request.getAttribute("tasks") : new java.util.ArrayList<>();
    int currentPage   = request.getAttribute("currentPage")  != null ? (Integer) request.getAttribute("currentPage")  : 1;
    int totalPages    = request.getAttribute("totalPages")   != null ? (Integer) request.getAttribute("totalPages")   : 1;
    int totalRecords  = request.getAttribute("totalRecords") != null ? (Integer) request.getAttribute("totalRecords") : 0;
    int pageSize      = request.getAttribute("pageSize")     != null ? (Integer) request.getAttribute("pageSize")     : 10;

    String fTitle    = (String) request.getAttribute("f_title");       if (fTitle    == null) fTitle    = "";
    String fDesc     = (String) request.getAttribute("f_description"); if (fDesc     == null) fDesc     = "";
    String fStatus   = (String) request.getAttribute("f_status");      if (fStatus   == null) fStatus   = "";
    String fPriority = (String) request.getAttribute("f_priority");    if (fPriority == null) fPriority = "";
    String fFrom     = (String) request.getAttribute("f_fromDate");    if (fFrom     == null) fFrom     = "";
    String fTo       = (String) request.getAttribute("f_toDate");      if (fTo       == null) fTo       = "";
    String fSortF    = (String) request.getAttribute("f_sortField");   if (fSortF    == null) fSortF    = "";
    String fSortD    = (String) request.getAttribute("f_sortDir");     if (fSortD    == null) fSortD    = "ASC";
%>
<style>
.sortable-th { cursor:pointer; user-select:none; white-space:nowrap; }
.sortable-th:hover { background:rgba(0,0,0,.04); }
.sortable-th .sort-icon { margin-left:4px; opacity:.5; }
.sortable-th.sorted .sort-icon { opacity:1; color:#0d6efd; }
.progress { height:8px; }
.filter-card .form-label { font-size:.82rem; font-weight:600; margin-bottom:2px; }
.table thead th {
    background-color: transparent;
}
</style>

<div class="page-wrapper">
 <div class="content">

  <%-- Header --%>
  <div class="page-header">
    <div class="page-title"><h4>Task List</h4><h6>Manage all tasks</h6></div>
    <a href="${pageContext.request.contextPath}/tasks/create" class="btn btn-added">
      <i class="fa fa-plus me-1"></i>Create Task
    </a>
  </div>

  <%-- ── Filter card ─────────────────────────────────────────────────── --%>
  <div class="card filter-card">
   <div class="card-body pb-2">
    <form id="searchForm" method="get" action="${pageContext.request.contextPath}/tasks/list">
      <input type="hidden" name="page"      id="h_page"      value="1">
      <input type="hidden" name="pageSize"  id="h_pageSize"  value="<%= pageSize %>">
      <input type="hidden" name="sortField" id="h_sortField" value="<%= fSortF %>">
      <input type="hidden" name="sortDir"   id="h_sortDir"   value="<%= fSortD %>">

      <div class="row g-2 align-items-end">
        <%-- Title --%>
        <div class="col-lg-3 col-md-4">
          <label class="form-label">Title</label>
          <input type="text" name="title" class="form-control form-control-sm"
                 placeholder="Search title…" value="<%= fTitle %>">
        </div>
        <%-- Description --%>
        <div class="col-lg-3 col-md-4">
          <label class="form-label">Description</label>
          <input type="text" name="description" class="form-control form-control-sm"
                 placeholder="Search description…" value="<%= fDesc %>">
        </div>
        <%-- Status --%>
        <div class="col-lg-2 col-md-4">
          <label class="form-label">Status</label>
          <select name="status" class="form-select form-select-sm">
            <option value="">All</option>
            <% for (String s : new String[]{"Pending","In Progress","Done","Overdue","Cancelled"}) { %>
            <option value="<%= s %>" <%= s.equals(fStatus) ? "selected" : "" %>><%= s %></option>
            <% } %>
          </select>
        </div>
        <%-- Priority --%>
        <div class="col-lg-2 col-md-3">
          <label class="form-label">Priority</label>
          <select name="priority" class="form-select form-select-sm">
            <option value="">All</option>
            <% for (String p : new String[]{"High","Medium","Low"}) { %>
            <option value="<%= p %>" <%= p.equals(fPriority) ? "selected" : "" %>><%= p %></option>
            <% } %>
          </select>
        </div>
        <%-- Page size --%>
        <div class="col-auto">
          <label class="form-label">Per page</label>
          <select id="pageSizeSelect" class="form-select form-select-sm" style="width:75px"
                  onchange="changePageSize(this.value)">
            <% for (int ps : new int[]{5,10,15,20}) { %>
            <option value="<%= ps %>" <%= ps == pageSize ? "selected" : "" %>><%= ps %></option>
            <% } %>
          </select>
        </div>
      </div>

      <%-- Date range row --%>
      <div class="row g-2 mt-1 align-items-end">
        <div class="col-lg-2 col-md-3">
          <label class="form-label">Due From</label>
          <input type="date" name="fromDate" class="form-control form-control-sm"
                 value="<%= fFrom %>">
        </div>
        <div class="col-lg-2 col-md-3">
          <label class="form-label">Due To</label>
          <input type="date" name="toDate" class="form-control form-control-sm"
                 value="<%= fTo %>">
        </div>
        <div class="col-auto d-flex gap-2">
          <button type="submit" class="btn btn-primary btn-sm">
            <i class="fa fa-search me-1"></i>Search
          </button>
          <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-redo me-1"></i>Reset
          </a>
          <span class="text-muted small align-self-center">
            <%= totalRecords %> record<%= totalRecords != 1 ? "s" : "" %>
          </span>
        </div>
      </div>
    </form>
   </div>
  </div>

  <%-- ── Table card ──────────────────────────────────────────────────── --%>
  <div class="card">
   <div class="card-body p-0">
    <div class="table-responsive">
     <table class="table table-striped table-hover mb-0">
      <thead class="table-dark">
       <tr>
         <th style="width:42px">ID</th>
         <th>Title</th>
         <%-- Sortable columns: dueDate > priority > progress --%>
         <th class="sortable-th <%= "dueDate".equals(fSortF) ? "sorted" : "" %>"
             onclick="toggleSort('dueDate')">
           Due Date <i class="fa fa-sort sort-icon"></i>
           <% if ("dueDate".equals(fSortF)) out.print("ASC".equals(fSortD) ? "↑" : "↓"); %>
         </th>
         <th class="sortable-th <%= "priority".equals(fSortF) ? "sorted" : "" %>"
             onclick="toggleSort('priority')">
           Priority <i class="fa fa-sort sort-icon"></i>
           <% if ("priority".equals(fSortF)) out.print("ASC".equals(fSortD) ? "↑" : "↓"); %>
         </th>
         <th>Status</th>
         <th>Assignees</th>
         <th>Created By</th>
         <th class="sortable-th <%= "progress".equals(fSortF) ? "sorted" : "" %>"
             onclick="toggleSort('progress')">
           Progress <i class="fa fa-sort sort-icon"></i>
           <% if ("progress".equals(fSortF)) out.print("ASC".equals(fSortD) ? "↑" : "↓"); %>
         </th>
         <th style="width:100px">Actions</th>
       </tr>
      </thead>
      <tbody>
       <%
         if (tasks.isEmpty()) { %>
         <tr><td colspan="9" class="text-center text-muted py-5">
           <i class="fa fa-inbox fa-2x d-block mb-2"></i>No tasks found.
         </td></tr>
       <% } else {
           int rowNum = (currentPage - 1) * pageSize + 1;
           for (Task t : tasks) {
               String priCls  = "bg-secondary";
               String priLbl  = t.getPriority() != null ? t.getPriority() : "-";
               if      ("High".equalsIgnoreCase(priLbl))   priCls = "bg-danger";
               else if ("Medium".equalsIgnoreCase(priLbl)) priCls = "bg-warning text-dark";
               else if ("Low".equalsIgnoreCase(priLbl))    priCls = "bg-success";

               String stCls = "bg-secondary";
               String stLbl = t.getStatus() != null ? t.getStatus() : "-";
               if      (stLbl.equalsIgnoreCase("Done"))        stCls = "bg-success";
               else if (stLbl.equalsIgnoreCase("In Progress")) stCls = "bg-info text-dark";
               else if (stLbl.equalsIgnoreCase("Pending"))     stCls = "bg-warning text-dark";
               else if (stLbl.equalsIgnoreCase("Overdue"))     stCls = "bg-danger";
               else if (stLbl.equalsIgnoreCase("Cancelled"))   stCls = "bg-dark";

               int pr = t.getProgress() != null ? t.getProgress() : 0;
               String prCls = pr < 40 ? "bg-danger" : pr < 75 ? "bg-warning" : "bg-success";

               StringBuilder aNames = new StringBuilder();
               if (t.getassignees() != null) {
                   for (TaskAssignee ta : t.getassignees()) {
                       if (ta.getUser() != null && ta.getUser().getFullName() != null) {
                           if (aNames.length() > 0) aNames.append(", ");
                           aNames.append(ta.getUser().getFullName());
                       }
                   }
               }
               String aShort  = aNames.length() > 28 ? aNames.substring(0, 28) + "…" : aNames.toString();
               String creator = t.getCreatedBy() != null && t.getCreatedBy().getFullName() != null
                                ? t.getCreatedBy().getFullName() : "-";
       %>
       <tr>
         <td class="text-muted small"><%= rowNum++ %></td>
         <td>
           <a href="${pageContext.request.contextPath}/tasks/details?id=<%= t.getTaskId() %>" class="fw-semibold">
             <%= t.getTitle() %>
           </a>
           <% if (t.getDescription() != null && !t.getDescription().isBlank()) { %>
           <div class="text-muted small text-truncate" style="max-width:200px">
             <%= t.getDescription().length() > 60 ? t.getDescription().substring(0,60)+"…" : t.getDescription() %>
           </div>
           <% } %>
         </td>
         <td class="small"><%= t.getDueDate() != null ? t.getDueDate().toString().replace("T"," ").substring(0,16) : "-" %></td>
         <td><span class="badge <%= priCls %>"><%= priLbl %></span></td>
         <td><span class="badge <%= stCls %>"><%= stLbl %></span></td>
         <td class="small">
           <% if (aNames.length() == 0) { %><span class="text-muted">-</span>
           <% } else { %><span title="<%= aNames.toString() %>"><%= aShort %></span><% } %>
         </td>
         <td class="small"><%= creator %></td>
         <td style="min-width:100px">
           <div class="d-flex align-items-center gap-1">
             <div class="progress flex-grow-1">
               <div class="progress-bar <%= prCls %>" role="progressbar"
                    style="width:<%= pr %>%" aria-valuenow="<%= pr %>"></div>
             </div>
             <small class="text-nowrap"><%= pr %>%</small>
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
       <% } } %>
      </tbody>
     </table>
    </div>

    <%-- ── Pagination ──────────────────────────────────────────────── --%>
    <div class="px-3 py-2 d-flex justify-content-between align-items-center flex-wrap gap-2 border-top">
      <small class="text-muted">
        Page <strong><%= currentPage %></strong> of <strong><%= totalPages %></strong>
        &nbsp;|&nbsp; <strong><%= totalRecords %></strong> total
      </small>
      <% if (totalPages > 1) { %>
      <nav>
        <ul class="pagination pagination-sm mb-0">
          <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
            <a class="page-link" href="javascript:void(0)" onclick="goPage(<%= currentPage-1 %>)">
              <i class="fa fa-chevron-left"></i>
            </a>
          </li>
          <% int startP = Math.max(1, currentPage - 2);
             int endP   = Math.min(totalPages, currentPage + 2);
             if (startP > 1) { %>
            <li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="goPage(1)">1</a></li>
            <% if (startP > 2) { %><li class="page-item disabled"><span class="page-link">…</span></li><% } %>
          <% }
             for (int pi = startP; pi <= endP; pi++) { %>
            <li class="page-item <%= pi == currentPage ? "active" : "" %>">
              <a class="page-link" href="javascript:void(0)" onclick="goPage(<%= pi %>)"><%= pi %></a>
            </li>
          <% }
             if (endP < totalPages) {
                 if (endP < totalPages - 1) { %><li class="page-item disabled"><span class="page-link">…</span></li><% } %>
                 <li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="goPage(<%= totalPages %>)"><%= totalPages %></a></li>
          <% } %>
          <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
            <a class="page-link" href="javascript:void(0)" onclick="goPage(<%= currentPage+1 %>)">
              <i class="fa fa-chevron-right"></i>
            </a>
          </li>
        </ul>
      </nav>
      <% } %>
      <%-- Per-page selector (mirrors the filter card) --%>
      <div class="d-flex align-items-center gap-2">
        <small class="text-muted">Rows:</small>
        <select class="form-select form-select-sm" style="width:70px" onchange="changePageSize(this.value)">
          <% for (int sz : new int[]{5,10,15,20}) { %>
          <option value="<%= sz %>" <%= sz == pageSize ? "selected" : "" %>><%= sz %></option>
          <% } %>
        </select>
      </div>
    </div>

   </div><%-- /card-body --%>
  </div><%-- /card --%>

 </div><%-- /content --%>
</div><%-- /page-wrapper --%>

<script>
function toggleSort(field) {
    const sf = document.getElementById('h_sortField');
    const sd = document.getElementById('h_sortDir');
    if (sf.value === field) sd.value = sd.value === 'ASC' ? 'DESC' : 'ASC';
    else { sf.value = field; sd.value = 'ASC'; }
    document.getElementById('h_page').value = 1;
    document.getElementById('searchForm').submit();
}

function goPage(p) {
    document.getElementById('h_page').value = p;
    document.getElementById('searchForm').submit();
}

function changePageSize(sz) {
    document.getElementById('h_pageSize').value = sz;
    document.getElementById('h_page').value = 1;
    document.getElementById('searchForm').submit();
}

function deleteTask(id) {
    const doIt = () => {
        fetch('${pageContext.request.contextPath}/tasks/delete', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'id=' + id
        })
        .then(r => r.json())
        .then(res => { if (res.success) location.reload(); else alert('Delete failed: ' + (res.message || '')); });
    };
    if (typeof Swal !== 'undefined') {
        Swal.fire({title:'Delete Task?', text:'This cannot be undone.',
                   icon:'warning', showCancelButton:true,
                   confirmButtonColor:'#d33', confirmButtonText:'Yes, delete!'
        }).then(r => { if (r.isConfirmed) doIt(); });
    } else if (confirm('Delete this task?')) doIt();
}
</script>
