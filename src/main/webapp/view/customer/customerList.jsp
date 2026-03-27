<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-users me-2"></i>Customer Center</h4>
                <p class="text-muted mb-0">List, search, and manage customers within the system.</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-primary" id="assign-segment-btn">
                    <i class="fas fa-folder-plus me-1"></i> Assign Segment
                </button>
                <a href="${pageContext.request.contextPath}/customers/add-customer"
                   class="btn btn-primary">
                    <i class="fas fa-plus-circle me-1"></i> Add New Customer
                </a>
            </div>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-1"></i> <strong>Thành công!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-1"></i> <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="card shadow-sm mb-4 filter-card">
            <div class="card-body">
                <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Search (name, phone)</label>
                        <input type="text" class="form-control" id="searchInput"
                               placeholder="Search by name, phone..."
                               <c:if test="${not empty keyword}">value="${keyword}"</c:if> />
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">Loyalty Tier</label>
                        <select class="form-select loyaltyFilter" name="loyaltyFilter">
                            <option value="ALL" selected>-- All --</option>
                            <option value="DIAMOND" <c:if test="${loyaltyFilterSelected eq 'DIAMOND'}">selected</c:if>>
                                Diamond
                            </option>
                            <option value="PLATINUM"
                                    <c:if test="${loyaltyFilterSelected eq 'PLATINUM'}">selected</c:if>>Platinum
                            </option>
                            <option value="GOLD" <c:if test="${loyaltyFilterSelected eq 'GOLD'}">selected</c:if>>Gold
                            </option>
                            <option value="SILVER" <c:if test="${loyaltyFilterSelected eq 'SILVER'}">selected</c:if>>
                                Silver
                            </option>
                            <option value="BRONZE" <c:if test="${loyaltyFilterSelected eq 'BRONZE'}">selected</c:if>>
                                Bronze
                            </option>
                            <option value="BLACKLIST"
                                    <c:if test="${loyaltyFilterSelected eq 'BLACKLIST'}">selected</c:if>>Blacklist
                            </option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">Source</label>
                        <select class="form-select source" name="source">
                            <option value="ALL" selected>-- All --</option>
                            <option value="Facebook" <c:if test="${sourceSelected eq 'Facebook'}">selected</c:if>>
                                Facebook
                            </option>
                            <option value="Instagram" <c:if test="${sourceSelected eq 'Instagram'}">selected</c:if>>
                                Instagram
                            </option>
                            <option value="Tiktok" <c:if test="${sourceSelected eq 'Tiktok'}">selected</c:if>>Tik Tok
                            </option>
                            <option value="LinkedIn" <c:if test="${sourceSelected eq 'LinkedIn'}">selected</c:if>>
                                LinkedIn
                            </option>
                            <option value="Referral" <c:if test="${sourceSelected eq 'Referral'}">selected</c:if>>
                                Referral
                            </option>
                            <option value="Website" <c:if test="${sourceSelected eq 'Website'}">selected</c:if>>
                                Website
                            </option>
                            <option value="Google" <c:if test="${sourceSelected eq 'Google'}">selected</c:if>>Google
                            </option>
                            <option value="Seminar" <c:if test="${sourceSelected eq 'Seminar'}">selected</c:if>>
                                Seminar
                            </option>
                            <option value="Email" <c:if test="${sourceSelected eq 'Email'}">selected</c:if>>Email
                                Campaign
                            </option>
                            <option value="Cold Call" <c:if test="${sourceSelected eq 'Cold Call'}">selected</c:if>>Cold
                                Call
                            </option>
                            <option value="Import" <c:if test="${sourceSelected eq 'Import'}">selected</c:if>>Import
                                File
                            </option>
                            <option value="Others" <c:if test="${sourceSelected eq 'Others'}">selected</c:if>>Others
                            </option>
                        </select>
                    </div>

                    <div class="col-md-2 d-flex align-items-end gap-2">
                        <button type="button" class="btn btn-primary w-100" onclick="filter()">
                            <i class="fas fa-search me-1"></i>
                        </button>
                        <a href="${pageContext.request.contextPath}/customers"
                           class="btn btn-outline-secondary w-100">
                            <i class="fas fa-redo me-1"></i> Reset
                        </a>
                    </div>

                    <div class="col-12 d-flex align-items-center gap-2 pt-1">
                        <button class="btn btn-outline-secondary btn-sm" onclick="openAdvancedFilter()">
                            <i class="fas fa-sliders-h me-1"></i> Advanced Filter
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Results -->
        <c:choose>

            <c:when test="${empty customerList}">
                <div class="alert alert-warning">
                    <i class="fas fa-search me-1"></i> No suitable customer found.
                </div>
            </c:when>

            <c:otherwise>

                <!-- Stats Banner -->
                <div class="card shadow-sm mb-3 border-0 stats-card bg-total-lead"
                     style="border-radius: 10px;">
                    <div class="card-body py-3 px-4">
                        <span class="fs-2 fw-bold text-white">${totalRecord}</span>
                        <span class="ms-2 text-white"> Customers</span>
                    </div>
                </div>

                <!-- Table -->
                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th style="width:50px;">
                                    <input type="checkbox" style="transform: scale(1.3);" class="check-all"/>
                                </th>
                                <th>#</th>
                                <th>Customer</th>
                                <th>Loyalty Tier</th>
                                <th>Email</th>
                                <th>Source</th>
                                <th>Last Purchase</th>
                                <th class="text-center">Action</th>
                            </tr>
                            </thead>
                            <tbody id="customerTableBody">
                            <c:forEach var="c" items="${customerList}" varStatus="loop">
                                <tr>
                                    <td>
                                        <input type="checkbox" style="transform: scale(1.3);" class="check-item"
                                               value="${c.customerId}"/>
                                    </td>
                                    <td class="text-muted">${loop.index + 1}</td>

                                    <td>
                                        <div onclick="viewCustomer(${c.customerId})" style="cursor:pointer;">
                                            <strong>${c.name}</strong>
                                        </div>
                                        <div class="text-muted small">${c.phone}</div>
                                    </td>

                                    <td>
                                        <span class="loyalty-badge
                                            <c:choose>
                                                <c:when test="${c.loyaltyTier == 'DIAMOND'}">diamond</c:when>
                                                <c:when test="${c.loyaltyTier == 'PLATINUM'}">platinum</c:when>
                                                <c:when test="${c.loyaltyTier == 'GOLD'}">gold</c:when>
                                                <c:when test="${c.loyaltyTier == 'SILVER'}">silver</c:when>
                                                <c:when test="${c.loyaltyTier == 'BRONZE'}">bronze</c:when>
                                                <c:when test="${c.loyaltyTier == 'BLACKLIST'}">blacklist</c:when>
                                            </c:choose>">
                                                ${c.loyaltyTier}
                                        </span>
                                    </td>

                                    <td>
                                        <span class="text-muted">${c.email}</span>
                                    </td>

                                    <td>${c.source}</td>

                                    <td>${c.lastPurchaseDate}</td>

                                    <td class="text-center">
                                        <button class="btn btn-sm btn-outline-info btn-action"
                                                title="View Details"
                                                onclick="viewCustomer(${c.customerId})">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="btn btn-sm btn-outline-warning ms-1 btn-action"
                                                title="Edit"
                                                onclick="editCustomer(${c.customerId})">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <div class="d-inline-block ms-1 action-wrapper">
                                            <button class="btn btn-sm btn-outline-secondary btn-action menu-btn"
                                                    title="More">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </button>
                                            <div class="action-menu" id="customerMenuAction-${c.customerId}">

                                                <div class="action-menu-item upgrade-item"
                                                     onclick="upgradeCustomer(${c.customerId})">
                                                    <i class="fa-solid fa-angles-up me-2"></i>Upgrade
                                                </div>
                                                <div class="action-menu-item downgrade-item"
                                                     onclick="downgradeCustomer(${c.customerId})">
                                                    <i class="fa-solid fa-angles-down me-2"></i>Downgrade
                                                </div>
                                                <div class="action-menu-item"
                                                     onclick="addDealCustomer(${c.customerId})">
                                                    <i class="fa-solid fa-handshake me-2"></i>Add Deal
                                                </div>
                                                <div class="action-menu-divider"></div>
                                                <div class="action-menu-item delete-item"
                                                     onclick="deleteCustomer(${c.customerId})">
                                                    <i class="fa-regular fa-trash-can me-2"></i>Delete
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <jsp:include page="/view/components/pagination.jsp"/>
                </div>

            </c:otherwise>

        </c:choose>

    </div>
</div>

<!-- Toast -->
<div id="toast" class="toast">
    <div class="toast-left">
        <div id="toastIcon" class="toast-icon"></div>
    </div>
    <div class="toast-content">
        <div id="toastMessage" class="toast-message"></div>
    </div>
    <button class="toast-close" id="toastCloseBtn">×</button>
    <div class="toast-progress">
        <div id="toastBar"></div>
    </div>
</div>

<!-- ADVANCED FILTER MODAL -->
<div id="advancedFilterModal" class="">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-sliders-h" style="font-size:20px;opacity:.7;margin-right:6px;"></i>Advanced Filter</h2>
            <span class="close-btn" style="font-size:20px;cursor:pointer;"
                  onclick="closeAdvancedFilter()">&#x2715;</span>
        </div>
        <div class="form-section">
            <!-- Loyalty Tier -->
            <div class="input-group">
                <label>&#x1F451; Loyalty Tier</label>
                <div class="checkbox-group">
                    <label class="checkbox-item" data-tier="diamond"><input type="checkbox" name="loyaltyFilter"
                                                                            value="DIAMOND"/> Diamond</label>
                    <label class="checkbox-item" data-tier="platinum"><input type="checkbox" name="loyaltyFilter"
                                                                             value="PLATINUM"/> Platinum</label>
                    <label class="checkbox-item" data-tier="gold"><input type="checkbox" name="loyaltyFilter"
                                                                         value="GOLD"/> Gold</label>
                    <label class="checkbox-item" data-tier="silver"><input type="checkbox" name="loyaltyFilter"
                                                                           value="SILVER"/> Silver</label>
                    <label class="checkbox-item" data-tier="bronze"><input type="checkbox" name="loyaltyFilter"
                                                                           value="BRONZE"/> Bronze</label>
                    <label class="checkbox-item" data-tier="blacklist"><input type="checkbox" name="loyaltyFilter"
                                                                              value="BLACKLIST"/> Blacklist</label>
                </div>
            </div>
            <!-- Sources -->
            <div class="input-group">
                <label>&#x1F4E5; Sources</label>
                <div class="checkbox-group">
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Facebook"/>
                        Facebook</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Instagram"/>
                        Instagram</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Tiktok"/> Tiktok</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="LinkedIn"/>
                        LinkedIn</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Referral"/>
                        Referral</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Website"/> Website</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Google"/> Google</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Seminar"/> Seminar</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Email"/> Email</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Cold Call"/> Cold
                        Call</label>
                    <label class="checkbox-item"><input type="checkbox" name="source" value="Import"/> Import</label>
                </div>
            </div>
            <!-- Gender -->
            <div class="input-group">
                <label>&#x26A5; Gender</label>
                <div class="checkbox-group">
                    <label class="checkbox-item" data-tier="male">&#x2642; <input type="radio" name="gender"
                                                                                  value="MALE"/> MALE</label>
                    <label class="checkbox-item" data-tier="female">&#x2640; <input type="radio" name="gender"
                                                                                    value="FEMALE"/> FEMALE</label>
                </div>
            </div>
            <!-- Timer -->
            <div class="group-condition">
                <label>&#x23F3; <strong>Timer Condition</strong></label>
                <div class="conditions"></div>
                <button class="add-condition">+ Add Condition</button>
                <template id="condition-template">
                    <div class="condition-row">
                        <select name="time_conditions">
                            <option value="last_purchase" selected>Last Purchase</option>
                            <option value="birth_day">Birth Day</option>
                        </select>
                        <select name="operators">
                            <option value="equal" selected>Equal</option>
                            <option value="before">Before</option>
                            <option value="after">After</option>
                        </select>
                        <input type="date" placeholder="Giá trị" name="dates">
                        <button class="delete" style="background-color:white;font-size:25px;border:none;">🗑</button>
                        <select class="sub-condition" name="subconditions">
                            <option value="and" selected>And</option>
                            <option value="or">Or</option>
                        </select>
                    </div>
                </template>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cancel btn-primary" onclick="resetAdvancedFilter()">&#x21BA; Reset</button>
            <button type="button" class=" btn btn-dark" onclick="closeAdvancedFilter()">Cancel</button>
            <button type="button" class="btn-save" onclick="applyAdvancedFilter()">
                <i class="fas fa-check" style="font-size:11px;margin-right:5px;"></i>Apply Filter
            </button>
        </div>
    </div>
</div>

<!-- Assign Segment Modal -->
<div id="segment-modal" class="modal">
    <div class="modal-content">
        <form method="post" action="${pageContext.request.contextPath}/customers/assign-segment">
            <div class="modal-header">
                <h3>Assign to Segment</h3>
                <span class="close-btn" onclick="closeSegmentModal()">&times;</span>
            </div>
            <div class="modal-body">
                <label>Choose Segment:</label>
                <div class="segment-list">
                    <c:forEach items="${segments}" var="s">
                        <div class="segment-item">
                            <input type="radio" name="segmentId" value="${s.segmentId}" id="seg-${s.segmentId}">
                            <label for="seg-${s.segmentId}" class="segment-card">
                                <span class="segment-name"><strong>${s.segmentName}</strong></span>
                                <p>${s.criteriaLogic}</p>
                            </label>
                        </div>
                    </c:forEach>
                </div>
                <input type="hidden" name="customerIds" id="customerIdsInput">
            </div>
            <div class="modal-footer">
                <button class="btn-success" type="submit">Assign</button>
                <button class="btn-primary" type="button" onclick="closeSegmentModal()">Cancel</button>
            </div>
        </form>
    </div>
</div>


<script>
    window.__PAGE_STATUS__ = "<c:out value='${param.status}' default='' />";
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.__SESSION_ID__ = "<c:out value='${sessionId}' default='' />";
    window.__TOTAL_PAGES__ = ${not empty totalPages ? totalPages : 1};
    window.__TOTAL_RECORDS__ = ${not empty totalRecord ? totalRecord : 0};
    window.__CURRENT_PAGE__ = ${not empty currentPage ? currentPage : 1};
</script>
