<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Activity" %>
<%
    Activity a = (Activity) request.getAttribute("activity");
    if (a == null) { response.sendError(404); return; }
    String dateVal = a.getActivityDate() != null
            ? a.getActivityDate().toString().substring(0, 16) : "";
    String desc = a.getDescription() != null ? a.getDescription() : "";
%>
<div>
<div class="page-wrapper">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Edit Activity</h4>
        <h6><%= a.getSubject() %></h6>
      </div>
      <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>"
         class="btn btn-outline-secondary">
        <i class="fa fa-arrow-left me-1"></i> Back
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
      <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/activities/edit">
          <input type="hidden" name="activityId" value="<%= a.getActivityId() %>">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
              <input type="text" name="subject" class="form-control" required
                     value="<%= a.getSubject() != null ? a.getSubject() : "" %>">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Activity Type <span class="text-danger">*</span></label>
              <select name="activityType" class="form-select" required>
                <% for (String t : new String[]{"Call","Email","Meeting","Note","Task"}) { %>
                <option value="<%= t %>" <%=t.equals(a.getActivityType()) ? "selected" : ""%>><%= t %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Date <span class="text-danger">*</span></label>
              <input type="datetime-local" name="activityDate" class="form-control" required
                     value="<%= dateVal %>">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Related Type</label>
              <select name="relatedType" class="form-select">
                <option value="">-- None --</option>
                <% for (String t : new String[]{"customer","lead","deal"}) { %>
                <option value="<%= t %>" <%=t.equalsIgnoreCase(a.getRelatedType()) ? "selected" : ""%>><%= t %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Related ID</label>
              <input type="number" name="relatedId" class="form-control" min="1"
                     value="<%= a.getRelatedId() != null && a.getRelatedId() > 0 ? a.getRelatedId() : "" %>">
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="4"><%= desc %></textarea>
            </div>
          </div>

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i> Save Changes
            </button>
            <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>"
               class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
</div>
