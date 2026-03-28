<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

            <form method="post">

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
                        <label class="form-label">Expected Value</label>
                        <input type="number" step="0.01" class="form-control" name="expectedValue"
                               value="${deal.expectedValue}"/>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Actual Value</label>
                        <input type="number" step="0.01" class="form-control" name="actualValue"
                               value="${deal.actualValue}"/>
                    </div>
                </div>

                <hr/>

                <h5><i class="fas fa-boxes me-1"></i> Deal Products</h5>

                <div class="table-responsive">
                    <table class="table table-bordered" id="itemsTable">
                        <thead class="table-light">
                        <tr>
                            <th>Product</th>
                            <th style="width:120px;">Qty</th>
                            <th style="width:160px;">Unit Price</th>
                            <th style="width:120px;">Discount %</th>
                            <th style="width:140px;">Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="it" items="${items}">
                            <tr>
                                <td>
                                    <select class="form-select" name="productId">
                                        <option value="">-- Select --</option>
                                        <c:forEach var="p" items="${products}">
                                            <option value="${p.productId}"
                                                    <c:if test="${it.productId == p.productId}">selected</c:if>>
                                                    ${p.name} (${p.sku})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td><input type="number" class="form-control" name="quantity" value="${it.quantity}"
                                           min="1"/></td>
                                <td><input type="number" step="0.01" class="form-control" name="unitPrice"
                                           value="${it.unitPrice}" min="0"/></td>
                                <td><input type="number" step="0.01" class="form-control" name="discount"
                                           value="${it.discount}" min="0" max="100"/></td>
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
    function removeRow(btn) {
        var row = btn.closest('tr');
        row.parentNode.removeChild(row);
    }

    function addRow() {
        var tbody = document.querySelector('#itemsTable tbody');
        var tr = document.createElement('tr');

        var productOptions = '<option value="">-- Select --</option>';
        <c:forEach var="p" items="${products}">
        productOptions += '<option value="${p.productId}">${p.name} (${p.sku})</option>';
        </c:forEach>

        tr.innerHTML =
            '<td><select class="form-select" name="productId">' + productOptions + '</select></td>' +
            '<td><input type="number" class="form-control" name="quantity" value="1" min="1" /></td>' +
            '<td><input type="number" step="0.01" class="form-control" name="unitPrice" value="0" min="0" /></td>' +
            '<td><input type="number" step="0.01" class="form-control" name="discount" value="0" min="0" max="100" /></td>' +
            '<td><button type="button" class="btn btn-sm btn-outline-danger" onclick="removeRow(this)">Remove</button></td>';

        tbody.appendChild(tr);
    }

    function loadRelatedEntities() {
        var typeSelect = document.getElementById('relatedType');
        var idSelect = document.getElementById('relatedId');
        var selectedType = typeSelect.value;

        idSelect.innerHTML = '<option value="">Loading...</option>';
        idSelect.disabled = true;

        if (!selectedType) {
            idSelect.innerHTML = '<option value="">Select type first</option>';
            return;
        }

        if (selectedType === 'INTERNAL') {
            idSelect.innerHTML = '<option value="">No entities</option>';
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
            })
            .catch(err => {
                idSelect.innerHTML = '<option value="">Error loading</option>';
            });
    }

    function loadSourceEntities() {
        var typeSelect = document.getElementById('sourceType');
        var idSelect = document.getElementById('sourceId');
        var selectedType = typeSelect.value;

        idSelect.innerHTML = '<option value="">Loading...</option>';
        idSelect.disabled = true;

        if (!selectedType) {
            idSelect.innerHTML = '<option value="">Select type first</option>';
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
            })
            .catch(err => {
                idSelect.innerHTML = '<option value="">Error loading</option>';
            });
    }

    function loadUsers() {
        fetch('${pageContext.request.contextPath}/api/related-entities?type=user')
            .then(r => r.json())
            .then(data => {
                var select = document.getElementById('performedBy');
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

    // Load users on page load
    document.addEventListener('DOMContentLoaded', function () {
        loadUsers();
    });
</script>

<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

