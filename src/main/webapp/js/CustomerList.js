// ===== GLOBAL STATE =====
let allCustomerData = [];
let filteredCustomers = [];
let currentPage = 1;
let rowsPerPage = 10;
let selectedFilters = {
    searchText: '',
    tags: [],
    loyalty: [],
    bodyShape: [],
    size: [],
    returnRate: [],
    styleTags: []
};

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', function () {
    // Get initial customer data from table
    loadCustomerDataFromTable();

    // Set up event listeners
    setupEventListeners();

    // Show initial toast if page has status
    const pageStatus = window.__PAGE_STATUS__;
    if (pageStatus) {
        // Determine type based on message content
        let toastType = 'info';
        if (pageStatus.toLowerCase().includes('success') || pageStatus.toLowerCase().includes('successfully') || pageStatus.toLowerCase().includes('created')) {
            toastType = 'success';
        } else if (pageStatus.toLowerCase().includes('error') || pageStatus.toLowerCase().includes('fail')) {
            toastType = 'error';
        } else if (pageStatus.toLowerCase().includes('warning')) {
            toastType = 'warning';
        }
        showToast(pageStatus, toastType);
    }

    // Render initial table
    renderTable();
});

// ===== LOAD DATA FROM TABLE =====
function loadCustomerDataFromTable() {
    const rows = document.querySelectorAll('table tbody tr');
    allCustomerData = [];

    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length > 0) {
            const customerData = {
                customerId: row.dataset.customerId || extractCustomerId(cells[6]),
                name: cells[0].querySelector('strong')?.textContent.trim() || '',
                phone: cells[0].querySelector('.muted')?.textContent.trim() || '',
                email: cells[0].dataset.email || '',
                loyaltyTier: cells[1].querySelector('.loyalty-badge')?.textContent.trim() || '',
                rfmScore: cells[1].querySelector('.muted')?.textContent.replace('RFM Score: ', '').trim() || '',
                preferredSize: cells[2].querySelector('strong')?.textContent.trim() || '',
                bodyShape: cells[2].querySelector('.muted')?.textContent.trim() || '',
                styleTags: Array.from(cells[3].querySelectorAll('.tag')).map(tag => tag.textContent.trim()),
                returnRate: parseInt(cells[4].textContent) || 0,
                lastPurchase: cells[5].textContent.trim() || '',
                row: row
            };
            allCustomerData.push(customerData);
        }
    });

    filteredCustomers = [...allCustomerData];
}

function extractCustomerId(actionCell) {
    const viewIcon = actionCell.querySelector('[onclick*="viewCustomer"]');
    if (viewIcon) {
        const match = viewIcon.getAttribute('onclick').match(/viewCustomer\((\d+)\)/);
        return match ? match[1] : Math.random().toString(36).substr(2, 9);
    }
    return Math.random().toString(36).substr(2, 9);
}

// ===== EVENT LISTENERS =====
function setupEventListeners() {
    // Search input
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', debounce(applyFilters, 300));
    }

    // Rows per page select
    const rowsPerPageSelect = document.getElementById('rowsPerPage');
    if (rowsPerPageSelect) {
        rowsPerPageSelect.addEventListener('change', function () {
            const value = this.value;
            if (value === 'all') {
                rowsPerPage = filteredCustomers.length || 10;
            } else {
                rowsPerPage = parseInt(value);
            }
            currentPage = 1;
            renderTable();
        });
    }

    // Filter tag buttons - Already using onclick in JSP, no need for event listener here
}

// ===== DEBOUNCE UTILITY =====
function debounce(callback, delay) {
    let timeoutId;
    return function (...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => callback(...args), delay);
    };
}

// ===== FILTER FUNCTIONS =====
function toggleFilterTag(tag) {
    const index = selectedFilters.tags.indexOf(tag);
    if (index > -1) {
        selectedFilters.tags.splice(index, 1);
    } else {
        selectedFilters.tags.push(tag);
    }

    // Update button styles
    document.querySelectorAll('.filter-btn:not(.advanced)').forEach(btn => {
        const btnTag = btn.textContent.trim();
        let tagValue = '';
        if (btnTag.includes('Gold')) {
            tagValue = 'GOLD';
        } else if (btnTag.includes('High Return')) {
            tagValue = 'HIGH_RETURN';
        }

        if (selectedFilters.tags.includes(tagValue)) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    applyFilters();
}

function applyFilters() {
    const searchText = document.getElementById('searchInput')?.value.toLowerCase() || '';
    selectedFilters.searchText = searchText;

    filteredCustomers = allCustomerData.filter(customer => {
        // Search filter
        if (searchText) {
            const matchesSearch =
                customer.name.toLowerCase().includes(searchText) ||
                customer.phone.includes(searchText) ||
                customer.styleTags.some(tag => tag.toLowerCase().includes(searchText));
            if (!matchesSearch) return false;
        }

        // Tag filters (Gold, High Return) - ALL tags must match (AND logic)
        if (selectedFilters.tags.length > 0) {
            for (let tag of selectedFilters.tags) {
                if (tag === 'GOLD' && customer.loyaltyTier !== 'GOLD') {
                    return false;
                }
                if (tag === 'HIGH_RETURN' && customer.returnRate <= 30) {
                    return false;
                }
            }
        }

        // Advanced filters
        if (selectedFilters.loyalty.length > 0 && !selectedFilters.loyalty.includes(customer.loyaltyTier)) {
            return false;
        }
        if (selectedFilters.bodyShape.length > 0 && !selectedFilters.bodyShape.includes(customer.bodyShape)) {
            return false;
        }
        if (selectedFilters.size.length > 0 && !selectedFilters.size.includes(customer.preferredSize)) {
            return false;
        }
        if (selectedFilters.returnRate.length > 0) {
            const isHighReturn = customer.returnRate > 30;
            if (!selectedFilters.returnRate.includes(isHighReturn ? 'HIGH' : 'NORMAL')) {
                return false;
            }
        }
        if (selectedFilters.styleTags.length > 0) {
            const hasMatchingTag = customer.styleTags.some(tag => selectedFilters.styleTags.includes(tag));
            if (!hasMatchingTag) return false;
        }

        return true;
    });

    currentPage = 1;
    renderTable();
}

// ===== ADVANCED FILTER MODAL =====
function openAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    if (modal) {
        modal.style.display = 'flex';
        // Check current filters
        checkCurrentFilters();
    }
}

function closeAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

function checkCurrentFilters() {
    // Check loyalty filters
    document.querySelectorAll('input[name="loyaltyFilter"]').forEach(checkbox => {
        checkbox.checked = selectedFilters.loyalty.includes(checkbox.value);
    });

    // Check body shape filters
    document.querySelectorAll('input[name="bodyShapeFilter"]').forEach(checkbox => {
        checkbox.checked = selectedFilters.bodyShape.includes(checkbox.value);
    });

    // Check size filters
    document.querySelectorAll('input[name="sizeFilter"]').forEach(checkbox => {
        checkbox.checked = selectedFilters.size.includes(checkbox.value);
    });

    // Check return rate filters
    document.querySelectorAll('input[name="returnRateFilter"]').forEach(checkbox => {
        checkbox.checked = selectedFilters.returnRate.includes(checkbox.value);
    });

    // Check style tag filters
    document.querySelectorAll('input[name="styleTagFilter"]').forEach(checkbox => {
        checkbox.checked = selectedFilters.styleTags.includes(checkbox.value);
    });
}

function applyAdvancedFilter() {
    // Get selected loyalty tiers
    selectedFilters.loyalty = Array.from(
        document.querySelectorAll('input[name="loyaltyFilter"]:checked')
    ).map(cb => cb.value);

    // Get selected body shapes
    selectedFilters.bodyShape = Array.from(
        document.querySelectorAll('input[name="bodyShapeFilter"]:checked')
    ).map(cb => cb.value);

    // Get selected sizes
    selectedFilters.size = Array.from(
        document.querySelectorAll('input[name="sizeFilter"]:checked')
    ).map(cb => cb.value);

    // Get selected return rates
    selectedFilters.returnRate = Array.from(
        document.querySelectorAll('input[name="returnRateFilter"]:checked')
    ).map(cb => cb.value);

    // Get selected style tags
    selectedFilters.styleTags = Array.from(
        document.querySelectorAll('input[name="styleTagFilter"]:checked')
    ).map(cb => cb.value);

    closeAdvancedFilter();
    applyFilters();
}

function resetAdvancedFilter() {
    selectedFilters.loyalty = [];
    selectedFilters.bodyShape = [];
    selectedFilters.size = [];
    selectedFilters.returnRate = [];
    selectedFilters.styleTags = [];

    // Uncheck all checkboxes
    document.querySelectorAll('#advancedFilterModal input[type="checkbox"]').forEach(cb => {
        cb.checked = false;
    });

    applyFilters();
}

// ===== TABLE RENDERING =====
function renderTable() {
    const tbody = document.querySelector('table tbody');
    if (!tbody) return;

    if (filteredCustomers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 40px;">No customers found</td></tr>';
        renderPagination();
        return;
    }

    // Calculate pagination
    const totalPages = Math.ceil(filteredCustomers.length / rowsPerPage);
    if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
    }

    const startIndex = (currentPage - 1) * rowsPerPage;
    const endIndex = startIndex + rowsPerPage;
    const pageCustomers = filteredCustomers.slice(startIndex, endIndex);

    // Render rows
    tbody.innerHTML = pageCustomers.map(customer => `
        <tr class="card-body-row">
            <td class="customer-info">
                <div class="avatar">
                    ${customer.name.charAt(0).toUpperCase()}
                </div>
                <div>
                    <div><strong>${customer.name}</strong></div>
                    <div class="muted">${customer.phone}</div>
                </div>
            </td>
            
            <td>
                <span class="loyalty-badge ${customer.loyaltyTier === 'GOLD' ? 'gold' : customer.loyaltyTier === 'BLACKLIST' ? 'blacklist' : ''}">
                    ${customer.loyaltyTier}
                </span>
                <div class="muted">RFM Score: ${customer.rfmScore}</div>
            </td>
            
            <td>
                <div><strong>${customer.preferredSize}</strong></div>
                <div class="muted">${customer.bodyShape}</div>
            </td>
            
            <td class="tags">
                ${customer.styleTags.slice(0, 2).map(tag => `<span class="tag">${tag}</span>`).join('')}
            </td>
            
            <td>
                <div>${customer.returnRate}%</div>
                <div class="progress">
                    <div class="progress-bar ${customer.returnRate > 30 ? 'high-return' : ''}" 
                         style="width: ${Math.min(customer.returnRate, 100)}%"></div>
                </div>
            </td>
            
            <td>${customer.lastPurchase}</td>
            
            <td class="actions">
                <i class="fa-regular fa-eye" title="View Details" onclick="viewCustomer(${customer.customerId})"></i>
                <div class="action-wrapper">
                    <i class="fa-solid fa-ellipsis-vertical" onclick="toggleMenu(this)"></i>
                    <div class="action-menu" style="display: none;">
                        <div onclick="openPreview(${customer.customerId})">Preview</div>
                        <div onclick="deleteCustomer(${customer.customerId})">Delete</div>
                    </div>
                </div>
            </td>
        </tr>
    `).join('');

    renderPagination();
}

// ===== PAGINATION =====
function renderPagination() {
    const totalPages = Math.ceil(filteredCustomers.length / rowsPerPage) || 1;
    const paginationControls = document.getElementById('paginationControls');

    if (!paginationControls) return;

    let html = '';

    // Previous button
    html += `
        <button class="btn btn-light" ${currentPage === 1 ? 'disabled' : ''}
                onclick="goToPage(${currentPage - 1})">
            <i class="fa-solid fa-chevron-left"></i>
        </button>
    `;

    // Page numbers
    const maxButtons = window.innerWidth < 768 ? 3 : 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxButtons / 2));
    let endPage = Math.min(totalPages, startPage + maxButtons - 1);

    if (endPage - startPage < maxButtons - 1) {
        startPage = Math.max(1, endPage - maxButtons + 1);
    }

    // First page button
    if (startPage > 1) {
        html += `<button class="btn btn-light" onclick="goToPage(1)">1</button>`;
        if (startPage > 2) {
            html += `<span style="padding: 0 8px;">...</span>`;
        }
    }

    // Page number buttons
    for (let i = startPage; i <= endPage; i++) {
        html += `
            <button class="btn ${i === currentPage ? 'btn-primary' : 'btn-light'}" 
                    onclick="goToPage(${i})">
                ${i}
            </button>
        `;
    }

    // Last page button
    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            html += `<span style="padding: 0 8px;">...</span>`;
        }
        html += `<button class="btn btn-light" onclick="goToPage(${totalPages})">${totalPages}</button>`;
    }

    // Next button
    html += `
        <button class="btn btn-light" ${currentPage === totalPages ? 'disabled' : ''}
                onclick="goToPage(${currentPage + 1})">
            <i class="fa-solid fa-chevron-right"></i>
        </button>
    `;

    // Page info
    const startRecord = filteredCustomers.length === 0 ? 0 : (currentPage - 1) * rowsPerPage + 1;
    const endRecord = Math.min(currentPage * rowsPerPage, filteredCustomers.length);
    html += `<span style="margin-left: 16px; color: var(--text-muted); font-size: 13px;">
        ${startRecord}-${endRecord} of ${filteredCustomers.length}
    </span>`;

    paginationControls.innerHTML = html;
}

function goToPage(pageNumber) {
    const totalPages = Math.ceil(filteredCustomers.length / rowsPerPage) || 1;
    if (pageNumber < 1 || pageNumber > totalPages) return;

    currentPage = pageNumber;
    renderTable();

    // Scroll to table
    const table = document.querySelector('table');
    if (table) {
        table.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

// ===== CUSTOMER ACTIONS =====
function openPreview(customerId) {
    const customer = allCustomerData.find(c => c.customerId == customerId);
    if (!customer) return;

    // Populate preview panel
    document.getElementById('previewName').textContent = customer.name;
    document.getElementById('previewPhone').textContent = customer.phone;
    document.getElementById('previewEmail').textContent = customer.email || 'Not provided';
    document.getElementById('previewGender').textContent = 'Not provided';
    document.getElementById('previewSize').textContent = customer.preferredSize;
    document.getElementById('previewBodyShape').textContent = customer.bodyShape;
    document.getElementById('previewHeight').textContent = 'Not available';
    document.getElementById('previewWeight').textContent = 'Not available';
    document.getElementById('previewLoyalty').textContent = customer.loyaltyTier;
    document.getElementById('previewLoyalty').className = `preview-value loyalty-badge ${customer.loyaltyTier === 'GOLD' ? 'gold' : ''}`;
    document.getElementById('previewRFM').textContent = customer.rfmScore;
    document.getElementById('previewReturnRate').textContent = customer.returnRate + '%';

    // Show preview panel
    const preview = document.getElementById('customerPreview');
    if (preview) {
        preview.classList.add('show');
    }
}

function viewCustomer(customerId) {
    if (!customerId) return;

    const ctx = window.__CTX__ || ""; // fallback nếu quên inject
    const url = `${ctx}/customers/detail?customerId=${encodeURIComponent(customerId)}`;

    window.location.href = url; // chuyển trang
}

function closePreview() {
    const preview = document.getElementById('customerPreview');
    if (preview) {
        preview.classList.remove('show');
    }
}

function deleteCustomer(customerId) {
    if (confirm('Are you sure you want to delete this customer?')) {
        // Make API call to delete
        const ctx = window.__CTX__ || ""; // fallback nếu quên inject

        const url = `${ctx}/customers/remove?customerId=${encodeURIComponent(customerId)}`;

        window.location.href = url; // chuyển trang
    }
}

// ===== ACTION MENU =====
function toggleMenu(element) {
    const menu = element.closest('.action-wrapper').querySelector('.action-menu');
    if (menu) {
        const isVisible = menu.style.display !== 'none';

        // Close all other menus
        document.querySelectorAll('.action-menu').forEach(m => m.style.display = 'none');

        // Toggle current menu
        menu.style.display = isVisible ? 'none' : 'flex';
        menu.style.flexDirection = 'column';
    }
}

// Close action menu when clicking outside
document.addEventListener('click', function (e) {
    if (!e.target.closest('.action-wrapper')) {
        document.querySelectorAll('.action-menu').forEach(menu => {
            menu.style.display = 'none';
        });
    }
});

// ===== TOAST NOTIFICATIONS =====
function showToast(message, type = 'success', duration = 3000) {
    const toast = document.getElementById('toast');
    const toastIcon = document.getElementById('toastIcon');
    const toastMessage = document.getElementById('toastMessage');
    const toastBar = document.getElementById('toastBar');

    if (!toast) return;

    // Set icon based on type
    const icons = {
        success: '<i class="fas fa-check-circle" style="color: #10b981; font-size: 20px;"></i>',
        error: '<i class="fas fa-exclamation-circle" style="color: #ef4444; font-size: 20px;"></i>',
        info: '<i class="fas fa-info-circle" style="color: #3b82f6; font-size: 20px;"></i>',
        warning: '<i class="fas fa-warning" style="color: #f59e0b; font-size: 20px;"></i>'
    };

    // Set bar color based on type
    const barColors = {
        success: '#10b981',
        error: '#ef4444',
        info: '#3b82f6',
        warning: '#f59e0b'
    };

    toastIcon.innerHTML = icons[type] || icons.info;
    toastMessage.textContent = message;

    // Set bar color
    toastBar.style.background = barColors[type] || barColors.info;

    // Reset animation
    toast.classList.remove('show', 'hide');
    toastBar.style.animation = 'none';

    // Show toast
    toast.classList.add('show');

    // Trigger animation
    setTimeout(() => {
        toastBar.style.animation = `slideOut ${duration}ms ease-out forwards`;
    }, 10);

    // Hide after duration
    setTimeout(() => {
        toast.classList.remove('show');
        toast.classList.add('hide');
    }, duration);
}

// Toast close button
document.getElementById('toastCloseBtn')?.addEventListener('click', function () {
    const toast = document.getElementById('toast');
    toast.classList.remove('show');
    toast.classList.add('hide');
});

// Close advanced filter modal when clicking outside
document.getElementById('advancedFilterModal')?.addEventListener('click', function (e) {
    if (e.target === this) {
        closeAdvancedFilter();
    }
});

// Close preview panel when clicking outside
document.getElementById('customerPreview')?.addEventListener('click', function (e) {
    if (e.target === this) {
        closePreview();
    }
});
