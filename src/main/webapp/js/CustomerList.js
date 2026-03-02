// ===== GLOBAL STATE =====
let allCustomerData = [];
let filteredCustomers = [];
let currentPage = 1;
let rowsPerPage = 10;
let advancedFilters = {
    loyaltyTiers: [],
    tagIds: [],
    bodyShapes: [],
    sizes: [],
    returnRateMode: null
};

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
    callFilterAPI(1); // Load first page with default filters

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

});



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
    applyFilters();
}

function toggleArrayValue(arr, value) {
    const index = arr.indexOf(value);
    if (index === -1) arr.push(value);
    else arr.splice(index, 1);
}

function applyFilters() {
    callFilterAPI(1);
}

async function callFilterAPI(page = 1) {

    currentPage = page;

    const keyword = document.getElementById("searchInput")?.value || "";

    const params = new URLSearchParams();

    params.append("page", currentPage);
    params.append("size", rowsPerPage);
    params.append("keyword", keyword);

    if (advancedFilters.loyaltyTiers.length)
        params.append("tiers", advancedFilters.loyaltyTiers.join(','));

    if (advancedFilters.tagIds.length)
        params.append("tags", advancedFilters.tagIds.join(','));

    if (advancedFilters.bodyShapes.length)
        params.append("bodyShapes", advancedFilters.bodyShapes.join(','));

    if (advancedFilters.sizes.length)
        params.append("sizes", advancedFilters.sizes.join(','));

    if (advancedFilters.returnRateMode)
        params.append("returnRateMode", advancedFilters.returnRateMode);

    const response = await fetch(`${window.__CTX__}/customers/filter`, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest"
        },
        body: params.toString()
    });

    const data = await response.json();

    /* 🔴 CỰC KỲ QUAN TRỌNG */
    selectedFilters = data.customers;

    /* dùng cho preview */
    filteredCustomers = data.customers;

    renderTableBody(data.customers);

    const totalPages = Math.ceil(data.totalRecords / rowsPerPage);
    renderPagination(totalPages, currentPage);
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

    callFilterAPI(1);
}


// ===== CUSTOMER ACTIONS =====
function openPreview(customerId) {
    const customer = selectedFilters.find(c => c.customerId == customerId);
    if (!customer)
        return;
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
// function toggleMenu(element, event) {

//     event.stopPropagation(); // 🛑 chặn document click

//     const menu = element.closest('.action-wrapper').querySelector('.action-menu');

//     const isVisible = menu.style.display === 'flex';

//     // đóng tất cả menu khác
//     document.querySelectorAll('.action-menu').forEach(m => m.style.display = 'none');

//     // toggle menu hiện tại
//     menu.style.display = isVisible ? 'none' : 'flex';
//     menu.style.flexDirection = 'column';
// }

// Close action menu when clicking outside
document.addEventListener("click", function (e) {

    const ellipsis = e.target.closest(".fa-ellipsis-vertical");

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
function loadPage(page, size) {

    currentPage = page;

    if (size) {
        rowsPerPage = size;
    }

    // GỌI LẠI FILTER (giữ toàn bộ điều kiện đang chọn)
    callFilterAPI(currentPage);
}

function renderTableBody(customers) {
    console.log(customers);

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
                <i class="fa-solid fa-ellipsis-vertical"></i>

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
    if (tier === "PLATINUM")
        return "platinum";
    if (tier === "GOLD")
        return "gold";
    if (tier === "SILVER")
        return "silver";
    if (tier === "BRONZE")
        return "bronze";
    if (tier === "BLACKLIST")
        return "blacklist";
    return "";
}

function renderPagination(totalPages, currentPage) {

    const container = document.getElementById("paginationControls");

    if (!totalPages || totalPages <= 1) {
        container.innerHTML = `<button class= "active btn btn-light">1</button>`;
        return;
    }

    let html = "";

    for (let i = 1; i <= totalPages; i++) {

        html += `
            <button onclick="loadPage(${i}, ${rowsPerPage})"
                class="btn btn-light ${i === currentPage ? "active" : ""}">
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