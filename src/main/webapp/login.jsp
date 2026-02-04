<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>CRM System Login</title>

        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>

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
                        fontFamily: {
                            display: ["Inter", "sans-serif"]
                        }
                    }
                }
            }
        </script>
    </head>

    <body class="bg-background-light dark:bg-background-dark font-display min-h-screen flex items-center justify-center">

        <div class="w-full max-w-[480px] px-4">

            <!-- Header -->
            <div class="mb-8 text-center">
                <div class="inline-flex items-center justify-center p-3 mb-4 bg-primary/10 rounded-xl">
                    <span class="material-symbols-outlined text-primary text-4xl">hub</span>
                </div>
                <h1 class="text-3xl font-bold dark:text-white">CRM System</h1>
                <p class="text-slate-500 mt-2">Manage your relationships better</p>
            </div>

            <!-- Login Card -->
            <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800">
                <div class="p-8">

                    <h2 class="text-xl font-bold dark:text-white mb-1">Welcome back</h2>
                    <p class="text-slate-500 text-sm mb-6">Please sign in using your username.</p>

                    <!-- ERROR MESSAGE -->
                    <c:if test="${not empty error}">
                        <div class="mb-4 p-3 rounded bg-red-100 text-red-600 text-sm">
                            ${error}
                        </div>
                    </c:if>

                    <!-- LOGIN FORM -->
                    <form action="login" method="post" class="space-y-4">

                        <!-- Username -->
                        <div>
                            <label class="text-sm font-medium dark:text-slate-200">
                                Username
                            </label>
                            <input
                            type="text"
                            name="username"
                            required
                            class="form-input w-full h-12 rounded-lg border px-4 text-sm dark:bg-slate-800 dark:text-white"
                            placeholder="e.g. admin"/>
                        </div>

                        <!-- Password -->
                        <div>
                            <label class="text-sm font-medium dark:text-slate-200">
                                Password
                            </label>
                            <div class="relative">
                                <input
                                type="password"
                                id="password"
                                name="password"
                                required
                                class="form-input w-full h-12 rounded-lg border px-4 pr-12 text-sm dark:bg-slate-800 dark:text-white"
                                placeholder="Enter your password"/>
                                <button
                                type="button"
                                onclick="togglePassword()"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500">
                                <span id="eye" class="material-symbols-outlined">visibility</span>
                            </button>
                        </div>
                    </div>

                    <!-- Remember -->
                    <div class="flex justify-between items-center">
                        <label class="flex items-center gap-2 text-sm dark:text-slate-300">
                            <input type="checkbox" name="remember"/>
                            Remember me
                        </label>
                        <a href="#" class="text-primary text-sm">Forgot password?</a>
                    </div>

                    <!-- Submit -->
                    <button
                    type="submit"
                    class="w-full h-12 bg-primary text-white rounded-lg font-semibold hover:bg-primary/90">
                    Login
                </button>

            </form>

        </div>
    </div>
</div>

<script>
    function togglePassword() {
        const input = document.getElementById("password");
        const eye = document.getElementById("eye");
        if (input.type === "password") {
            input.type = "text";
            eye.innerText = "visibility_off";
            } else {
                input.type = "password";
                eye.innerText = "visibility";
            }
        }
    </script>

</body>
</html>
