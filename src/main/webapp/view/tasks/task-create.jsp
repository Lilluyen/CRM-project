<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.User" %>
<%
  boolean isManager   = Boolean.TRUE.equals(request.getAttribute("isManager"));
  User    currentUser = (User) session.getAttribute("user");
  String  relatedType = (String) request.getAttribute("relatedType"); if(relatedType==null)relatedType="";
  String  relatedId   = (String) request.getAttribute("relatedId");   if(relatedId==null)relatedId="";
%>
<div><div class="content">

<div class="page-header">
  <div class="page-title"><h4>Create Task</h4><h6>Add a new task</h6></div>
  <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
    <i class="fa fa-arrow-left me-1"></i>Back to List</a>
</div>

<c:if test="${not empty error}">
  <div class="alert alert-danger">${fn:escapeXml(error)}</div>
</c:if>

<div class="card"><div class="card-body">
<form method="post" action="${pageContext.request.contextPath}/tasks/create">
  <input type="hidden" name="relatedType" value="<%= fn.escapeXml(relatedType) %>">
  <input type="hidden" name="relatedId"   value="<%= fn.escapeXml(relatedId) %>">
  <%-- Progress always 0 on create (calculated from work items later) --%>
  <input type="hidden" name="progress" value="0">

  <style>
    #assignList{max-height:260px;overflow-y:auto;border:1px solid #dee2e6;border-top:0;border-radius:0 0 6px 6px}
    #assignList .user-item{padding:8px 12px;cursor:pointer;border-bottom:1px solid #f1f3f5;display:flex;align-items:center;gap:8px}
    #assignList .user-item:hover{background:#f8f9fa}
    #assignList .user-item.selected{background:#e7f5ff}
    .status-fixed{display:inline-flex;align-items:center;gap:8px;padding:7px 14px;
                  background:#0d6efd15;border:1px solid #0d6efd40;border-radius:6px;font-weight:600;color:#0d6efd}
  </style>

  <div class="row g-3">
    <div class="col-md-8">
      <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
      <input type="text" name="title" class="form-control" required maxlength="200" placeholder="Enter task title">
    </div>
    <div class="col-md-4">
      <label class="form-label fw-semibold">Priority</label>
      <select name="priority" class="form-select">
        <option value="Low">Low</option>
        <option value="Medium" selected>Medium</option>
        <option value="High">High</option>
      </select>
    </div>
    <div class="col-12">
      <label class="form-label fw-semibold">Description</label>
      <textarea name="description" class="form-control" rows="4" placeholder="Describe the task…"></textarea>
    </div>

    <%-- STATUS: In Progress default; only manager can change --%>
    <div class="col-md-3">
      <label class="form-label fw-semibold">Status</label>
      <% if(isManager){ %>
        <select name="status" class="form-select">
          <option value="Pending">Pending</option>
          <option value="In Progress" selected>In Progress</option>
          <option value="Done">Done</option>
          <option value="Cancelled">Cancelled</option>
        </select>
        <small class="text-muted d-block mt-1"><i class="fa fa-info-circle me-1"></i>Managers may set any status.</small>
      <% }else{ %>
        <input type="hidden" name="status" value="In Progress">
        <div class="status-fixed"><i class="fa fa-play-circle"></i> In Progress</div>
        <small class="text-muted d-block mt-1"><i class="fa fa-lock me-1"></i>Fixed for new tasks. Managers can change.</small>
      <% } %>
    </div>

    <div class="col-md-3">
      <label class="form-label fw-semibold">Start Date</label>
      <input type="datetime-local" name="startDate" class="form-control">
    </div>
    <div class="col-md-3">
      <label class="form-label fw-semibold">Due Date</label>
      <input type="datetime-local" name="dueDate" class="form-control">
    </div>

    <%-- Progress display only --%>
    <div class="col-md-3">
      <label class="form-label fw-semibold">Progress</label>
      <div class="d-flex align-items-center gap-2 mt-1">
        <div class="progress flex-grow-1" style="height:10px">
          <div class="progress-bar bg-secondary" style="width:0%"></div>
        </div>
        <small class="fw-semibold text-muted">0%</small>
      </div>
      <small class="text-muted d-block mt-1"><i class="fa fa-calculator me-1"></i>Auto-calculated from work items.</small>
    </div>

    <%-- Assignees --%>
    <div class="col-12">
      <% if(isManager){ %>
        <label class="form-label fw-semibold">Assign To</label>
        <input type="text" id="assignSearch" class="form-control" placeholder="Search…" oninput="filterUsers(this.value)"
               style="border-radius:6px 6px 0 0">
        <div id="assignList">
          <% List<User> allUsers=(List<User>)request.getAttribute("allUsers");
             if(allUsers!=null){for(User u:allUsers){
               String dn=u.getFullName()!=null&&!u.getFullName().isBlank()?u.getFullName():u.getUsername(); %>
            <div class="user-item" data-uid="<%= u.getUserId() %>"
                 data-name="<%= u.getFullName()!=null?u.getFullName().toLowerCase():"" %>"
                 data-email="<%= u.getEmail()!=null?u.getEmail().toLowerCase():"" %>"
                 onclick="toggleUser(this)">
              <div style="width:32px;height:32px;border-radius:50%;background:#0d6efd;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;flex-shrink:0">
                <%= dn!=null&&!dn.isEmpty()?dn.substring(0,1).toUpperCase():"?" %></div>
              <div>
                <div class="fw-semibold" style="font-size:.88rem"><%= fn.escapeXml(dn) %></div>
                <div class="text-muted" style="font-size:.78rem"><%= u.getEmail()!=null?fn.escapeXml(u.getEmail()):"" %></div>
              </div>
              <i class="fa fa-circle text-muted ms-auto"></i>
            </div>
          <% }}%>
        </div>
        <small class="text-muted d-block mt-1">Select multiple assignees.</small>
        <div id="assigneeHidden"></div>
      <% }else{ %>
        <label class="form-label fw-semibold">Assign To</label>
        <div class="d-flex align-items-center gap-2 p-2 bg-light border rounded">
          <i class="fa fa-user-circle text-primary"></i>
          <span class="fw-semibold">
            <%= currentUser!=null?((currentUser.getFullName()!=null&&!currentUser.getFullName().isBlank())?currentUser.getFullName():currentUser.getUsername()):"-" %>
          </span>
          <span class="text-muted small">(auto-assigned)</span>
        </div>
      <% } %>
    </div>
  </div>

  <div class="d-flex gap-2 mt-4">
    <button type="submit" class="btn btn-primary"><i class="fa fa-save me-1"></i>Create Task</button>
    <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">Cancel</a>
  </div>
</form>
</div></div>
</div></div>

<script>
function filterUsers(q){
  q=(q||'').toLowerCase();
  document.querySelectorAll('#assignList .user-item').forEach(i=>{
    i.style.display=(i.dataset.name||'').includes(q)||(i.dataset.email||'').includes(q)?'':'none';
  });
}
function toggleUser(el){
  el.classList.toggle('selected');
  const ic=el.querySelector('i.fa');
  if(ic)ic.className=el.classList.contains('selected')?'fa fa-check-circle text-success ms-auto':'fa fa-circle text-muted ms-auto';
  syncHidden();
}
function syncHidden(){
  const box=document.getElementById('assigneeHidden');if(!box)return;
  box.innerHTML='';
  document.querySelectorAll('#assignList .user-item.selected').forEach(i=>{
    const inp=document.createElement('input');inp.type='hidden';inp.name='assigneeIds';inp.value=i.dataset.uid;
    box.appendChild(inp);
  });
}
</script>
