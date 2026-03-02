<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Create Ticket</title>

    <!-- Google Font (fix 404 css2) -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">

    <!-- Bootstrap -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">

    <!-- Main Style -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">
</head>

<body>

<!-- LOADER -->
<div id="global-loader">
    <div class="whirly-loader"></div>
</div>

<div class="main-wrapper">

    <!-- HEADER -->
    <div class="header d-flex align-items-center justify-content-between px-3">

        <div class="header-left">
            <a href="#" class="logo text-decoration-none fw-bold">
                CRM System
            </a>
        </div>

        <div class="d-flex align-items-center">

            <div class="me-3">
                Welcome, <strong>${sessionScope.customer.name}</strong>
            </div>

            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-sm btn-outline-danger">
                Logout
            </a>

        </div>

    </div>

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-inner">
            <div id="sidebar-menu" class="sidebar-menu">
                <ul>

                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <i data-feather="columns"></i>
                            <span> Ticket</span>
                            <span class="menu-arrow"></span>
                        </a>
                        <ul>
                            <li>
                                <a href="${pageContext.request.contextPath}/customer/my-tickets">
                                    My Tickets
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/customer/create-ticket"
                                   class="active">
                                    Create Ticket
                                </a>
                            </li>
                        </ul>
                    </li>

                    <li class="submenu">
                        <a href="javascript:void(0);">
                            <i data-feather="layout"></i>
                            <span> Feedback </span>
                            <span class="menu-arrow"></span>
                        </a>
                        <ul>
                            <li><a href="#">My Feedbacks</a></li>
                            <li><a href="#">Create Feedback</a></li>
                        </ul>
                    </li>

                </ul>
            </div>
        </div>
    </div>

    <!-- PAGE CONTENT -->
    <div class="page-wrapper">
        <div class="content p-4">

            <div class="page-header mb-4">
                <div class="page-title">
                    <h4>Create Ticket</h4>
                    <h6>Submit a new support request</h6>
                </div>
            </div>

            <div class="card">
                <div class="card-body">

                    <!-- ERROR LIST -->
                    <c:if test="${not empty errors}">
                        <div class="alert alert-danger">
                            <ul class="mb-0">
                                <c:forEach var="e" items="${errors}">
                                    <li>${e}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/customer/create-ticket"
                          method="post">

                        <div class="mb-3">
                            <label class="form-label">Subject</label>
                            <input type="text"
                                   name="subject"
                                   class="form-control"
                                   value="${subject}"
                                   required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea name="description"
                                      rows="5"
                                      class="form-control"
                                      required>${description}</textarea>
                        </div>

                        <div class="d-flex gap-2">

                            <button type="submit" class="btn btn-primary">
                                Submit Ticket
                            </button>

                            <a href="${pageContext.request.contextPath}/customer/my-tickets"
                               class="btn btn-secondary">
                                Cancel
                            </a>

                        </div>

                    </form>

                </div>
            </div>

        </div>
    </div>

</div>

<!-- JS SECTION -->

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

<!-- FIX feather is not defined -->
<script src="https://unpkg.com/feather-icons"></script>
<script>
    feather.replace();
</script>

<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>

</body>
</html>