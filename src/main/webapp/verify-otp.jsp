<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">

    <title>Verify OTP</title>

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
                            <li class="breadcrumb-item active">Verify Your Email</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="row justify-content-center mt-5">
                <div class="col-lg-6">

                    <div class="card shadow">
                        <div class="card-header text-center">
                            <h5 class="card-title mb-0">Verify Your Email</h5>
                        </div>

                        <div class="card-body text-center">

                            <!-- ERROR MESSAGE -->
                            <%
                                String error = (String) request.getAttribute("error");
                                if (error != null) {
                            %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                            <%
                                }
                            %>

                            <!-- SUCCESS MESSAGE -->
                            <%
                                String success = (String) request.getAttribute("success");
                                if (success != null) {
                            %>
                            <div class="alert alert-success">
                                <%= success %>
                            </div>
                            <%
                                }
                            %>

                            <p>Please enter the 6-digit code sent to your email.</p>

                            <form action="${pageContext.request.contextPath}/customer/verify-otp"
                                  method="post">

                                <div class="mb-4">
                                    <input type="text"
                                           class="form-control text-center"
                                           name="otp"
                                           maxlength="6"
                                           pattern="\d{6}"
                                           inputmode="numeric"
                                           autocomplete="one-time-code"
                                           placeholder="Enter 6-digit OTP"
                                           required
                                           style="font-size: 22px; letter-spacing: 8px;">
                                </div>

                                <button type="submit" class="btn btn-success w-100">
                                    <i class="fas fa-check me-1"></i>
                                    Verify Code
                                </button>

                            </form>

                            <div class="mt-3">
                                <small>
                                    Didn't receive code?
                                    <form action="${pageContext.request.contextPath}/customer/resend-otp" method="post"
                                          style="display:inline;">
                                        <button type="submit" class="btn btn-link p-0">Resend</button>
                                    </form>
                                </small>
                            </div>

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

<script>
    // Chỉ cho nhập số
    document.querySelector("input[name='otp']")
        .addEventListener("input", function () {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
</script>

</body>
</html>