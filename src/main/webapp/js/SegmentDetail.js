document.querySelectorAll(".tab-btn").forEach(btn => {

    btn.addEventListener("click", () => {

        document.querySelectorAll(".tab-btn")
            .forEach(b => b.classList.remove("active"));

        document.querySelectorAll(".tab-content")
            .forEach(c => c.classList.remove("active"));

        btn.classList.add("active");

        const tab = btn.dataset.tab;

        document.getElementById(tab)
            .classList.add("active");

    });

});

document.addEventListener('DOMContentLoaded', () => {
    init();
})

const container = document.getElementById("conditions-container");
const template = document.getElementById("condition-template");

document.getElementById("add-condition").addEventListener("click", addCondition);

function addCondition() {

    const clone = template.content.cloneNode(true);
    const row = clone.querySelector(".condition-row");

    const fieldSelect = row.querySelector(".field");
    const valueInput = row.querySelector(".value");

    changeInputType(fieldSelect);

    fieldSelect.addEventListener("change", () => {
        changeInputType(fieldSelect);
    });

    row.querySelector(".delete-condition").addEventListener("click", () => {
        row.remove();
    });


    container.appendChild(row);
}

function init() {
    const rows = document.querySelectorAll(".condition-row");

    rows.forEach(row => {
        const fieldSelect = row.querySelector(".field");


        fieldSelect.addEventListener("change", () => {
            changeInputType(fieldSelect);
        });

        row.querySelector(".delete-condition")?.addEventListener("click", () => {
            row.remove();
        });
    });
}


function changeInputType(fieldSelect) {

    const selected = fieldSelect.options[fieldSelect.selectedIndex];
    const type = selected.dataset.type;
    const inputType = selected.dataset.input;
    const sourceId = selected.dataset.source;

    const row = fieldSelect.closest(".condition-row");

    const oldValue = row.querySelector(".value");
    console.log("old: ", oldValue)
    if (oldValue) oldValue.remove();

    let newInput;

    if (inputType === "select") {

        newInput = document.createElement("select");
        newInput.className = "value";

        const sourceSelect = template.content.querySelector(`#${sourceId}`);
        console.log(sourceId)
        console.log(sourceSelect)
        if (sourceSelect) {
            newInput.innerHTML = sourceSelect.innerHTML;
            newInput.style = "width: 110px"
            console.log("new: ", newInput)
        }

    } else {

        newInput = document.createElement("input");
        newInput.className = "value";

        if (type === "date") {
            newInput.type = "date";
            newInput.style = "width: 110px"
        } else if (type === "number") {
            newInput.type = "number";
            newInput.style = "width: 110px"
            newInput.step = "any";
        } else {
            newInput.type = "text";
            newInput.style = "width: 115px"
        }

    }

    row.querySelector(".operator").after(newInput);
}


function getFilters() {

    const rows = document.querySelectorAll(".condition-row");
    const filters = [];

    rows.forEach(row => {

        filters.push({
            field: row.querySelector(".field").value,
            operator: row.querySelector(".operator").value,
            value: row.querySelector(".value").value,
            logic: row.querySelector(".logic-operator").value
        });

    });

    return filters;
}

const slicer = document.querySelector('.switch input[type="checkbox"]');
if (slicer.checked) {
    document.querySelectorAll('.method').forEach(m => m.classList.add('show'));
} else {
    document.querySelectorAll('.method').forEach(m => m.classList.remove('show'));
}
slicer.addEventListener("change", function () {
    if (slicer.checked) {
        document.querySelectorAll('.method').forEach(m => m.classList.add('show'));
    } else {
        document.querySelectorAll('.method').forEach(m => m.classList.remove('show'));
    }
})

const editBtn = document.getElementById("editBtn");
let isEditing = false;

editBtn.addEventListener("click", function () {

    const items = document.querySelectorAll(".info-item span");

    if (!isEditing) {

        items.forEach((span, index) => {
            const value = span.innerText;
            if (index === 2) {
                const textArea = document.createElement('textarea');
                textArea.type = "text";
                textArea.value = value;
                textArea.style.width = "333px";

                span.replaceWith(textArea);
            } else if (index === 0) {
                const input = document.createElement("input");
                input.type = "text";
                input.value = value;
                input.style.width = "333px";

                span.replaceWith(input);
            } else if (index === 1) {
                const input = document.createElement("select");
                const options = value === 'STATIC' ? "<option value='STATIC' selected>STATIC</option> <option value='DYNAMIC'>DYNAMIC</option>" :
                    "<option value='STATIC' >STATIC</option> <option value='DYNAMIC' selected>DYNAMIC</option>";
                input.innerHTML = options;
                input.style.width = "333px";
                input.style.height = "30px";
                span.replaceWith(input);
            }
        });

        editBtn.innerHTML = '<i class="fas fa-save" style="color:white"></i><span style="margin-left:5px;color:white">Save</span>';

        isEditing = true;

    } else {

        const inputs = document.querySelectorAll(".info-item input");
        const textArea = document.querySelector(".info-item textarea");
        const select = document.querySelector(".info-item select");
        inputs.forEach(input => {
            const span = document.createElement("span");
            span.innerText = input.value;

            input.replaceWith(span);
        });

        const span = document.createElement("span");
        span.innerText = textArea.value;
        textArea.replaceWith(span);

        const span2 = document.createElement("span");
        span2.innerText = select.value;
        select.replaceWith(span2);

        editBtn.innerHTML = '<i class="fas fa-pen" style="color:white"></i><span style="margin-left:5px;color:white">Edit</span>';

        isEditing = false;
    }

});

const items = document.querySelectorAll('.info-grid .info-item');

const currentName = items[0].querySelector('span').innerText;
const currentType = items[1].querySelector('span').innerText;
const currentDesc = items[2].querySelector('span').innerText;

document.querySelector('#editBtn').addEventListener('click', function () {
    if (isEditing === false) {
        const itemss = document.querySelectorAll('.info-grid .info-item');
        const name = itemss[0].querySelector('span').innerText;
        const type = itemss[1].querySelector('span').innerText;
        const desc = itemss[2].querySelector('span').innerText;
        const segmentId = window.segmentId;
        const params = new URLSearchParams();
        if (segmentId) params.append('segment_id', segmentId);
        if (name.trim() && currentName.trim()) {
            params.append('segment_name', name);
            params.append('current_name', currentName);
        }
        if (type.trim() && currentType.trim()) {
            params.append('segment_type', type);
            params.append('current_type', currentType);
        }
        if (desc.trim() && currentDesc.trim()) {
            params.append('criteria_logic', desc);
            params.append('current_logic', currentDesc);
        }

        const ctx = window.__CTX__;

        if (!params.toString()) {
            alert("No changes detected");
            return;
        }

        fetch(`${ctx}/customers/update-segment`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: params.toString()
        })
            .then(res => res.text())
            .then(data => {
                console.log(data);
                window.location.reload()
            })
            .catch(err => console.error(err));
    }
});


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
