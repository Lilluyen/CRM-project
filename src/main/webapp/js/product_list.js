/**
 * Product List Page JavaScript
 * Handles interactions for product list management
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
    var searchForm = document.querySelector('form[action*="/sale/product/list"]');
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
function confirmDelete(productName) {
    return confirm('Are you sure you want to delete product: ' + productName + '?');
}

// Handle inline edit if needed
function editProduct(productId) {
    window.location.href = '/sale/product/edit?id=' + productId;
}

// Handle inline delete if needed
function deleteProduct(productId) {
    window.location.href = '/sale/product/delete?id=' + productId;
}
