<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<c:set var="ex" value="${conflict.existingCustomer}"/>
<c:set var="inc" value="${conflict.incomingData}"/>

<div class="rc">
    <div class="rc__container">

        <!-- ══ HEADER ══ -->
        <div class="rc__header">
            <div class="rc__header-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"
                     stroke-linecap="round" stroke-linejoin="round">
                    <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                    <line x1="12" y1="9" x2="12" y2="13"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
            </div>
            <div>
                <h2 class="rc__title">Duplicate Record Detected</h2>
                <p class="rc__subtitle">
                    A customer with the same
                    <span class="rc__conflict-field">${conflict.conflictField}</span>
                    already exists. Please review and choose an action.
                </p>
            </div>
        </div>

        <%-- Error message nếu có --%>
        <c:if test="${not empty errorMsg}">
            <div class="rc__error-banner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                    ${errorMsg}
            </div>
        </c:if>

        <!-- ══ SO SÁNH 2 BẢN GHI ══ -->
        <div class="rc__compare">

            <!-- Cột existing -->
            <div class="rc__card rc__card--existing">
                <div class="rc__card-header">
                    <span class="rc__badge rc__badge--existing">Existing record</span>
                    <span class="rc__card-id">ID #${ex.customerId}</span>
                </div>
                <div class="rc__fields">
                    <div class="rc__row">
                        <span class="rc__label">Full name</span>
                        <span class="rc__value">${ex.name}</span>
                    </div>
                    <div class="rc__row ${conflict.conflictField == 'phone' ? 'rc__row--conflict' : ''}">
                        <span class="rc__label">Phone</span>
                        <span class="rc__value">${ex.phone}</span>
                    </div>
                    <div class="rc__row ${conflict.conflictField == 'email' ? 'rc__row--conflict' : ''}">
                        <span class="rc__label">Email</span>
                        <span class="rc__value">${not empty ex.email ? ex.email : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Gender</span>
                        <span class="rc__value">${not empty ex.gender ? ex.gender : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Birthday</span>
                        <span class="rc__value">${not empty ex.birthday ? ex.birthday : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Address</span>
                        <span class="rc__value">${not empty ex.address ? ex.address : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Source</span>
                        <span class="rc__value">${not empty ex.source ? ex.source : '—'}</span>
                    </div>

                    <%-- Contacts phụ của existing nếu có --%>
                    <c:if test="${not empty ex.contacts}">
                        <div class="rc__row rc__row--contacts">
                            <span class="rc__label">Other contacts</span>
                            <div class="rc__contact-list">
                                <c:forEach items="${ex.contacts}" var="ct">
                                    <span class="rc__contact-pill rc__contact-pill--${fn:toLowerCase(ct.type)}">
                                        ${ct.type}: ${ct.value}
                                    </span>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Divider giữa -->
            <div class="rc__vs">
                <div class="rc__vs-line"></div>
                <span class="rc__vs-label">VS</span>
                <div class="rc__vs-line"></div>
            </div>

            <!-- Cột incoming -->
            <div class="rc__card rc__card--incoming">
                <div class="rc__card-header">
                    <span class="rc__badge rc__badge--incoming">New data</span>
                    <span class="rc__card-id">Being ${conflict.source == 'create' ? 'created' : 'updated'}</span>
                </div>
                <div class="rc__fields">
                    <div class="rc__row">
                        <span class="rc__label">Full name</span>
                        <span class="rc__value">${inc.name}</span>
                    </div>
                    <div class="rc__row ${conflict.conflictField == 'phone' ? 'rc__row--conflict' : ''}">
                        <span class="rc__label">Phone</span>
                        <span class="rc__value">${inc.phone}</span>
                    </div>
                    <div class="rc__row ${conflict.conflictField == 'email' ? 'rc__row--conflict' : ''}">
                        <span class="rc__label">Email</span>
                        <span class="rc__value">${not empty inc.email ? inc.email : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Gender</span>
                        <span class="rc__value">${not empty inc.gender ? inc.gender : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Birthday</span>
                        <span class="rc__value">${not empty inc.birthday ? inc.birthday : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Address</span>
                        <span class="rc__value">${not empty inc.address ? inc.address : '—'}</span>
                    </div>
                    <div class="rc__row">
                        <span class="rc__label">Source</span>
                        <span class="rc__value">${not empty inc.source ? inc.source : '—'}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══ MERGE PREVIEW ══ -->
        <div class="rc__merge-preview">
            <div class="rc__merge-preview-header">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="18" cy="18" r="3"/>
                    <circle cx="6" cy="6" r="3"/>
                    <circle cx="6" cy="18" r="3"/>
                    <path d="M6 9v3a3 3 0 003 3h3"/>
                    <line x1="18" y1="9" x2="18" y2="15"/>
                </svg>
                If you merge — the result will be:
            </div>
            <div class="rc__merge-rows">
                <div class="rc__merge-row">
                    <span class="rc__label">Name</span>
                    <span class="rc__value">${ex.name}</span>
                    <span class="rc__merge-source">kept from existing</span>
                </div>
                <div class="rc__merge-row">
                    <span class="rc__label">Phone (primary)</span>
                    <span class="rc__value">${ex.phone}</span>
                    <span class="rc__merge-source">kept from existing</span>
                </div>
                <div class="rc__merge-row">
                    <span class="rc__label">Email (primary)</span>
                    <span class="rc__value">${ex.email}</span>
                    <span class="rc__merge-source">kept from existing</span>
                </div>
                <c:if test="${inc.phone != ex.phone}">
                    <div class="rc__merge-row rc__merge-row--added">
                        <span class="rc__label">Phone (secondary)</span>
                        <span class="rc__value">${inc.phone}</span>
                        <span class="rc__merge-source rc__merge-source--added">added to contacts</span>
                    </div>
                </c:if>
                <c:if test="${not empty inc.email and inc.email != ex.email}">
                    <div class="rc__merge-row rc__merge-row--added">
                        <span class="rc__label">Email (secondary)</span>
                        <span class="rc__value">${inc.email}</span>
                        <span class="rc__merge-source rc__merge-source--added">added to contacts</span>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- ══ ACTION FORMS ══ -->
        <div class="rc__actions">

            <!-- Nút Cancel — quay lại -->
            <a href="javascript:history.back()" class="rc__btn rc__btn--cancel">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="6" x2="6" y2="18"/>
                    <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
                Cancel
            </a>

            <!-- IGNORE form -->
            <form method="post" action="${pageContext.request.contextPath}/customers/resolve-conflict"
                  id="ignoreForm" class="rc__action-form">
                <input type="hidden" name="action" value="ignore"/>
                <div class="rc__ignore-wrap">
                    <textarea class="rc__note-input" name="note" id="noteInput"
                              placeholder="Reason for keeping as separate record (optional)..."
                              rows="2"></textarea>
                    <button type="submit" class="rc__btn rc__btn--ignore"
                            onclick="return confirmIgnore()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/>
                            <line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/>
                        </svg>
                        Ignore &amp; Keep Separate
                    </button>
                </div>
            </form>

            <!-- MERGE form -->
            <form method="post" action="${pageContext.request.contextPath}/customers/resolve-conflict"
                  id="mergeForm">
                <input type="hidden" name="action" value="merge"/>
                <button type="submit" class="rc__btn rc__btn--merge"
                        onclick="return confirmMerge()">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="18" cy="18" r="3"/>
                        <circle cx="6" cy="6" r="3"/>
                        <circle cx="6" cy="18" r="3"/>
                        <path d="M6 9v3a3 3 0 003 3h3"/>
                        <line x1="18" y1="9" x2="18" y2="15"/>
                    </svg>
                    Merge Records
                </button>
            </form>

        </div>

    </div>
</div>

<style>
    /* ── Tokens ── */
    :root {
        --rc-primary: #E87020;
        --rc-primary-lt: #FEF0E6;
        --rc-primary-dk: #C25A10;
        --rc-existing: #1E3A5F;
        --rc-existing-lt: #EEF3FA;
        --rc-incoming: #065F46;
        --rc-incoming-lt: #ECFDF5;
        --rc-conflict: #DC2626;
        --rc-conflict-lt: #FEF2F2;
        --rc-added: #059669;
        --rc-added-lt: #D1FAE5;
        --rc-border: #E5E7EB;
        --rc-text: #111827;
        --rc-muted: #6B7280;
        --rc-surface: #FFFFFF;
        --rc-bg: #FDF8F5;
        --rc-radius: 10px;
        --rc-radius-sm: 6px;
    }

    .rc {
        background: var(--rc-bg);
        min-height: 100vh;
        padding: 28px 20px 48px;
    }

    .rc__container {
        max-width: 980px;
        margin: 0 auto;
        background: var(--rc-surface);
        border-radius: 14px;
        border: 1px solid #F0D9C8;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(232, 112, 32, .08), 0 4px 16px rgba(232, 112, 32, .06);
    }

    /* Header */
    .rc__header {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 24px 28px 20px;
        border-bottom: 2px solid var(--rc-primary-lt);
        background: linear-gradient(135deg, #FEF0E6 0%, #FFFDF9 100%);
    }

    .rc__header-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        background: var(--rc-primary);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .rc__header-icon svg {
        width: 22px;
        height: 22px;
        stroke: #fff;
    }

    .rc__title {
        font-size: 1.15rem;
        font-weight: 700;
        color: var(--rc-text);
        margin: 0 0 3px;
    }

    .rc__subtitle {
        font-size: .85rem;
        color: var(--rc-muted);
        margin: 0;
    }

    .rc__conflict-field {
        font-weight: 700;
        color: var(--rc-conflict);
        text-transform: uppercase;
        font-size: .8rem;
        background: var(--rc-conflict-lt);
        padding: 1px 6px;
        border-radius: 4px;
    }

    /* Error banner */
    .rc__error-banner {
        display: flex;
        align-items: center;
        gap: 10px;
        margin: 16px 28px 0;
        padding: 10px 14px;
        background: var(--rc-conflict-lt);
        border: 1px solid #FECACA;
        border-radius: var(--rc-radius-sm);
        color: var(--rc-conflict);
        font-size: .875rem;
        font-weight: 500;
    }

    .rc__error-banner svg {
        width: 16px;
        height: 16px;
        stroke: var(--rc-conflict);
        flex-shrink: 0;
    }

    /* Compare grid */
    .rc__compare {
        display: grid;
        grid-template-columns: 1fr 40px 1fr;
        gap: 0;
        padding: 24px 28px 0;
    }

    .rc__card {
        border-radius: var(--rc-radius);
        border: 2px solid var(--rc-border);
        overflow: hidden;
    }

    .rc__card--existing {
        border-color: #BFDBFE;
    }

    .rc__card--incoming {
        border-color: #A7F3D0;
    }

    .rc__card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px 14px;
    }

    .rc__card--existing .rc__card-header {
        background: var(--rc-existing-lt);
    }

    .rc__card--incoming .rc__card-header {
        background: var(--rc-incoming-lt);
    }

    .rc__badge {
        font-size: .72rem;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 10px;
        text-transform: uppercase;
        letter-spacing: .04em;
    }

    .rc__badge--existing {
        background: var(--rc-existing);
        color: #fff;
    }

    .rc__badge--incoming {
        background: var(--rc-incoming);
        color: #fff;
    }

    .rc__card-id {
        font-size: .78rem;
        color: var(--rc-muted);
        font-weight: 500;
    }

    /* Field rows */
    .rc__fields {
        padding: 4px 0 8px;
    }

    .rc__row {
        display: grid;
        grid-template-columns: 90px 1fr;
        gap: 8px;
        padding: 7px 14px;
        border-bottom: 1px solid #F9FAFB;
        align-items: center;
    }

    .rc__row:last-child {
        border-bottom: none;
    }

    .rc__row--conflict {
        background: var(--rc-conflict-lt);
    }

    .rc__row--conflict .rc__label,
    .rc__row--conflict .rc__value {
        color: var(--rc-conflict);
        font-weight: 600;
    }

    .rc__row--contacts {
        align-items: flex-start;
    }

    .rc__label {
        font-size: .75rem;
        font-weight: 600;
        color: var(--rc-muted);
        text-transform: uppercase;
        letter-spacing: .03em;
    }

    .rc__value {
        font-size: .88rem;
        color: var(--rc-text);
        font-weight: 500;
        word-break: break-all;
    }

    .rc__contact-list {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
    }

    .rc__contact-pill {
        font-size: .72rem;
        font-weight: 600;
        padding: 2px 8px;
        border-radius: 10px;
    }

    .rc__contact-pill--phone {
        background: var(--rc-primary-lt);
        color: var(--rc-primary-dk);
    }

    .rc__contact-pill--email {
        background: var(--rc-existing-lt);
        color: var(--rc-existing);
    }

    /* VS divider */
    .rc__vs {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 16px 0;
    }

    .rc__vs-line {
        flex: 1;
        width: 1px;
        background: var(--rc-border);
    }

    .rc__vs-label {
        font-size: .72rem;
        font-weight: 800;
        color: var(--rc-muted);
        background: var(--rc-surface);
        padding: 4px 6px;
        border: 1px solid var(--rc-border);
        border-radius: 4px;
        letter-spacing: .06em;
    }

    /* Merge preview */
    .rc__merge-preview {
        margin: 20px 28px 0;
        border: 1.5px solid #FCD34D;
        border-radius: var(--rc-radius);
        overflow: hidden;
    }

    .rc__merge-preview-header {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 14px;
        background: #FFFBEB;
        font-size: .82rem;
        font-weight: 700;
        color: #92400E;
        border-bottom: 1px solid #FCD34D;
    }

    .rc__merge-preview-header svg {
        width: 16px;
        height: 16px;
        stroke: #92400E;
    }

    .rc__merge-rows {
        padding: 4px 0 6px;
    }

    .rc__merge-row {
        display: grid;
        grid-template-columns: 140px 1fr auto;
        gap: 8px;
        padding: 6px 14px;
        align-items: center;
        border-bottom: 1px solid #F9FAFB;
    }

    .rc__merge-row:last-child {
        border-bottom: none;
    }

    .rc__merge-row--added {
        background: var(--rc-added-lt);
    }

    .rc__merge-source {
        font-size: .72rem;
        color: var(--rc-muted);
        font-style: italic;
        white-space: nowrap;
    }

    .rc__merge-source--added {
        color: var(--rc-added);
        font-weight: 600;
        font-style: normal;
    }

    /* Actions */
    .rc__actions {
        display: flex;
        align-items: flex-end;
        gap: 12px;
        padding: 20px 28px 28px;
        flex-wrap: wrap;
        justify-content: flex-end;
    }

    .rc__action-form {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .rc__ignore-wrap {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .rc__note-input {
        width: 320px;
        padding: 8px 12px;
        border: 1.5px solid var(--rc-border);
        border-radius: var(--rc-radius-sm);
        font-size: .85rem;
        color: var(--rc-text);
        resize: vertical;
        font-family: inherit;
        transition: border-color .15s;
    }

    .rc__note-input:focus {
        outline: none;
        border-color: var(--rc-primary);
        box-shadow: 0 0 0 3px rgba(232, 112, 32, .15);
    }

    .rc__btn {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        padding: 10px 20px;
        border-radius: var(--rc-radius-sm);
        font-size: .88rem;
        font-weight: 600;
        cursor: pointer;
        border: none;
        text-decoration: none;
        transition: all .18s;
        white-space: nowrap;
    }

    .rc__btn svg {
        width: 16px;
        height: 16px;
    }

    .rc__btn--cancel {
        background: var(--rc-surface);
        color: var(--rc-muted);
        border: 1.5px solid var(--rc-border);
        align-self: flex-end;
    }

    .rc__btn--cancel:hover {
        border-color: var(--rc-primary);
        color: var(--rc-primary);
    }

    .rc__btn--cancel svg {
        stroke: currentColor;
    }

    .rc__btn--ignore {
        background: var(--rc-surface);
        color: var(--rc-conflict);
        border: 1.5px solid #FECACA;
    }

    .rc__btn--ignore svg {
        stroke: var(--rc-conflict);
    }

    .rc__btn--ignore:hover {
        background: var(--rc-conflict-lt);
        border-color: var(--rc-conflict);
    }

    .rc__btn--merge {
        background: var(--rc-primary);
        color: #fff;
    }

    .rc__btn--merge svg {
        stroke: #fff;
    }

    .rc__btn--merge:hover {
        background: var(--rc-primary-dk);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(232, 112, 32, .35);
    }

    /* Responsive */
    @media (max-width: 680px) {
        .rc__compare {
            grid-template-columns: 1fr;
        }

        .rc__vs {
            flex-direction: row;
            padding: 8px 0;
        }

        .rc__vs-line {
            width: 100%;
            height: 1px;
            flex: 1;
        }

        .rc__note-input {
            width: 100%;
        }

        .rc__actions {
            flex-direction: column;
            align-items: stretch;
        }

        .rc__btn {
            justify-content: center;
        }

        .rc__merge-row {
            grid-template-columns: 120px 1fr;
        }

        .rc__merge-source {
            display: none;
        }
    }
</style>

<script>
    function confirmMerge() {
        return confirm(
            'Merge these two records?\n\n' +
            '• The existing record will be kept as primary\n' +
            '• New phone/email will be saved as secondary contacts\n' +
            '• This action cannot be undone'
        );
    }

    function confirmIgnore() {
        var note = document.getElementById('noteInput').value.trim();
        var msg = 'Save as a separate record?';
        if (!note) {
            msg += '\n\nTip: add a reason in the note box so you can trace this later.';
        }
        return confirm(msg);
    }
</script>
