<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Activity Form - CRM System</title>

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
                    <a href="${pageContext.request.contextPath}/activities/list" class="text-slate-600 dark:text-slate-400 hover:text-primary">Activities</a>
                </div>
            </div>
        </nav>

        <div class="max-w-2xl mx-auto px-4 py-8">

            <!-- Breadcrumb -->
            <div class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400 mb-6">
                <a href="${pageContext.request.contextPath}/activities/list" class="hover:text-primary">Activities</a>
                <span class="material-symbols-outlined text-base">chevron_right</span>
                <span class="text-slate-900 dark:text-white">
                    <c:choose>
                        <c:when test="${param.action == 'edit'}">
                            Edit Activity
                        </c:when>
                        <c:otherwise>
                            New Activity
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <!-- Form Card -->
            <div class="bg-white dark:bg-slate-900 rounded-xl shadow border dark:border-slate-800 p-8">

                <!-- Header -->
                <div class="mb-8">
                    <h1 class="text-3xl font-bold dark:text-white mb-2">
                        <c:choose>
                            <c:when test="${param.action == 'edit'}">
                                Edit Activity
                            </c:when>
                            <c:otherwise>
                                Create New Activity
                            </c:otherwise>
                        </c:choose>
                    </h1>
                    <p class="text-slate-500">
                        <c:choose>
                            <c:when test="${param.action == 'edit'}">
                                Update the activity details below
                            </c:when>
                            <c:otherwise>
                                Fill in the details to create a new activity
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <!-- Activity Form -->
                <c:choose>
                    <c:when test="${param.action == 'edit'}">
                        <c:set var="formAction" value="${pageContext.request.contextPath}/activities/update" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="formAction" value="${pageContext.request.contextPath}/activities/create" />
                    </c:otherwise>
                </c:choose>

                <form id="activityForm" method="post" 
                      action="${formAction}"
                      class="space-y-6">

                    <!-- Hidden Activity ID for Edit -->
                    <c:if test="${param.action == 'edit'}">
                        <input type="hidden" name="activityId" value="${param.id}"/>
                    </c:if>

                    <!-- Subject Field -->
                    <div>
                        <label for="subject" class="block text-sm font-medium text-slate-900 dark:text-slate-200 mb-2">
                            <span class="text-red-500">*</span> Subject
                        </label>
                        <input
                            type="text"
                            id="subject"
                            name="subject"
                            value="${activity.subject}"
                            required
                            placeholder="e.g., Team Meeting Notes"
                            class="w-full h-12 px-4 rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
                            />
                        <p class="text-xs text-slate-500 mt-1">The main title of this activity</p>
                    </div>

                    <!-- Description Field -->
                    <div>
                        <label for="description" class="block text-sm font-medium text-slate-900 dark:text-slate-200 mb-2">
                            <span class="text-red-500">*</span> Description
                        </label>
                        <textarea
                            id="description"
                            name="description"
                            required

                            rows="6"
                            placeholder="Enter activity details..."
                            class="w-full px-4 py-3 rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition resize-none"
                            >${activity.description}</textarea>
                        <p class="text-xs text-slate-500 mt-1">Detailed information about this activity</p>
                    </div>

                    <!-- Two Column Layout -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                        <!-- Activity Type -->
                        <div>
                            <label for="activityType" class="block text-sm font-medium text-slate-900 dark:text-slate-200 mb-2">
                                <span class="text-red-500">*</span> Activity Type
                            </label>
                            <select
                                id="activityType"
                                name="activityType"
                                required
                                class="w-full h-12 px-4 rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
                                >
                                <option <c:if test="${empty activity.activityType}">selected</c:if> value="">Select activity type...</option>
                                <option <c:if test="${activity.activityType == 'call'}">selected</c:if> value="call">Call</option>
                                <option <c:if test="${activity.activityType == 'email'}">selected</c:if> value="email">Email</option>
                                <option <c:if test="${activity.activityType == 'meeting'}">selected</c:if> value="meeting">Meeting</option>
                                <option <c:if test="${activity.activityType == 'task'}">selected</c:if> value="task">Task</option>
                                <option <c:if test="${activity.activityType == 'note'}">selected</c:if> value="note">Note</option>
                                <option <c:if test="${activity.activityType == 'other'}">selected</c:if> value="other">Other</option>
                                </select>
                            </div>

                            <!-- Related Type -->
                            <div>
                                <label for="relatedType" class="block text-sm font-medium text-slate-900 dark:text-slate-200 mb-2">
                                    <span class="text-red-500">*</span> Related To (Type)
                                </label>
                                <select
                                    id="relatedType"
                                    name="relatedType"
                                    required
                                    class="w-full h-12 px-4 rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
                                    >
                                    <option <c:if test="${empty activity.relatedType}">selected</c:if> value="">Select related type...</option>
                                <option <c:if test="${activity.relatedType == 'customer'}">selected</c:if> value="customer">Customer</option>
                                <option <c:if test="${activity.relatedType == 'lead'}">selected</c:if> value="lead">Lead</option>
                                <option <c:if test="${activity.relatedType == 'deal'}">selected</c:if> value="deal">Deal</option>
                                </select>
                            </div>

                            <!-- Related ID / Name (select + hidden id) -->
                            <!-- Related Name -->
                            <div>
                                <label for="relatedName" class="block text-sm font-medium mb-2">
                                    <span class="text-red-500">*</span> Related To
                                </label>

                                <!-- Hidden ID gửi về server -->
                                <input type="hidden" id="relatedId" name="relatedId" />

                                <div class="relative w-full">
                                    <!-- Input search -->
                                    <input type="text"
                                           id="relatedSearch"
                                           placeholder="Select related name..."
                                           value="${activity.relatedName}"
                                           class="w-full h-12 px-4 rounded-lg border"
                                           autocomplete="off">

                                    <!-- Select thật (ẩn đi nhưng vẫn submit form) -->
                                    <select id="relatedName" name="relatedName" class="hidden">
                                        <option value="">Select related name...</option>
                                    </select>

                                    <input type="hidden" id="relatedId" name="relatedId">

                                    <!-- Dropdown -->
                                    <div id="relatedDropdown"
                                         class="absolute z-50 w-full bg-white border rounded-lg mt-1 max-h-60 overflow-y-auto hidden">
                                    </div>
                                </div>

                                <p class="text-xs text-slate-500 mt-1">
                                    Select related entity after choosing type
                                </p>
                            </div>

                            <!-- Created By is auto-filled from session; no input shown -->

                        </div>

                        <!-- Form Actions -->
                        <div class="flex gap-4 pt-6 border-t dark:border-slate-700">
                            <button
                                type="submit"
                                class="flex-1 h-12 rounded-lg bg-primary text-white font-medium hover:bg-primary/90 transition flex items-center justify-center gap-2"
                                >
                                <span class="material-symbols-outlined">check</span>
                            <c:choose>
                                <c:when test="${param.action == 'edit'}">
                                    Update Activity
                                </c:when>
                                <c:otherwise>
                                    Create Activity
                                </c:otherwise>
                            </c:choose>
                        </button>
                        <a
                            href="${pageContext.request.contextPath}/activities/list"
                            class="flex-1 h-12 rounded-lg bg-slate-200 dark:bg-slate-800 text-slate-900 dark:text-slate-100 font-medium hover:bg-slate-300 dark:hover:bg-slate-700 transition flex items-center justify-center gap-2"
                            >
                            <span class="material-symbols-outlined">close</span>
                            Cancel
                        </a>
                    </div>

                </form>

                <!-- Info Box -->
                <div class="mt-8 p-4 rounded-lg bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800">
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5">info</span>
                        <div>
                            <p class="text-sm font-medium text-blue-900 dark:text-blue-100">Required Fields</p>
                            <p class="text-xs text-blue-800 dark:text-blue-200 mt-1">All fields marked with <span class="text-red-500 font-bold">*</span> are required and must be filled before submitting the form.</p>
                        </div>
                    </div>
                </div>

            </div>

        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function () {

                const relatedType = document.getElementById("relatedType");
                const relatedName = document.getElementById("relatedName"); // select ẩn
                const relatedSearch = document.getElementById("relatedSearch"); // input search
                const relatedDropdown = document.getElementById("relatedDropdown");
                const relatedIdInput = document.getElementById("relatedId");
                const form = document.getElementById("activityForm");

                const contextPath = "${pageContext.request.contextPath}";

                console.log("Activity form script loaded");

                // ==============================
                // Load data khi đổi Related Type
                // ==============================
                relatedType.addEventListener("change", function () {

                    const type = this.value;

                    relatedName.innerHTML = '<option value="">Select related name...</option>';
                    relatedDropdown.innerHTML = "";
                    relatedSearch.value = "";
                    relatedIdInput.value = "";

                    if (!type)
                        return;

                    fetch(contextPath + "/api/related-entities?type=" + type)
                            .then(response => {
                                if (!response.ok)
                                    throw new Error("Network response was not ok");
                                return response.json();
                            })
                            .then(data => {

                                if (!data || data.length === 0)
                                    return;

                                data.forEach(item => {

                                    // Thêm vào select ẩn
                                    const option = document.createElement("option");
                                    option.value = item.id;
                                    option.textContent = item.name;
                                    relatedName.appendChild(option);

                                    // Thêm vào dropdown custom
                                    const div = document.createElement("div");
                                    div.className = "px-4 py-2 hover:bg-gray-100 cursor-pointer";
                                    div.textContent = item.name;

                                    div.addEventListener("click", function () {
                                        relatedSearch.value = item.name;
                                        relatedName.value = item.id;
                                        relatedIdInput.value = item.id;
                                        relatedDropdown.classList.add("hidden");
                                    });

                                    relatedDropdown.appendChild(div);
                                });

                            })
                            .catch(error => {
                                console.error("Error loading related entities:", error);
                            });
                });

                // ==============================
                // Filter khi gõ search
                // ==============================
                relatedSearch.addEventListener("input", function () {

                    const filter = this.value.toLowerCase();
                    const items = relatedDropdown.children;

                    for (let i = 0; i < items.length; i++) {
                        const text = items[i].textContent.toLowerCase();
                        items[i].style.display = text.includes(filter) ? "" : "none";
                    }

                    relatedDropdown.classList.remove("hidden");
                });

                // ==============================
                // Show dropdown khi focus
                // ==============================
                relatedSearch.addEventListener("focus", function () {
                    if (relatedDropdown.children.length > 0) {
                        relatedDropdown.classList.remove("hidden");
                    }
                });

                // ==============================
                // Click ngoài thì đóng
                // ==============================
                document.addEventListener("click", function (e) {
                    if (!e.target.closest(".relative")) {
                        relatedDropdown.classList.add("hidden");
                    }
                });

                // ==============================
                // Validate khi submit
                // ==============================
                form.addEventListener("submit", function (e) {

                    if (!relatedIdInput.value) {
                        e.preventDefault();
                        alert("Please enter a name that already exists in the system.");
                        return;
                    }

                    console.log("Form submitted successfully");
                });

            });
        </script>
    </body>
</html>
