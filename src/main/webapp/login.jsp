<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html class="light" lang="en"><head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>CRM System Login</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#197fe6",
                        "background-light": "#f6f7f8",
                        "background-dark": "#111921",
                    },
                    fontFamily: {
                        "display": ["Inter", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                },
            },
        }
    </script>
    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display min-h-screen flex flex-col transition-colors duration-300">
    <div class="flex-1 flex flex-col justify-center items-center px-4 py-12">
        <div class="w-full max-w-[480px]">
            <!-- Header Logo/Title Area -->
            <div class="mb-8 text-center">
                <div class="inline-flex items-center justify-center p-3 mb-4 bg-primary/10 rounded-xl">
                    <span class="material-symbols-outlined text-primary text-4xl">hub</span>
                </div>
                <h1 class="text-[#111418] dark:text-white tracking-light text-[32px] font-bold leading-tight">CRM System</h1>
                <p class="text-[#637588] dark:text-slate-400 text-base font-normal mt-2">Manage your relationships better</p>
            </div>
            <!-- Login Card -->
            <div class="bg-white dark:bg-slate-900 rounded-xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-slate-100 dark:border-slate-800 overflow-hidden">
                <div class="p-8">
                    <div class="mb-6">
                        <h2 class="text-[#111418] dark:text-white text-xl font-bold leading-tight">Welcome back</h2>
                        <p class="text-[#637588] dark:text-slate-400 text-sm mt-1">Please enter your details to sign in.</p>
                    </div>
                    <form class="space-y-4" onsubmit="return false;">
                        <!-- Username Field -->
                        <div class="flex flex-col gap-1.5">
                            <label class="text-[#111418] dark:text-slate-200 text-sm font-medium leading-normal">
                                Username or Email
                            </label>
                            <input class="form-input w-full rounded-lg text-[#111418] dark:text-white focus:outline-0 focus:ring-2 focus:ring-primary/20 border border-[#dce0e5] dark:border-slate-700 bg-white dark:bg-slate-800 focus:border-primary h-12 placeholder:text-[#637588] dark:placeholder:text-slate-500 px-4 text-sm font-normal" placeholder="e.g. john.doe@company.com" type="text"/>
                        </div>
                        <!-- Password Field -->
                        <div class="flex flex-col gap-1.5">
                            <label class="text-[#111418] dark:text-slate-200 text-sm font-medium leading-normal">
                                Password
                            </label>
                            <div class="relative flex items-center">
                                <input class="form-input w-full rounded-lg text-[#111418] dark:text-white focus:outline-0 focus:ring-2 focus:ring-primary/20 border border-[#dce0e5] dark:border-slate-700 bg-white dark:bg-slate-800 focus:border-primary h-12 placeholder:text-[#637588] dark:placeholder:text-slate-500 px-4 text-sm font-normal pr-12" placeholder="Enter your password" type="password"/>
                                <button class="absolute right-3 text-[#637588] dark:text-slate-400 hover:text-primary transition-colors" type="button">
                                    <span class="material-symbols-outlined">visibility</span>
                                </button>
                            </div>
                        </div>
                        <!-- Options Row -->
                        <div class="flex items-center justify-between py-2">
                            <div class="flex items-center gap-2">
                                <input class="h-4 w-4 rounded border-[#dce0e5] dark:border-slate-700 text-primary focus:ring-0 focus:ring-offset-0 transition-colors cursor-pointer" id="remember-me" type="checkbox"/>
                                <label class="text-[#111418] dark:text-slate-300 text-sm font-normal cursor-pointer" for="remember-me">Remember me</label>
                            </div>
                            <a class="text-primary hover:text-primary/80 text-sm font-medium transition-colors" href="#">Forgot password?</a>
                        </div>
                        <!-- Login Button -->
                        <button class="w-full flex items-center justify-center rounded-lg h-12 bg-primary hover:bg-primary/90 text-white text-base font-semibold shadow-sm transition-all active:scale-[0.98]">
                            Login
                        </button>
                    </form>
                    <div class="mt-8 pt-6 border-t border-slate-100 dark:border-slate-800 text-center">
                        <p class="text-[#637588] dark:text-slate-400 text-sm">
                            Don't have an account?
                            <a class="text-primary font-semibold hover:underline" href="#">Request access</a>
                        </p>
                    </div>
                </div>
            </div>
            <!-- Footer Links -->
            <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4 text-[#637588] dark:text-slate-500 text-xs">
                <span>© 2024 CRM Enterprise System</span>
                <div class="hidden sm:block w-1 h-1 bg-slate-300 dark:bg-slate-700 rounded-full"></div>
                <a class="hover:text-primary transition-colors" href="#">Privacy Policy</a>
                <div class="hidden sm:block w-1 h-1 bg-slate-300 dark:bg-slate-700 rounded-full"></div>
                <a class="hover:text-primary transition-colors" href="#">Terms of Service</a>
            </div>
        </div>
    </div>
    <!-- Theme Toggle (Bonus functionality for better UX representation) -->
    <div class="fixed bottom-6 right-6">
        <button class="p-3 bg-white dark:bg-slate-800 shadow-lg rounded-full border border-slate-200 dark:border-slate-700 text-[#637588] dark:text-slate-400 hover:text-primary transition-colors" onclick="document.documentElement.classList.toggle('dark')">
            <span class="material-symbols-outlined block dark:hidden">dark_mode</span>
            <span class="material-symbols-outlined hidden dark:block">light_mode</span>
        </button>
    </div>
</body></html>
