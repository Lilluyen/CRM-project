<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">

    <title>Email Verification</title>

    <link rel="shortcut icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/assets/img/favicon.jpg">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/animate.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/plugins/fontawesome/css/all.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">
</head>

<body>

<div class="main-wrapper">

    <!-- HEADER -->
    <div class="header">
        <div class="header-left active">
            <a href="#" class="logo">
                CRM System
            </a>
        </div>
    </div>

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-inner slimscroll">
            <div id="sidebar-menu" class="sidebar-menu">
                <ul>
                    <li>
                        <a href="#"><i data-feather="mail"></i>
                            <span>Email Verification</span>
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <!-- PAGE CONTENT -->
    <div class="page-wrapper">
        <div class="content container-fluid">

            <div class="page-header">
                <div class="row">
                    <div class="col">
                        <h3 class="page-title">Email Verification</h3>
                        <ul class="breadcrumb">
                            <li class="breadcrumb-item">Customer</li>
                            <li class="breadcrumb-item active">Send OTP</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="row justify-content-center">
                <div class="col-lg-8">

                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title">Send Verification Code</h5>
                        </div>

                        <div class="card-body">

                            <!-- Alert -->
                            <%
                                String error = (String) request.getAttribute("error");
                                String success = (String) request.getAttribute("success");
                                if (error != null) {
                            %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                            <%
                                }
                                if (success != null) {
                            %>
                            <div class="alert alert-success">
                                <%= success %>
                            </div>
                            <%
                                }
                            %>

                            <!-- FORM -->
                            <form action="${pageContext.request.contextPath}/customer/request-otp"
                                  method="post">

                                <div class="form-group row mb-3">
                                    <label class="col-form-label col-md-3">
                                        Email Address
                                    </label>
                                    <div class="col-md-9">
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-envelope"></i>
                                            </span>
                                            <input type="email"
                                                   name="email"
                                                   class="form-control"
                                                   placeholder="Enter your registered email"
                                                   required>
                                        </div>
                                    </div>
                                </div>

                                <div class="text-end">
                                    <button type="submit"
                                            class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-1"></i>
                                        Send OTP
                                    </button>
                                </div>

                            </form>

                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/feather.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/script.js"></script>

</body>
</html>