function openCreateModal() {
    document.getElementById("createModal").style.display = "flex";
}

function closeCreateModal() {
    document.getElementById("createModal").style.display = "none";
}

document.querySelector(".seg-search input").addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
        event.preventDefault();
        filterSegment();
    }
});

function filterSegment() {
    const segType = document.querySelector('.segment_type').value;
    const creator = document.querySelector('.created_by').value;
    const updater = document.querySelector('.updated_by').value;
    const fromDate = document.querySelector('.from-date').value;
    const toDate = document.querySelector('.to-date').value;
    const keyword = document.querySelector('.seg-search input').value;

    const params = new URLSearchParams();
    if (segType) params.append('segment_type', segType);
    if (creator) params.append('created_by', creator);
    if (updater) params.append('updated_by', updater);
    if (fromDate) params.append('from_date', fromDate);
    if (toDate) params.append('to_date', toDate);
    if (keyword) params.append('keyword', keyword)

    const ctx = window.__CTX__ || "";
    const url = `${ctx}/customers/segments/filter?${params.toString()}`;

    console.log(url)
    window.location.href = url;
}

document.querySelector('.btn-submit').addEventListener('click', function (e) {
    const name = document.querySelector('input[name="segment_name"]').value;
    const logic = document.querySelector('textarea[name="criteria_logic"]').value;
    const method = document.querySelector('input[name="type"]:checked').value;
    const error = document.querySelector('.modal-body p');

    console.log(name, error);
    if (name.trim().length === 0) {
        e.preventDefault();
        if (!error) {
            const error = document.createElement('p');
            error.style = "color: red;" +
                " margin-top: 10px;";
            error.innerText = 'Segmentation name is required';
            document.querySelector('.modal-body').appendChild(error);
        }
    }

    if (name.length > 255) {
        e.preventDefault();
        if (!error) {
            const error = document.createElement('p');
            error.style = "color: red;" +
                " margin-top: 10px;";
            error.innerText = 'Segmentation name is too long';
            document.querySelector('.modal-body').appendChild(error);
        }
    }

    if (logic.length > 1000) {
        e.preventDefault();
        if (!error) {
            const error = document.createElement('p');
            error.style = "color: red;" +
                " margin-top: 10px;";
            error.innerText = 'Description is too long';
            document.querySelector('.modal-body').appendChild(error);
        }
    }

    if (method !== 'STATIC' && method !== 'DYNAMIC') {
        e.preventDefault();
        if (!error) {
            const error = document.createElement('p');
            error.style = "color: red;" +
                " margin-top: 10px;";
            error.innerText = 'Type of segmentation must be equal static or dynamic';
            document.querySelector('.modal-body').appendChild(error);
        }
    }
})

function removeSegment(segmentId) {
    const confirmDelete = confirm("Do you mant to delete this segmentation ?");
    if (confirmDelete) {
        console.log(confirmDelete);
        const ctx = window.__CTX__ || '';
        const url = `${ctx}/customers/remove-segmentation?segment_id=${encodeURIComponent(segmentId)}`
        window.location.href = url;
    }
}

document.addEventListener("DOMContentLoaded", function () {
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
})

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
