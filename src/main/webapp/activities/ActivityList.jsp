<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Activities - CRM System</title>

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
                <a href="${pageContext.request.contextPath}/" class="text-slate-600 dark:text-slate-400 hover:text-primary">Dashboard</a>
                <a href="${pageContext.request.contextPath}/activities/list" class="text-primary font-medium">Activities</a>
            </div>
        </div>
    </nav>

    <div class="max-w-7xl mx-auto px-4 py-8">

        <!-- Header Section -->
        <div class="flex justify-between items-center mb-8">
            <div>
                <h1 class="text-3xl font-bold dark:text-white">Activities</h1>
                <p class="text-slate-500 mt-1">Total: ${totalActivities} activities</p>
            </div>
            <a href="${pageContext.request.contextPath}/activities/ActivityForm.jsp" class="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90 transition">
                <span class="material-symbols-outlined">add</span>
                New Activity
            </a>
        </div>

        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="mb-6 p-4 rounded-lg bg-red-100 dark:bg-red-900/20 text-red-600 dark:text-red-400 flex items-center gap-3">
                <span class="material-symbols-outlined">error</span>
                ${error}
            </div>
        </c:if>

        <!-- Activities Table -->
        <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 overflow-hidden">
            
            <c:choose>
                <c:when test="${not empty activities}">
                    <div class="overflow-x-auto">
                        <table class="w-full">
                            <thead class="bg-slate-50 dark:bg-slate-800/50 border-b dark:border-slate-700">
                                <tr>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Subject</th>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Type</th>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Related To</th>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Created By</th>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Date</th>
                                    <th class="px-6 py-4 text-left text-sm font-semibold dark:text-slate-200">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y dark:divide-slate-700">
                                <c:forEach var="activity" items="${activities}">
                                    <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition">
                                        <td class="px-6 py-4 text-sm dark:text-slate-300">
                                            <div class="font-medium">${activity.subject}</div>
                                            <div class="text-slate-500 text-xs mt-1">${activity.description}</div>
                                        </td>
                                        <td class="px-6 py-4 text-sm dark:text-slate-300">
                                            <span class="inline-block px-3 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary">
                                                ${activity.activityType}
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 text-sm dark:text-slate-300">
                                            <div class="text-slate-600 dark:text-slate-400">${activity.relatedType}</div>
                                            <div class="text-xs text-slate-500">ID: ${activity.relatedId}</div>
                                        </td>
                                        <td class="px-6 py-4 text-sm dark:text-slate-300">${activity.createdBy}</td>
                                        <td class="px-6 py-4 text-sm dark:text-slate-300">
                                            <fmt:formatDate value="${activity.activityDate}" pattern="MMM dd, yyyy HH:mm"/>
                                        </td>
                                        <td class="px-6 py-4 text-sm">
                                            <div class="flex gap-2">
                                                <a href="${pageContext.request.contextPath}/activities/details?id=${activity.activityId}" 
                                                   class="text-primary hover:text-primary/80 transition flex items-center gap-1">
                                                    <span class="material-symbols-outlined text-base">visibility</span>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/activities/ActivityForm.jsp?id=${activity.activityId}&action=edit" 
                                                   class="text-primary hover:text-primary/80 transition flex items-center gap-1">
                                                    <span class="material-symbols-outlined text-base">edit</span>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="p-8 text-center">
                        <div class="text-5xl text-slate-300 dark:text-slate-700 mb-4">
                            <span class="material-symbols-outlined" style="font-size: 80px;">inbox</span>
                        </div>
                        <h3 class="text-lg font-semibold dark:text-white mb-2">No Activities Found</h3>
                        <p class="text-slate-500 dark:text-slate-400 mb-4">Start by creating your first activity</p>
                        <a href="${pageContext.request.contextPath}/activities/ActivityForm.jsp" class="inline-flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90 transition">
                            <span class="material-symbols-outlined">add</span>
                            Create Activity
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>

    </div>

</body>
</html>
