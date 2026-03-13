<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Admin Home</title>
</head>
<body>
<h2>Admin Home</h2>
<!-- Hiển thị tên người dùng -->
<p>
    Welcome, <strong>${sessionScope.user.fullName}</strong>
</p>

<!-- Nút Logout -->
<form action="${pageContext.request.contextPath}/logout" method="post">
    <button type="submit">Logout</button>
</form>
</body>
</html>
