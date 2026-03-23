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
                <h2 class="mr__title">Merge Requests</h2>
                <p class="mr__subtitle">
                    <c:choose>
                        <c:when test="${empty rows}">No pending requests.</c:when>
                        <c:otherwise>${fn:length(rows)} pending request${fn:length(rows) > 1 ? 's' : ''} awaiting review.</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>

        <%-- Status banners --%>
        <c:if test="${param.status == 'approved'}">
            <div class="mr__success-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
                Merge request approved and executed successfully.
            </div>
        </c:if>
        <c:if test="${param.status == 'rejected'}">
            <div class="mr__warn-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="15" y1="9" x2="9" y2="15"/>
                    <line x1="9" y1="9" x2="15" y2="15"/>
                </svg>
                Merge request rejected.
            </div>
        </c:if>

        <!-- ══ LIST ══ -->
        <c:choose>
            <c:when test="${empty rows}">
                <div class="mr__empty">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
                         stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="18" cy="18" r="3"/>
                        <circle cx="6" cy="6" r="3"/>
                        <circle cx="6" cy="18" r="3"/>
                        <path d="M6 9v3a3 3 0 003 3h3"/>
                        <line x1="18" y1="9" x2="18" y2="15"/>
                    </svg>
                    <p>All caught up — no pending merge requests.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mr__list">
                    <c:forEach items="${rows}" var="row">
                        <a href="${pageContext.request.contextPath}/customers/merge-request/${row.request.id}"
                           class="mr__list-item">

                            <div class="mr__list-item-main">
                                <div class="mr__list-customers">
                                <span class="mr__list-customer mr__list-customer--source">
                                    <span class="mr__badge mr__badge--source">Source</span>
                                    ${row.source.name}
                                    <span class="mr__list-id">#${row.request.sourceId}</span>
                                </span>
                                    <svg class="mr__list-arrow" viewBox="0 0 24 24" fill="none"
                                         stroke="currentColor" stroke-width="2"
                                         stroke-linecap="round" stroke-linejoin="round">
                                        <line x1="5" y1="12" x2="19" y2="12"/>
                                        <polyline points="12 5 19 12 12 19"/>
                                    </svg>
                                    <span class="mr__list-customer mr__list-customer--target">
                                    <span class="mr__badge mr__badge--target">Target</span>
                                    ${row.target.name}
                                    <span class="mr__list-id">#${row.request.targetId}</span>
                                </span>
                                </div>

                                <c:if test="${not empty row.request.reason}">
                                    <p class="mr__list-reason">${fn:substring(row.request.reason, 0, 100)}${fn:length(row.request.reason) > 100 ? '...' : ''}</p>
                                </c:if>
                            </div>

                            <div class="mr__list-item-meta">
                                <span class="mr__status mr__status--pending">Pending</span>
                                <span class="mr__list-date">by #${row.request.createdBy}</span>
                                <svg class="mr__list-chevron" viewBox="0 0 24 24" fill="none"
                                     stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="9 18 15 12 9 6"/>
                                </svg>
                            </div>

                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<style>

</style>
