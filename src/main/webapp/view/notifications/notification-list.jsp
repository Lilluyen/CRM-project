<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*, model.Notification, model.NotificationRecipient" %>
<%
  @SuppressWarnings("unchecked")
  List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
  if (notifications == null) notifications = new ArrayList<>();
  dto.Pagination pagination = (dto.Pagination) request.getAttribute("pagination");
%>

<style>
  .inbox-row { padding:12px 14px; border:1px solid #e9ecef; border-radius:12px; background:#fff; margin-bottom:10px; }
  .inbox-row.unread { border-left:4px solid #0d6efd; background:#f8fbff; }
  .inbox-title { font-weight:700; margin:0; }
  .inbox-time { color:#6c757d; font-size:.85rem; white-space:nowrap; }
  .inbox-body { color:#495057; font-size:.92rem; margin-top:4px; }
  .inbox-actions button { font-size:.85rem; }
</style>

<div class="content">
  <div class="page-header">
    <div class="page-title">
      <h4>Notification Inbox</h4>
      <h6>Your notifications</h6>
    </div>
  </div>

  <% if (notifications.isEmpty()) { %>
    <div class="alert alert-light border">
      <i class="fa fa-inbox me-1"></i>No notifications.
    </div>
  <% } %>

  <div>
    <%
      for (Notification n : notifications) {
        boolean isRead = false;
        if (n.getNrs() != null && !n.getNrs().isEmpty()) {
          NotificationRecipient nr = n.getNrs().get(0);
          isRead = nr != null && nr.isRead();
        }
    %>
    <div class="inbox-row <%= isRead ? "" : "unread" %>" id="notif-row-<%= n.getNotificationId() %>">
      <div class="d-flex justify-content-between gap-2">
        <div>
          <p class="inbox-title"><%= n.getTitle() != null ? n.getTitle() : "" %></p>
          <div class="inbox-body"><%= n.getContent() != null ? n.getContent() : "" %></div>
        </div>
        <div class="text-end">
          <div class="inbox-time"><%= n.getCreatedAt() != null ? n.getCreatedAt().toString().replace('T',' ') : "" %></div>
          <div class="inbox-actions mt-2 d-flex gap-2 justify-content-end">
            <a class="btn btn-sm btn-outline-primary"
               href="${pageContext.request.contextPath}/notifications/view?id=<%= n.getNotificationId() %>">
              View
            </a>
            <% if (isRead) { %>
              <button type="button" class="btn btn-sm btn-outline-secondary"
                      onclick="markUnread(<%= n.getNotificationId() %>)">Mark unread</button>
            <% } else { %>
              <button type="button" class="btn btn-sm btn-outline-success"
                      onclick="markRead(<%= n.getNotificationId() %>)">Mark read</button>
            <% } %>
          </div>
        </div>
      </div>
    </div>
    <% } %>
  </div>

  <% if (pagination != null && pagination.getTotalItems() > 0) { %>
    <jsp:include page="/view/components/pagination.jsp" />
  <% } %>
</div>

<script>
  var CTX = '${pageContext.request.contextPath}';

  function markRead(id) {
    fetch(CTX + '/notifications/markRead?id=' + id, { method: 'POST' })
      .then(function(r) { return r.json(); })
      .then(function(res) { if (res.success) location.reload(); })
      .catch(function() {});
  }

  function markUnread(id) {
    fetch(CTX + '/notifications/markUnread?id=' + id, { method: 'POST' })
      .then(function(r) { return r.json(); })
      .then(function(res) { if (res.success) location.reload(); })
      .catch(function() {});
  }
</script>
