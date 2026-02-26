



function toggleModal() {
    const modal = document.getElementById("customerModal");
    modal.style.display =
        modal.style.display === "block" ? "none" : "block";
}

// Toggle menu 3 chấm
function toggleMenu(element) {
    const menu = element.nextElementSibling;

    // Đóng tất cả menu khác
    document.querySelectorAll('.action-menu').forEach(m => {
        if (m !== menu) m.style.display = 'none';
    });

    // Toggle menu hiện tại
    menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
}

// Đóng menu khi click ra ngoài
document.addEventListener('click', function (e) {
    if (!e.target.closest('.action-wrapper')) {
        document.querySelectorAll('.action-menu').forEach(m => {
            m.style.display = 'none';
        });
    }
});

// Gắn sự kiện cho nút "Thêm khách mới" ở trang danh sách
document.querySelector(".btn-add").addEventListener("click", toggleModal);


// Gắn sự kiện xem more tag và less tag
const toggleBtn = document.getElementById("toggleTags");
const extraTags = document.querySelectorAll(".extra-tag");

let expanded = false;

toggleBtn.addEventListener("click", function () {
    expanded = !expanded;

    extraTags.forEach(tag => {
        tag.style.display = expanded ? "inline-block" : "none";
    });

    toggleBtn.textContent = expanded ? "See less" : "See more";
});


// thông báo create customer thành công hoặc failed
let startTime = 0;
const duration = 3200; // thời gian sống cố định
let paused = false;
let pauseStartedAt = 0;
let rafId = null;

const toast = document.getElementById("toast");
const bar = document.getElementById("toastBar");

function showToast(type, message) {
    cancelAnimationFrame(rafId);

    toast.classList.remove("hide");
    void toast.offsetWidth; // reset animation

    document.getElementById("toastMessage").innerText = message;

    if (type === "success") {
        document.getElementById("toastIcon").innerHTML =
            `<svg fill="#22c55e" viewBox="0 0 24 24">
                <path d="M9 16.2l-3.5-3.5L4 14.2l5 5 11-11-1.5-1.5z"/>
            </svg>`;
        bar.style.background = "#22c55e";
    } else {
        document.getElementById("toastIcon").innerHTML =
            `<svg fill="#ef4444" viewBox="0 0 24 24">
                <path d="M18.3 5.71L12 12l6.3 6.29-1.41 1.41L10.59 13.41
                         4.29 19.7 2.88 18.29 9.17 12 2.88 5.71
                         4.29 4.29 10.59 10.59l6.3-6.3z"/>
            </svg>`;
        bar.style.background = "#ef4444";
    }

    bar.style.transform = "scaleX(1)";
    paused = false;

    toast.classList.add("show");

    startTime = performance.now();
    rafId = requestAnimationFrame(animateBar);
}

function easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
}

function animateBar(now) {
    if (paused)
        return;

    const elapsed = now - startTime;
    let progress = elapsed / duration;

    progress = Math.min(progress, 1);
    const eased = easeOutCubic(progress);

    bar.style.transform = `scaleX(${1 - eased})`;

    if (progress < 1) {
        rafId = requestAnimationFrame(animateBar);
    } else {
        hideToast();
    }
}

function hideToast() {
    cancelAnimationFrame(rafId);
    toast.classList.remove("show");
    toast.classList.add("hide");
}

/* ===== Pause khi hover ===== */
toast.addEventListener("mouseenter", () => {
    if (!paused) {
        paused = true;
        pauseStartedAt = performance.now();
    }
});

/* ===== Resume khi rời chuột ===== */
toast.addEventListener("mouseleave", () => {
    if (paused) {
        paused = false;

        const pauseDuration = performance.now() - pauseStartedAt;
        startTime += pauseDuration; // bù lại thời gian bị pause

        rafId = requestAnimationFrame(animateBar);
    }
});


function viewCustomer(customerId) {
    const contextPath = window.location.pathname.split("/")[1];
    window.location.href = `/${contextPath}/customer/detail?customerId=${customerId}`;
}

// ===== PREVIEW FUNCTIONS =====
let currentCustomerId = null;
let currentCustomerData = {}; // Lưu data để dùng khi edit

function openPreview(customerId) {
    currentCustomerId = customerId;

    // Tìm row của customer trong bảng
    let row = null;
    document.querySelectorAll('tbody tr').forEach(r => {
        const idInRow = r.querySelector('.actions i').getAttribute('onclick');
        if (idInRow && idInRow.includes(`openPreview(${customerId})`)) {
            row = r;
        }
    });

    // Nếu không tìm được, lấy row gần nhất
    if (!row) {
        row = event?.target?.closest('tr');
    }

    if (!row) {
        showToast('error', 'Unable to load customer data');
        return;
    }

    // Lấy dữ liệu customer từ bảng
    const name = row.querySelector('.customer-info strong').textContent;
    const phone = row.querySelector('.customer-info .muted').textContent;
    const preferredSize = row.querySelector('td:nth-child(3) strong').textContent;
    const bodyShape = row.querySelector('td:nth-child(3) .muted').textContent;
    const loyaltyTier = row.querySelector('.loyalty-badge').textContent.trim();
    const rfmScore = row.querySelector('td:nth-child(2) .muted').textContent.replace('RFM Score: ', '');
    const returnRate = row.querySelector('td:nth-child(5) > div:first-child').textContent;

    // Lưu dữ liệu hiện tại
    currentCustomerData = {
        customerId: customerId,
        name: name,
        phone: phone,
        email: '-',
        gender: '-',
        height: '-',
        weight: '-',
        preferredSize: preferredSize,
        bodyShape: bodyShape,
        loyaltyTier: loyaltyTier,
        rfmScore: rfmScore,
        returnRate: returnRate
    };

    // Fill dữ liệu vào preview panel (view mode)
    document.getElementById('previewName').textContent = name;
    document.getElementById('previewPhone').textContent = phone;
    document.getElementById('previewEmail').textContent = '-';
    document.getElementById('previewGender').textContent = '-';
    document.getElementById('previewHeight').textContent = '-';
    document.getElementById('previewWeight').textContent = '-';
    document.getElementById('previewSize').textContent = preferredSize;
    document.getElementById('previewBodyShape').textContent = bodyShape;
    document.getElementById('previewLoyalty').textContent = loyaltyTier;

    // Update loyalty badge class
    let loyaltyClass = 'loyalty-badge';
    if (loyaltyTier === 'GOLD') loyaltyClass += ' gold';
    else if (loyaltyTier === 'BLACKLIST') loyaltyClass += ' blacklist';

    document.getElementById('previewLoyalty').className = loyaltyClass;
    document.getElementById('previewRFM').textContent = rfmScore;
    document.getElementById('previewReturnRate').textContent = returnRate;

    // Reset mode về view
    if (document.getElementById('previewViewMode')) {
        document.getElementById('previewViewMode').style.display = 'block';
    }
    if (document.getElementById('previewEditMode')) {
        document.getElementById('previewEditMode').style.display = 'none';
    }
    if (document.getElementById('previewViewFooter')) {
        document.getElementById('previewViewFooter').style.display = 'flex';
    }
    if (document.getElementById('previewEditFooter')) {
        document.getElementById('previewEditFooter').style.display = 'none';
    }

    // Show preview panel
    const previewPanel = document.getElementById('customerPreview');
    previewPanel.classList.add('show');
}

function closePreview() {
    const previewPanel = document.getElementById('customerPreview');
    previewPanel.classList.remove('show');
    currentCustomerId = null;
    currentCustomerData = {};
}

function deleteCustomer(customerId) {
    if (confirm('Are you sure you want to delete this customer?')) {
        // TODO: Gửi request xóa customer
        // fetch(`/api/customers/${customerId}`, { method: 'DELETE' })
        // .then(res => res.json())
        // .then(data => {
        //     showToast('success', 'Customer deleted successfully');
        //     location.reload();
        // })
        // .catch(err => showToast('error', 'Delete failed'));

        showToast('success', 'Customer deleted successfully');
        // Xóa row khỏi bảng (demo)
        const row = event?.target?.closest('tr');
        if (row) row.remove();
    }
}

// ===== FILTER FUNCTIONS =====
let activeFilters = {
    search: '',
    tags: [],
    loyalty: [],
    bodyShape: [],
    size: [],
    returnRate: [],
    styleTag: []
};

function toggleFilterTag(tag) {
    const btn = event.target;
    const index = activeFilters.tags.indexOf(tag);

    if (index > -1) {
        activeFilters.tags.splice(index, 1);
        btn.classList.remove('active');
    } else {
        activeFilters.tags.push(tag);
        btn.classList.add('active');
    }

    applyFilters();
}

function openAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    modal.style.display = 'block';
}

function closeAdvancedFilter() {
    const modal = document.getElementById('advancedFilterModal');
    modal.style.display = 'none';
}

function resetAdvancedFilter() {
    // Uncheck tất cả checkboxes
    document.querySelectorAll('#advancedFilterModal input[type="checkbox"]').forEach(cb => {
        cb.checked = false;
    });

    activeFilters.loyalty = [];
    activeFilters.bodyShape = [];
    activeFilters.size = [];
    activeFilters.returnRate = [];
    activeFilters.styleTag = [];

    applyFilters();
    showToast('success', 'Filters reset');
}

function applyAdvancedFilter() {
    // Lấy giá trị từ checkboxes
    activeFilters.loyalty = Array.from(
        document.querySelectorAll('input[name="loyaltyFilter"]:checked')
    ).map(cb => cb.value);

    activeFilters.bodyShape = Array.from(
        document.querySelectorAll('input[name="bodyShapeFilter"]:checked')
    ).map(cb => cb.value);

    activeFilters.size = Array.from(
        document.querySelectorAll('input[name="sizeFilter"]:checked')
    ).map(cb => cb.value);

    activeFilters.returnRate = Array.from(
        document.querySelectorAll('input[name="returnRateFilter"]:checked')
    ).map(cb => cb.value);

    activeFilters.styleTag = Array.from(
        document.querySelectorAll('input[name="styleTagFilter"]:checked')
    ).map(cb => cb.value);

    closeAdvancedFilter();
    applyFilters();
    showToast('success', 'Filters applied');
}

function applyFilters() {
    // Lấy search value
    const searchInput = document.getElementById('searchInput');
    activeFilters.search = searchInput ? searchInput.value.toLowerCase() : '';

    // Lấy tất cả rows
    const rows = document.querySelectorAll('tbody tr');
    let visibleCount = 0;

    rows.forEach(row => {
        if (matchesFilters(row)) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });

    // Show no results message nếu cần
    if (visibleCount === 0) {
        showToast('info', 'No customers match your filters');
    }
}

function matchesFilters(row) {
    // Search filter
    if (activeFilters.search) {
        const name = row.querySelector('.customer-info strong').textContent.toLowerCase();
        const phone = row.querySelector('.customer-info .muted').textContent.toLowerCase();

        if (!name.includes(activeFilters.search) && !phone.includes(activeFilters.search)) {
            return false;
        }
    }

    // Loyalty filter
    if (activeFilters.loyalty.length > 0 || activeFilters.tags.includes('GOLD')) {
        const loyalty = row.querySelector('.loyalty-badge').textContent.trim();
        if (activeFilters.tags.includes('GOLD')) {
            if (loyalty !== 'GOLD') return false;
        } else if (activeFilters.loyalty.length > 0) {
            if (!activeFilters.loyalty.includes(loyalty)) return false;
        }
    }

    // Body Shape filter
    if (activeFilters.bodyShape.length > 0) {
        const bodyShape = row.querySelector('td:nth-child(3) .muted').textContent;
        if (!activeFilters.bodyShape.some(bs => bodyShape.includes(bs))) {
            return false;
        }
    }

    // Size filter
    if (activeFilters.size.length > 0) {
        const size = row.querySelector('td:nth-child(3) strong').textContent;
        if (!activeFilters.size.includes(size)) {
            return false;
        }
    }

    // Return Rate filter
    if (activeFilters.returnRate.length > 0) {
        const returnRateText = row.querySelector('td:nth-child(5) > div:first-child').textContent;
        const returnRate = parseInt(returnRateText);
        const hasHigh = activeFilters.returnRate.includes('HIGH');
        const hasNormal = activeFilters.returnRate.includes('NORMAL');

        if (hasHigh && returnRate <= 30) return false;
        if (hasNormal && returnRate > 30) return false;
    }

    // High Return tag filter
    if (activeFilters.tags.includes('HIGH_RETURN')) {
        const returnRateText = row.querySelector('td:nth-child(5) > div:first-child').textContent;
        const returnRate = parseInt(returnRateText);
        if (returnRate <= 30) return false;
    }


    // Style Tag filter
    if (activeFilters.styleTag.length > 0) {
        const tagsCell = row.querySelector('td.tags');
        const tagsText = tagsCell ? tagsCell.textContent.toLowerCase() : '';
        if (!activeFilters.styleTag.some(tag => tagsText.includes(tag.toLowerCase()))) {
            return false;
        }
    }

    return true;
}

// Add event listener cho search input
document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keyup', applyFilters);
    }
});


