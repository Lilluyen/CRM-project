<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="customer-detail rank-${fn:toLowerCase(fn:replace(customerDetail.loyaltyTier, ' ', '-'))}">

    <!-- HEADER -->
    <div class="customer-detail__header">

        <div class="customer-detail__profile">
            <div class="customer-detail__avatar">
                ${customerDetail.name.substring(0,1)}
            </div>
            <div class="customer-detail__info">
                <h2 class="customer-detail__name">${customerDetail.name}</h2>
                <p class="customer-detail__meta">
                    ${customerDetail.phone} • ${customerDetail.email}
                </p>
                <p class="customer-detail__owner">
                    Owner: ${customerDetail.ownerName}
                </p>
            </div>
        </div>

        <div class="customer-detail__actions">
            <a href="${pageContext.request.contextPath}/customer-journey?type=customer&customerId=${customerDetail.customerId}"
               class="customer-detail__btn customer-detail__btn--outline">
                View Journey
            </a>
            <a href="${pageContext.request.contextPath}/customers/edit?customerId=${customerDetail.customerId}"
               class="customer-detail__btn customer-detail__btn--outline">
                Edit
            </a>

            <%-- Nút Merge with — mở modal tìm kiếm customer target --%>
            <button type="button"
                    class="customer-detail__btn customer-detail__btn--merge"
                    onclick="openMergeModal()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="18" cy="18" r="3"/>
                    <circle cx="6" cy="6" r="3"/>
                    <circle cx="6" cy="18" r="3"/>
                    <path d="M6 9v3a3 3 0 003 3h3"/>
                    <line x1="18" y1="9" x2="18" y2="15"/>
                </svg>
                Merge with...
            </button>

            <a style="display: none;" href="mailto:${customerDetail.email}"
               class="customer-detail__btn customer-detail__btn--primary">
                Send Email
            </a>
        </div>

    </div>

    <div class="customer-detail__body">

        <!-- SIDEBAR -->
        <div class="customer-detail__sidebar">

            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">Basic Information</h3>
                <div class="customer-detail__row">
                    <span>Gender</span>
                    <strong>${customerDetail.gender}</strong>
                </div>
                <div class="customer-detail__row">
                    <span>Birthday</span>
                    <strong>${customerDetail.birthday}</strong>
                </div>
                <div class="customer-detail__row">
                    <span>Address</span>
                    <strong>${customerDetail.address}</strong>
                </div>
                <div class="customer-detail__row">
                    <span>Source</span>
                    <strong>${customerDetail.source}</strong>
                </div>
            </div>
            <div class="customer-detail__card">
               
                <div class="d-flex align-items-center justify-content-between">
                    <h3 class="customer-detail__card-title">Deals (${totalDeals})</h3>
                    <a style="margin: 0 0 1.1rem;
                                padding-bottom: 0.75rem;" 
                    href="${pageContext.request.contextPath}/sale/deal/create?relatedId=${customerDetail.customerId}&relatedType=CUSTOMER">+ New</a>
                </div>

                <div class="customer-detail__deals">
                    <c:forEach items="${deals}" var="d">
                        <div class="customer-detail__row">
                            <a href="${pageContext.request.contextPath}/sale/deal/detail?id=${d.dealId}"><strong style="color: blue;">${d.dealName}</strong></a>
                            <span>Value: <fmt:formatNumber type="number" value="${d.actualValue}" maxFractionDigits="0"/>đ</span> 
                            
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">Style Preferences</h3>
                <div class="customer-detail__tags">
                    <c:forEach var="tag" items="${customerDetail.styleTags}">
                        <span class="customer-detail__tag">${tag.tagName}</span>
                    </c:forEach>
                    <c:if test="${empty customerDetail.styleTags}">
                        <span class="customer-detail__empty">No style tags</span>
                    </c:if>
                    <button type="button" class="customer-detail__add-tag"
                            onclick="toggleTagPicker()">+ Add Tag
                    </button>
                </div>
            </div>

            <%-- Merge Requests liên quan đến customer này --%>
            <c:if test="${not empty mergeRequests}">
                <div class="customer-detail__card">
                    <h3 class="customer-detail__card-title">Merge Requests</h3>
                    <div class="cd-merge-list">
                        <c:forEach items="${mergeRequests}" var="mr">
                            <a href="${pageContext.request.contextPath}/customers/merge-request/${mr.id}"
                               class="cd-merge-item">
                                <div class="cd-merge-item__info">
                                    <span class="cd-merge-item__role">
                                        <c:choose>
                                            <c:when test="${mr.sourceId == customerDetail.customerId}">Source</c:when>
                                            <c:otherwise>Target</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="cd-merge-item__id">Request #${mr.id}</span>
                                </div>
                                <span class="cd-merge-item__status cd-merge-item__status--${fn:toLowerCase(mr.status)}">
                                        ${mr.status}
                                </span>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

        </div>

        <!-- MAIN CONTENT -->
        <div class="customer-detail__main">

            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">Customer Metrics</h3>
                <div class="customer-detail__metrics">
                    <!-- <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Status</span>
                        <span class="customer-detail__metric-value customer-detail__badge">
                            ${customerDetail.status}
                        </span>
                    </div> -->
                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Loyalty Tier</span>
                        <span class="customer-detail__metric-value customer-detail__rank-pill">${customerDetail.loyaltyTier}</span>
                    </div>
                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Total Spent</span>
                        <span class="customer-detail__metric-value">${customerDetail.totalSpent}</span>
                    </div>
                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Last Purchase</span>
                        <span class="customer-detail__metric-value">${customerDetail.lastPurchaseDate}</span>
                    </div>
                </div>
            </div>

            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">Customer Report</h3>
                <div class="cd-report">
                    <div class="cd-report__tabs" role="tablist">
                        <button type="button" class="cd-report__tab" data-tab="growth">Growth</button>
                        <button type="button" class="cd-report__tab" data-tab="activities">Recent activities</button>
                        <button type="button" class="cd-report__tab" data-tab="contacts">Contacts</button>
                        <button type="button" class="cd-report__tab" data-tab="notes">Notes</button>
                    </div>

                    <div class="cd-report__content">
                        <div class="cd-report__panel" data-panel="growth">
                            <div class="cd-report__panel-header">
                                <div>
                                    <div class="cd-report__title">Customer growth</div>
                                    <div class="cd-report__subtitle">Cumulative spend from deals (by month)</div>
                                </div>
                            </div>
                            <div class="cd-report__chart-wrap">
                                <canvas id="growthChart" height="90"></canvas>
                            </div>
                        </div>

                        <div class="cd-report__panel" data-panel="activities">
                            <div class="cd-report__panel-header">
                                <div class="cd-report__title">Completed tasks</div>
                                <div class="cd-report__subtitle">Tasks with progress = 100</div>
                            </div>
                            <c:choose>
                                <c:when test="${empty completedTasks}">
                                    <div class="cd-report__empty">No completed tasks yet.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="cd-timeline">
                                        <c:forEach items="${completedTasks}" var="t">
                                            <div class="cd-timeline__item">
                                                <div class="cd-timeline__dot"></div>
                                                <div class="cd-timeline__body">
                                                    <div class="cd-timeline__title">${fn:escapeXml(t.title)}</div>
                                                    <div class="cd-timeline__meta">
                                                        <c:choose>
                                                            <c:when test="${not empty t.completedAt}">
                                                                ${t.completedAt}
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${t.updatedAt}
                                                            </c:otherwise>
                                                        </c:choose>
                                                        • Progress: ${t.progress}%
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="cd-report__panel" data-panel="contacts">
                            <div class="cd-report__panel-header">
                                <div class="cd-report__title">Contact tab</div>
                                <div class="cd-report__subtitle">All contacts of customer</div>
                            </div>
                            <c:choose>
                                <c:when test="${empty contacts}">
                                    <div class="cd-report__empty">No contacts found.</div>
                                </c:when>
                                <c:otherwise>
                                    <table class="cd-table">
                                        <thead>
                                        <tr>
                                            <th>Type</th>
                                            <th>Value</th>
                                            <th>Primary</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach items="${contacts}" var="c">
                                            <tr>
                                                <td>${c.type}</td>
                                                <td>${fn:escapeXml(c.value)}</td>
                                                <td>
                                                    <c:if test="${c.primary}">Yes</c:if>
                                                    <c:if test="${not c.primary}">No</c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="cd-report__panel" data-panel="notes">
                            <div class="cd-report__panel-header">
                                <div class="cd-report__title">Notes</div>
                                <div class="cd-report__subtitle">Create a note and view newest first</div>
                            </div>

                            <form class="cd-note-form" method="post" action="${pageContext.request.contextPath}/customers/detail">
                                <input type="hidden" name="action" value="addNote"/>
                                <input type="hidden" name="customerId" value="${customerDetail.customerId}"/>
                                <textarea name="note" rows="3" class="cd-note-form__textarea"
                                          placeholder="Write a note for this customer..."></textarea>
                                <div class="cd-note-form__actions">
                                    <button type="submit" class="cd-note-form__btn">Save note</button>
                                </div>
                            </form>

                            <c:choose>
                                <c:when test="${empty notes}">
                                    <div class="cd-report__empty">No notes yet.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="cd-notes">
                                        <c:forEach items="${notes}" var="n">
                                            <div class="cd-notes__item">
                                                <div class="cd-notes__meta">
                                                    <c:if test="${not empty n.createdAt}">${n.createdAt}</c:if>
                                                </div>
                                                <div class="cd-notes__text">${fn:escapeXml(n.note)}</div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>


    </div>

</div>

<!-- ══ TAG PICKER MODAL ══ -->
<div id="tagPicker" class="tag-picker hidden" onclick="handleTagPickerBackdrop(event)">
    <div class="tag-picker__dialog">
        <div class="tag-picker__header">
            <h3 class="tag-picker__title">Add Style Tags</h3>
            <button type="button" class="tag-picker__close" onclick="toggleTagPicker()" title="Close">✕</button>
        </div>
        <div class="tag-picker__body">
            <form action="${pageContext.request.contextPath}/add-tag" method="post">
                <input type="hidden" name="customerId" value="${customerDetail.customerId}"/>
                <div class="tag-picker__list">
                    <c:forEach var="tag" items="${allStyleTags}">
                        <label class="tag-picker__item">
                            <input type="checkbox" name="tagIds" value="${tag.tagId}"/>
                            <span>${tag.tagName}</span>
                        </label>
                    </c:forEach>
                </div>
                <div class="tag-picker__actions">
                    <button type="submit">Add</button>
                    <button type="button" onclick="toggleTagPicker()">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══ MERGE MODAL ══ -->
<div id="mergeModal" class="merge-modal" style="display:none">
    <div class="merge-modal__backdrop" onclick="closeMergeModal()"></div>
    <div class="merge-modal__dialog">

        <div class="merge-modal__header">
            <div class="merge-modal__header-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="18" cy="18" r="3"/>
                    <circle cx="6" cy="6" r="3"/>
                    <circle cx="6" cy="18" r="3"/>
                    <path d="M6 9v3a3 3 0 003 3h3"/>
                    <line x1="18" y1="9" x2="18" y2="15"/>
                </svg>
            </div>
            <div>
                <h3 class="merge-modal__title">Merge with another customer</h3>
                <p class="merge-modal__subtitle">
                    This record (<strong>${customerDetail.name}</strong>) will be the <strong>source</strong> — it will
                    be removed after merge.
                </p>
            </div>
            <button type="button" class="merge-modal__close" onclick="closeMergeModal()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="6" x2="6" y2="18"/>
                    <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
            </button>
        </div>

        <div class="merge-modal__search">
            <div class="merge-modal__search-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input type="text" id="mergeSearchInput" class="merge-modal__search-input"
                       placeholder="Search by name, phone or email..."
                       oninput="searchCustomers(this.value)">
            </div>
        </div>

        <div id="mergeSearchResults" class="merge-modal__results">
            <p class="merge-modal__hint">Type to search for a customer to merge with.</p>
        </div>

        <div class="merge-modal__footer">
            <button type="button" class="merge-modal__cancel" onclick="closeMergeModal()">Cancel</button>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
    var CURRENT_CUSTOMER_ID = Number('${customerDetail.customerId}');
    var CONTEXT_PATH = '${pageContext.request.contextPath}';
    var searchTimer = null;

    function toggleTagPicker() {
        var el = document.getElementById("tagPicker");
        el.classList.toggle("hidden");
        document.body.style.overflow = el.classList.contains("hidden") ? '' : 'hidden';
    }

    function handleTagPickerBackdrop(e) {
        if (e.target === document.getElementById("tagPicker")) toggleTagPicker();
    }

    function openMergeModal() {
        document.getElementById('mergeModal').style.display = 'flex';
        document.getElementById('mergeSearchInput').focus();
    }

    function closeMergeModal() {
        document.getElementById('mergeModal').style.display = 'none';
        document.getElementById('mergeSearchInput').value = '';
        document.getElementById('mergeSearchResults').innerHTML =
            '<p class="merge-modal__hint">Type to search for a customer to merge with.</p>';
    }

    function searchCustomers(keyword) {
        clearTimeout(searchTimer);
        var q = keyword.trim();

        if (q.length < 2) {
            document.getElementById('mergeSearchResults').innerHTML =
                '<p class="merge-modal__hint">Type to search for a customer to merge with.</p>';
            return;
        }

        document.getElementById('mergeSearchResults').innerHTML =
            '<p class="merge-modal__loading">Searching...</p>';

        searchTimer = setTimeout(function () {
            fetch(CONTEXT_PATH + '/customers/search?keyword=' + encodeURIComponent(q) + '&exclude=' + CURRENT_CUSTOMER_ID)
                .then(function (res) {
                    return res.json();
                })
                .then(function (data) {
                    renderResults(data);
                })
                .catch(function () {
                    document.getElementById('mergeSearchResults').innerHTML =
                        '<p class="merge-modal__hint">Search failed. Please try again.</p>';
                });
        }, 300);
    }

    function renderResults(customers) {
        var container = document.getElementById('mergeSearchResults');

        if (!customers || customers.length === 0) {
            container.innerHTML = '<p class="merge-modal__hint">No customers found.</p>';
            return;
        }

        var html = '';
        customers.forEach(function (c) {
            var meta = [c.phone, c.email].filter(Boolean).join(' • ');
            html +=
                '<div class="merge-result-item">' +
                '  <div class="merge-result-item__info">' +
                '    <div class="merge-result-item__name">' + escHtml(c.name) + '</div>' +
                '    <div class="merge-result-item__meta">' + escHtml(meta) + ' · ID #' + c.customerId + '</div>' +
                '  </div>' +
                '  <a href="' + CONTEXT_PATH + '/customers/merge-request/new' +
                '?sourceId=' + CURRENT_CUSTOMER_ID + '&targetId=' + c.customerId + '"' +
                '     class="merge-result-item__btn">Select as target</a>' +
                '</div>';
        });
        container.innerHTML = html;
    }

    function escHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // Đóng modal khi bấm Escape
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeMergeModal();
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Customer Report Tabs + Growth Chart
    // ─────────────────────────────────────────────────────────────────────────
    function initCustomerReport() {
        var defaultTab = '${activeTab}';
        var tabs = document.querySelectorAll('.cd-report__tab');
        var panels = document.querySelectorAll('.cd-report__panel');

        function setActive(tabName) {
            tabs.forEach(function (b) {
                b.classList.toggle('is-active', b.dataset.tab === tabName);
            });
            panels.forEach(function (p) {
                p.style.display = (p.dataset.panel === tabName) ? 'block' : 'none';
            });
        }

        tabs.forEach(function (btn) {
            btn.addEventListener('click', function () {
                var t = btn.dataset.tab;
                setActive(t);
                try {
                    var url = new URL(window.location.href);
                    url.searchParams.set('tab', t);
                    window.history.replaceState({}, '', url.toString());
                } catch (e) {
                }
            });
        });

        setActive(defaultTab || 'growth');
        renderGrowthChart();
    }

    function renderGrowthChart() {
        var el = document.getElementById('growthChart');
        if (!el || typeof Chart === 'undefined') return;

        var deals = [
            <c:forEach items="${deals}" var="d" varStatus="st">
            {
                createdAt: '${d.createdAt}',
                stage: '${d.stage}',
                actualValue: Number('${empty d.actualValue ? 0 : d.actualValue}')
            }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
        ];

        var byMonth = {};
        deals.forEach(function (d) {
            if (!d.createdAt) return;
            var stage = String(d.stage || '').toLowerCase().replace(/[_\-\s]+/g, ' ').trim();
            if (stage !== 'closed won') return; // totalSpent chỉ tính deal đã win
            var month = String(d.createdAt).substring(0, 7); // yyyy-MM
            byMonth[month] = (byMonth[month] || 0) + (Number(d.actualValue) || 0);
        });
        var months = Object.keys(byMonth).sort();
        var cumulative = [];
        var run = 0;
        months.forEach(function (m) {
            run += byMonth[m];
            cumulative.push(run);
        });

        new Chart(el, {
            type: 'line',
            data: {
                labels: months,
                datasets: [{
                    label: 'Total spent',
                    data: cumulative,
                    tension: 0.25,
                    borderWidth: 2,
                    pointRadius: 2
                }]
            },
            options: {
                responsive: true,
                plugins: {legend: {display: false}},
                scales: {
                    y: {
                        ticks: {
                            callback: function (value) {
                                try {
                                    return Number(value).toLocaleString('vi-VN') + ' đ';
                                } catch (e) {
                                    return value;
                                }
                            }
                        }
                    }
                }
            }
        });
    }

    document.addEventListener('DOMContentLoaded', initCustomerReport);
</script>
