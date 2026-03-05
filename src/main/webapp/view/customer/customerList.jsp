<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="content mt-5">
    <h1>Customer Center</h1>
    <div class="sub">Managing ${totalRecord} customers & body profiles</div>

    <div class="top-bar">
        <div class="filter-section">
            <div>
                <div class="search-box">
                    <input type="text" id="searchInput" placeholder="Search by name, phone, or style..." />
                    <button class="btn btn-filter" onclick="applyFilters()">Filter</button>
                </div>
            </div>

            <div class="filter-buttons">
                <button class="filter-btn gold-members" onclick="toggleFilterTag('GOLD')">Gold Members</button>
                <button class="filter-btn high-return" onclick="toggleFilterTag('HIGH_RETURN')">High Return</button>
                <button class="filter-btn advanced" onclick="openAdvancedFilter()"><i class="fas fa-sliders-h"></i> Advanced</button>
            </div>
        </div>

        <div style="display:flex;align-items:center;gap:12px;flex-direction:column;">
            <div style="display:flex;gap:8px;flex-wrap:wrap; order:2;">
                <label style="font-weight:600;margin-right:6px;">Rows per page:</label>
                <select id="rowsPerPage" class="form-select form-select-sm" style="width:auto;">
                    <option value="5">5</option>
                    <option value="10" selected>10</option>
                    <option value="15">15</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option value="all">All</option>
                </select>
            </div>

            <button class="btn btn-add" style="order:1;"><a href="${pageContext.request.contextPath}/customers/add-customer">+ Add New Customer</a></button>
        </div>
    </div>

    <div class="card" id="customerTable">
        <table>
            <thead>
                <tr>
                    <th>Customer</th>
                    <th>Loyalty & RFM</th>
                    <th>Fit Profile</th>
                    <th>Styles</th>
                    <th>Return Rate</th>
                    <th>Last Purchase</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="customerTableBody">
                <c:forEach var="c" items="${customerList}">
                    <tr class="card-body-row">

                        <td class="customer-info">
                            <div class="avatar">
                                <c:if test="${not empty c.name}">
                                    ${fn:toUpperCase(fn:substring(c.name,0,1))}
                                </c:if>
                            </div>
                            <div>
                                <div onclick="viewCustomer(${c.customerId})" style="cursor:pointer;"><strong>${c.name}</strong></div>
                                <div class="muted">${c.phone}</div>
                            </div>
                        </td>

                        <td>
                            <span class="loyalty-badge
                                  <c:choose>
                                      <c:when test="${c.loyaltyTier == 'PLATINUM'}">platinum</c:when>
                                      <c:when test="${c.loyaltyTier == 'GOLD'}">gold</c:when>
                                      <c:when test="${c.loyaltyTier == 'SILVER'}">silver</c:when>
                                      <c:when test="${c.loyaltyTier == 'BRONZE'}">bronze</c:when>
                                      <c:when test="${c.loyaltyTier == 'BLACKLIST'}">blacklist</c:when>
                                  </c:choose>">
                                ${c.loyaltyTier}
                            </span>

                            <div class="muted table_rfm_score">RFM Score: ${c.rfmScore}</div>
                        </td>

                        <td>
                            <div><strong>${c.preferredSize}</strong></div>
                            <div class="muted">${c.bodyShape}</div>
                        </td>

                        <td class="tags">
                            <c:forEach items="${c.styleTags}" var="tag" begin="0" end="1">
                                <span class="tag">${tag}</span>
                            </c:forEach>
                        </td>

                        <td>
                            <div>${c.returnRate}%</div>
                            <div class="progress">
                                <div class="progress-bar
                                     <c:if test="${c.returnRate > 30}">high-return</c:if>"
                                     style="width:${c.returnRate}%">
                                </div>
                            </div>
                        </td>

                        <td>${c.lastPurchase}</td>


                        <td class="actions">
                            <button class="action-icon-btn view-btn" title="View Details" onclick="viewCustomer(${c.customerId})">
                                <i class="fa-solid fa-arrow-up-right-from-square"></i>
                            </button>

                            <button class="action-icon-btn edit-btn" title="Edit" onclick="editCustomer(${c.customerId})>
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
                                    <div class="action-menu-item upgrade-item" onclick="upgradeCustomer(${c.customerId})">
                                        <i class="fa-solid fa-angles-up"></i>
                                        <span>Upgrade Level</span>
                                    </div>
                                    <div class="action-menu-divider"></div>
                                    <div class="action-menu-item delete-item" onclick="deleteCustomer(${c.customerId})">
                                        <i class="fa-regular fa-trash-can"></i>
                                        <span>Delete</span>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td style="display: none;">${c.email}</td>
                        <td style="display: none;">${c.gender}</td>
                        <td style="display: none;">${c.height}</td>
                        <td style="display: none;">${c.weight}</td>
                    </tr> 
                </c:forEach>
            </tbody>


        </table>
        <!-- pagination controls -->
        <div id="paginationControls" style="margin-top:16px;display:flex;gap:8px;justify-content:center;">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <button onclick="loadPage(${i})" class="btn btn-light ${i == currentPage ? 'active' : ''}"> 
                    ${i}
                </button> 
            </c:forEach>
        </div>
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
    <div id="advancedFilterModal" class="modal">
        <div class="modal-content">

            <div class="modal-header">
                <h2><i class="fas fa-sliders-h" style="font-size:13px;opacity:.7;margin-right:6px;"></i>Advanced Filter</h2>
                <span class="close-btn" onclick="closeAdvancedFilter()">&#x2715;</span>
            </div>

            <div class="form-section">

                <!-- Loyalty Tier -->
                <div class="input-group">
                    <label>&#x1F451; Loyalty Tier</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-tier="platinum">
                            <input type="checkbox" name="loyaltyFilter" value="PLATINUM" />
                            Platinum
                        </label>
                        <label class="checkbox-item" data-tier="gold">
                            <input type="checkbox" name="loyaltyFilter" value="GOLD" />
                            Gold
                        </label>
                        <label class="checkbox-item" data-tier="silver">
                            <input type="checkbox" name="loyaltyFilter" value="SILVER" />
                            Silver
                        </label>
                        <label class="checkbox-item" data-tier="bronze">
                            <input type="checkbox" name="loyaltyFilter" value="BRONZE" />
                            Bronze
                        </label>
                        <label class="checkbox-item" data-tier="blacklist">
                            <input type="checkbox" name="loyaltyFilter" value="BLACKLIST" />
                            Blacklist
                        </label>
                    </div>
                </div>

                <!-- Body Shape -->
                <div class="input-group">
                    <label>&#x1F9CD; Body Shape</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="HOURGLASS" />
                            &#x231B; Hourglass
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="PEAR" />
                            &#x1F350; Pear
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="APPLE" />
                            &#x1F34E; Apple
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="RECTANGLE" />
                            &#x25AC; Rectangle
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="INVERTED TRIANGLE" />
                            &#x25BD; Inv. Triangle
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="bodyShapeFilter" value="SLENDER" />
                            &#x2736; Slender
                        </label>
                    </div>
                </div>

                <!-- Preferred Size -->
                <div class="input-group">
                    <label>&#x1F3F7; Preferred Size</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item">
                            <input type="checkbox" name="sizeFilter" value="S" />
                            S
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="sizeFilter" value="M" />
                            M
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="sizeFilter" value="L" />
                            L
                        </label>
                        <label class="checkbox-item">
                            <input type="checkbox" name="sizeFilter" value="XL" />
                            XL
                        </label>
                    </div>
                </div>

                <!-- Return Rate -->
                <div class="input-group">
                    <label>&#x21BA; Return Rate</label>
                    <div class="checkbox-group">
                        <label class="checkbox-item" data-return="HIGH">
                            <input type="checkbox" name="returnRateFilter" value="HIGH" />
                            High &gt; 40%
                        </label>
                        <label class="checkbox-item" data-return="NORMAL">
                            <input type="checkbox" name="returnRateFilter" value="NORMAL" />
                            Normal &#x2264; 40%
                        </label>
                    </div>
                </div>

                <!-- Style Tags -->
                <div class="input-group">
                    <label>&#x1F3A8; Style Tags</label>
                    <div class="checkbox-group">
                        <table>
                            <c:forEach items="${styleTagList}" var="style" varStatus="loop">

                                <c:if test="${loop.index % 4 == 0}">
                                    </tr>
                                </c:if>

                                <td style="height: 15px; padding: 3px 0;">
                                    <label class="checkbox-item">
                                        <input type="checkbox" name="styleTagFilter" value="${style.tagId}" />
                                        ${style.tagName}
                                    </label>
                                </td>
                                <c:if test="${loop.index % 4 == 3}">
                                    </tr>
                                </c:if>

                            </c:forEach>

                            <!-- Nếu tổng số item không chia hết cho 4 thì đóng tr cuối -->
                            <c:if test="${styleTagList.size() % 4 != 0}">
                                </tr>
                            </c:if>
                        </table>
                    </div>
                </div>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="resetAdvancedFilter()">&#x21BA; Reset</button>
                <button type="button" class="btn-cancel" onclick="closeAdvancedFilter()">Cancel</button>
                <button type="button" class="btn-save" onclick="applyAdvancedFilter()">
                    <i class="fas fa-check" style="font-size:11px;margin-right:5px;"></i>Apply Filter
                </button>
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


    <script>
        window.__PAGE_STATUS__ = "<c:out value='${param.status}' default='' />";
        window.__CTX__ = "${pageContext.request.contextPath}";
    </script>

