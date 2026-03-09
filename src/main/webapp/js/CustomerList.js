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

    renderPagination(totalPages, currentPage);

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
    // Search input
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', debounce(applyFilters, 300));
    }

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
    paginationSessionId = null;  // Filter thay đổi → reset keyset session
    applyFilters();
}

// Sync modal checkboxes ↔ quick-filter buttons
// (registered after DOM ready — see setupEventListeners)

function toggleArrayValue(arr, value) {
    const index = arr.indexOf(value);
    if (index === -1) arr.push(value);
    else arr.splice(index, 1);
}

function applyFilters() {
    // Filter thay đổi → reset session để server tạo keyset mới
    paginationSessionId = null;
    callFilterAPI(1);
}

async function callFilterAPI(page = 1) {

    currentPage = page;

    const keyword = document.getElementById("searchInput")?.value || "";

    const params = new URLSearchParams();

    params.append("page", currentPage);
    params.append("size", rowsPerPage);
    params.append("keyword", keyword);

    // Gửi sessionId lên server để dùng keyset pagination
    if (paginationSessionId) {
        params.append("sessionId", paginationSessionId);
    }

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

    let data = null;
    try {
        const response = await fetch(`${window.__CTX__}/customers/filter`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: params.toString()
        });

        if (!response.ok) {
            console.error(`Filter API error: HTTP ${response.status}`);
            showToast(`Server error (${response.status}). Please try again.`, 'error');
            return;
        }

        const text = await response.text();
        if (!text || text.trim() === '') {
            console.error('Filter API returned empty response');
            showToast('No data returned from server.', 'warning');
            return;
        }

        data = JSON.parse(text);
    } catch (err) {
        console.error('Filter API failed:', err);
        showToast('Failed to load customers. Please try again.', 'error');
        return;
    }

    if (!data) return;

    // Lưu sessionId mới từ server (nếu có)
    if (data.sessionId) {
        paginationSessionId = data.sessionId;
    }

    // Cập nhật totalPages từ server (chỉ khi server trả về, tức page=1 hoặc session mới)
    if (data.totalPages) {
        totalPages = data.totalPages;
        totalRecords = data.totalRecords;
    }


    const customers = data.customers ?? data.data ?? [];

    // Cache customers của page hiện tại để openPreview() dùng
    currentPageCustomers = customers;

    if (customers.length === 0) {
        totalPages = 1; // Reset về 1 page nếu filter quá chặt không còn kết quả nào
    }

    renderTableBody(customers);
    renderPagination(totalPages, currentPage);
}

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
        setTimeout(() => { modal.style.display = 'none'; }, 200);
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
    const tbody = document.getElementById("customerTableBody");

    // Fade out
    tbody.style.transition = 'opacity 0.15s ease';
    tbody.style.opacity = '0';

    setTimeout(() => {
        if (!customers || customers.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="8" style="text-align:center;padding:40px;color:#888;">
                        <i class="fas fa-search" style="font-size:24px;margin-bottom:8px;display:block;opacity:0.4;"></i>
                        No customers found.
                    </td>
                </tr>`;
        } else {

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
        <button class="action-icon-btn view-btn" title="View Details" onclick="viewCustomer(${c.customerId})">
            <i class="fa-solid fa-arrow-up-right-from-square"></i>
        </button>

        <button class="action-icon-btn edit-btn" title="Edit" onclick="editCustomer(${c.customerId})">
            <i class="fa-solid fa-pen-to-square"></i>
        </button>
        <div class="action-wrapper">
            <button class="action-icon-btn menu-btn">
                <i class="fa-solid fa-ellipsis"></i>
            </button>
            <div class="action-menu">
                <div class="action-menu-item" onclick="openPreview(${c.customerId})">
                    <i class="fa-regular fa-id-card"></i>
                    <span>Preview</span>
                </div>
                <div class="action-menu-item upgrade-item" onclick="upgradeCustomer(${c.customerId})">
                    <i class="fa-solid fa-angles-up"></i>
                    <span>Upgrade</span>
                </div>
        <div class="action-menu-item downgrade-item" onclick="downgradeCustomer(${c.customerId})">
                                        <i class="fa-solid fa-angles-down"></i>
                                        <span>Downgrade</span>
                                    </div>
                <div class="action-menu-divider"></div>
                <div class="action-menu-item delete-item" onclick="deleteCustomer(${c.customerId})">
                    <i class="fa-regular fa-trash-can"></i>
                    <span>Delete</span>
                </div>
            </div>
        </div>
    </td>
<td style="display: none;">${c.email}</td>
                        <td style="display: none;">${c.gender}</td>
                        <td style="display: none;">${c.height}</td>
                        <td style="display: none;">${c.weight}</td>
</tr>
`;
            });

            tbody.innerHTML = html;
        }
        // Fade in
        tbody.style.opacity = '1';
    }, 150);
}

function renderTags(tags) {

    if (!tags)
        return "";

    return tags.slice(0, 2).map(tag =>
        `<span class="tag">${tag}</span>`
    ).join("");
}

function getLoyaltyClass(tier) {
    if (tier === "DIAMOND")
        return "diamond";
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
        container.innerHTML = `<button class="active btn btn-light">1</button>`;
        return;
    }

    function getPageRange(current, total) {
        const delta = 2;
        const range = [];
        const rangeWithDots = [];

        for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
            range.push(i);
        }

        if (range[0] > 2) rangeWithDots.push(1, '...');
        else rangeWithDots.push(1);

        rangeWithDots.push(...range);

        if (range[range.length - 1] < total - 1) rangeWithDots.push('...', total);
        else rangeWithDots.push(total);

        return rangeWithDots;
    }

    const pages = getPageRange(currentPage, totalPages);

    let html = "";

    // Prev button
    html += `
        <button onclick="loadPage(${currentPage - 1}, ${rowsPerPage})"
            class="btn btn-light btn-nav"
            ${currentPage === 1 ? "disabled" : ""}>
            <i class="fas fa-chevron-left"></i> Prev
        </button>
    `;

    // Page number buttons
    pages.forEach(p => {
        if (p === '...') {
            html += `<span class="pagination-dots">...</span>`;
        } else {
            html += `
                <button onclick="loadPage(${p}, ${rowsPerPage})"
                    class="btn btn-light ${p === currentPage ? "active" : ""}">
                    ${p}
                </button>
            `;
        }
    });

    // Next button
    html += `
        <button onclick="loadPage(${currentPage + 1}, ${rowsPerPage})"
            class="btn btn-light btn-nav"
            ${currentPage === totalPages ? "disabled" : ""}>
            Next <i class="fas fa-chevron-right"></i>
        </button>
    `;

    container.innerHTML = html;
}

document.getElementById("rowsPerPage")?.addEventListener("change", function () {
    const value = this.value === "all" ? 999999 : parseInt(this.value);
    rowsPerPage = value;
    paginationSessionId = null;  // PageSize thay đổi → keyset anchor không còn hợp lệ
    loadPage(1, value);
});