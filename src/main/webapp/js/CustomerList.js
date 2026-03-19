// Hybrid Keyset Pagination state
let paginationSessionId = window.__SESSION_ID__ || null;
let totalPages = window.__TOTAL_PAGES__ || 1;
let totalRecords = window.__TOTAL_RECORDS__ || 0;
let advancedFilters = {
    loyaltyTiers: [],
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

document.querySelectorAll(".btn-return-rate").forEach(btn => {
    btn.addEventListener("click", function () {

        const isActive = this.classList.contains("btn-primary");

        document.querySelectorAll(".btn-return-rate")
            .forEach(b => b.classList.remove("btn-primary"));

        if (!isActive) {
            this.classList.add("btn-primary");
        }

    });
});

function search() {
    const keyword = document.getElementById('searchInput').value;
    const ctx = window.__CTX__ || "";
    const url = `${ctx}/customers/filter?keyword=${encodeURIComponent(keyword)}`;
    window.location.href = url;
}

function filter() {
    const keyword = document.getElementById('searchInput').value;
    const loyaltys = document.querySelector('.loyaltyFilter').value;
    const sources = document.querySelector('.source').value;
    const active = document.querySelector(".btn-return-rate.btn-primary");
    let returnRate
    if (active) {
        returnRate = active.classList.contains("btn-high-return")
            ? "HIGH"
            : "LOW";

    }

    const params = new URLSearchParams();

    if (keyword) params.append("keyword", keyword);
    if (loyaltys && loyaltys !== 'ALL') params.append("loyaltyFilter", loyaltys);
    if (sources && sources !== 'ALL') params.append("source", sources);
    if (returnRate) params.append("returnRateFilter", returnRate);

    const ctx = window.__CTX__ || "";
    const url = `${ctx}/customers/filter?${params.toString()}`;

    console.log(url)
    window.location.href = url;

}

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

function openAdvancedFilter() {
    const advancedFilterModal = document.getElementById('advancedFilterModal');
    if (advancedFilterModal) {
        advancedFilterModal.classList.add('show');
    }
}

function closeAdvancedFilter() {
    const advancedFilterModal = document.getElementById('advancedFilterModal');
    if (advancedFilterModal) {
        advancedFilterModal.classList.remove('show');
    }
}

const btn = document.querySelector(".add-condition");
const container = document.querySelector(".conditions");
const template = document.querySelector("#condition-template");

btn.addEventListener("click", () => {

    const clone = template.content.cloneNode(true);

    container.appendChild(clone);

});

document.addEventListener("click", function (e) {

    if (e.target.classList.contains("delete")) {
        e.target.parentElement.remove();
        document.querySelector('.sub-condition').remove();
    }

});

function resetAdvancedFilter() {

    advancedFilters = {
        loyaltyTiers: [],
        returnRateMode: null
    };
    localStorage.removeItem("advancedFilter");
    document.querySelectorAll('#advancedFilterModal input').forEach(cb => {
        cb.checked = false;
    });

    document.querySelectorAll('.btn-return-rate')
        .forEach(b => {
            b.classList.remove('btn-primary');
        });
    document.querySelectorAll('.condition-row').forEach(r => r.remove());
}

function getCheckedValues(selector) {
    return [...document.querySelectorAll(selector + ":checked")]
        .map(el => el.value);
}

document.getElementById("searchInput").addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
        event.preventDefault();
        applyAdvancedFilter();
    }
});

function applyAdvancedFilter() {
    const keyword = document.getElementById('searchInput').value;
    const loyaltys = getCheckedValues('input[name="loyaltyFilter"]');
    const sources = getCheckedValues('input[name="source"]');
    const gender = document.querySelector('input[name="gender"]:checked')?.value;
    const returnRate = document.querySelector('input[name="returnRateFilter"]:checked')?.value;

    const params = new URLSearchParams();

    if (keyword) params.append("keyword", keyword);
    loyaltys.forEach(l => params.append("loyaltyFilter", l));
    sources.forEach(s => params.append("source", s));
    if (gender) params.append("gender", gender);
    if (returnRate) params.append("returnRateFilter", returnRate);
    const timeConditions = [];
    document.querySelectorAll(".condition-row").forEach(row => {

        const field = row.querySelector('[name="time_conditions"]').value;
        const operator = row.querySelector('[name="operators"]').value;
        const date = row.querySelector('[name="dates"]').value;
        const subCondition = row.querySelector('[name="subconditions"]').value;

        if (date) {
            params.append("time_conditions", field);
            params.append("operators", operator);
            params.append("dates", date);
            params.append("subconditions", subCondition);

            timeConditions.push({
                field,
                operator,
                date,
                subCondition
            });
        }
    });

    // 🔥 LƯU LOCALSTORAGE
    const filterData = {
        keyword,
        loyaltys,
        sources,
        gender,
        returnRate,
        timeConditions
    };

    localStorage.setItem("advancedFilter", JSON.stringify(filterData));
    const ctx = window.__CTX__ || "";
    const url = `${ctx}/customers/filter?${params.toString()}`;

    console.log(url);

    window.location.href = url;

}

document.addEventListener("DOMContentLoaded", function () {

    const data = JSON.parse(localStorage.getItem("advancedFilter"));

    if (!data) return;

    // keyword
    if (data.keyword) {
        document.getElementById("searchInput").value = data.keyword;
    }

    // loyalty
    document.querySelectorAll('input[name="loyaltyFilter"]').forEach(cb => {
        if (data.loyaltys.includes(cb.value)) {
            cb.checked = true;
        }
    });

    // source
    document.querySelectorAll('input[name="source"]').forEach(cb => {
        if (data.sources.includes(cb.value)) {
            cb.checked = true;
        }
    });

    // gender
    if (data.gender) {
        const g = document.querySelector(`input[name="gender"][value="${data.gender}"]`);
        if (g) g.checked = true;
    }

    // return rate
    if (data.returnRate) {
        const r = document.querySelector(`input[name="returnRateFilter"][value="${data.returnRate}"]`);
        if (r) r.checked = true;
    }

    // time conditions
    if (data.timeConditions && data.timeConditions.length > 0) {

        const container = document.querySelector(".conditions");
        const template = document.getElementById("condition-template");

        data.timeConditions.forEach(cond => {

            const clone = template.content.cloneNode(true);

            const row = clone.querySelector(".condition-row");

            row.querySelector('[name="time_conditions"]').value = cond.field;
            row.querySelector('[name="operators"]').value = cond.operator;
            row.querySelector('[name="dates"]').value = cond.date;
            row.querySelector('[name="subconditions"]').value = cond.subCondition;

            container.appendChild(clone);

        });

    }

});


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

function addDealCustomer(customerId) {
    const ctx = window.__CTX__ || "";
    const url = `${ctx}/customers/add?customerId=${encodeURIComponent(customerId)}`;
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
    toastMessage.textContent = `${message}`;
    toastMessage.style = "text-align: center;"

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


// ===== LOAD PAGE =====
document.addEventListener("DOMContentLoaded", () => {

    const selected = JSON.parse(localStorage.getItem('selected')) || [];
    const items = document.querySelectorAll(".check-item");

    let checkedCount = 0;

    items.forEach(cb => {
        if (selected.includes(cb.value)) {
            cb.checked = true;
            checkedCount++;
        } else {
            cb.checked = false;
        }
    });

    const checkAll = document.querySelector(".check-all");

    if (checkAll) {
        checkAll.checked = checkedCount === items.length;
        checkAll.indeterminate = checkedCount > 0 && checkedCount < items.length;
    }

});


// ===== HANDLE CHANGE =====
document.addEventListener("change", function (e) {

    // ===== CHECK ALL =====
    if (e.target.classList.contains("check-all")) {

        const checked = e.target.checked;

        let selectedCustomers = JSON.parse(localStorage.getItem("selected")) || [];

        document.querySelectorAll(".check-item").forEach(cb => {
            cb.checked = checked;

            if (checked) {
                if (!selectedCustomers.includes(cb.value)) {
                    selectedCustomers.push(cb.value);
                }
            } else {
                selectedCustomers = selectedCustomers.filter(id => id !== cb.value);
            }
        });

        localStorage.setItem("selected", JSON.stringify(selectedCustomers));

        // 🔥 reset trạng thái gạch ngang
        e.target.indeterminate = false;
    }


    // ===== CHECK ITEM =====
    if (e.target.classList.contains("check-item")) {

        let selectedCustomers = JSON.parse(localStorage.getItem("selected")) || [];
        const id = e.target.value;

        if (e.target.checked) {
            if (!selectedCustomers.includes(id)) {
                selectedCustomers.push(id);
            }
        } else {
            selectedCustomers = selectedCustomers.filter(c => c !== id);
        }

        localStorage.setItem("selected", JSON.stringify(selectedCustomers));

        // 🔥 update check-all + indeterminate
        const total = document.querySelectorAll(".check-item").length;
        const checked = document.querySelectorAll(".check-item:checked").length;

        const checkAll = document.querySelector(".check-all");

        if (checkAll) {
            checkAll.checked = total === checked;
            checkAll.indeterminate = checked > 0 && checked < total;
        }
    }

});

let selectedCustomers = JSON.parse(localStorage.getItem("selected")) || [];
document.querySelectorAll('.check-item').forEach(cb => {
    cb.addEventListener("change", () => {
        let id = cb.value;
        if (cb.checked) {
            selectedCustomers.push(id);
        } else {
            selectedCustomers = selectedCustomers.filter(c => c !== id);
        }
        localStorage.setItem('selected', JSON.stringify(selectedCustomers));
    })
});

window.onload = function () {
    const selected = JSON.parse(localStorage.getItem('selected')) || [];
    document.querySelectorAll('.check-item').forEach(cb => {
        if (selected.includes(cb.value)) {
            cb.checked = true;
        }
    })
}

document.querySelector('.btn-outline-secondary').addEventListener('click', function () {
    localStorage.removeItem('selected');
})

function assignTask() {
    const check = document.querySelectorAll('.check-item:checked').length;
    if (!check) {
        alert('Please select a customer to assign the task to.');
    } else {

    }
}

const assignBtn = document.getElementById("assign-segment-btn");
assignBtn.addEventListener("click", () => {
    const selected = JSON.parse(localStorage.getItem("selected")) || [];
    console.log(selected)
    if (selected.length === 0) {
        alert("Vui lòng chọn ít nhất 1 customer!");
        return;
    }

    // nhét vào hidden input (chuỗi: 1,2,3)
    document.getElementById("customerIdsInput").value = selected.join(",");
    console.log(document.getElementById("customerIdsInput"))
    openSegmentModal();
});

function openSegmentModal() {
    document.getElementById("segment-modal").style.display = "block";
}

function closeSegmentModal() {
    document.getElementById("segment-modal").style.display = "none";
}

document.querySelectorAll('.segment-card').forEach(card => {
    card.addEventListener('click', function (e) {

        const radio = this.previousElementSibling; // input radio

        if (radio.checked) {
            // nếu đã chọn → bỏ chọn
            radio.checked = false;
        } else {
            // nếu chưa → chọn (và bỏ chọn các cái khác)
            document.querySelectorAll('input[name="segmentId"]').forEach(r => r.checked = false);
            radio.checked = true;
        }

        // ngăn label auto check (quan trọng)
        e.preventDefault();
    });
});

document.querySelector("#segment-modal form").addEventListener("submit", function (e) {

    const selectedSegment = document.querySelector('input[name="segmentId"]:checked');

    if (!selectedSegment) {
        e.preventDefault();
        alert("Vui lòng chọn segment!");
        return;
    }
});

