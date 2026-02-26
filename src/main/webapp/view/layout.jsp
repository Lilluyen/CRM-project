
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta
            name="keywords"
            content="admin, estimates, bootstrap, business, corporate, creative, invoice, html5, responsive, Projects" />
        <meta name="author" content="Dreamguys - Bootstrap Admin Template" />
        <meta name="robots" content="noindex, nofollow" />
        <title>${pageTitle}</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link
            rel="shortcut icon"
            type="image/x-icon"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/favicon.jpg" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/bootstrap.min.css" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/animate.css" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/select2/css/select2.min.css" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/dataTables.bootstrap4.min.css" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/fontawesome/css/fontawesome.min.css" />
        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/fontawesome/css/all.min.css" />

        <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/style.css" />

        <link href="${pageContext.request.contextPath}/assets/css/customerList.css" rel="stylesheet" type="text/css"/>
    </head>

    <body>

        <!-- Sidebar dùng chung -->
        <jsp:include page="components/sidebar.jsp" />

        <!-- Header dùng chung -->
        <jsp:include page="components/header.jsp" />

        <!-- Nội dung thay đổi nằm ở đây -->
        <main class="main-content layout container-fluid">
            <jsp:include page="${contentPage}" />
        </main>


        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/jquery-3.6.0.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/feather.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/jquery.slimscroll.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/dataTables.bootstrap4.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/select2/js/select2.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/sweetalert/sweetalert2.all.min.js"></script>
        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/sweetalert/sweetalerts.min.js"></script>

        <script src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/js/script.js"></script>
        <script src="${pageContext.request.contextPath}/js/CustomerList.js"></script>
        <script>
            /* ===== Trigger từ server ===== */
            const status = "${param.status}";

            if (status === "success") {
                showToast("success", "Create customer successfully");
            }

            if (status === "failed") {
                showToast("error", "Create customer failed");
            }



        </script>
    </body>
</html>

