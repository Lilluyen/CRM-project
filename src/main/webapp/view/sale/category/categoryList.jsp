<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Category Management</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f8fb;
        }

        .container-box {
            width: 95%;
            margin: 30px auto;
            background: #ffffff;
            padding: 25px;
            border: 3px solid #2196F3;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        h1 {
            color: #1565c0;
            margin-bottom: 20px;
        }

        .top-bar {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            align-items: center;
        }

        .top-bar input, .top-bar select {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        .btn {
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            color: white;
        }

        .btn-search { background-color: #1976d2; }
        .btn-add { background-color: #2e7d32; }
        .btn-export { background-color: #757575; }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #e3f2fd;
        }

        thead {
            background-color: #0d47a1;
            color: white;
        }

        th, td {
            padding: 12px;
            border: 1px solid #bbdefb;
            text-align: left;
        }

        tbody tr:hover {
            background-color: #bbdefb;
        }

        .status-active {
            background: #2e7d32;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
        }

        .status-inactive {
            background: #757575;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
        }

        .action-btn {
            padding: 5px 10px;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            color: white;
        }

        .edit-btn { background: #1976d2; }
        .delete-btn { background: #d32f2f; }

        .pagination {
            margin-top: 20px;
            text-align: center;
        }

        .pagination a {
            padding: 8px 12px;
            margin: 3px;
            background: #bbdefb;
            text-decoration: none;
            border-radius: 6px;
            color: black;
        }

        .pagination a.active {
            background: #1976d2;
            color: white;
            font-weight: bold;
        }
    </style>
</head>

<body>

<div class="container-box">

    <h1>Category Management</h1>

    <!-- SEARCH + STATUS -->
    <form method="get" action="list" class="top-bar">

        <input type="text" name="search"
               placeholder="Search category..."
               value="${param.search}" />

        <select name="status">
            <option value="">All Status</option>
            <option value="ACTIVE"
                ${param.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
            <option value="INACTIVE"
                ${param.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
        </select>

        <button type="submit" class="btn btn-search">Search</button>

        <a href="create" class="btn btn-add">+ Add</a>
        <a href="export" class="btn btn-export">Export</a>
    </form>

    <!-- TABLE -->
    <table>
        <thead>
        <tr>
            <th>STT</th>
            <th>Category Name</th>
            <th>Description</th>
            <th>Status</th>
            <th>Created At</th>
            <th>Action</th>
        </tr>
        </thead>

        <tbody>

        <c:forEach var="c" items="${categoryList}" varStatus="loop">
            <tr>
                <!-- STT chạy liên tục qua các trang -->
                <td>${(currentPage - 1) * 5 + loop.index + 1}</td>

                <td>${c.categoryName}</td>
                <td>${c.description}</td>

                <td>
                    <c:choose>
                        <c:when test="${c.status == 'ACTIVE'}">
                            <span class="status-active">ACTIVE</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-inactive">INACTIVE</span>
                        </c:otherwise>
                    </c:choose>
                </td>

                <td>${c.createdAt}</td>

                <td>
                    <a href="edit?id=${c.categoryId}">
                        <button type="button" class="action-btn edit-btn">Edit</button>
                    </a>

                    <a href="delete?id=${c.categoryId}"
                       onclick="return confirm('Are you sure to delete this category?')">
                        <button type="button" class="action-btn delete-btn">Delete</button>
                    </a>
                </td>
            </tr>
        </c:forEach>

        </tbody>
    </table>

    <!-- PAGINATION -->
    <div class="pagination">
        <c:forEach begin="1" end="${totalPages}" var="i">
            <a href="list?page=${i}&search=${param.search}&status=${param.status}"
               class="${i == currentPage ? 'active' : ''}">
                ${i}
            </a>
        </c:forEach>
    </div>

</div>

</body>
</html>