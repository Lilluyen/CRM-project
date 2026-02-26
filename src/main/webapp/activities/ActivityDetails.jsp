<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Activity Details - CRM System</title>

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

<body class="bg-background-light dark:bg-background-dark font-display">

    <!-- Navigation -->
    <nav class="bg-white dark:bg-slate-900 border-b dark:border-slate-800 sticky top-0 z-10">
        <div class="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
            <div class="text-xl font-bold dark:text-white flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">hub</span>
                CRM System
            </div>
            <div class="flex gap-4">
                <a href="/" class="text-slate-600 dark:text-slate-400 hover:text-primary">Dashboard</a>
                <a href="/activities/list" class="text-slate-600 dark:text-slate-400 hover:text-primary">Activities</a>
            </div>
        </div>
    </nav>

    <div class="max-w-4xl mx-auto px-4 py-8">

        <!-- Breadcrumb -->
        <div class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400 mb-6">
            <a href="/activities/list" class="hover:text-primary">Activities</a>
            <span class="material-symbols-outlined text-base">chevron_right</span>
            <span class="text-slate-900 dark:text-white">Activity Details</span>
        </div>

        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="mb-6 p-4 rounded-lg bg-red-100 dark:bg-red-900/20 text-red-600 dark:text-red-400 flex items-center gap-3">
                <span class="material-symbols-outlined">error</span>
                ${error}
            </div>
        </c:if>

        <c:if test="${not empty activity}">
            <!-- Header Section -->
            <div class="flex justify-between items-start mb-8">
                <div>
                    <h1 class="text-3xl font-bold dark:text-white">${activity.subject}</h1>
                    <p class="text-slate-500 mt-2">Activity ID: ${activity.activityId}</p>
                </div>
                <div class="flex gap-2">
                    <a href="${pageContext.request.contextPath}/activities/ActivityForm.jsp?id=${activity.activityId}&action=edit" 
                       class="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90 transition">
                        <span class="material-symbols-outlined">edit</span>
                        Edit
                    </a>
                    <a href="${pageContext.request.contextPath}/activities/list" 
                       class="flex items-center gap-2 bg-slate-200 dark:bg-slate-800 text-slate-900 dark:text-slate-100 px-4 py-2 rounded-lg hover:bg-slate-300 dark:hover:bg-slate-700 transition">
                        <span class="material-symbols-outlined">arrow_back</span>
                        Back
                    </a>
                </div>
            </div>

            <!-- Main Content Cards -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">

                <!-- Activity Type Card -->
                <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400">Activity Type</h3>
                        <span class="material-symbols-outlined text-primary text-base">category</span>
                    </div>
                    <p class="text-lg font-bold dark:text-white">${activity.activityType}</p>
                </div>

                <!-- Related To Card -->
                <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400">Related Type</h3>
                        <span class="material-symbols-outlined text-primary text-base">link</span>
                    </div>
                    <p class="text-lg font-bold dark:text-white">${activity.relatedType}</p>
                    <p class="text-sm text-slate-500 mt-2">ID: ${activity.relatedId}</p>
                </div>

                <!-- Created By Card -->
                <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400">Created By</h3>
                        <span class="material-symbols-outlined text-primary text-base">person</span>
                    </div>
                    <p class="text-lg font-bold dark:text-white">
                        <c:choose>
                            <c:when test="${not empty activity.createdBy.fullName}">${activity.createdBy.fullName}</c:when>
                            <c:when test="${not empty activity.createdBy.username}">${activity.createdBy.username}</c:when>
                            <c:otherwise>Unknown</c:otherwise>
                        </c:choose>
                    </p>
                </div>

            </div>

            <!-- Details Card -->
            <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-6">

                <!-- Description -->
                <div class="mb-6">
                    <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400 mb-3">Description</h3>
                    <div class="p-4 rounded-lg bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-slate-100 min-h-32 whitespace-pre-wrap">
                        ${activity.description}
                    </div>
                </div>

                <!-- Timestamps -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400 mb-2">Activity Date</h3>
                        <div class="flex items-center gap-2 text-slate-900 dark:text-slate-100">
                            <span class="material-symbols-outlined text-primary">access_time</span>
                            ${activity.activityDate}
                        </div>
                    </div>

                    <c:if test="${not empty activity.createdAt}">
                        <div>
                            <h3 class="text-sm font-semibold text-slate-600 dark:text-slate-400 mb-2">Created At</h3>
                            <div class="flex items-center gap-2 text-slate-900 dark:text-slate-100">
                                <span class="material-symbols-outlined text-primary">schedule</span>
                                ${activity.createdAt}
                            </div>
                        </div>
                    </c:if>
                </div>

            </div>

        </c:if>

    </div>

</body>
</html>
