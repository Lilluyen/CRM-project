<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="mr">
    <div class="mr__container">

        <!-- ══ HEADER ══ -->
        <div class="mr__header">
            <div class="mr__header-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="18" cy="18" r="3"/>
                    <circle cx="6" cy="6" r="3"/>
                    <circle cx="6" cy="18" r="3"/>
                    <path d="M6 9v3a3 3 0 003 3h3"/>
                    <line x1="18" y1="9" x2="18" y2="15"/>
                </svg>
            </div>
            <div>
                <h2 class="mr__title">Merge Request #${mergeReq.id}</h2>
                <p class="mr__subtitle">
                    Submitted by user #${mergeReq.createdBy}
                    &nbsp;·&nbsp;
                    <c:choose>
                        <c:when test="${mergeReq.status == 'PENDING'}">
                            <span class="mr__status mr__status--pending">Pending</span>
                        </c:when>
                        <c:when test="${mergeReq.status == 'MERGED'}">
                            <span class="mr__status mr__status--merged">Merged</span>
                        </c:when>
                        <c:when test="${mergeReq.status == 'REJECTED'}">
                            <span class="mr__status mr__status--rejected">Rejected</span>
                        </c:when>
                    </c:choose>
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/customers/merge-request/list"
               class="mr__back-btn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <line x1="19" y1="12" x2="5" y2="12"/>
                    <polyline points="12 19 5 12 12 5"/>
                </svg>
                Back to list
            </a>
        </div>

        <%-- Error từ redirect --%>
        <c:if test="${not empty errorMsg}">
            <div class="mr__error-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                    ${errorMsg}
            </div>
        </c:if>
        <c:if test="${param.status == 'already-processed'}">
            <div class="mr__warn-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                    <line x1="12" y1="9" x2="12" y2="13"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
                This request has already been processed.
            </div>
        </c:if>

        <!-- ══ REASON ══ -->
        <c:if test="${not empty mergeReq.reason}">
            <div class="mr__reason-box">
                <div class="mr__reason-box-label">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
                    </svg>
                    Reason from requester
                </div>
                <p class="mr__reason-box-text">${mergeReq.reason}</p>
            </div>
        </c:if>

        <!-- ══ COLUMN HEADERS ══ -->
        <div class="mr__col-headers">
            <div class="mr__col-label mr__col-label--source">
                <span class="mr__badge mr__badge--source">Source</span>
                <span class="mr__col-name">${source.name}</span>
                <span class="mr__col-id">ID #${source.customerId}</span>
            </div>
            <div class="mr__col-label mr__col-label--center">Result</div>
            <div class="mr__col-label mr__col-label--target">
                <span class="mr__badge mr__badge--target">Target</span>
                <span class="mr__col-name">${target.name}</span>
                <span class="mr__col-id">ID #${target.customerId}</span>
            </div>
        </div>

        <!-- ══ FIELD RESULT TABLE (read-only) ══ -->
        <div class="mr__fields">

            <c:set var="fields" value="name,phone,email,gender,birthday,address,source"/>
            <c:forTokens items="${fields}" delims="," var="field">
                <div class="mr__field-row mr__field-row--readonly">

                        <%-- Source cell --%>
                    <div class="mr__cell mr__cell--source
                    ${overrides[field] == 'source' ? ' mr__cell--chosen' : ''}">
                        <c:choose>
                            <c:when test="${field == 'name'}"><span>${source.name}</span></c:when>
                            <c:when test="${field == 'phone'}"><span>${source.phone}</span></c:when>
                            <c:when test="${field == 'email'}"><span>${not empty source.email ? source.email : '—'}</span></c:when>
                            <c:when test="${field == 'gender'}"><span>${not empty source.gender ? source.gender : '—'}</span></c:when>
                            <c:when test="${field == 'birthday'}"><span>${not empty source.birthday ? source.birthday : '—'}</span></c:when>
                            <c:when test="${field == 'address'}"><span>${not empty source.address ? source.address : '—'}</span></c:when>
                            <c:when test="${field == 'source'}"><span>${not empty source.source ? source.source : '—'}</span></c:when>
                        </c:choose>
                        <c:if test="${overrides[field] == 'source'}">
                            <span class="mr__chosen-badge">Kept</span>
                        </c:if>
                    </div>

                        <%-- Label --%>
                    <div class="mr__cell mr__cell--label">
                        <c:choose>
                            <c:when test="${field == 'name'}">Name</c:when>
                            <c:when test="${field == 'phone'}">Phone</c:when>
                            <c:when test="${field == 'email'}">Email</c:when>
                            <c:when test="${field == 'gender'}">Gender</c:when>
                            <c:when test="${field == 'birthday'}">Birthday</c:when>
                            <c:when test="${field == 'address'}">Address</c:when>
                            <c:when test="${field == 'source'}">Source</c:when>
                        </c:choose>
                    </div>

                        <%-- Target cell --%>
                    <div class="mr__cell mr__cell--target
                    ${overrides[field] != 'source' ? ' mr__cell--chosen' : ''}">
                        <c:if test="${overrides[field] != 'source'}">
                            <span class="mr__chosen-badge">Kept</span>
                        </c:if>
                        <c:choose>
                            <c:when test="${field == 'name'}"><span>${target.name}</span></c:when>
                            <c:when test="${field == 'phone'}"><span>${target.phone}</span></c:when>
                            <c:when test="${field == 'email'}"><span>${not empty target.email ? target.email : '—'}</span></c:when>
                            <c:when test="${field == 'gender'}"><span>${not empty target.gender ? target.gender : '—'}</span></c:when>
                            <c:when test="${field == 'birthday'}"><span>${not empty target.birthday ? target.birthday : '—'}</span></c:when>
                            <c:when test="${field == 'address'}"><span>${not empty target.address ? target.address : '—'}</span></c:when>
                            <c:when test="${field == 'source'}"><span>${not empty target.source ? target.source : '—'}</span></c:when>
                        </c:choose>
                    </div>

                </div>
            </c:forTokens>

        </div>

        <!-- ══ REJECT REASON (nếu đã bị reject) ══ -->
        <c:if test="${mergeReq.status == 'REJECTED' and not empty mergeReq.rejectReason}">
            <div class="mr__reject-reason">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="15" y1="9" x2="9" y2="15"/>
                    <line x1="9" y1="9" x2="15" y2="15"/>
                </svg>
                <div>
                    <strong>Rejected by manager #${mergeReq.reviewedBy}:</strong>
                        ${mergeReq.rejectReason}
                </div>
            </div>
        </c:if>

        <!-- ══ MANAGER ACTIONS (chỉ hiện khi PENDING và là manager) ══ -->
        <c:if test="${mergeReq.status == 'PENDING' and isManager}">
            <div class="mr__actions">

                    <%-- Reject form --%>
                <form method="post"
                      action="${pageContext.request.contextPath}/customers/merge-request/${mergeReq.id}"
                      class="mr__reject-form">
                    <input type="hidden" name="action" value="reject"/>
                    <textarea class="mr__reject-input" name="rejectReason"
                              placeholder="Reason for rejection (required)..." rows="2"></textarea>
                    <button type="submit" class="mr__btn mr__btn--reject"
                            onclick="return confirmReject()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="15" y1="9" x2="9" y2="15"/>
                            <line x1="9" y1="9" x2="15" y2="15"/>
                        </svg>
                        Reject
                    </button>
                </form>

                    <%-- Approve form --%>
                <form method="post"
                      action="${pageContext.request.contextPath}/customers/merge-request/${mergeReq.id}">
                    <input type="hidden" name="action" value="approve"/>
                    <button type="submit" class="mr__btn mr__btn--approve"
                            onclick="return confirmApprove()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"/>
                        </svg>
                        Approve &amp; Merge
                    </button>
                </form>

            </div>
        </c:if>

    </div>
</div>

<style>

</style>

<script>
    function confirmApprove() {
        return confirm(
            'Approve and execute this merge?\n\n' +
            '• Source customer will be deleted\n' +
            '• All contacts will be merged into target\n' +
            '• This cannot be undone'
        );
    }

    function confirmReject() {
        var reason = document.querySelector('.mr__reject-input').value.trim();
        if (!reason) {
            alert('Please enter a rejection reason.');
            return false;
        }
        return confirm('Reject this merge request?');
    }
</script>
