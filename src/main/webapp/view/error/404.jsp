<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <title>Page Not Found</title>
    </head>
    <body>
        <h2>404 - Page Not Found</h2>
        <p>The path you entered does not exist.</p>
        <a href="<%= request.getContextPath() %>/admin.jsp">Back to Home</a>
    </body>
</html>
