/**
 * Category List Page JavaScript
 * Handles interactions for category list management
 */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips or popovers if needed
    initializeElements();
    
    // Handle search form submissions
    initializeSearchForm();
    
    // Handle pagination
    initializePagination();
});

function initializeElements() {
    // Initialize Bootstrap tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

function initializeSearchForm() {
    var searchForm = document.querySelector('form[action*="/sale/category/list"]');
    if (searchForm) {
        // Form submission handling can be added here if needed
    }
}

function initializePagination() {
    var paginationLinks = document.querySelectorAll('.pagination a');
    paginationLinks.forEach(function(link) {
        link.addEventListener('click', function(e) {
            // Pagination is handled by links, no additional handling needed
        });
    });
}

// Utility function for delete confirmation
function confirmDelete(categoryName) {
    return confirm('Are you sure you want to delete category: ' + categoryName + '?');
}

// Handle inline edit if needed
function editCategory(categoryId) {
    window.location.href = '/sale/category/edit?id=' + categoryId;
}

// Handle inline delete if needed
function deleteCategory(categoryId) {
    window.location.href = '/sale/category/delete?id=' + categoryId;
}
