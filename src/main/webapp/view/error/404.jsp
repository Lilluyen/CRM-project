<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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

        <c:set var="userRole" value="${sessionScope.user.role.roleName}" />
<c:choose>
  <c:when test="${fn:toUpperCase(userRole) eq 'ADMIN'}">
    <c:set var="rolePrefix" value="/admin" />
  </c:when>
  <c:when test="${fn:toUpperCase(userRole) eq 'SALE'}">
    <c:set var="rolePrefix" value="/sale" />
  </c:when>
  <c:when test="${fn:toUpperCase(userRole) eq 'MARKETING'}">
    <c:set var="rolePrefix" value="/marketing" />
  </c:when>
  <c:when test="${fn:toUpperCase(userRole) eq 'CS'}">
    <c:set var="rolePrefix" value="/cs" />
  </c:when>
  <c:otherwise>
    <c:set var="rolePrefix" value="" />
  </c:otherwise>
</c:choose>
        <a href="${pageContext.request.contextPath}${rolePrefix}/dashboard">Go to Dashboard</a>
    </body>
</html>
