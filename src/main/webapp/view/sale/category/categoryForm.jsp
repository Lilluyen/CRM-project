<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Category Form</title>
</head>
<body>

<h2>${category == null ? "Add Category" : "Edit Category"}</h2>

<form method="post">

    <c:if test="${category != null}">
        <input type="hidden" name="id" value="${category.categoryId}" />
    </c:if>

    Name:
    <input type="text" name="name"
           value="${category.categoryName}" required /><br><br>

    Description:
    <input type="text" name="description"
           value="${category.description}" /><br><br>

    Status:
    <select name="status">
        <option value="ACTIVE"
            ${category.status == 'ACTIVE' ? 'selected' : ''}>
            ACTIVE
        </option>
        <option value="INACTIVE"
            ${category.status == 'INACTIVE' ? 'selected' : ''}>
            INACTIVE
        </option>
    </select><br><br>

    <button type="submit">Save</button>

</form>

</body>
</html>