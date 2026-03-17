<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*, java.time.format.DateTimeFormatter, model.NotificationRule" %>
<%
    @SuppressWarnings("unchecked")
    List<NotificationRule> rules = (List<NotificationRule>) request.getAttribute("rules");
    if (rules == null) rules = new ArrayList<>();
    boolean isManager = Boolean.TRUE.equals(request.getAttribute("isManager"));
    String success = request.getParameter("success");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>

<div class="content">
  <div class="page-header">
    <div class="page-title">
      <h4>Alarm Rules</h4>
      <h6>Manage scheduled notification rules</h6>
    </div>
    <div class="d-flex gap-2">
      <a href="${pageContext.request.contextPath}/notifications/rules/manage" class="btn btn-added">
        <i class="fa fa-plus me-1"></i>Create Rule
      </a>
    </div>
  </div>

  <% if ("1".equals(success)) { %>
    <div class="alert alert-success alert-dismissible fade show">
      Saved successfully.
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  <% } %>

  <div class="card">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-dark">
            <tr>
              <th style="width:50px">ID</th>
              <th>Rule Name</th>
              <th>Type</th>
              <th>Interval</th>
              <th>Next Run</th>
              <th>Priority</th>
              <th>Status</th>
              <th style="width:140px">Actions</th>
            </tr>
          </thead>
          <tbody>
            <% if (rules.isEmpty()) { %>
              <tr><td colspan="8" class="text-center text-muted py-5">
                <i class="fa fa-inbox fa-2x d-block mb-2"></i>No rules found.
              </td></tr>
            <% } else {
                 for (NotificationRule r : rules) {
                   String typeLabel;
                   String typeBadge;
                   switch (r.getRuleType() != null ? r.getRuleType() : "") {
                       case "schedule":      typeLabel = "Schedule"; typeBadge = "bg-info"; break;
                       case "condition":      typeLabel = "Condition"; typeBadge = "bg-warning text-dark"; break;
                       case "event_trigger":  typeLabel = "Event"; typeBadge = "bg-primary"; break;
                       default:               typeLabel = r.getRuleType(); typeBadge = "bg-secondary"; break;
                   }
                   String interval = "";
                   if (r.getConditionValue() != null) {
                       interval = r.getConditionValue() + " " + (r.getConditionUnit() != null ? r.getConditionUnit() : "");
                   } else if (r.getTriggerEvent() != null) {
                       interval = "on: " + r.getTriggerEvent();
                   }
                   String nextRun = r.getNextRunAt() != null ? r.getNextRunAt().format(dtf) : "-";
                   String priLabel = r.getNotificationPriority() != null ? r.getNotificationPriority() : "normal";
                   String priBadge;
                   switch (priLabel.toLowerCase()) {
                       case "urgent": priBadge = "bg-danger"; break;
                       case "high":   priBadge = "bg-warning text-dark"; break;
                       case "low":    priBadge = "bg-secondary"; break;
                       default:       priBadge = "bg-info"; break;
                   }
            %>
              <tr>
                <td><%= r.getRuleId() %></td>
                <td>
                  <strong><%= r.getRuleName() != null ? r.getRuleName() : "" %></strong>
                  <% if (r.getNotificationTitleTemplate() != null && !r.getNotificationTitleTemplate().isBlank()) { %>
                    <br/><small class="text-muted"><%= r.getNotificationTitleTemplate() %></small>
                  <% } %>
                </td>
                <td><span class="badge <%= typeBadge %>"><%= typeLabel %></span></td>
                <td><%= interval %></td>
                <td><%= nextRun %></td>
                <td><span class="badge <%= priBadge %>"><%= priLabel %></span></td>
                <td>
                  <% if (r.isActive()) { %>
                    <span class="badge bg-success">Active</span>
                  <% } else { %>
                    <span class="badge bg-secondary">Inactive</span>
                  <% } %>
                </td>
                <td>
                  <a class="btn btn-sm btn-outline-primary"
                     href="${pageContext.request.contextPath}/notifications/rules/manage?ruleId=<%= r.getRuleId() %>">
                    <i class="fa fa-edit"></i>
                  </a>
                  <button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteRule(<%= r.getRuleId() %>)">
                    <i class="fa fa-trash"></i>
                  </button>
                </td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </div>

    <jsp:include page="/view/components/pagination.jsp" />
  </div>
</div>

<script>
  var CTX = '${pageContext.request.contextPath}';

  function deleteRule(id) {
    if (!confirm('Delete this rule?')) return;
    fetch(CTX + '/notifications/rules/delete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'ruleId=' + encodeURIComponent(id)
    })
      .then(function(r) { return r.json(); })
      .then(function(res) {
        if (res.success) { location.reload(); }
        else { alert(res.message || 'Delete failed'); }
      })
      .catch(function() { alert('Delete failed'); });
  }
</script>
