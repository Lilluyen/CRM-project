<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*, model.Notification, model.NotificationRule" %>
<%
    @SuppressWarnings("unchecked")
    List<NotificationRule> rules = (List<NotificationRule>) request.getAttribute("rules");
    if (rules == null) rules = new ArrayList<>();
    Map<Integer, Notification> notificationMap = (Map<Integer, Notification>) request.getAttribute("notificationMap");
    if (notificationMap == null) notificationMap = new HashMap<>();
    dto.Pagination pagination = (dto.Pagination) request.getAttribute("pagination");
    boolean isManager = Boolean.TRUE.equals(request.getAttribute("isManager"));
    String success = request.getParameter("success");
%>

<div class="content">
  <div class="page-header">
    <div class="page-title">
      <h4>Reminder Rules</h4>
      <h6>Manage scheduled notifications</h6>
    </div>
    <div class="d-flex gap-2">
      <a href="${pageContext.request.contextPath}/notifications/rules/manage" class="btn btn-added">
        <i class="fa fa-plus me-1"></i>Create Rule
      </a>
    </div>
  </div>

  <c:if test="${not empty success}">
    <div class="alert alert-success">Saved successfully.</div>
  </c:if>

  <div class="card">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-dark">
            <tr>
              <th style="width:60px">ID</th>
              <th>Notification</th>
              <th>Rule Type</th>
              <th>Interval</th>
              <th>Next Run</th>
              <th>Active</th>
              <th>Created</th>
              <th style="width:140px">Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${fn:length(rules) == 0}">
                <tr><td colspan="8" class="text-center text-muted py-5">
                  <i class="fa fa-inbox fa-2x d-block mb-2"></i>No rules found.
                </td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="rule" items="${rules}">
                  <c:set var="notif" value="${notificationMap[rule.notificationId]}" />
                  <tr>
                    <td>${rule.ruleId}</td>
                    <td>
                      <strong>${notif != null ? notif.title : "(missing)"}</strong><br />
                      <small class="text-muted">${notif != null ? notif.content : ""}</small>
                    </td>
                    <td>${rule.ruleType}</td>
                    <td>
                      <c:choose>
                        <c:when test="${rule.intervalValue != null}">${rule.intervalValue} </c:when>
                      </c:choose>
                      <c:out value="${rule.intervalUnit}"/>
                    </td>
                    <td><c:out value="${rule.nextRun}"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${rule.active}">
                          <span class="badge bg-success">Active</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge bg-secondary">Inactive</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><c:out value="${rule.createdAt}"/></td>
                    <td>
                      <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/notifications/rules/manage?ruleId=${rule.ruleId}">Edit</a>
                      <button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteRule(${rule.ruleId})">Delete</button>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>

    <c:if test="${pagination != null && pagination.totalItems > 0}">
      <jsp:include page="/view/components/pagination.jsp" />
    </c:if>
  </div>
</div>

<script>
  const CTX = '${pageContext.request.contextPath}';

  function deleteRule(id) {
    if (!confirm('Delete this rule?')) return;
    fetch(CTX + '/notifications/rules/delete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'ruleId=' + encodeURIComponent(id)
    })
      .then(r => r.json())
      .then(res => {
        if (res.success) {
          location.reload();
        } else {
          alert(res.message || 'Delete failed');
        }
      })
      .catch(() => {
        alert('Delete failed');
      });
  }
</script>
