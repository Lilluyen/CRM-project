<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Reset Password</title>

    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>

    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        primary: "#197fe6",
                        "background-light": "#f6f7f8",
                        "background-dark": "#111921"
                    },
                    fontFamily: {display: ["Inter", "sans-serif"]}
                }
            }
        }
    </script>
</head>

<body class="bg-background-light dark:bg-background-dark font-display min-h-screen flex items-center justify-center">

<div class="w-full max-w-[480px] px-4">

    <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800">
        <div class="p-8">

            <h2 class="text-xl font-bold dark:text-white mb-2">
                Reset Password
            </h2>

            <p class="text-slate-500 text-sm mb-6">
                Enter your email to receive an OTP. Then use the OTP to reset your password.
            </p>

            <!-- ERROR -->
            <c:if test="${not empty error}">
                <div class="mb-4 p-3 rounded bg-red-100 text-red-600 text-sm">
                        ${error}
                </div>
            </c:if>

            <!-- MESSAGE -->
            <c:if test="${not empty message}">
                <div class="mb-4 p-3 rounded bg-blue-100 text-blue-600 text-sm">
                        ${message}
                </div>
            </c:if>

            <!-- SUCCESS -->
            <c:if test="${not empty success}">
                <div class="mb-4 p-3 rounded bg-green-100 text-green-600 text-sm">
                        ${success}
                </div>

                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/login"
                       class="text-primary font-medium hover:underline">
                        Go to Login
                    </a>
                </div>
            </c:if>

            <!-- FORM -->
            <c:if test="${empty success}">
                <form action="${pageContext.request.contextPath}/reset-password"
                      method="post"
                      class="space-y-4">

                    <!-- Email -->
                    <div>
                        <label class="text-sm font-medium dark:text-slate-200">
                            Email
                        </label>
                        <input
                                type="email"
                                name="email"
                                value="${email}"
                                required
                                class="w-full h-12 rounded-lg border px-4 text-sm dark:bg-slate-800 dark:text-white"
                                placeholder="Enter your email"/>
                    </div>

                    <!-- OTP -->
                    <div>
                        <label class="text-sm font-medium dark:text-slate-200">
                            OTP Code
                        </label>
                        <input
                                type="text"
                                id="otp"
                                name="otp"
                                maxlength="6"
                                class="w-full h-12 text-center tracking-widest text-xl rounded-lg border px-4 dark:bg-slate-800 dark:text-white"
                                placeholder="------"/>
                    </div>

                    <!-- New Password -->
                    <div>
                        <label class="text-sm font-medium dark:text-slate-200">
                            New Password
                        </label>
                        <input
                                type="password"
                                name="newPassword"
                                class="w-full h-12 rounded-lg border px-4 text-sm dark:bg-slate-800 dark:text-white"
                                placeholder="Enter new password"/>
                    </div>

                    <!-- Confirm Password -->
                    <div>
                        <label class="text-sm font-medium dark:text-slate-200">
                            Confirm Password
                        </label>
                        <input
                                type="password"
                                name="confirmPassword"
                                class="w-full h-12 rounded-lg border px-4 text-sm dark:bg-slate-800 dark:text-white"
                                placeholder="Confirm password"/>
                    </div>

                    <!-- BUTTONS -->
                    <div class="space-y-3 pt-2">

                        <!-- Send OTP -->
                        <button
                                type="submit"
                                name="action"
                                value="sendOtp"
                                class="w-full h-12 bg-slate-200 dark:bg-slate-700 text-slate-800 dark:text-white rounded-lg font-medium hover:bg-slate-300 dark:hover:bg-slate-600">
                            Send Reset Code
                        </button>

                        <!-- Reset Password -->
                        <button
                                type="submit"
                                id="resetBtn"
                                name="action"
                                value="resetPassword"
                                disabled
                                class="w-full h-12 bg-primary text-white rounded-lg font-semibold hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed">
                            Reset Password
                        </button>

                    </div>
                </form>
            </c:if>

            <div class="text-center mt-6">
                <a href="${pageContext.request.contextPath}/login"
                   class="text-sm text-primary hover:underline">
                    Back to Login
                </a>
            </div>

        </div>
    </div>

</div>

<script>
    const otpInput = document.getElementById("otp");
    const resetBtn = document.getElementById("resetBtn");

    if (otpInput && resetBtn) {
        otpInput.addEventListener("input", function () {
            const value = otpInput.value.trim();

            // Chỉ enable khi đủ 6 ký tự
            resetBtn.disabled = value.length !== 6;
        });
    }
</script>

</body>
</html>