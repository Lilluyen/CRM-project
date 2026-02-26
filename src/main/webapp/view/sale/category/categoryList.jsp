<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Category Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4">
    <h2>Category Management</h2>

    <form method="get" action="list" class="mb-3">
        <input type="text" name="search"
               value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>"
               class="form-control"
               placeholder="Search category...">
    </form>

    <table class="table table-bordered table-hover">
        <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Description</th>
            <th>Status</th>
            <th>Created At</th>
        </tr>
        </thead>
        <tbody>

        <%
            List<Category> list =
                (List<Category>) request.getAttribute("categoryList");

            if (list != null && !list.isEmpty()) {
                for (Category c : list) {
        %>
        <tr>
            <td><%= c.getCategoryId() %></td>
            <td><%= c.getCategoryName() %></td>
            <td><%= c.getDescription() %></td>
            <td><%= c.getStatus() %></td>
            <td><%= c.getCreatedAt() %></td>
        </tr>
        <%
                }
            } else {
        %>
        <tr>
            <td colspan="5" class="text-center text-danger">
                No categories found
            </td>
        </tr>
        <%
            }
        %>

        </tbody>
    </table>
</div>

</body>
</html>