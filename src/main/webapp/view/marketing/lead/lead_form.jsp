<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1">
                    <c:choose>
                        <c:when test="${lead.leadId > 0}">
                            <i class="fas fa-edit me-2"></i>Edit Lead
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-plus-circle me-2"></i>Create New Lead
                        </c:otherwise>
                    </c:choose>
                </h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/marketing/leads">Leads</a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">
                            <c:choose>
                                <c:when test="${lead.leadId > 0}">Edit</c:when>
                                <c:otherwise>Create</c:otherwise>
                            </c:choose>
                        </li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/leads${not empty lockedCampaignId ? '?campaignId='.concat(lockedCampaignId) : (not empty param.campaignId ? '?campaignId='.concat(param.campaignId) : '')}"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to List
            </a>
        </div>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-1"></i>
                <strong>Error!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Form -->
        <div class="form-container">
            <form id="leadForm" method="POST"
                  action="${pageContext.request.contextPath}/marketing/leads/form"
                  novalidate>
                <c:if test="${lead.leadId > 0}">
                    <input type="hidden" name="leadId" value="${lead.leadId}">
                </c:if>

                <!-- Section 1: Thông tin cơ bản -->
                <div class="form-section">
                    <h5><i class="fas fa-user me-1"></i> Lead Information</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="fullName" class="form-label required">Full Name</label>
                                <input type="text" class="form-control" id="fullName" name="fullName"
                                       value="${lead.fullName}" placeholder="e.g., John Doe"
                                       maxlength="100" required>
                                <div class="invalid-feedback">Please enter your full name.</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="email" class="form-label required">Email</label>
                                <input type="email" class="form-control" id="email" name="email"
                                       value="${lead.email}" placeholder="e.g., john.doe@company.com"
                                       maxlength="100" required>
                                <div class="invalid-feedback">Please enter a valid email address.</div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="text" class="form-control" id="phone" name="phone"
                                       value="${lead.phone}" placeholder="e.g., 0901234567"
                                       maxlength="20">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="interest" class="form-label">Interests / Preferences</label>
                                <input type="text" class="form-control" id="interest" name="interest"
                                       value="${lead.interest}" placeholder="e.g., Product A, Service B"
                                       maxlength="255">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 2: Nguồn & Campaign -->
                <div class="form-section">
                    <h5><i class="fas fa-bullhorn me-1"></i> Source & Campaign</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="source" class="form-label">Lead Source</label>
                                <select class="form-select" id="source" name="source">
                                    <option value="">-- Select Source --</option>
                                    <option value="Website"      ${lead.source == 'Website'      ? 'selected' : ''}>Website</option>
                                    <option value="Facebook"     ${lead.source == 'Facebook'     ? 'selected' : ''}>Facebook</option>
                                    <option value="LinkedIn"     ${lead.source == 'LinkedIn'     ? 'selected' : ''}>LinkedIn</option>
                                    <option value="Referral"     ${lead.source == 'Referral'     ? 'selected' : ''}>Referral</option>
                                    <option value="Seminar"      ${lead.source == 'Seminar'      ? 'selected' : ''}>Seminar</option>
                                    <option value="Email"        ${lead.source == 'Email'        ? 'selected' : ''}>Email Campaign</option>
                                    <option value="Cold Call"    ${lead.source == 'Cold Call'    ? 'selected' : ''}>Cold Call</option>
                                    <option value="Import"       ${lead.source == 'Import'       ? 'selected' : ''}>Import File</option>
                                    <option value="Other"        ${lead.source == 'Other'        ? 'selected' : ''}>Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label class="form-label">Campaign</label>

                                <c:choose>

                                    <%-- CASE 1: CREATE MODE từ campaign → lock, không cho chọn --%>
                                    <c:when test="${lead.leadId == 0 and not empty lockedCampaignId}">
                                        <input type="hidden" name="campaignId" value="${lockedCampaignId}"/>
                                        <input type="hidden" name="selectedCampaigns" value="${lockedCampaignId}"/>
                                        <input type="text" class="form-control bg-light"
                                               value="${lockedCampaignName}" readonly/>
                                        <small class="form-text text-muted mt-1 d-block">
                                            <i class="fas fa-lock me-1"></i>
                                            Lead will be attached to this campaign.
                                        </small>
                                    </c:when>

                                    <%-- CASE 2: EDIT MODE → checkbox dropdown (giữ nguyên logic cũ) --%>
                                    <c:when test="${lead.leadId > 0}">
                                        <c:if test="${not empty param.campaignId}">
                                            <input type="hidden" name="returnCampaignId" value="${param.campaignId}"/>
                                        </c:if>

                                        <c:set var="joinedCount" value="0" />
                                        <c:forEach var="jc" items="${leadCampaigns}">
                                            <c:set var="joinedCount" value="${joinedCount + 1}" />
                                        </c:forEach>

                                        <div class="camp-wrap" style="position:relative;">
                                            <button type="button" id="campBtn"
                                                    class="form-select text-start d-flex justify-content-between align-items-center"
                                                    style="cursor:pointer;"
                                                    onclick="toggleCampPanel(event)">
                                                <span id="campBtnText">
                                                    <c:choose>
                                                        <c:when test="${joinedCount > 0}">
                                                            Selected <strong>${joinedCount}</strong> campaign
                                                        </c:when>
                                                        <c:otherwise>-- No campaign selected --</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <i class="fas fa-chevron-down" id="campChevron"
                                                   style="transition:transform .2s; flex-shrink:0;"></i>
                                            </button>

                                            <div id="campPanel"
                                                 style="display:none; position:absolute; z-index:1050;
                                                        width:100%; top:calc(100% + 4px); left:0;
                                                        background:#fff; border:1px solid #dee2e6;
                                                        border-radius:6px;
                                                        box-shadow:0 4px 16px rgba(0,0,0,.12);
                                                        max-height:260px; overflow-y:auto;">
                                                <div class="d-flex justify-content-between align-items-center
                                                            px-3 py-2 border-bottom bg-light"
                                                     style="position:sticky; top:0; z-index:1;">
                                                    <span class="small fw-semibold text-muted">Campaign List</span>
                                                    <div class="d-flex gap-2">
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-primary py-0 px-2"
                                                                onclick="selectAllCamps()">Select All</button>
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-secondary py-0 px-2"
                                                                onclick="deselectAllCamps()">Deselect All</button>
                                                    </div>
                                                </div>
                                                <div class="p-2">
                                                    <c:choose>
                                                        <c:when test="${not empty campaigns}">
                                                            <c:forEach var="camp" items="${campaigns}">
                                                                <c:set var="isTicked" value="false" />
                                                                <c:forEach var="joined" items="${leadCampaigns}">
                                                                    <c:if test="${joined.campaignId == camp.campaignId}">
                                                                        <c:set var="isTicked" value="true" />
                                                                    </c:if>
                                                                </c:forEach>
                                                                <c:if test="${camp.status == 'ACTIVE'}">
                                                                    <label class="camp-item d-flex align-items-center
                                                                                  gap-2 px-2 py-2 rounded mb-1"
                                                                           for="ck_${camp.campaignId}"
                                                                           style="cursor:pointer; user-select:none;
                                                                                  background:${isTicked ? 'rgba(13,110,253,.08)' : 'transparent'}">
                                                                        <input type="checkbox"
                                                                               class="form-check-input camp-cb flex-shrink-0"
                                                                               name="selectedCampaigns"
                                                                               value="${camp.campaignId}"
                                                                               id="ck_${camp.campaignId}"
                                                                               onchange="onCampCb(this)"
                                                                            <c:if test="${isTicked}">checked</c:if> >
                                                                        <span class="flex-grow-1">${camp.name}</span>
                                                                        <c:if test="${isTicked}">
                                                                            <span class="badge bg-primary"
                                                                                  style="font-size:.65rem;">Currently Joined</span>
                                                                        </c:if>
                                                                    </label>
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p class="text-muted small px-2 mb-0">No campaign available.</p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                        <small class="form-text text-muted mt-1 d-block">
                                            <i class="fas fa-info-circle me-1"></i>
                                            Check to add, uncheck to leave campaign.
                                        </small>
                                    </c:when>

                                    <%-- CASE 3: CREATE MODE thông thường → checkbox dropdown --%>
                                    <c:otherwise>
                                        <div class="camp-wrap" style="position:relative;">
                                            <button type="button" id="campBtn"
                                                    class="form-select text-start d-flex justify-content-between align-items-center"
                                                    style="cursor:pointer;"
                                                    onclick="toggleCampPanel(event)">
                                                <span id="campBtnText">-- No Campaign Selected --</span>
                                                <i class="fas fa-chevron-down" id="campChevron"
                                                   style="transition:transform .2s; flex-shrink:0;"></i>
                                            </button>
                                            <div id="campPanel"
                                                 style="display:none; position:absolute; z-index:1050;
                                                        width:100%; top:calc(100% + 4px); left:0;
                                                        background:#fff; border:1px solid #dee2e6;
                                                        border-radius:6px;
                                                        box-shadow:0 4px 16px rgba(0,0,0,.12);
                                                        max-height:260px; overflow-y:auto;">
                                                <div class="d-flex justify-content-between align-items-center
                                                            px-3 py-2 border-bottom bg-light"
                                                     style="position:sticky; top:0; z-index:1;">
                                                    <span class="small fw-semibold text-muted"> Campaign List</span>
                                                    <div class="d-flex gap-2">
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-primary py-0 px-2"
                                                                onclick="selectAllCamps()">Select All</button>
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-secondary py-0 px-2"
                                                                onclick="deselectAllCamps()">Deselect All</button>
                                                    </div>
                                                </div>
                                                <div class="p-2">
                                                    <c:choose>
                                                        <c:when test="${not empty campaigns}">
                                                            <c:forEach var="camp" items="${campaigns}">
                                                                <c:if test="${camp.status == 'ACTIVE'}">
                                                                    <label class="camp-item d-flex align-items-center
                                                                                  gap-2 px-2 py-2 rounded mb-1"
                                                                           for="ck_${camp.campaignId}"
                                                                           style="cursor:pointer; user-select:none; background:transparent;">
                                                                        <input type="checkbox"
                                                                               class="form-check-input camp-cb flex-shrink-0"
                                                                               name="selectedCampaigns"
                                                                               value="${camp.campaignId}"
                                                                               id="ck_${camp.campaignId}"
                                                                               onchange="onCampCb(this)">
                                                                        <span class="flex-grow-1">${camp.name}</span>
                                                                    </label>
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p class="text-muted small px-2 mb-0">No campaign available.</p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                        <small class="form-text text-muted mt-1 d-block">
                                            <i class="fas fa-info-circle me-1"></i>
                                            Check to add to campaign. Only shows ACTIVE campaigns.
                                        </small>
                                    </c:otherwise>

                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="assignedTo" class="form-label">Assigned To</label>
                                <select class="form-select" id="assignedTo" name="assignedTo">
                                    <option value="0">-- Not Assigned --</option>
                                    <c:forEach var="user" items="${users}">
                                        <option value="${user.userId}"
                                            ${lead.assignedTo == user.userId ? 'selected' : ''}>
                                            ${user.fullName} (${user.role.roleName})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 3: Trạng thái & Điểm (chỉ cho edit mode, read-only) -->
                <c:if test="${lead.leadId > 0}">
                    <div class="form-section">
                        <h5><i class="fas fa-chart-line me-1"></i> Status & Score</h5>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="field-group">
                                    <label class="form-label">Status</label>
                                    <input type="text" class="form-control" value="${lead.status}" disabled>
                                    <small class="form-text text-muted">Status is automatically determined based on score</small>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="field-group">
                                    <label class="form-label">Score</label>
                                    <input type="text" class="form-control" value="${lead.score}" disabled>
                                    <small class="form-text text-muted">Full Name +20 | Email +20 | Phone +20 | Campaign +10</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Actions -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/marketing/leads${not empty lockedCampaignId ? '?campaignId='.concat(lockedCampaignId) : (not empty param.campaignId ? '?campaignId='.concat(param.campaignId) : '')}"
                       class="btn btn-large btn-cancel">
                        <i class="fas fa-times-circle me-1"></i> Cancel
                    </a>

                    <c:choose>
                        <c:when test="${lead.leadId > 0}">
                            <button type="submit" class="btn btn-large btn-save">
                                <i class="fas fa-check-circle me-1"></i> Update
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="reset" class="btn btn-large btn-delete">
                                <i class="fas fa-eraser me-1"></i> Clear
                            </button>
                            <button type="submit" class="btn btn-large btn-save">
                                <i class="fas fa-plus-circle me-1"></i> Create New
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>

    <script>
        const form = document.getElementById('leadForm');

        document.addEventListener('DOMContentLoaded', function () {
            form.addEventListener('submit', function (event) {
                event.preventDefault();
                event.stopPropagation();

                if (validateForm()) {
                    form.submit();
                } else {
                    form.classList.add('was-validated');
                    scrollToFirstError();
                }
            }, false);
        });

        function validateForm() {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();

            if (!fullName) {
                showFieldError('fullName', 'Please enter your full name.');
                return false;
            }
            if (!email) {
                showFieldError('email', 'Please enter your email.');
                return false;
            }
            // Simple email format check
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showFieldError('email', 'Invalid email format.');
                return false;
            }

            const scoreField = document.getElementById('score');
            if (scoreField) {
                const score = parseInt(scoreField.value);
                if (scoreField.value !== '' && (isNaN(score) || score < 0 || score > 100)) {
                    showFieldError('score', 'Score must be between 0 and 100.');
                    return false;
                }
            }

            return true;
        }

        function showFieldError(fieldId, message) {
            const field = document.getElementById(fieldId);
            if (field) {
                field.classList.add('is-invalid');
                const feedback = field.parentElement.querySelector('.invalid-feedback');
                if (feedback) {
                    feedback.textContent = message;
                }
            }
        }

        function scrollToFirstError() {
            const firstError = document.querySelector('.is-invalid');
            if (firstError) {
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                firstError.focus();
            }
        }

        /* ================================================================
           Campaign checkbox dropdown — chỉ chạy ở edit mode
           ================================================================ */
        function toggleCampPanel(e) {
            e.stopPropagation();
            var panel   = document.getElementById('campPanel');
            var chevron = document.getElementById('campChevron');
            if (!panel) return;
            var isOpen = panel.style.display !== 'none';
            panel.style.display     = isOpen ? 'none' : 'block';
            chevron.style.transform = isOpen ? 'rotate(0deg)' : 'rotate(180deg)';
        }

        /* Đóng panel khi click ra ngoài */
        document.addEventListener('click', function (e) {
            var wrap = document.querySelector('.camp-wrap');
            if (!wrap || wrap.contains(e.target)) return;
            var panel   = document.getElementById('campPanel');
            var chevron = document.getElementById('campChevron');
            if (panel)   panel.style.display     = 'none';
            if (chevron) chevron.style.transform = 'rotate(0deg)';
        });

        function onCampCb(cb) {
            var item = cb.closest('.camp-item');
            if (item) {
                item.style.background = cb.checked ? 'rgba(13,110,253,.08)' : 'transparent';
            }
            refreshCampBtn();
        }

        function selectAllCamps() {
            document.querySelectorAll('.camp-cb').forEach(function (cb) {
                cb.checked = true;
                var item = cb.closest('.camp-item');
                if (item) item.style.background = 'rgba(13,110,253,.08)';
            });
            refreshCampBtn();
        }

        function deselectAllCamps() {
            document.querySelectorAll('.camp-cb').forEach(function (cb) {
                cb.checked = false;
                var item = cb.closest('.camp-item');
                if (item) item.style.background = 'transparent';
            });
            refreshCampBtn();
        }

        function refreshCampBtn() {
            var txt = document.getElementById('campBtnText');
            if (!txt) return;
            var count = document.querySelectorAll('.camp-cb:checked').length;
            txt.innerHTML = count > 0
                ? 'Selected <strong>' + count + '</strong> campaign'
                : '-- No Campaign Selected --';
        }
    </script>
</div>
