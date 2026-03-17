/**
 * Category Form Page JavaScript
 * Handles interactions for category form management
 */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize form validation
    initializeFormValidation();
    
    // Handle form submission
    initializeFormSubmission();
});

function initializeFormValidation() {
    var categoryForm = document.querySelector('form[action*="/sale/category"]');
    if (categoryForm) {
        // Add form validation if Bootstrap validation is needed
        if (window.bootstrap) {
            // Bootstrap 5 form validation
            categoryForm.addEventListener('submit', function(e) {
                if (!categoryForm.checkValidity()) {
                    e.preventDefault();
                    e.stopPropagation();
                }
                categoryForm.classList.add('was-validated');
            }, false);
        }
    }
}

function initializeFormSubmission() {
    var submitButton = document.querySelector('button[type="submit"]');
    if (submitButton) {
        submitButton.addEventListener('click', function(e) {
            // Additional form submission handling if needed
        });
    }
}

// Validate category name
function validateCategoryName(name) {
    if (!name || name.trim() === '') {
        alert('Category name is required');
        return false;
    }
    if (name.length < 2) {
        alert('Category name must be at least 2 characters');
        return false;
    }
    if (name.length > 100) {
        alert('Category name cannot exceed 100 characters');
        return false;
    }
    return true;
}

// Validate category description
function validateDescription(description) {
    if (description && description.length > 500) {
        alert('Description cannot exceed 500 characters');
        return false;
    }
    return true;
}

// Handle cancel button
function cancelForm() {
    window.history.back();
}
