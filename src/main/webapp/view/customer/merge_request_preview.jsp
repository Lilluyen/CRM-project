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
                <h2 class="mr__title">New Merge Request</h2>
                <p class="mr__subtitle">Choose which value to keep for each field, then submit for manager approval.</p>
            </div>
        </div>

        <%-- Warning: đã có PENDING request --%>
        <c:if test="${hasPending}">
            <div class="mr__warn-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                    <line x1="12" y1="9" x2="12" y2="13"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
                A pending merge request already exists for these two customers. Submitting another will be blocked.
            </div>
        </c:if>

        <%-- Warning: already-pending từ redirect --%>
        <c:if test="${param.status == 'already-pending'}">
            <div class="mr__error-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                A pending merge request already exists between these two customers.
            </div>
        </c:if>

        <!-- ══ HEADER 2 CỘT ══ -->
        <div class="mr__col-headers">
            <div class="mr__col-label mr__col-label--source">
                <span class="mr__badge mr__badge--source">Source</span>
                <span class="mr__col-name">${source.name}</span>
                <span class="mr__col-id">ID #${source.customerId}</span>
            </div>
            <div class="mr__col-label mr__col-label--center">Keep</div>
            <div class="mr__col-label mr__col-label--target">
                <span class="mr__badge mr__badge--target">Target</span>
                <span class="mr__col-name">${target.name}</span>
                <span class="mr__col-id">ID #${target.customerId}</span>
            </div>
        </div>

        <!-- ══ FORM ══ -->
        <form class="mr__form" method="post"
              action="${pageContext.request.contextPath}/customers/merge-request/new"
              novalidate>

            <input type="hidden" name="sourceId" value="${source.customerId}"/>
            <input type="hidden" name="targetId" value="${target.customerId}"/>

            <!-- ══ FIELD PICKER TABLE ══ -->
            <div class="mr__fields">

                <%-- Name --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_name" value="source" checked>
                            <span>${not empty source.name ? source.name : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Full name</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_name" value="target">
                            <span>${not empty target.name ? target.name : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Phone --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_phone" value="source" checked>
                            <span>${not empty source.phone ? source.phone : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Phone</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_phone" value="target">
                            <span>${not empty target.phone ? target.phone : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Email --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_email" value="source" checked>
                            <span>${not empty source.email ? source.email : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Email</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_email" value="target">
                            <span>${not empty target.email ? target.email : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Gender --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_gender" value="source" checked>
                            <span>${not empty source.gender ? source.gender : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Gender</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_gender" value="target">
                            <span>${not empty target.gender ? target.gender : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Birthday --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_birthday" value="source" checked>
                            <span>${not empty source.birthday ? source.birthday : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Birthday</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_birthday" value="target">
                            <span>${not empty target.birthday ? target.birthday : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Address --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_address" value="source" checked>
                            <span>${not empty source.address ? source.address : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Address</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_address" value="target">
                            <span>${not empty target.address ? target.address : '—'}</span>
                        </label>
                    </div>
                </div>

                <%-- Source --%>
                <div class="mr__field-row">
                    <div class="mr__cell mr__cell--source">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_source" value="source" checked>
                            <span>${not empty source.source ? source.source : '—'}</span>
                        </label>
                    </div>
                    <div class="mr__cell mr__cell--label">Source</div>
                    <div class="mr__cell mr__cell--target">
                        <label class="mr__cell-label">
                            <input type="radio" name="field_source" value="target">
                            <span>${not empty target.source ? target.source : '—'}</span>
                        </label>
                    </div>
                </div>

            </div>
            <%-- /.mr__fields --%>

            <!-- ══ CONTACTS NOTE ══ -->
            <div class="mr__contacts-note">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                All secondary contacts from both customers will be merged automatically — no selection needed.
            </div>

            <!-- ══ REASON ══ -->
            <div class="mr__reason">
                <label class="mr__reason-label">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
                    </svg>
                    Reason <span class="mr__muted">(optional)</span>
                </label>
                <textarea class="mr__reason-input" name="reason" rows="3"
                          placeholder="Why are these two customers the same person?..."></textarea>
            </div>

            <!-- ══ FOOTER ══ -->
            <div class="mr__footer">
                <a href="${pageContext.request.contextPath}/customers/detail?customerId=${source.customerId}"
                   class="mr__btn mr__btn--cancel">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                    Cancel
                </a>
                <button type="submit" class="mr__btn mr__btn--submit" ${hasPending ? 'disabled' : ''}>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="18" cy="18" r="3"/>
                        <circle cx="6" cy="6" r="3"/>
                        <circle cx="6" cy="18" r="3"/>
                        <path d="M6 9v3a3 3 0 003 3h3"/>
                        <line x1="18" y1="9" x2="18" y2="15"/>
                    </svg>
                    Submit Merge Request
                </button>
            </div>

        </form>
    </div>
</div>

