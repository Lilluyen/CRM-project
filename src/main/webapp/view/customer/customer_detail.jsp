<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="customer-detail">

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

            <a href="mailto:${customerDetail.email}"
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
                    <div id="tagPicker" class="tag-picker hidden">
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
                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Status</span>
                        <span class="customer-detail__metric-value customer-detail__badge">
                            ${customerDetail.status}
                        </span>
                    </div>
                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">Loyalty Tier</span>
                        <span class="customer-detail__metric-value">${customerDetail.loyaltyTier}</span>
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


<script>
    var CURRENT_CUSTOMER_ID = ${customerDetail.customerId};
    var CONTEXT_PATH = '${pageContext.request.contextPath}';
    var searchTimer = null;

    function toggleTagPicker() {
        document.getElementById("tagPicker").classList.toggle("hidden");
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
</script>
