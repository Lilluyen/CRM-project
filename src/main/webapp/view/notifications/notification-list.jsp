<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Notification, model.NotificationRecipient" %>
<%
  @SuppressWarnings("unchecked")
  List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
  if (notifications == null) notifications = new ArrayList<>();
%>

<style>
  .inbox-row { padding:12px 14px; border:1px solid #e9ecef; border-radius:12px; background:#fff; margin-bottom:10px; }
  .inbox-row.unread { border-left:4px solid #0d6efd; background:#f8fbff; }
  .inbox-title { font-weight:700; margin:0; }
  .inbox-time { color:#6c757d; font-size:.85rem; white-space:nowrap; }
  .inbox-body { color:#495057; font-size:.92rem; margin-top:4px; }
  .inbox-actions button { font-size:.85rem; }
</style>

<div class="">
  <div class="content">
    <div class="page-header">
      <div class="page-title">
        <h4>Notifications</h4>
        <h6>Inbox</h6>
      </div>
      <div class="d-flex gap-2">
        <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/tasks/list">
          <i class="fa fa-arrow-left me-1"></i>Back
        </a>
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
  </div>
</div>

<script>
  const CTX = '${pageContext.request.contextPath}';

  function markRead(id) {
    fetch(CTX + '/notifications/markRead?id=' + id, { method: 'POST' })
      .then(r => r.json())
      .then(res => { if (res.success) location.reload(); })
      .catch(() => {});
  }

  function markUnread(id) {
    fetch(CTX + '/notifications/markUnread?id=' + id, { method: 'POST' })
      .then(r => r.json())
      .then(res => { if (res.success) location.reload(); })
      .catch(() => {});
  }
</script>

