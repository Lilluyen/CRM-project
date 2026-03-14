// ===== GLOBAL STATE =====
let currentPage = 1;
let rowsPerPage = 10;

// Hybrid Keyset Pagination state
let paginationSessionId = window.__SESSION_ID__ || null;
let totalPages = window.__TOTAL_PAGES__ || 1;
let totalRecords = window.__TOTAL_RECORDS__ || 0;
let advancedFilters = {
    loyaltyTiers: [],
    tagIds: [],
    bodyShapes: [],
    sizes: [],
    returnRateMode: null
};

// Cache of current page's customer data — used by openPreview()
let currentPageCustomers = [];

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', function () {
    currentPage = window.__CURRENT_PAGE__ || 1;
    totalPages = window.__TOTAL_PAGES__ || 1;

    // Parse server-rendered rows vào currentPageCustomers
    // để openPreview() hoạt động ngay khi F5 mà không cần gọi API trước
    currentPageCustomers = parseCustomersFromDOM();


    const rowsSelect = document.getElementById('rowsPerPage');
    if (rowsSelect) rowsSelect.value = rowsPerPage;

    setupEventListeners();

    const pageStatus = window.__PAGE_STATUS__;
    if (pageStatus) {
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
});

// Parse data từ các hidden <td> mà JSP đã render sẵn
// Dùng khi F5 — lúc này JS chưa gọi API nào nhưng DOM đã có data
function parseCustomersFromDOM() {
    const customers = [];
    document.querySelectorAll('#customerTableBody tr.card-body-row').forEach(row => {
        const viewBtn = row.querySelector('[onclick*="viewCustomer"]');
        const idMatch = viewBtn?.getAttribute('onclick')?.match(/viewCustomer\((\d+)\)/);
        if (!idMatch) return;

        const tds = row.querySelectorAll('td');
        customers.push({
            customerId: parseInt(idMatch[1]),
            name: row.querySelector('.customer-info strong')?.textContent?.trim() || '',
            phone: row.querySelector('.customer-info .muted')?.textContent?.trim() || '',
            email: tds[tds.length - 4]?.textContent?.trim() || '',
            gender: tds[tds.length - 3]?.textContent?.trim() || '',
            height: tds[tds.length - 2]?.textContent?.trim() || '',
            weight: tds[tds.length - 1]?.textContent?.trim() || '',
            loyaltyTier: row.querySelector('.loyalty-badge')?.textContent?.trim() || '',
            rfmScore: row.querySelector('.table_rfm_score')?.textContent?.replace('RFM Score:', '')?.trim() || '',
            preferredSize: row.querySelector('td:nth-child(3) strong')?.textContent?.trim() || '',
            bodyShape: row.querySelector('td:nth-child(3) .muted')?.textContent?.trim() || '',
            returnRate: parseFloat(row.querySelector('td:nth-child(5) div')?.textContent) || 0,
        });
    });
    return customers;
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


    // Sync modal loyalty checkbox ↔ quick-filter Gold button
    const goldCb = document.querySelector('input[name="loyaltyFilter"][value="GOLD"]');
    if (goldCb) {
        goldCb.addEventListener('change', function () {
            document.querySelector('.gold-members')?.classList.toggle('active', this.checked);
        });
    }

    // Sync modal return-rate checkbox ↔ quick-filter High Return button
    const highCb = document.querySelector('input[name="returnRateFilter"][value="HIGH"]');
    if (highCb) {
        highCb.addEventListener('change', function () {
            document.querySelector('.high-return')?.classList.toggle('active', this.checked);
        });
    }
}


// ===== FILTER FUNCTIONS =====
function toggleFilterTag(type) {
    if (type === 'GOLD') {
        toggleArrayValue(advancedFilters.loyaltyTiers, 'GOLD');
        const goldButton = document.querySelector('.gold-members');
        goldButton.classList.toggle('active');
        document.querySelector('input[name="loyaltyFilter"][value="GOLD"]').checked = goldButton.classList.contains('active');
    }

    if (type === 'HIGH_RETURN') {
        advancedFilters.returnRateMode =
            advancedFilters.returnRateMode === 'HIGH' ? null : 'HIGH';
        const highReturnButton = document.querySelector('.high-return');
        highReturnButton.classList.toggle('active');
        document.querySelector('input[name="returnRateFilter"][value="HIGH"]').checked = highReturnButton.classList.contains('active');
    }

    currentPage = 1;
    paginationSessionId = null;  // Filter thay đổi → reset keyset session
    applyFilters();
}

// Sync modal checkboxes ↔ quick-filter buttons
// (registered after DOM ready — see setupEventListeners)


// ===== ADVANCED FILTER MODAL =====
function openAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    if (modal) {
        modal.style.display = 'flex';
        requestAnimationFrame(() => modal.classList.add('open'));
        checkCurrentFilters();
    }
}

function closeAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    if (modal) {
        modal.classList.remove('open');
        // wait for CSS transition then hide
        setTimeout(() => {
            modal.style.display = 'none';
        }, 200);
    }
}

function checkCurrentFilters() {

    document.querySelectorAll('input[name="loyaltyFilter"]').forEach(cb => {
        cb.checked = advancedFilters.loyaltyTiers.includes(cb.value);
    });

    document.querySelectorAll('input[name="bodyShapeFilter"]').forEach(cb => {
        cb.checked = advancedFilters.bodyShapes.includes(cb.value);
    });

    document.querySelectorAll('input[name="sizeFilter"]').forEach(cb => {
        cb.checked = advancedFilters.sizes.includes(cb.value);
    });

    document.querySelectorAll('input[name="styleTagFilter"]').forEach(cb => {
        cb.checked = advancedFilters.tagIds.includes(parseInt(cb.value));
    });

    document.querySelectorAll('input[name="returnRateFilter"]').forEach(cb => {
        cb.checked = advancedFilters.returnRateMode === cb.value;
    });
}

function applyAdvancedFilter() {

    // Loyalty
    advancedFilters.loyaltyTiers = Array.from(
        document.querySelectorAll('input[name="loyaltyFilter"]:checked')
    ).map(cb => cb.value);

    // Body shape
    advancedFilters.bodyShapes = Array.from(
        document.querySelectorAll('input[name="bodyShapeFilter"]:checked')
    ).map(cb => cb.value);

    // Sizes
    advancedFilters.sizes = Array.from(
        document.querySelectorAll('input[name="sizeFilter"]:checked')
    ).map(cb => cb.value);

    // Style Tags → map sang tagIds (INT)
    advancedFilters.tagIds = Array.from(
        document.querySelectorAll('input[name="styleTagFilter"]:checked')
    ).map(cb => parseInt(cb.value));

    // Return Rate (radio → chỉ lấy 1)
    const returnRate = document.querySelector('input[name="returnRateFilter"]:checked');
    advancedFilters.returnRateMode = returnRate ? returnRate.value : null;

    closeAdvancedFilter();
    paginationSessionId = null;  // Filter thay đổi → reset keyset session
    callFilterAPI(1);
}

function resetAdvancedFilter() {

    advancedFilters = {
        loyaltyTiers: [],
        tagIds: [],
        bodyShapes: [],
        sizes: [],
        returnRateMode: null
    };

    document.querySelectorAll('#advancedFilterModal input').forEach(cb => {
        cb.checked = false;
    });

    const highReturnButton = document.querySelector('.high-return');
    highReturnButton.classList.remove('active');

    const goldButton = document.querySelector('.gold-members');
    goldButton.classList.remove('active');

    // Reset session pagination khi filter thay đổi
    paginationSessionId = null;
    callFilterAPI(1);
}

// ===== CUSTOMER ACTIONS =====
function openPreview(customerId) {
    const customer = currentPageCustomers.find(c => c.customerId == customerId);
    if (!customer) return;
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
    document.getElementById('previewLoyalty').className = `preview-value loyalty-badge ${getLoyaltyClass(customer.loyaltyTier)}`;
    document.getElementById('previewRFM').textContent = customer.rfmScore;
    document.getElementById('previewReturnRate').textContent = customer.returnRate + '%';

    // Show preview panel
    const preview = document.getElementById('customerPreview');
    if (preview) {
        preview.classList.add('show');
    }
}

function getLoyaltyClass(loyaltyTier) {
    switch (loyaltyTier) {
        case 'DIAMOND':
            return 'diamond';
            break
        case 'PLATINUM':
            return 'platinum';
            break
        case 'GOLD':
            return 'gold';
            break
        case 'SILVER':
            return 'silver';
            break
        case 'BRONZE':
            return 'bronze';
            break
        case 'BLACKLIST':
            return 'blacklist';
            break
        default:
            return '';
    }
}

function viewCustomer(customerId) {
    if (!customerId)
        return;

    const ctx = window.__CTX__ || ""; // fallback nếu quên inject
    const url = `${ctx}/customers/detail?customerId=${encodeURIComponent(customerId)}`;

    window.location.href = url; // chuyển trang
}

function editCustomer(customerId) {
    if (!customerId)
        return;
    const ctx = window.__CTX__ || ""; // fallback nếu quên inject
    const url = `${ctx}/customers/edit?customerId=${encodeURIComponent(customerId)}`;
    window.location.href = url;
}

function closePreview() {
    const preview = document.getElementById('customerPreview');
    if (preview) {
        preview.classList.remove('show');
    }
}

function upgradeCustomer(customerId) {
    if (confirm('Upgrade loyalty level for this customer?')) {
        const ctx = window.__CTX__ || "";
        const url = `${ctx}/customers/upgrade?customerId=${encodeURIComponent(customerId)}`;
        window.location.href = url;
    }
}

function downgradeCustomer(customerId) {
    if (confirm('Downgrade loyalty level for this customer?')) {
        const ctx = window.__CTX__ || '';
        const url = `${ctx}/customers/downgrade?customerId=${encodeURIComponent(customerId)}`;
        window.location.href = url;
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


// Close action menu when clicking outside
document.addEventListener("click", function (e) {

    const ellipsis = e.target.closest(".menu-btn");

    // CLICK vào dấu ...
    if (ellipsis) {
        e.stopPropagation();

        const wrapper = ellipsis.closest(".action-wrapper");
        const menu = wrapper.querySelector(".action-menu");

        const isOpen = menu.classList.contains("show");

        // đóng tất cả menu khác
        document.querySelectorAll(".action-menu").forEach(m => {
            m.classList.remove("show");
        });

        if (!isOpen) {
            menu.classList.add("show");
        }

        return;
    }

    // CLICK ngoài → đóng hết
    document.querySelectorAll(".action-menu").forEach(m => {
        m.classList.remove("show");
    });
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
    toastMessage.textContent = `========       ${message}       ========`;

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

document.addEventListener("change", function (e) {

    // Khi click checkbox SELECT ALL
    if (e.target.classList.contains("check-all")) {

        const checked = e.target.checked;

        document.querySelectorAll(".check-item").forEach(cb => {
            cb.checked = checked;
        });

    }

    // Khi click từng checkbox item
    if (e.target.classList.contains("check-item")) {

        const total = document.querySelectorAll(".check-item").length;
        const checked = document.querySelectorAll(".check-item:checked").length;

        const checkAll = document.querySelector(".check-all");
        if (checkAll) {
            checkAll.checked = total === checked;
        }

    }

});

