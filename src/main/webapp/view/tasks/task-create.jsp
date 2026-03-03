<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.User" %>
<div >
<div class="page-wrapper">
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

            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="Pending" selected>Pending</option>
                <option value="In Progress">In Progress</option>
                <option value="Done">Done</option>
                <option value="Cancelled">Cancelled</option>
              </select>
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Due Date</label>
              <input type="datetime-local" name="dueDate" class="form-control">
            </div>

            <div class="col-md-4">
              <label class="form-label fw-semibold">Initial Progress (%)</label>
              <input type="number" name="progress" class="form-control"
                     min="0" max="100" value="0">
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Assign To (multi-select)</label>
              <select name="assigneeIds" class="form-select" multiple size="5">
                <%
                    List<User> allUsers = (List<User>) request.getAttribute("allUsers");
                    if (allUsers != null) {
                        for (User u : allUsers) {
                %>
                <option value="<%= u.getUserId() %>">
                  <%= u.getFullName() != null ? u.getFullName() : u.getUsername() %>
                  (<%= u.getEmail() %>)
                </option>
                <% } } %>
              </select>
              <small class="text-muted">Hold Ctrl / Cmd to select multiple users.</small>
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
