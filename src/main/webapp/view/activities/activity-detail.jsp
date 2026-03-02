<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Activity" %>
<%
    Activity a = (Activity) request.getAttribute("activity");
    if (a == null) { response.sendError(404); return; }
    String typeBadge = "bg-secondary";
    String at = a.getActivityType() != null ? a.getActivityType() : "-";
    if ("Call".equals(at))    typeBadge = "bg-info text-dark";
    else if ("Email".equals(at))   typeBadge = "bg-primary";
    else if ("Meeting".equals(at)) typeBadge = "bg-success";
    else if ("Note".equals(at))    typeBadge = "bg-warning text-dark";
    else if ("Task".equals(at))    typeBadge = "bg-danger";
%>
<div>
<div class="page-wrapper">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Activity Details</h4>
        <h6><%= a.getSubject() != null ? a.getSubject() : "" %></h6>
      </div>
      <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/activities/edit?id=<%= a.getActivityId() %>"
           class="btn btn-warning"><i class="fa fa-edit me-1"></i> Edit</a>
        <a href="${pageContext.request.contextPath}/activities/list"
           class="btn btn-outline-secondary"><i class="fa fa-arrow-left me-1"></i> Back</a>
      </div>
    </div>

    <div class="card">
      <div class="card-body">
        <table class="table table-borderless">
          <tr><th style="width:160px">Activity ID</th>
              <td><%= a.getActivityId() %></td></tr>
          <tr><th>Subject</th>
              <td><strong><%= a.getSubject() != null ? a.getSubject() : "-" %></strong></td></tr>
          <tr><th>Activity Type</th>
              <td><span class="badge <%= typeBadge %>"><%= at %></span></td></tr>
          <tr><th>Related To</th>
              <td>
                <%= a.getRelatedType() != null ? a.getRelatedType() : "-" %>
                <% if (a.getRelatedId() != null && a.getRelatedId() > 0) { %>
                  <span class="ms-1 text-muted">(ID: <%= a.getRelatedId() %>)</span>
                <% } %>
              </td></tr>
          <tr><th>Activity Date</th>
              <td><%= a.getActivityDate() != null ? a.getActivityDate().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
          <tr><th>Created By</th>
              <td><%= a.getCreatedBy() != null && a.getCreatedBy().getFullName() != null
                      ? a.getCreatedBy().getFullName() : "-" %></td></tr>
          <tr><th>Created At</th>
              <td><%= a.getCreatedAt() != null ? a.getCreatedAt().toString().replace("T"," ").substring(0,16) : "-" %></td></tr>
          <tr><th>Description</th>
              <td style="white-space:pre-wrap"><%= a.getDescription() != null ? a.getDescription() : "-" %></td></tr>
        </table>

        <button class="btn btn-outline-danger mt-2"
                onclick="deleteActivity(<%= a.getActivityId() %>)">
          <i class="fa fa-trash me-1"></i> Delete Activity
        </button>
      </div>
    </div>
  </div>
</div>
<script>
function deleteActivity(id) {
    if (!confirm('Delete this activity? This cannot be undone.')) return;
    fetch('${pageContext.request.contextPath}/activities/delete', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'id=' + id
    }).then(r=>r.json()).then(res=>{
        if (res.success) window.location.href = '${pageContext.request.contextPath}/activities/list';
        else alert('Delete failed');
    });
}
</script>
</div>
