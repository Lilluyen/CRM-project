<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
            
            <div class="row">
                <div class="col-2">
                    
                </div>

                <div class="content col-10 mt-5">
                    <h1>Customer Center</h1>
                    <div class="sub">Managing ${fn:length(customerList)} customers & body profiles</div>

                    <div class="top-bar">
                        <div class="filter-section">
                            <div>
                                <div class="search-box">
                                    <input type="text" id="searchInput" placeholder="Search by name, phone, or style..." />
                                    <button class="btn btn-filter" onclick="applyFilters()">Filter</button>
                                </div>
                            </div>

                            <div class="filter-buttons">
                                <button class="filter-btn" onclick="toggleFilterTag('GOLD')">Gold Members</button>
                                <button class="filter-btn" onclick="toggleFilterTag('HIGH_RETURN')">High Return</button>
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

                            <button class="btn btn-add" onclick="openAddCustomerModal()" style="order:1;">+ Add New Customer</button>
                        </div>
                    </div>

                    <div class="card">
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
                            <tbody>
                                <c:forEach var="c" items="${customerList}">
                                    <tr class="card-body-row">

                                        <td class="customer-info">
                                            <div class="avatar">
                                                <c:if test="${not empty c.name}">
                                                    ${fn:toUpperCase(fn:substring(c.name,0,1))}
                                                </c:if>
                                            </div>
                                            <div>
                                                <div><strong>${c.name}</strong></div>
                                                <div class="muted">${c.phone}</div>
                                            </div>
                                        </td>

                                        <td>
                                            <span class="loyalty-badge
                                                  <c:choose>
                                                      <c:when test="${c.loyaltyTier == 'GOLD'}">gold</c:when>
                                                      <c:when test="${c.loyaltyTier == 'BLACKLIST'}">blacklist</c:when>
                                                  </c:choose>">
                                                ${c.loyaltyTier}
                                            </span>
                                            <div class="muted">RFM Score: ${c.rfmScore}</div>
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
                                            <i class="fa-regular fa-eye" title="View Details" onclick="viewCustomer(${c.customerId})"></i>
                                            <div class="action-wrapper">
                                                <i class="fa-solid fa-ellipsis-vertical"
                                                   onclick="toggleMenu(this)"></i>

                                                <div class="action-menu">
                                                    <div onclick="openPreview(${c.customerId})">Preview</div>
                                                    <div onclick="deleteCustomer(${c.customerId})">Delete</div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr> 
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- pagination controls -->
                    <div id="paginationControls" style="margin-top:16px;display:flex;gap:8px;justify-content:center;"></div>

                    <!-- MODAL -->
                    <div id="customerModal" class="modal">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h2>New Customer Profile</h2>
                                <span class="close-btn" onclick="toggleModal()">&times;</span>
                            </div>

                            <form id="addCustomerForm" method="post" action="${pageContext.request.contextPath}/customers/add-customer">

                                <div class="form-section">
                                    <h3><i class="fas fa-id-card"></i> Basic Information</h3>
                                    <div class="grid-2">
                                        <div class="input-group">
                                            <label>Full Name *</label>
                                            <input type="text" name="name" placeholder="Ex: Nguyen Lan Anh" required />
                                        </div>

                                        <div class="input-group">
                                            <label>Phone Number *</label>
                                            <input type="tel" name="phone" placeholder="Ex: 0901234567" required />
                                        </div>

                                        <div class="input-group">
                                            <label>Gender *</label>
                                            <select name="gender" required>
                                                <option value="">Select gender</option>
                                                <option value="MALE">Male</option>
                                                <option value="FEMALE">Female</option>
                                                <option value="OTHER">Other</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="grid-2">
                                        <div class="input-group">
                                            <label>Email</label>
                                            <input type="email" name="email" placeholder="example@gmail.com" />
                                        </div>

                                        <div class="input-group">
                                            <label>Date of Birth</label>
                                            <input type="date" name="birthday" />
                                        </div>
                                    </div>

                                    <div class="input-group">
                                        <label>Social Link</label>
                                        <input type="text" name="socialLink" placeholder="Ex: Facebook / Instagram URL">
                                    </div>

                                    <div class="input-group">
                                        <label>Address</label>
                                        <input type="text" name="address" placeholder="Ex: 123 ABC Street, District 1">
                                    </div>
                                </div>

                                <div class="form-section">
                                    <h3><i class="fas fa-ruler-combined"></i> Fit Profile</h3>
                                    <div class="grid-3">
                                        <div class="input-group">
                                            <label>Height (cm)</label>
                                            <input type="number" name="height" placeholder="165"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Weight (kg)</label>
                                            <input type="number" name="weight" placeholder="55"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Preferred Size</label>
                                            <select name="preferred_size">
                                                <option value="S">Size S</option>
                                                <option value="M" selected>Size M</option>
                                                <option value="L">Size L</option>
                                                <option value="XL">Size XL</option>
                                            </select>
                                        </div>

                                        <div class="input-group">
                                            <label>Bust (cm)</label>
                                            <input type="number" name="bust" placeholder="85"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Waist (cm)</label>
                                            <input type="number" name="waist" placeholder="70"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Hips (cm)</label>
                                            <input type="number" name="hips" placeholder="90"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Shoulder (cm)</label>
                                            <input type="number" name="shoulder" placeholder="40"/>
                                        </div>

                                        <div class="input-group">
                                            <label>Body Shape</label>
                                            <select name="bodyShape">
                                                <option value="HOURGLASS">Hourglass</option>
                                                <option value="PEAR">Pear</option>
                                                <option value="APPLE">Apple</option>
                                                <option value="RECTANGLE">Rectangle</option>
                                                <option value="INVERTED_TRIANGLE">Inverted Triangle</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-section">
                                    <h3><i class="fas fa-tshirt"></i> Preferences & Style</h3>
                                    <div class="tag-selector">
                                        <c:forEach items="${styleTagList}" var="s" varStatus="loop">
                                            <label class="tag-item ${loop.index >= 10 ? 'extra-tag' : ''}">
                                                <input type="checkbox" name="styleTags" value="${s.tagId}" /> ${s.tagName}
                                            </label>
                                        </c:forEach>
                                    </div>
                                    <button type="button" id="toggleTags" class="see-more-btn">See more</button>
                                </div>

                                <div class="modal-footer">
                                    <button type="button" class="btn-cancel" onclick="toggleModal()">Cancel</button>
                                    <button type="submit" class="btn-save">Save Profile</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div id="toast" class="toast">
                        <div class="toast-left">
                            <div id="toastIcon" class="toast-icon"></div>
                        </div>

                        <div class="toast-content">
                            <div id="toastMessage" class="toast-message"></div>
                        </div>

                        <button class="toast-close" onclick="hideToast()">×</button>

                        <div class="toast-progress">
                            <div id="toastBar"></div>
                        </div>
                    </div>

                    <!-- ADVANCED FILTER MODAL -->
                    <div id="advancedFilterModal" class="modal">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h2>Advanced Filter</h2>
                                <span class="close-btn" onclick="closeAdvancedFilter()">&times;</span>
                            </div>

                            <div class="form-section">
                                <div class="input-group">
                                    <label>Loyalty Tier</label>
                                    <div class="checkbox-group">
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="loyaltyFilter" value="GOLD" />
                                            Gold
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="loyaltyFilter" value="SILVER" />
                                            Silver
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="loyaltyFilter" value="BRONZE" />
                                            Bronze
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="loyaltyFilter" value="BLACKLIST" />
                                            Blacklist
                                        </label>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label>Body Shape</label>
                                    <div class="checkbox-group">
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="bodyShapeFilter" value="HOURGLASS" />
                                            Hourglass
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="bodyShapeFilter" value="PEAR" />
                                            Pear
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="bodyShapeFilter" value="APPLE" />
                                            Apple
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="bodyShapeFilter" value="RECTANGLE" />
                                            Rectangle
                                        </label>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label>Preferred Size</label>
                                    <div class="checkbox-group">
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="sizeFilter" value="S" />
                                            Size S
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="sizeFilter" value="M" />
                                            Size M
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="sizeFilter" value="L" />
                                            Size L
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="sizeFilter" value="XL" />
                                            Size XL
                                        </label>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label>Return Rate</label>
                                    <div class="checkbox-group">
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="returnRateFilter" value="HIGH" />
                                            High (> 30%)
                                        </label>
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="returnRateFilter" value="NORMAL" />
                                            Normal (≤ 30%)
                                        </label>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label>Style Tags</label>
                                    <div class="checkbox-group checkbox-group-3">
                                        <c:forEach items="${styleTagList}" var="style">
                                            <label class="checkbox-item">
                                                <input type="checkbox" name="styleTagFilter" value="${style.tagName}" />
                                                ${style.tagName}
                                            </label>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn-cancel" onclick="resetAdvancedFilter()">Reset</button>
                                <button type="button" class="btn-cancel" onclick="closeAdvancedFilter()">Cancel</button>
                                <button type="button" class="btn-save" onclick="applyAdvancedFilter()">Apply Filter</button>
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
                   



                



