<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="content">
    <div class="d-flex align-items-center gap-3 list__header">
        <i class="fas fa-users"></i>
        <h1>Customer Center</h1>
    </div>
    <div class="sub">Managing ${totalRecord} customers & body profiles</div>

    <div style="position: absolute; right: 25px;
    top: 115px;">
        <button class="btn btn-add" style="order:1;"><a
                href="${pageContext.request.contextPath}/customers/add-customer">+ Add New Customer</a></button>
    </div>

    <div class="top-bar">
        <div class="filter-section">


            <div>

                <div class="search-box">
                    <label style="display: flex; gap: 5px; flex-direction: column">
                        <strong>Search by name, phone, or style: </strong>
                        <input type="text" id="searchInput" placeholder="Search by name, phone, or style..."
                               <c:if test="${not empty keyword}">value="${keyword}"</c:if>
                        />

                    </label>
                    <button class="btn btn-filter" onclick="search()">
                        <i class="fas fa-search"></i>
                        <span style="margin-left: 5px">Search</span>

                    </button>
                    <div style="position: absolute; right: 95px; top: 294.5px; border: 2px solid var(--border); ">
                        <a href="${pageContext.request.contextPath}/customers"
                           class="btn btn-outline-secondary w-100">
                            <i class="fas fa-redo me-1"></i> Reset
                        </a>
                    </div>

                </div>

                <div class="filter-buttons mt-3">
                    <label><strong>Loyalty Tier: </strong>
                        <select style="padding: 5px 10px; border-radius: 5px; margin-left: 9px" name="loyaltyFilter"
                                class="loyaltyFilter">
                            <option value="ALL" selected>All</option>
                            <option value="DIAMOND"
                                    <c:if test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'DIAMOND'}">selected</c:if>>
                                Diamond
                            </option>
                            <option value="PLATINUM"
                                    <c:if test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'PLATINUM'}">selected</c:if>>
                                Platinum
                            </option>
                            <option value="GOLD"
                                    <c:if
                                            test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'GOLD'}">selected</c:if>>
                                Gold
                            </option>
                            <option value="SILVER"
                                    <c:if test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'SILVER'}">selected</c:if>>
                                Silver
                            </option>
                            <option value="BRONZE"
                                    <c:if test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'BRONZE'}">selected</c:if>>
                                Bronze
                            </option>
                            <option value="BLACKLIST"
                                    <c:if test="${not empty loyaltyFilterSelected && loyaltyFilterSelected eq 'BLACKLIST'}">selected</c:if>>
                                Blacklist
                            </option>
                        </select>
                    </label>

                    <label style="margin-left: 20px"><strong>Source: </strong>
                        <select style="padding: 5px 10px; border-radius: 5px; margin-left: 9px" name="source"
                                class="source">
                            <option value="ALL" selected>All</option>
                            <option value="Facebook"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Facebook'}">selected
                            </c:if>>Facebook
                            </option>
                            <option value="Instagram"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Instagram'}">selected</c:if>>
                                Instagram
                            </option>
                            <option value="Tiktok"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Tiktok'}">selected
                            </c:if>>Tik Tok
                            </option>
                            <option value="LinkedIn"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'LinkedIn'}">selected
                            </c:if>>LinkedIn
                            </option>
                            <option value="Referral"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Referral'}">selected
                            </c:if>>Referral
                            </option>
                            <option value="Website"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Website'}">selected
                            </c:if>>Website
                            </option>
                            <option value="Google"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Google'}">selected
                            </c:if>>Google
                            </option>
                            <option value="Seminar" <c:if test="${not empty sourceSelected && sourceSelected eq
                            'Seminar'}">selected
                            </c:if>>Seminar
                            </option>
                            <option value="Email" <c:if test="${not empty sourceSelected && sourceSelected eq
                            'Email'}">selected
                            </c:if>>Email Campaign
                            </option>
                            <option value="Cold Call"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Cold Call'}">selected
                            </c:if>>Cold Call
                            </option>
                            <option value="Import"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Import'}">selected
                            </c:if>>Import File
                            </option>
                            <option value="Others"
                                    <c:if test="${not empty sourceSelected && sourceSelected eq 'Others'}">selected
                            </c:if>>Others
                            </option>
                        </select>
                    </label>

                    <label style="margin-left: 20px"><strong>Return Rate: </strong></label>
                    <button name="returnRateFilter" class="btn-high-return btn btn-return-rate <c:if test="${not
                        empty returnRateFilter && returnRateFilter eq 'HIGH'}">btn-primary</c:if>"
                            style="margin-left: 9px">High Return ( >40% )
                    </button>
                    <button name="returnRateFilter" class="btn-low-return btn btn-return-rate <c:if test="${not
                        empty returnRateFilter && returnRateFilter eq 'LOW'}">btn-primary</c:if>"
                            style="margin-left: 9px">Low Return (<= 40%)
                    </button>


                    <button class="advance-filter btn-filter btn-primary" style="margin-top: -122px;transform: translate(50px, -3px);"
                            onclick="openAdvancedFilter()">
                        <i class="fas fa-sliders-h"></i>
                        <span>Advanced Filter</span>
                    </button>

                    <button class="btn-filter" onclick="filter()"
                            style="margin-top: 2px; transform: translateX(-175px);">
                        <i class="fas fa-filter" style="margin-right: 5px;"></i>
                        <span>Filter</span>
                    </button>

                    <button class="btn btn-segment" id="assign-segment-btn"
                    >
                        <i class="fas fa-folder-plus"></i>
                        <span>Assign Segment</span>
                    </button>

                    <button class="btn btn-assign-task"
                            onclick="assignTask()">
                        <i class="fas fa-user-plus"></i>
                        <span>Assign Task</span>
                    </button>
                </div>


            </div>

        </div>


    </div>

    <div class="card" id="customerTable">
        <table>
            <thead>
            <tr>
                <th>
                    <input type="checkbox" style="transform: scale(1.3);" class="check-all"
                    />
                </th>
                <th>Customer</th>
                <th>Loyalty & RFM</th>
                <th>Email</th>
                <th>Source</th>
                <th>Return Rate</th>
                <th>Last Purchase</th>
                <th></th>
            </tr>
            </thead>
            <tbody id="customerTableBody">
            <c:if test="${empty customerList}">
                <div class="alert alert-warning">
                    <i class="fas fa-search me-1"></i> No suitable customer found.
                </div>
            </c:if>
            <c:if test="${not empty customerList}">
                <c:forEach var="c" items="${customerList}">
                    <tr class="card-body-row">
                        <td style="padding: 20px">
                            <input type="checkbox" style="transform: scale(1.3);" class="check-item"
                                   value="${c.customerId}"/>
                        </td>

                        <td class="customer-info">

                            <div>
                                <div onclick="viewCustomer(${c.customerId})" style="cursor:pointer;">
                                    <strong>${c.name}</strong></div>
                                <div class="muted">${c.phone}</div>
                            </div>
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
                            <div class="muted">${c.email}</div>
                        </td>

                        <td class="tags">
                            <div>${c.source}</div>
                        </td>

                        <td>
                            <div>${c.returnRate}%</div>
                            <div class="progress">
                                <div class="progress-bar
                                     <c:if test="${c.returnRate > 40}">high-return</c:if>"
                                     style="width:${c.returnRate}%">
                                </div>
                            </div>
                        </td>

                        <td>
                                ${c.lastPurchaseDate}
                        </td>


                        <td class="actions">
                            <button class="action-icon-btn view-btn" title="View Details"
                                    onclick="viewCustomer(${c.customerId})">
                                <i class="fa-solid fa-arrow-up-right-from-square"></i>
                            </button>

                            <button class="action-icon-btn edit-btn" title="Edit"
                                    onclick="editCustomer(${c.customerId})">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <div class="action-wrapper">
                                <button class="action-icon-btn menu-btn">
                                    <i class="fa-solid fa-ellipsis"></i>
                                </button>
                                <div class="action-menu" id="customerMenuAction">
                                    <div class="action-menu-item" onclick="openPreview(${c.customerId})">
                                        <i class="fa-regular fa-id-card"></i>
                                        <span>Preview</span>
                                    </div>
                                    <div class="action-menu-item upgrade-item"
                                         onclick="upgradeCustomer(${c.customerId})">
                                        <i class="fa-solid fa-angles-up"></i>
                                        <span>Upgrade</span>
                                    </div>
                                    <div class="action-menu-item downgrade-item"
                                         onclick="downgradeCustomer(${c.customerId})">
                                        <i class="fa-solid fa-angles-down"></i>
                                        <span>Downgrade</span>
                                    </div>
                                    <div class="action-menu-item downgrade-item"
                                         onclick="downgradeCustomer(${c.customerId})">
                                        <i class="fa-solid fa-handshake"></i>
                                        <span>Add Deal</span>
                                    </div>
                                    <div class="action-menu-divider"></div>
                                    <div class="action-menu-item delete-item" onclick="deleteCustomer(${c.customerId})">
                                        <i class="fa-regular fa-trash-can"></i>
                                        <span>Delete</span>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </c:if>
            </tbody>


        </table>
        <!-- pagination controls -->
        <jsp:include page="/view/components/pagination.jsp"/>
    </div>

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
                <h2><i class="fas fa-sliders-h"
                       style="font-size:20px;opacity:.7;margin-right:6px;"></i>
                    Advanced Filter
                </h2>
                <span class="close-btn" style="font-size: 20px; cursor: pointer" onclick="closeAdvancedFilter()">&#x2715;
                </span>
            </div>

            <div class="form-section">

                <!-- Loyalty Tier -->
                <div class="input-group">
                    <label>&#x1F451; Loyalty Tier</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-tier="diamond">
                            <input type="checkbox" name="loyaltyFilter" value="DIAMOND"/>
                            Diamond
                        </label>
                        <label class="checkbox-item" data-tier="platinum">
                            <input type="checkbox" name="loyaltyFilter" value="PLATINUM"/>
                            Platinum
                        </label>
                        <label class="checkbox-item" data-tier="gold">
                            <input type="checkbox" name="loyaltyFilter" value="GOLD"/>
                            Gold
                        </label>
                        <label class="checkbox-item" data-tier="silver">
                            <input type="checkbox" name="loyaltyFilter" value="SILVER"/>
                            Silver
                        </label>
                        <label class="checkbox-item" data-tier="bronze">
                            <input type="checkbox" name="loyaltyFilter" value="BRONZE"/>
                            Bronze
                        </label>
                        <label class="checkbox-item" data-tier="blacklist">
                            <input type="checkbox" name="loyaltyFilter" value="BLACKLIST"/>
                            Blacklist
                        </label>
                    </div>
                </div>

                <!--  -->
                <div class="input-group">
                    <label>
                        &#x1F4E5;
                        <span>Sources</span>
                    </label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-tier="facebook">
                            <input type="checkbox" name="source" value="Facebook"/>
                            Facebook
                        </label>
                        <label class="checkbox-item" data-tier="instagram">
                            <input type="checkbox" name="source" value="Instagram"/>
                            Instagram
                        </label>
                        <label class="checkbox-item" data-tier="tiktok">
                            <input type="checkbox" name="source" value="Tiktok"/>
                            Tiktok
                        </label>
                        <label class="checkbox-item" data-tier="linkedIn">
                            <input type="checkbox" name="source" value="LinkedIn"/>
                            LinkedIn
                        </label>
                        <label class="checkbox-item" data-tier="referral">
                            <input type="checkbox" name="source" value="Referral"/>
                            Referral
                        </label>
                        <label class="checkbox-item" data-tier="website">
                            <input type="checkbox" name="source" value="Website"/>
                            Website
                        </label>
                        <label class="checkbox-item" data-tier="google">
                            <input type="checkbox" name="source" value="Google"/>
                            Google
                        </label>
                        <label class="checkbox-item" data-tier="seminar">
                            <input type="checkbox" name="source" value="Seminar"/>
                            Seminar
                        </label>
                        <label class="checkbox-item" data-tier="email">
                            <input type="checkbox" name="source" value="Email"/>
                            Email
                        </label>
                        <label class="checkbox-item" data-tier="coldcall">
                            <input type="checkbox" name="source" value="Cold Call"/>
                            Cold Call
                        </label>
                        <label class="checkbox-item" data-tier="import">
                            <input type="checkbox" name="source" value="Import"/>
                            Import
                        </label>
                    </div>
                </div>

                <!-- Gender  -->
                <div class="input-group">
                    <label>&#x26A5; Gender</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-tier="male">&#x2642;
                            <input type="radio" name="gender" value="MALE"/>
                            MALE
                        </label>
                        <label class="checkbox-item" data-tier="female">&#x2640;
                            <input type="radio" name="gender" value="FEMALE"/>
                            FEMALE
                        </label>
                    </div>
                </div>

                <!-- Return Rate -->
                <div class="input-group">
                    <label>&#x21BA; Return Rate</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-tier="high">
                            <input type="radio" name="returnRateFilter" value="HIGH"/>
                            HIGH
                        </label>
                        <label class="checkbox-item" data-tier="low">
                            <input type="radio" name="returnRateFilter" value="LOW"/>
                            LOW
                        </label>
                    </div>
                </div>

                <!-- Timer -->
                <div class="group-condition">
                    <label>&#x23F3; <strong>Timer Condition</strong></label>

                    <div class="conditions"></div>

                    <button class="add-condition">+ Add Condition</button>

                    <!-- template điều kiện -->
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

                            <button class="delete" style="background-color: white; font-size: 25px; border: none">🗑
                            </button>
                            <select class="sub-condition" name="subconditions">
                                <option value="and" selected>And</option>
                                <option value="or">Or</option>
                            </select>

                        </div>

                    </template>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="resetAdvancedFilter()">&#x21BA;
                    Reset
                </button>
                <button type="button" class="btn-cancel" onclick="closeAdvancedFilter()">Cancel</button>
                <button type="button" class="btn-save" onclick="applyAdvancedFilter()">
                    <i class="fas fa-check" style="font-size:11px;margin-right:5px;"></i>Apply Filter
                </button>
            </div>
        </div>


    </div>

    <div id="segment-modal" class="modal">
        <div class="modal-content">

            <form method="post" action="${pageContext.request.contextPath}/customers/assign-segment">

                <!-- HEADER -->
                <div class="modal-header">
                    <h3>Assign to Segment</h3>
                    <span class="close-btn" onclick="closeSegmentModal()">&times;</span>
                </div>

                <!-- BODY -->
                <div class="modal-body">

                    <label>Chọn Segment:</label>

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

                    <!-- hidden customerIds -->
                    <input type="hidden" name="customerIds" id="customerIdsInput">

                </div>

                <!-- FOOTER -->
                <div class="modal-footer">
                    <button class="btn-success" type="submit">Assign</button>
                    <button class="btn-primary" type="button" onclick="closeSegmentModal()">Cancel</button>
                </div>

            </form>

        </div>
    </div>
</div>


<div id="customerPreview" class="preview-panel">
    <div class="preview-content">

        <div class="preview-header">
            <h3>Customer Preview</h3>
            <span class="close-preview" onclick="closePreview()">✕</span>
        </div>

        <div class="preview-body" id="previewViewMode">
            <div class="preview-section">
                <h4>Basic Information</h4>
                <div class="preview-grid">
                    <div class="preview-item">
                        <span class="preview-label">Name</span>
                        <span id="previewName" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Phone</span>
                        <span id="previewPhone" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Email</span>
                        <span id="previewEmail" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Gender</span>
                        <span id="previewGender" class="preview-value">-</span>
                    </div>
                </div>
            </div>

            <div class="preview-section">
                <h4>Fit Profile</h4>
                <div class="preview-grid">
                    <div class="preview-item">
                        <span class="preview-label">Preferred Size</span>
                        <span id="previewSize" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Body Shape</span>
                        <span id="previewBodyShape" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Height (cm)</span>
                        <span id="previewHeight" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Weight (kg)</span>
                        <span id="previewWeight" class="preview-value">-</span>
                    </div>
                </div>
            </div>

            <div class="preview-section">
                <h4>Customer Status</h4>
                <div class="preview-grid">
                    <div class="preview-item">
                        <span class="preview-label">Loyalty Tier</span>
                        <span id="previewLoyalty" class="preview-value loyalty-badge">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">RFM Score</span>
                        <span id="previewRFM" class="preview-value">-</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Return Rate</span>
                        <span id="previewReturnRate" class="preview-value">-</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- hidden customerIds -->
<input type="hidden" name="customerIds" id="customerIdsInput">

</div>


<script>
    window.__PAGE_STATUS__ = "<c:out value='${param.status}' default='' />";
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.__SESSION_ID__ = "<c:out value='${sessionId}' default='' />";
    window.__TOTAL_PAGES__ = ${not empty totalPages ? totalPages : 1};
    window.__TOTAL_RECORDS__ = ${not empty totalRecord ? totalRecord : 0};
    window.__CURRENT_PAGE__ = ${not empty currentPage ? currentPage : 1};
</script>

