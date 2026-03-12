<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.format.DateTimeFormatter, java.time.LocalDateTime, java.util.List, model.Notification, model.NotificationRule" %>
<%
    @SuppressWarnings("unchecked")
    NotificationRule rule = (NotificationRule) request.getAttribute("rule");
    Notification selectedNotification = (Notification) request.getAttribute("selectedNotification");
    @SuppressWarnings("unchecked")
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    dto.Pagination notifPagination = (dto.Pagination) request.getAttribute("notifPagination");
    boolean isManager = Boolean.TRUE.equals(request.getAttribute("isManager"));

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    String nextRunVal = "";
    if (rule != null && rule.getNextRun() != null) {
        nextRunVal = rule.getNextRun().format(dtf);
    }
%>

<div class="content">
  <div class="page-header">
    <div class="page-title">
      <h4><%= rule == null ? "Create Rule" : "Edit Rule" %></h4>
      <h6>Schedule notification reminders</h6>
    </div>
    <div class="d-flex gap-2">
      <a href="${pageContext.request.contextPath}/notifications/rules" class="btn btn-outline-secondary btn-sm">
        <i class="fa fa-arrow-left me-1"></i>Back to list
      </a>
    </div>
  </div>

  <div class="row">
    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <h6 class="mb-0">Choose notification</h6>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th style="width:60px">ID</th>
                  <th>Title</th>
                  <th style="width:120px">Action</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${fn:length(notifications) == 0}">
                    <tr><td colspan="3" class="text-center text-muted py-4">No notifications found.</td></tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="n" items="${notifications}">
                      <tr class="notif-row" data-id="${n.notificationId}"
                        data-title="${fn:escapeXml(n.title)}"
                        data-content="${fn:escapeXml(n.content)}"
                        data-type="${fn:escapeXml(n.type)}"
                        data-relatedtype="${fn:escapeXml(n.relatedType)}"
                        data-relatedid="${n.relatedId}">
                        <td>${n.notificationId}</td>
                        <td>
                          <strong>${n.title}</strong><br/>
                          <small class="text-muted">${n.content}</small>
                        </td>
                        <td>
                          <button type="button" class="btn btn-sm btn-outline-primary" onclick="selectNotification(${n.notificationId})">
                            Select
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>
        </div>
        <c:if test="${notifPagination != null && notifPagination.totalItems > 0}">
          <c:set var="baseArgs" value="" />
          <c:if test="${not empty rule}"><c:set var="baseArgs" value="&ruleId=${rule.ruleId}"/></c:if>
          <c:if test="${not empty selectedNotification}"><c:set var="baseArgs" value="${baseArgs}&notificationId=${selectedNotification.notificationId}"/></c:if>
          <div class="card-footer">
            <nav aria-label="Notification pagination">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item ${!notifPagination.isHasPreviousPage() ? 'disabled' : ''}">
                  <a class="page-link" href="?notifPage=${notifPagination.isHasPreviousPage() ? notifPagination.currentPage - 1 : 1}&notifPageSize=${notifPagination.pageSize}${baseArgs}" aria-label="Previous">&laquo;</a>
                </li>
                <%-- Render a small range of pages --%>
                <c:forEach begin="${notifPagination.startPage}" end="${notifPagination.endPage}" var="p">
                  <li class="page-item ${p == notifPagination.currentPage ? 'active' : ''}">
                    <a class="page-link" href="?notifPage=${p}&notifPageSize=${notifPagination.pageSize}${baseArgs}">${p}</a>
                  </li>
                </c:forEach>
                <li class="page-item ${!notifPagination.isHasNextPage() ? 'disabled' : ''}">
                  <a class="page-link" href="?notifPage=${notifPagination.isHasNextPage() ? notifPagination.currentPage + 1 : notifPagination.currentPage}&notifPageSize=${notifPagination.pageSize}${baseArgs}" aria-label="Next">&raquo;</a>
                </li>
              </ul>
            </nav>
          </div>
        </c:if>
      </div>
    </div>

    <div class="col-lg-6">
      <div class="card">
        <div class="card-header">
          <h6 class="mb-0">Rule details</h6>
        </div>
        <div class="card-body">
          <form method="post" action="${pageContext.request.contextPath}/notifications/rules/manage">
            <c:if test="${not empty rule}">
              <input type="hidden" name="ruleId" value="${rule.ruleId}" />
            </c:if>
            <input type="hidden" name="notificationId" id="notificationId" value="<%= selectedNotification != null ? selectedNotification.getNotificationId() : "" %>" />

            <div class="mb-3">
              <label class="form-label">Notification Title</label>
              <input type="text" id="title" name="title" class="form-control" required
                     value="<%= selectedNotification != null ? selectedNotification.getTitle() : "" %>" />
            </div>

            <div class="mb-3">
              <label class="form-label">Content</label>
              <textarea id="content" name="content" class="form-control" rows="3"><%= selectedNotification != null ? selectedNotification.getContent() : "" %></textarea>
            </div>

            <div class="mb-3">
              <label class="form-label">Type</label>
              <input type="text" id="type" name="type" class="form-control"
                     value="<%= selectedNotification != null ? selectedNotification.getType() : "" %>" />
            </div>

            <div class="row g-2">
              <div class="col-md-6">
                <label class="form-label">Related Type</label>
                <input type="text" id="relatedType" name="relatedType" class="form-control"
                       value="<%= selectedNotification != null ? selectedNotification.getRelatedType() : "" %>" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Related ID</label>
                <input type="number" id="relatedId" name="relatedId" class="form-control"
                       value="<%= selectedNotification != null && selectedNotification.getRelatedId() != null ? selectedNotification.getRelatedId() : "" %>" />
              </div>
            </div>

            <hr />

            <div class="mb-3">
              <label class="form-label">Rule Type</label>
              <input type="text" name="ruleType" class="form-control"
                     value="<%= rule != null ? rule.getRuleType() : "" %>" placeholder="e.g. ONCE, DAILY" />
            </div>

            <div class="row g-2">
              <div class="col-md-4">
                <label class="form-label">Interval</label>
                <input type="number" name="intervalValue" class="form-control"
                       value="<%= rule != null && rule.getIntervalValue() != null ? rule.getIntervalValue() : "" %>" />
              </div>
              <div class="col-md-8">
                <label class="form-label">Interval Unit</label>
                <select name="intervalUnit" class="form-select">
                  <option value="">--</option>
                  <option value="minutes" <%= rule != null && "minutes".equalsIgnoreCase(rule.getIntervalUnit()) ? "selected" : "" %>>Minutes</option>
                  <option value="hours" <%= rule != null && "hours".equalsIgnoreCase(rule.getIntervalUnit()) ? "selected" : "" %>>Hours</option>
                  <option value="days" <%= rule != null && "days".equalsIgnoreCase(rule.getIntervalUnit()) ? "selected" : "" %>>Days</option>
                  <option value="weeks" <%= rule != null && "weeks".equalsIgnoreCase(rule.getIntervalUnit()) ? "selected" : "" %>>Weeks</option>
                  <option value="months" <%= rule != null && "months".equalsIgnoreCase(rule.getIntervalUnit()) ? "selected" : "" %>>Months</option>
                </select>
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label">Next Run</label>
              <input type="datetime-local" name="nextRun" class="form-control"
                     value="<%= nextRunVal %>" />
              <div class="form-text">Leave blank to schedule immediately.</div>
            </div>

            <div class="form-check mb-3">
              <input class="form-check-input" type="checkbox" name="active" id="active" <%= rule == null || rule.isActive() ? "checked" : "" %> />
              <label class="form-check-label" for="active">Active</label>
            </div>

            <button type="submit" class="btn btn-primary">Save</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  const notifications = document.querySelectorAll('.notif-row');
  const selectedRowClass = 'table-primary';

  function selectNotification(id) {
    document.getElementById('notificationId').value = id;
    notifications.forEach(r => {
      if (r.dataset.id === String(id)) {
        r.classList.add(selectedRowClass);
        // Autofill notification fields
        document.getElementById('title').value = r.dataset.title || '';
        document.getElementById('content').value = r.dataset.content || '';
        document.getElementById('type').value = r.dataset.type || '';
        document.getElementById('relatedType').value = r.dataset.relatedtype || '';
        document.getElementById('relatedId').value = r.dataset.relatedid || '';
      } else {
        r.classList.remove(selectedRowClass);
      }
    });
  }

  // Highlight selected notification if set
  (function () {
    const selectedId = document.getElementById('notificationId').value;
    if (selectedId) selectNotification(selectedId);
  })();
</script>
