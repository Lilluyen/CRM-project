<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Success - CRM System</title>

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

    <div class="max-w-md mx-auto px-4">

        <!-- Success Card -->
        <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-8 text-center">

            <!-- Success Icon -->
            <div class="mb-6 flex justify-center">
                <div class="w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
                    <span class="material-symbols-outlined text-4xl text-green-600 dark:text-green-400">check_circle</span>
                </div>
            </div>

            <!-- Message -->
            <h1 class="text-2xl font-bold dark:text-white mb-3">Success!</h1>
            <p class="text-slate-600 dark:text-slate-400 mb-6">
                ${message}
            </p>

            <!-- Action Buttons -->
            <div class="space-y-3">
                <a href="${pageContext.request.contextPath}/activities/list" class="block w-full h-12 rounded-lg bg-primary text-white font-medium hover:bg-primary/90 transition flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined">arrow_back</span>
                    Back to Activities
                </a>
                <a href="${pageContext.request.contextPath}/" class="block w-full h-12 rounded-lg bg-slate-200 dark:bg-slate-800 text-slate-900 dark:text-slate-100 font-medium hover:bg-slate-300 dark:hover:bg-slate-700 transition flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined">home</span>
                    Go to Dashboard
                </a>
            </div>

        </div>

    </div>

    <script>
        // Optional: Auto-redirect after 3 seconds
        // setTimeout(function() {
        //     window.location.href = '${pageContext.request.contextPath}/activities/list';
        // }, 3000);
    </script>

</body>
</html>
