<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<%--
    Value resolution strategy:
    - On GET  (no errors): use customerDetail.xxx  and customerDetail.latestMeasurement.xxx
    - On POST (with errors): controller sets oldXxx attributes to preserve typed values
    We use a JSTL choose block per field:
      if oldXxx is set → use it (POST re-render)
      else             → use customerDetail.xxx (GET)
--%>

<%-- ── Pre-compute resolved values once at top ─────────────────── --%>
<c:set var="v_name" value="${not empty oldName     ? oldName     : customerDetail.name}"/>
<c:set var="v_phone" value="${not empty oldPhone    ? oldPhone    : customerDetail.phone}"/>
<c:set var="v_email" value="${not empty oldEmail    ? oldEmail    : customerDetail.email}"/>
<c:set var="v_gender" value="${not empty oldGender   ? oldGender   : customerDetail.gender}"/>
<c:set var="v_birthday" value="${not empty oldBirthday ? oldBirthday : customerDetail.birthday}"/>
<c:set var="v_source" value="${not empty oldSource   ? oldSource   : customerDetail.source}"/>
<c:set var="v_address" value="${not empty oldAddress  ? oldAddress  : customerDetail.address}"/>

<%-- latestMeasurement may be null for new customers with no body data yet --%>
<c:set var="m" value="${customerDetail.latestMeasurement}"/>
<c:set var="v_height" value="${not empty oldHeight        ? oldHeight        : (m != null ? m.height        : '')}"/>
<c:set var="v_weight" value="${not empty oldWeight        ? oldWeight        : (m != null ? m.weight        : '')}"/>
<c:set var="v_preferredSize"
       value="${not empty oldPreferredSize ? oldPreferredSize : (m != null ? m.preferredSize : '')}"/>
<c:set var="v_bust" value="${not empty oldBust          ? oldBust          : (m != null ? m.bust          : '')}"/>
<c:set var="v_waist" value="${not empty oldWaist         ? oldWaist         : (m != null ? m.waist         : '')}"/>
<c:set var="v_hips" value="${not empty oldHips          ? oldHips          : (m != null ? m.hips          : '')}"/>
<c:set var="v_shoulder" value="${not empty oldShoulder      ? oldShoulder      : (m != null ? m.shoulder      : '')}"/>
<c:set var="v_bodyShape" value="${not empty oldBodyShape     ? oldBodyShape     : (m != null ? m.bodyShape     : '')}"/>

<%--
    Tag resolution:
    - POST error → selectedTags (Set<String> of tagId strings)
    - GET        → customerDetail.styleTags (List<StyleTag> with tagId)
    We handle this inline per tag below.
--%>

<div class="cf">
    <div class="cf__container">

        <!-- ══ HEADER ══ -->
        <div class="cf__header">
            <div class="cf__header-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"
                     stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
                    <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
            </div>
            <div>
                <h2 class="cf__title">Edit Customer Profile</h2>
                <p class="cf__subtitle">
                    Updating record for
                    <strong style="color:var(--navy)">${customerDetail.name}</strong>
                    &nbsp;·&nbsp; ID #${customerDetail.customerId}
                </p>
            </div>
        </div>

        <%-- ── Global error banner ── --%>
        <c:if test="${not empty fieldErrors}">
            <div class="cf__error-banner" id="cfErrorBanner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                Please review the highlighted fields and correct any errors before saving.
            </div>
        </c:if>

        <form class="cf__form" method="post"
              action="${pageContext.request.contextPath}/customers/edit"
              novalidate>

            <%-- Pass customerId as hidden so POST knows which record to update --%>
            <input type="hidden" name="customerId" value="${customerDetail.customerId}"/>

            <div class="cf__body">

                <!-- ══ COL 1: PERSONAL INFO ══ -->
                <div class="cf__col cf__col--1">
                    <div class="cf__col-header">
                        <div class="cf__col-icon cf__col-icon--blue">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                        </div>
                        <span class="cf__col-title">Personal Info</span>
                    </div>

                    <div class="cf__fields">

                        <%-- Full Name --%>
                        <c:set var="e" value="${fieldErrors['name']}"/>
                        <div class="cf__field${not empty e ? ' cf__field--error' : ''}">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                                    <circle cx="12" cy="7" r="4"/>
                                </svg>
                                Full Name <span class="cf__req">*</span>
                            </label>
                            <input class="cf__input" type="text" name="name"
                                   value="${v_name}" placeholder="Ex: Nguyen Lan Anh">
                            <c:if test="${not empty e}">
                                <span class="cf__err-msg">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8"
                                                                                                   x2="12" y2="12"/><line
                                            x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    ${e}
                                </span>
                            </c:if>
                        </div>

                        <%-- Phone --%>
                        <c:set var="e" value="${fieldErrors['phone']}"/>
                        <div class="cf__field${not empty e ? ' cf__field--error' : ''}">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M22 16.92v3a2 2 0 01-2.18 2A19.79 19.79 0 013.07 9.81 19.79 19.79 0 012 2.18h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.37 7.69a16 16 0 006 6l.88-.88a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/>
                                </svg>
                                Phone Number <span class="cf__req">*</span>
                            </label>
                            <input class="cf__input" type="tel" name="phone"
                                   value="${v_phone}" placeholder="Ex: 0987654321">
                            <c:if test="${not empty e}">
                                <span class="cf__err-msg">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8"
                                                                                                   x2="12" y2="12"/><line
                                            x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    ${e}
                                </span>
                            </c:if>
                        </div>

                        <%-- Email --%>
                        <c:set var="e" value="${fieldErrors['email']}"/>
                        <div class="cf__field${not empty e ? ' cf__field--error' : ''}">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                    <polyline points="22,6 12,13 2,6"/>
                                </svg>
                                Email
                            </label>
                            <input class="cf__input" type="email" name="email"
                                   value="${v_email}" placeholder="Ex: example@gmail.com">
                            <c:if test="${not empty e}">
                                <span class="cf__err-msg">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8"
                                                                                                   x2="12" y2="12"/><line
                                            x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    ${e}
                                </span>
                            </c:if>
                        </div>

                        <%-- Gender --%>
                        <c:set var="e" value="${fieldErrors['gender']}"/>
                        <div class="cf__field${not empty e ? ' cf__field--error' : ''}">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="10"/>
                                    <line x1="2" y1="12" x2="22" y2="12"/>
                                    <path d="M12 2a15.3 15.3 0 010 20M12 2a15.3 15.3 0 000 20"/>
                                </svg>
                                Gender <span class="cf__req">*</span>
                            </label>
                            <select class="cf__input" name="gender">
                                <option value="">Select gender</option>
                                <option value="MALE"   ${fn:toUpperCase(v_gender) == 'MALE'   ? 'selected' : ''}>Male
                                </option>
                                <option value="FEMALE" ${fn:toUpperCase(v_gender) == 'FEMALE' ? 'selected' : ''}>
                                    Female
                                </option>
                                <option value="OTHER"  ${fn:toUpperCase(v_gender) == 'OTHER'  ? 'selected' : ''}>Other
                                </option>
                            </select>
                            <c:if test="${not empty e}">
                                <span class="cf__err-msg">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8"
                                                                                                   x2="12" y2="12"/><line
                                            x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    ${e}
                                </span>
                            </c:if>
                        </div>

                        <%-- Date of Birth --%>
                        <c:set var="e" value="${fieldErrors['birthday']}"/>
                        <div class="cf__field${not empty e ? ' cf__field--error' : ''}">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <rect x="3" y="4" width="18" height="18" rx="2"/>
                                    <line x1="16" y1="2" x2="16" y2="6"/>
                                    <line x1="8" y1="2" x2="8" y2="6"/>
                                    <line x1="3" y1="10" x2="21" y2="10"/>
                                </svg>
                                Date of Birth <span class="cf__req">*</span>
                            </label>
                            <input class="cf__input" type="date" name="birthday"
                                   value="${v_birthday}">
                            <c:if test="${not empty e}">
                                <span class="cf__err-msg">
                                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8"
                                                                                                   x2="12" y2="12"/><line
                                            x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    ${e}
                                </span>
                            </c:if>
                        </div>

                        <%-- Source --%>
                        <div class="cf__field">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8"/>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                                </svg>
                                Source
                            </label>
                            <input class="cf__input" type="text" name="source"
                                   value="${v_source}" placeholder="Facebook, Instagram...">
                        </div>

                        <%-- Address --%>
                        <div class="cf__field">
                            <label class="cf__label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                     stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/>
                                    <circle cx="12" cy="10" r="3"/>
                                </svg>
                                Address
                            </label>
                            <input class="cf__input" type="text" name="address"
                                   value="${v_address}"
                                   placeholder="Ex: 123 Nguyen Van Linh, Q7...">
                        </div>

                    </div>
                </div>


                <!-- ══ COL 3: STYLE TAGS ══ -->
                <div class="cf__col cf__col--3">
                    <div class="cf__col-header">
                        <div class="cf__col-icon cf__col-icon--navy">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/>
                                <line x1="7" y1="7" x2="7.01" y2="7"/>
                            </svg>
                        </div>
                        <span class="cf__col-title">Style Preferences</span>
                    </div>

                    <p class="cf__tag-hint">Select all that apply — these help us personalize recommendations.</p>

                    <div class="cf__tags">
                        <c:forEach items="${allStyleTags}" var="s">
                            <%--
                                Check logic:
                                Case A (POST error): selectedTags is a Set<String> → check contains(tagId.toString())
                                Case B (GET):        customerDetail.styleTags is List<StyleTag>
                                                     → check if any tag in the list has tagId == s.tagId
                                We detect which case by testing whether selectedTags is set.
                            --%>
                            <c:set var="isChecked" value="false"/>
                            <c:choose>
                                <c:when test="${not empty selectedTags}">
                                    <%-- POST error path: use Set<String> --%>
                                    <c:if test="${selectedTags.contains(s.tagId.toString())}">
                                        <c:set var="isChecked" value="true"/>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <%-- GET path: iterate customerDetail.styleTags --%>
                                    <c:forEach items="${customerDetail.styleTags}" var="ct">
                                        <c:if test="${ct.tagId == s.tagId}">
                                            <c:set var="isChecked" value="true"/>
                                        </c:if>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>

                            <label class="cf__tag">
                                <input type="checkbox" name="tagIds" value="${s.tagId}"
                                    ${isChecked ? 'checked' : ''}>
                                <span>${s.tagName}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

            </div>
            <%-- /.cf__body --%>

            <!-- ══ FOOTER ══ -->
            <div class="cf__footer">
                <a href="${pageContext.request.contextPath}/customers/detail?customerId=${customerDetail.customerId}"
                   class="cf__btn cf__btn--secondary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                    Cancel
                </a>

                <button type="submit" class="cf__btn cf__btn--primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v14a2 2 0 01-2 2z"/>
                        <polyline points="17 21 17 13 7 13 7 21"/>
                        <polyline points="7 3 7 8 15 8"/>
                    </svg>
                    Save Changes
                </button>
            </div>

        </form>
    </div>
</div>

<script>
    (function () {
        /* Scroll to first error on POST re-render */
        var first = document.querySelector('.cf__field--error');
        if (first) {
            first.scrollIntoView({behavior: 'smooth', block: 'center'});
            var input = first.querySelector('input, select');
            if (input) input.focus({preventScroll: true});
        }
        /* Auto-dismiss banner after 6s */
        var banner = document.getElementById('cfErrorBanner');
        if (banner) {
            setTimeout(function () {
                banner.style.transition = 'opacity .4s';
                banner.style.opacity = '0';
                setTimeout(function () {
                    banner.remove();
                }, 400);
            }, 6000);
        }
    })();
</script>
