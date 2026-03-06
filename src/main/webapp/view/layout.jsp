
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
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/bootstrap.min.css" />

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/animate.css" />

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/select2/css/select2.min.css" />

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/dataTables.bootstrap4.min.css" />

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/plugins/fontawesome/css/all.min.css" />

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/css/style.css" />

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/${pageCss}?v=<%= System.currentTimeMillis() %>" />


    </head>

    <body>

        <!-- <div id="global-loader">
            <div class="whirly-loader"> </div>
        </div> -->

        <!-- Nội dung thay đổi nằm ở đây -->
        <main class="main-content main-wrapper layout container-fluid">

            <!-- Header dùng chung -->
            <jsp:include page="components/header.jsp" />
            <!-- Sidebar dùng chung -->



            <jsp:include page="components/sidebar.jsp" />



            <div class="page-wrapper">
                <jsp:include page="${contentPage}" />
            </div>

        </main>


        <!-- Bootstrap JS -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/js/feather.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.slimscroll.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/plugins/select2/js/select2.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/js/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/dataTables.bootstrap4.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/plugins/sweetalert/sweetalert2.all.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/js/script.js"></script>  <!-- luôn phải cuối -->
        <script src="${pageContext.request.contextPath}/js/${pageJs}?v=<%= System.currentTimeMillis() %>"></script>
    </body>
</html>

