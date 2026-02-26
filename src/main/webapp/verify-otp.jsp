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

    <style>
        .otp-input {
            width: 50px;
            height: 50px;
            text-align: center;
            font-size: 20px;
            margin: 5px;
        }
    </style>
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

    <!-- PAGE CONTENT -->
    <div class="page-wrapper">
        <div class="content container-fluid">

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

                                <div class="d-flex justify-content-center mb-4">
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d1" required>
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d2" required>
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d3" required>
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d4" required>
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d5" required>
                                    <input type="text" maxlength="1" class="form-control otp-input" name="d6" required>
                                </div>

                                <button type="submit" class="btn btn-success w-100">
                                    <i class="fas fa-check me-1"></i>
                                    Verify Code
                                </button>

                            </form>

                            <div class="mt-3">
                                <small>
                                    Didn't receive code?
                                    <a href="${pageContext.request.contextPath}/customer/request-otp">
                                        Resend
                                    </a>
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
    // Auto focus next input
    const inputs = document.querySelectorAll(".otp-input");

    inputs.forEach((input, index) => {
        input.addEventListener("keyup", function () {
            if (this.value.length === 1 && index < inputs.length - 1) {
                inputs[index + 1].focus();
            }
        });

        // Chỉ cho nhập số
        input.addEventListener("input", function () {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
    });
</script>

</body>
</html>