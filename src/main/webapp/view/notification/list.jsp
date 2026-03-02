<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Notification" %>
<%
    java.util.List<Notification> notes = (java.util.List<Notification>) request.getAttribute("notifications");
    if (notes == null) notes = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Notifications</title>
    <style>
        .unread { font-weight: bold; }
        .read { color: #888; }
    </style>
</head>
<body>
<h2>Your Notifications</h2>
<ul>
<% for (Notification n : notes) { %>
    <li class="<%= n.isRead() ? "read" : "unread" %>">
        <a href="<%= request.getContextPath() + "/tasks" %>">
            <%= n.getTitle() %> - <%= n.getContent() %> (<%= n.getCreatedAt() %>)
        </a>
    </li>
<% } %>
</ul>
</body>
</html>