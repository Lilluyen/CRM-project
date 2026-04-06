<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Embed product price map as JS object for client-side lookup --%>
<script>
    const PRODUCT_PRICES = {};
    <c:forEach var="p" items="${products}">
    PRODUCT_PRICES[${p.productId}] = ${p.price};
    </c:forEach>
</script>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-handshake me-2"></i>${deal.dealId == 0 ? "Add Deal" : "Edit Deal"}</h4>
            <p class="text-muted mb-0">${deal.dealId == 0 ? "Create new deal" : "Update deal information"}</p>
        </div>
        <a href="${pageContext.request.contextPath}/sale/deal/list" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-1"></i> Back to List
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-1"></i> ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body">

            <form method="post" action="${pageContext.request.contextPath}/sale/deal/create">

                <c:if test="${deal.dealId != 0}">
                    <input type="hidden" name="dealId" value="${deal.dealId}"/>
                    <input type="hidden" name="ownerId" value="${deal.ownerId}"/>
                </c:if>

                <div class="mb-3">
                    <label class="form-label">Deal Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="dealName" value="${deal.dealName}" required/>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Related Type</label>
                    <select name="relatedType" class="form-select" id="relatedType" onchange="loadRelatedEntities()">
                        <option value="">-- None --</option>
                        <option value="CUSTOMER"
                                <c:if test="${relatedType eq 'CUSTOMER'}">selected</c:if>>Customer
                        </option>
                        <option value="LEAD" <c:if test="${relatedType eq 'LEAD'}">selected</c:if>>Lead</option>
                    </select>
                </div>

                <div class="mb-3">

                    <c:set var="type"
                           value="${relatedType eq 'CUSTOMER' ? customers : relatedType eq 'LEAD' ? leads : null}"/>
                    <c:set var="idField"
                           value="${relatedType eq 'CUSTOMER' ? 'customerId' : relatedType eq 'LEAD' ? 'leadId' : null}"/>
                    <c:set var="nameField"
                           value="${relatedType eq 'CUSTOMER' ? 'name' : relatedType eq 'LEAD' ? 'fullName' : null}"/>

                    <label class="form-label fw-semibold">Related Name</label>

                    <select name="relatedId" class="form-select" id="relatedId"
                            <c:if test="${empty relatedType}">disabled</c:if>>

                        <option value="">Select type first</option>

                        <c:forEach items="${type}" var="t">

                            <c:set var="currentId" value="${t[idField]}"/>
                            <c:set var="currentName" value="${t[nameField]}"/>

                            <option value="${currentId}"
                                    <c:if test="${currentId == relatedId}">selected</c:if>>
                                    ${currentName}
                            </option>

                        </c:forEach>

                    </select>
                </div>

                <div class="mb-3" id="campaignSelectWrapper"
                     style="display:${relatedType eq 'LEAD' ? 'block' : 'none'};">
                    <label class="form-label fw-semibold">Campaign <span class="text-danger">*</span></label>
                    <select name="campaignId" class="form-select" id="campaignId"
                            data-selected="${not empty selectedCampaignId ? selectedCampaignId : deal.campaignId}">
                        <option value="">-- Select Campaign --</option>
                        <c:forEach items="${leadCampaigns}" var="camp">
                            <option value="${camp.campaignId}"
                                    <c:if test="${camp.campaignId == selectedCampaignId || camp.campaignId == deal.campaignId}">selected</c:if>>
                                    ${camp.name}
                            </option>
                        </c:forEach>
                    </select>
                    <small class="text-muted">Mỗi deal của lead phải thuộc đúng một campaign.</small>
                </div>

                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Stage</label>
                        <select class="form-select" name="stage">
                            <c:forEach var="s" items="${stages}">
                                <option value="${s}"
                                        <c:if test="${deal.stage == s || (deal.stage == null && s == 'Prospecting')}">selected</c:if>>${s}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Probability (0-100)</label>
                        <input type="number" class="form-control" name="probability" value="${deal.probability}"/>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Expected Close Date</label>
                        <input type="date" class="form-control" name="expectedCloseDate"
                               value="${deal.expectedCloseDate}"/>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            Expected Value
                            <small class="text-muted">(tổng trước discount)</small>
                        </label>
                        <input type="number" step="0.01" class="form-control" name="expectedValue"
                               id="expectedValue" value="${deal.expectedValue}" readonly
                               style="background-color:#f8f9fa; font-weight:600;"/>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            Actual Value
                            <small class="text-muted">(tổng sau discount)</small>
                        </label>
                        <input type="number" step="0.01" class="form-control" name="actualValue"
                               id="actualValue" value="${deal.actualValue}" readonly
                               style="background-color:#f8f9fa; font-weight:600;"/>
                    </div>
                </div>

                <hr/>

                <h5><i class="fas fa-boxes me-1"></i> Deal Products</h5>

                <div class="table-responsive">
                    <table class="table table-bordered" id="itemsTable">
                        <thead class="table-light">
                        <tr>
                            <th>Product</th>
                            <th style="width:110px;">Qty</th>
                            <th style="width:160px;">Unit Price</th>
                            <th style="width:120px;">Discount %</th>
                            <th style="width:150px;">Line Total</th>
                            <th style="width:100px;">Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="it" items="${items}">
                            <tr>
                                <td>
                                    <select class="form-select product-select" name="productId"
                                            onchange="onProductChange(this)">
                                        <option value="">-- Select --</option>
                                        <c:forEach var="p" items="${products}">
                                            <option value="${p.productId}"
                                                    data-price="${p.price}"
                                                    <c:if test="${it.productId == p.productId}">selected</c:if>>
                                                    ${p.name} (${p.sku})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td>
                                    <input type="number" class="form-control qty-input" name="quantity"
                                           value="${it.quantity}" min="1" oninput="recalcRow(this)"/>
                                </td>
                                <td>
                                    <input type="number" step="0.01" class="form-control unit-price-input"
                                           name="unitPrice" value="${it.unitPrice}" min="0"
                                           oninput="recalcRow(this)"/>
                                </td>
                                <td>
                                    <input type="number" step="0.01" class="form-control discount-input"
                                           name="discount" value="${it.discount}" min="0" max="100"
                                           oninput="recalcRow(this)"/>
                                </td>
                                <td>
                                    <input type="text" class="form-control line-total-display"
                                           readonly tabindex="-1"
                                           style="background:#f8f9fa; font-weight:600;"
                                           value="${it.totalPrice}"/>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                            onclick="removeRow(this)">Remove
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>

                <button type="button" class="btn btn-outline-secondary" onclick="addRow()">
                    <i class="fas fa-plus me-1"></i> Add Product
                </button>

                <hr/>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-1"></i> Save
                    </button>
                    <a href="${pageContext.request.contextPath}/deal/list" class="btn btn-secondary">Cancel</a>
                </div>

            </form>

        </div>
    </div>

</div>

<script>
    /* =====================================================
       Product price lookup & auto-calculation logic
    ===================================================== */

    /**
     * Khi đổi product → điền unit price từ PRODUCT_PRICES map
     */
    function onProductChange(select) {
        var row = select.closest('tr');
        var productId = select.value;
        var unitPriceInput = row.querySelector('.unit-price-input');

        if (productId && PRODUCT_PRICES[productId] !== undefined) {
            unitPriceInput.value = PRODUCT_PRICES[productId];
        } else {
            unitPriceInput.value = 0;
        }

        recalcRow(select);
    }

    /**
     * Tính line total cho một hàng, sau đó cập nhật tổng toàn bộ
     */
    function recalcRow(element) {
        var row = element.closest('tr');

        var qty = parseFloat(row.querySelector('.qty-input').value) || 0;
        var unitPrice = parseFloat(row.querySelector('.unit-price-input').value) || 0;
        var discount = parseFloat(row.querySelector('.discount-input').value) || 0;

        // Clamp discount to [0, 100]
        if (discount < 0) discount = 0;
        if (discount > 100) discount = 100;

        var lineGross = qty * unitPrice;                          // trước discount
        var lineNet = lineGross * (1 - discount / 100);       // sau discount

        var lineTotalDisplay = row.querySelector('.line-total-display');
        if (lineTotalDisplay) {
            lineTotalDisplay.value = lineNet.toFixed(2);
        }

        recalcTotals();
    }

    /**
     * Cộng dồn tất cả hàng → cập nhật Expected Value & Actual Value
     * - Expected Value = tổng (qty × unitPrice)           [trước discount]
     * - Actual Value   = tổng (qty × unitPrice × (1 - d)) [sau discount]
     */
    function recalcTotals() {
        var rows = document.querySelectorAll('#itemsTable tbody tr');

        var totalExpected = 0;
        var totalActual = 0;

        rows.forEach(function (row) {
            var qty = parseFloat(row.querySelector('.qty-input').value) || 0;
            var unitPrice = parseFloat(row.querySelector('.unit-price-input').value) || 0;
            var discount = parseFloat(row.querySelector('.discount-input').value) || 0;

            if (discount < 0) discount = 0;
            if (discount > 100) discount = 100;

            var lineGross = qty * unitPrice;
            var lineNet = lineGross * (1 - discount / 100);

            totalExpected += lineGross;
            totalActual += lineNet;
        });

        document.getElementById('expectedValue').value = totalExpected.toFixed(2);
        document.getElementById('actualValue').value = totalActual.toFixed(2);
    }

    /**
     * Xoá hàng và tính lại tổng
     */
    function removeRow(btn) {
        var row = btn.closest('tr');
        row.parentNode.removeChild(row);
        recalcTotals();
    }

    /**
     * Thêm hàng mới với đầy đủ event handlers
     */
    function addRow() {
        var tbody = document.querySelector('#itemsTable tbody');
        var tr = document.createElement('tr');

        // Build product options from PRODUCT_PRICES map + server-rendered list
        var productOptions = '<option value="">-- Select --</option>';
        <c:forEach var="p" items="${products}">
        productOptions += '<option value="${p.productId}" data-price="${p.price}">${p.name} (${p.sku})</option>';
        </c:forEach>

        tr.innerHTML =
            '<td><select class="form-select product-select" name="productId" onchange="onProductChange(this)">'
            + productOptions +
            '</select></td>' +
            '<td><input type="number" class="form-control qty-input" name="quantity" value="1" min="1" oninput="recalcRow(this)"/></td>' +
            '<td><input type="number" step="0.01" class="form-control unit-price-input" name="unitPrice" value="0" min="0" oninput="recalcRow(this)"/></td>' +
            '<td><input type="number" step="0.01" class="form-control discount-input" name="discount" value="0" min="0" max="100" oninput="recalcRow(this)"/></td>' +
            '<td><input type="text" class="form-control line-total-display" readonly tabindex="-1" style="background:#f8f9fa;font-weight:600;" value="0.00"/></td>' +
            '<td><button type="button" class="btn btn-sm btn-outline-danger" onclick="removeRow(this)">Remove</button></td>';

        tbody.appendChild(tr);
    }

    function clearCampaignOptions() {
        var campaignSelect = document.getElementById('campaignId');
        if (!campaignSelect) return;
        campaignSelect.innerHTML = '<option value="">-- Select Campaign --</option>';
        campaignSelect.value = '';
    }

    function toggleCampaignSelector() {
        var typeSelect = document.getElementById('relatedType');
        var wrapper = document.getElementById('campaignSelectWrapper');
        var campaignSelect = document.getElementById('campaignId');
        if (!typeSelect || !wrapper || !campaignSelect) return;

        var isLead = (typeSelect.value || '').toUpperCase() === 'LEAD';
        wrapper.style.display = isLead ? 'block' : 'none';
        campaignSelect.required = isLead;
        if (!isLead) {
            clearCampaignOptions();
        }
    }

    function loadLeadCampaigns() {
        var typeSelect = document.getElementById('relatedType');
        var relatedIdSelect = document.getElementById('relatedId');
        var campaignSelect = document.getElementById('campaignId');

        if (!typeSelect || !relatedIdSelect || !campaignSelect) return;
        if ((typeSelect.value || '').toUpperCase() !== 'LEAD') {
            clearCampaignOptions();
            return;
        }

        var leadId = relatedIdSelect.value;
        if (!leadId) {
            clearCampaignOptions();
            return;
        }

        campaignSelect.innerHTML = '<option value="">Loading campaigns...</option>';

        fetch('${pageContext.request.contextPath}/api/related-entities?type=lead-campaign&leadId=' + encodeURIComponent(leadId))
            .then(r => r.json())
            .then(data => {
                clearCampaignOptions();
                data.forEach(function (item) {
                    var opt = document.createElement('option');
                    opt.value = item.id;
                    opt.textContent = item.name;
                    campaignSelect.appendChild(opt);
                });

                var selectedCampaign = campaignSelect.dataset.selected;
                if (selectedCampaign) {
                    campaignSelect.value = selectedCampaign;
                    campaignSelect.dataset.selected = '';
                }
            })
            .catch(() => {
                campaignSelect.innerHTML = '<option value="">Error loading campaigns</option>';
            });
    }

    /* =====================================================
       Related entity loaders (giữ nguyên từ bản gốc)
    ===================================================== */

    function loadRelatedEntities() {
        var typeSelect = document.getElementById('relatedType');
        var idSelect = document.getElementById('relatedId');
        var selectedType = typeSelect.value;

        idSelect.innerHTML = '<option value="">Loading...</option>';
        idSelect.disabled = true;
        toggleCampaignSelector();

        if (!selectedType) {
            idSelect.innerHTML = '<option value="">Select type first</option>';
            clearCampaignOptions();
            return;
        }

        if (selectedType === 'INTERNAL') {
            idSelect.innerHTML = '<option value="">No entities</option>';
            clearCampaignOptions();
            return;
        }

        var apiType = selectedType.toLowerCase();
        fetch('${pageContext.request.contextPath}/api/related-entities?type=' + apiType)
            .then(r => r.json())
            .then(data => {
                idSelect.innerHTML = '<option value="">-- Select --</option>';
                data.forEach(function (item) {
                    var opt = document.createElement('option');
                    opt.value = item.id;
                    opt.textContent = item.name;
                    idSelect.appendChild(opt);
                });
                idSelect.disabled = false;

                if ((selectedType || '').toUpperCase() === 'LEAD') {
                    loadLeadCampaigns();
                } else {
                    clearCampaignOptions();
                }
            })
            .catch(() => {
                idSelect.innerHTML = '<option value="">Error loading</option>';
                clearCampaignOptions();
            });
    }

    function loadUsers() {
        fetch('${pageContext.request.contextPath}/api/related-entities?type=user')
            .then(r => r.json())
            .then(data => {
                var select = document.getElementById('performedBy');
                if (!select) return;
                select.innerHTML = '<option value="">-- Select User --</option>';
                data.forEach(function (item) {
                    var opt = document.createElement('option');
                    opt.value = item.id;
                    opt.textContent = item.name + (item.email ? ' (' + item.email + ')' : '');
                    select.appendChild(opt);
                });
            })
            .catch(err => console.error('Error loading users:', err));
    }

    /* =====================================================
       Khởi tạo khi trang load xong
    ===================================================== */
    document.addEventListener('DOMContentLoaded', function () {
        loadUsers();
        toggleCampaignSelector();

        var relatedIdSelect = document.getElementById('relatedId');
        if (relatedIdSelect) {
            relatedIdSelect.addEventListener('change', function () {
                loadLeadCampaigns();
            });
        }
        loadLeadCampaigns();

        // Tính lại tổng cho những sản phẩm đã có sẵn (edit mode / validation error)
        document.querySelectorAll('#itemsTable tbody tr').forEach(function (row) {
            recalcRow(row.querySelector('.qty-input'));
        });
    });
</script>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>
