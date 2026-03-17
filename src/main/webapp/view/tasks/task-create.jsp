<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.User" %>
<%
  boolean isManager = Boolean.TRUE.equals(request.getAttribute("isManager"));
  User currentUser = (User) session.getAttribute("user");
%>
<div >
<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Create Task</h4>
        <h6>Add a new task</h6>
      </div>
      <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
        <i class="fa fa-arrow-left me-1"></i> Back to List
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
      <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/tasks/create">

          <style>
            .assign-badge { display:inline-flex; align-items:center; gap:6px;
                            background:#e9ecef; border-radius:20px; padding:4px 10px; font-size:.9rem; }
            #assignSearch  { border-radius:6px 6px 0 0; }
            #assignList    { max-height:260px; overflow-y:auto; border:1px solid #dee2e6;
                             border-top:0; border-radius:0 0 6px 6px; }
            #assignList .user-item { padding:8px 12px; cursor:pointer; border-bottom:1px solid #f1f3f5;
                                     display:flex; align-items:center; gap:8px; }
            #assignList .user-item:hover { background:#f8f9fa; }
            #assignList .user-item.selected { background:#e7f5ff; }
          </style>

          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" required
                     placeholder="Enter task title" maxlength="200">
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
              <textarea name="description" class="form-control" rows="4"
                        placeholder="Describe the task…"></textarea>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="Pending" selected>Pending</option>
                <option value="In Progress">In Progress</option>
                <option value="Done">Done</option>
                <option value="Cancelled">Cancelled</option>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Start Date</label>
              <input type="datetime-local" name="startDate" class="form-control">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Due Date</label>
              <input type="datetime-local" name="dueDate" class="form-control">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Initial Progress (%)</label>
              <input type="number" name="progress" class="form-control"
                     min="0" max="100" value="0">
            </div>

            <div class="col-12">
              <% if (isManager) { %>
                <label class="form-label fw-semibold">Assign To</label>
                <input type="text" id="assignSearch" class="form-control"
                       placeholder="Search by name or email…" oninput="filterUsers(this.value)">
                <div id="assignList">
                  <%
                      List<User> allUsers = (List<User>) request.getAttribute("allUsers");
                      if (allUsers != null) {
                          for (User u : allUsers) {
                              String display = u.getFullName() != null ? u.getFullName() : u.getUsername();
                  %>
                    <div class="user-item"
                         data-uid="<%= u.getUserId() %>"
                         data-name="<%= (u.getFullName() != null ? u.getFullName().toLowerCase() : "") %>"
                         data-email="<%= (u.getEmail() != null ? u.getEmail().toLowerCase() : "") %>"
                         onclick="toggleUser(this)">
                      <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"
                           style="width:32px;height:32px;flex-shrink:0;font-weight:600">
                        <%= display != null && !display.isEmpty() ? display.substring(0,1).toUpperCase() : "?" %>
                      </div>
                      <div>
                        <div class="fw-semibold" style="font-size:.88rem"><%= display %></div>
                        <div class="text-muted" style="font-size:.78rem"><%= u.getEmail() != null ? u.getEmail() : "" %></div>
                      </div>
                      <i class="fa fa-circle text-muted ms-auto"></i>
                    </div>
                  <% } } %>
                </div>
                <small class="text-muted d-block mt-1">You can select multiple users.</small>
                <div id="assigneeHidden"></div>
              <% } else { %>
                <label class="form-label fw-semibold">Assign To</label>
                <div class="assign-badge">
                  <i class="fa fa-user-circle"></i>
                  <%= currentUser != null
                          ? ((currentUser.getFullName() != null && !currentUser.getFullName().isBlank())
                                ? currentUser.getFullName()
                                : currentUser.getUsername())
                          : "-" %>
                  <span class="text-muted">(auto)</span>
                </div>
                <div class="text-muted small mt-1">
                  This task will be automatically assigned to you as a reminder.
                </div>
              <% } %>
            </div>
          </div><!-- /row -->

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i> Create Task
            </button>
            <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
              Cancel
            </a>
          </div>
        </form>
      </div>
    </div>

  </div>
</div>
</div>

<script>
  function filterUsers(query) {
    const q = (query || '').toLowerCase();
    document.querySelectorAll('#assignList .user-item').forEach(item => {
      const name = item.dataset.name || '';
      const email = item.dataset.email || '';
      item.style.display = (name.includes(q) || email.includes(q)) ? '' : 'none';
    });
  }

  function toggleUser(el) {
    el.classList.toggle('selected');
    const icon = el.querySelector('i.fa');
    if (icon) {
      icon.className = el.classList.contains('selected')
        ? 'fa fa-check-circle text-success ms-auto'
        : 'fa fa-circle text-muted ms-auto';
    }
    syncHidden();
  }

  function syncHidden() {
    const box = document.getElementById('assigneeHidden');
    if (!box) return;
    box.innerHTML = '';
    document.querySelectorAll('#assignList .user-item.selected').forEach(item => {
      const uid = item.dataset.uid;
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'assigneeIds';
      input.value = uid;
      box.appendChild(input);
    });
  }
</script>
