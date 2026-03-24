// ===== MODAL =====

function openCreateModal() {
    document.getElementById('createModal').classList.add('show');
    // Reset lỗi cũ mỗi lần mở
    clearModalErrors();
}

function closeCreateModal() {
    document.getElementById('createModal').classList.remove('show');
    clearModalErrors();
}

// Đóng modal khi click ra ngoài backdrop
document.getElementById('createModal')?.addEventListener('click', function (e) {
    if (e.target === this) closeCreateModal();
});


// ===== FILTER =====

// Enter trên ô search cũng trigger filter
document.getElementById('searchInput')?.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        filterSegment();
    }
});

function filterSegment() {
    const segType = document.querySelector('.segment_type')?.value || '';
    const creator = document.querySelector('.created_by')?.value || '';
    const updater = document.querySelector('.updated_by')?.value || '';
    const fromDate = document.querySelector('.from-date')?.value || '';
    const toDate = document.querySelector('.to-date')?.value || '';
    const keyword = document.getElementById('searchInput')?.value || '';

    const params = new URLSearchParams();
    if (segType) params.append('segment_type', segType);
    if (creator) params.append('created_by', creator);
    if (updater) params.append('updated_by', updater);
    if (fromDate) params.append('from_date', fromDate);
    if (toDate) params.append('to_date', toDate);
    if (keyword) params.append('keyword', keyword);

    const ctx = window.__CTX__ || '';
    window.location.href = `${ctx}/customers/segments/filter?${params.toString()}`;
}


// ===== FORM VALIDATION =====

document.querySelector('.btn.btn-primary[type="submit"]')?.addEventListener('click', function (e) {
    const name = document.querySelector('input[name="segment_name"]')?.value || '';
    const logic = document.querySelector('textarea[name="criteria_logic"]')?.value || '';
    const method = document.querySelector('input[name="type"]:checked')?.value;

    // Xoá lỗi cũ trước khi validate lại
    clearModalErrors();

    let hasError = false;

    if (name.trim().length === 0) {
        showModalError('Segmentation name is required.');
        hasError = true;
    } else if (name.length > 50) {
        showModalError('Segmentation name must not exceed 50 characters.');
        hasError = true;
    }

    if (!hasError && logic.length > 500) {
        showModalError('Description must not exceed 500 characters.');
        hasError = true;
    }

    if (!hasError && method !== 'STATIC' && method !== 'DYNAMIC') {
        showModalError('Please select a valid segment type (Static or Dynamic).');
        hasError = true;
    }

    if (hasError) e.preventDefault();
});

function showModalError(message) {
    // Chèn thông báo lỗi vào cuối modal-body, tránh duplicate
    const body = document.querySelector('#createModal .modal-body');
    if (!body) return;

    let errEl = body.querySelector('.modal-error-msg');
    if (!errEl) {
        errEl = document.createElement('div');
        errEl.className = 'modal-error-msg';
        errEl.style.cssText = [
            'margin-top: 12px',
            'padding: 10px 14px',
            'background: #fee2e2',
            'border: 1px solid rgba(239,68,68,.25)',
            'border-radius: 8px',
            'color: #dc2626',
            'font-size: 0.8125rem',
            'font-weight: 500',
            'display: flex',
            'align-items: center',
            'gap: 8px',
        ].join(';');
        body.appendChild(errEl);
    }
    errEl.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
}

function clearModalErrors() {
    document.querySelector('#createModal .modal-error-msg')?.remove();
}


// ===== DELETE SEGMENT =====

function removeSegment(segmentId) {
    if (!confirm('Bạn có chắc muốn xóa segment này không?')) return;
    const ctx = window.__CTX__ || '';
    window.location.href = `${ctx}/customers/remove-segmentation?segment_id=${encodeURIComponent(segmentId)}`;
}


// ===== INIT =====

document.addEventListener('DOMContentLoaded', function () {
    const pageStatus = window.__PAGE_STATUS__;
    if (!pageStatus) return;

    let toastType = 'info';
    const s = pageStatus.toLowerCase();
    if (s.includes('success') || s.includes('successfully') || s.includes('created')) {
        toastType = 'success';
    } else if (s.includes('error') || s.includes('fail')) {
        toastType = 'error';
    } else if (s.includes('warning')) {
        toastType = 'warning';
    }
    showToast(pageStatus, toastType);
});


// ===== TOAST =====

function showToast(message, type = 'success', duration = 3000) {
    const toast = document.getElementById('toast');
    const toastIcon = document.getElementById('toastIcon');
    const toastMessage = document.getElementById('toastMessage');
    const toastBar = document.getElementById('toastBar');
    if (!toast) return;

    const icons = {
        success: '<i class="fas fa-check-circle"      style="color:#10b981;font-size:20px;"></i>',
        error: '<i class="fas fa-exclamation-circle" style="color:#ef4444;font-size:20px;"></i>',
        info: '<i class="fas fa-info-circle"        style="color:#3b82f6;font-size:20px;"></i>',
        warning: '<i class="fas fa-warning"            style="color:#f59e0b;font-size:20px;"></i>',
    };
    const barColors = {
        success: '#10b981', error: '#ef4444', info: '#3b82f6', warning: '#f59e0b',
    };

    toastIcon.innerHTML = icons[type] || icons.info;
    toastMessage.textContent = message;
    toastBar.style.background = barColors[type] || barColors.info;

    toast.classList.remove('show', 'hide');
    toastBar.style.animation = 'none';

    toast.classList.add('show');
    setTimeout(() => {
        toastBar.style.animation = `slideOut ${duration}ms ease-out forwards`;
    }, 10);
    setTimeout(() => {
        toast.classList.remove('show');
        toast.classList.add('hide');
    }, duration);
}

document.getElementById('toastCloseBtn')?.addEventListener('click', function () {
    const toast = document.getElementById('toast');
    toast.classList.remove('show');
    toast.classList.add('hide');
});