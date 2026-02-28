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
//    renderTable();
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
                email: cells[7].textContent.trim() || '',
                loyaltyTier: cells[1].querySelector('.loyalty-badge')?.textContent.trim() || '',
                rfmScore: cells[1].querySelector('.muted')?.textContent.replace('RFM Score: ', '').trim() || '',
                preferredSize: cells[2].querySelector('strong')?.textContent.trim() || '',
                bodyShape: cells[2].querySelector('.muted')?.textContent.trim() || '',
                styleTags: Array.from(cells[3].querySelectorAll('.tag')).map(tag => tag.textContent.trim()),
                returnRate: parseInt(cells[4].textContent) || 0,
                lastPurchase: cells[5].textContent.trim() || '',
                gender: cells[8].textContent.trim() || '',
                height: cells[9].textContent.trim() || '',
                weight: cells[10].textContent.trim() || '',
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
            if (!matchesSearch)
                return false;
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
        if (selectedFilters.size.length > 0 && !selectedFilters.size.includes(customer.preferredSize.charAt(0))) {
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
            if (!hasMatchingTag)
                return false;
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


// ===== CUSTOMER ACTIONS =====
function openPreview(customerId) {
    const customer = allCustomerData.find(c => c.customerId == customerId);
    if (!customer)
        return;
    console.log(customer);
    // Populate preview panel
    document.getElementById('previewName').textContent = customer.name;
    document.getElementById('previewPhone').textContent = customer.phone;
    document.getElementById('previewEmail').textContent = customer.email || 'Not provided';
    document.getElementById('previewGender').textContent = customer.gender;
    document.getElementById('previewSize').textContent = customer.preferredSize;
    document.getElementById('previewBodyShape').textContent = customer.bodyShape;
    document.getElementById('previewHeight').textContent = customer.height || 'Not available';
    document.getElementById('previewWeight').textContent = customer.weight || 'Not available';
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
    if (!customerId)
        return;

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
function toggleMenu(element, event) {

    event.stopPropagation(); // 🛑 chặn document click

    const menu = element.closest('.action-wrapper').querySelector('.action-menu');

    const isVisible = menu.style.display === 'flex';

    // đóng tất cả menu khác
    document.querySelectorAll('.action-menu').forEach(m => m.style.display = 'none');

    // toggle menu hiện tại
    menu.style.display = isVisible ? 'none' : 'flex';
    menu.style.flexDirection = 'column';
}

// Close action menu when clicking outside
document.addEventListener("click", function (e) {

    const ellipsis = e.target.closest(".fa-ellipsis-vertical");

    if (ellipsis) {

        e.stopPropagation();

        const wrapper = ellipsis.closest(".action-wrapper");
        const menu = wrapper.querySelector(".action-menu");

        const isVisible = menu.classList.contains("show");

        document.querySelectorAll(".action-menu")
            .forEach(m => m.classList.remove("show"));

        if (!isVisible) {
            menu.classList.add("show");
        }

        return;
    }

    document.querySelectorAll(".action-menu")
        .forEach(m => m.classList.remove("show"));
});

// ===== TOAST NOTIFICATIONS =====
function showToast(message, type = 'success', duration = 3000) {
    const toast = document.getElementById('toast');
    const toastIcon = document.getElementById('toastIcon');
    const toastMessage = document.getElementById('toastMessage');
    const toastBar = document.getElementById('toastBar');

    if (!toast)
        return;

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



// ================= PAGINATION AJAX =================
function loadPage(page = 1, pageSize = rowsPerPage) {

    rowsPerPage = pageSize;
    currentPage = page;

    fetch(`${window.__CTX__ || ""}/customers?page=${page}&size=${pageSize}`, {
        headers: {
            "X-Requested-With": "XMLHttpRequest"
        }
    })
            .then(res => res.json())
            .then(data => {

                console.log("DATA:", data);

                allCustomerData = data.customers;

                renderTableBody(data.customers);

                // TÍNH TOTAL PAGES TỪ totalRecords
                const totalPages = Math.ceil(data.totalRecords / rowsPerPage);

                renderPagination(totalPages, currentPage);

            })
            .catch(err => console.error(err));
}

function renderTableBody(customers) {

    let html = "";

    customers.forEach(c => {

        html += `
<tr class="card-body-row">

<td class="customer-info">
    <div class="avatar">
        ${c.name ? c.name.charAt(0).toUpperCase() : ""}
    </div>
    <div>
        <div onclick="viewCustomer(${c.customerId})" style="cursor:pointer;">
            <strong>${c.name}</strong>
        </div>
        <div class="muted">${c.phone}</div>
    </div>
</td>

<td>
    <span class="loyalty-badge ${getLoyaltyClass(c.loyaltyTier)}">
        ${c.loyaltyTier}
    </span>
    <div class="muted">RFM Score: ${c.rfmScore}</div>
</td>

<td>
    <div><strong>${c.preferredSize ?? ""}</strong></div>
    <div class="muted">${c.bodyShape ?? ""}</div>
</td>

<td class="tags">
    ${renderTags(c.styleTags)}
</td>

<td>
    <div>${c.returnRate}%</div>
    <div class="progress">
        <div class="progress-bar ${c.returnRate > 30 ? "high-return" : ""}"
             style="width:${c.returnRate}%">
        </div>
    </div>
</td>

<td>${c.lastPurchase ?? ""}</td>

    <td class="actions">
        <i class="fa-regular fa-eye" title="View Details" onclick="viewCustomer(${c.customerId})"></i>
            <div class="action-wrapper">
                <i class="fa-solid fa-ellipsis-vertical"
                    onclick="toggleMenu(this)"></i>

                    <div class="action-menu">
                    <div onclick="openPreview(${c.customerId})">Preview</div>
                    <div onclick="deleteCustomer(${c.customerId})">Delete</div>
             </div>
     </td>
<td style="display: none;">${c.email}</td>
                        <td style="display: none;">${c.gender}</td>
                        <td style="display: none;">${c.height}</td>
                        <td style="display: none;">${c.weight}</td>
</tr>
`;
    });

    document.getElementById("customerTableBody").innerHTML = html;
}

function renderTags(tags) {

    if (!tags)
        return "";

    return tags.slice(0, 2).map(tag =>
            `<span class="tag">${tag}</span>`
    ).join("");
}

function getLoyaltyClass(tier) {
    if (tier === "GOLD")
        return "gold";
    if (tier === "BLACKLIST")
        return "blacklist";
    return "";
}

function renderPagination(totalPages, currentPage) {

    const container = document.getElementById("paginationControls");

    if (!totalPages || totalPages <= 1) {
        container.innerHTML = "<button class=" + "active" + ">1</button>";
        return;
    }

    let html = "";

    for (let i = 1; i <= totalPages; i++) {

        html += `
            <button onclick="loadPage(${i}, ${rowsPerPage})"
                class="${i === currentPage ? "active" : ""}">
                ${i}
            </button>
        `;
    }

    container.innerHTML = html;
}

document.getElementById("rowsPerPage")?.addEventListener("change", function () {

    const value = this.value === "all" ? 999999 : parseInt(this.value);

    rowsPerPage = value;
    loadPage(1, value);
});