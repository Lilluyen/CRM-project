<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>

<div class="cf">
    <div class="cf__container">

        <!-- HEADER -->
        <div class="cf__header">
            <div class="cf__header-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"
                     stroke-linecap="round" stroke-linejoin="round">
                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                    <line x1="19" y1="8" x2="19" y2="14"/>
                    <line x1="16" y1="11" x2="22" y2="11"/>
                </svg>
            </div>
            <div>
                <h2 class="cf__title">New Customer Profile</h2>
                <p class="cf__subtitle">Fill in the details below to register a new customer</p>
            </div>
        </div>

        <%-- Global error banner --%>
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
              action="${pageContext.request.contextPath}/customers/add-customer"
              novalidate>

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
                                   value="${not empty oldName ? oldName : ''}"
                                   placeholder="Ex: Nguyen Lan Anh">
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
                                   value="${not empty oldPhone ? oldPhone : ''}"
                                   placeholder="Ex: 0987654321">
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
                                   value="${not empty oldEmail ? oldEmail : ''}"
                                   placeholder="Ex: example@gmail.com">
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
                                <option value="MALE"   ${oldGender == 'MALE'   ? 'selected' : ''}>Male</option>
                                <option value="FEMALE" ${oldGender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                <option value="OTHER"  ${oldGender == 'OTHER'  ? 'selected' : ''}>Other</option>
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

                        <%-- Birthday --%>
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
                                   value="${not empty oldBirthday ? oldBirthday : ''}">
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
                                   value="${not empty oldSource ? oldSource : ''}"
                                   placeholder="Facebook, Instagram...">
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
                                   value="${not empty oldAddress ? oldAddress : ''}"
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
                        <c:forEach items="${styleTagList}" var="s">
                            <label class="cf__tag">
                                <input type="checkbox" name="styleTags" value="${s.tagId}"
                                    ${not empty selectedTags and selectedTags.contains(s.tagId.toString()) ? 'checked' : ''}>
                                <span>${s.tagName}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

            </div>
            <%-- /.cf__body --%>

            <!-- FOOTER -->
            <div class="cf__footer">
                <button type="button" class="cf__btn cf__btn--secondary"
                        onclick="window.location.href='${pageContext.request.contextPath}/customers'">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                         stroke-linejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                    Cancel
                </button>
                <button type="submit" class="cf__btn cf__btn--primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                         stroke-linejoin="round">
                        <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v14a2 2 0 01-2 2z"/>
                        <polyline points="17 21 17 13 7 13 7 21"/>
                        <polyline points="7 3 7 8 15 8"/>
                    </svg>
                    Save Profile
                </button>
            </div>

        </form>
    </div>
</div>

<script>
    (function () {
        /* Auto-scroll to first error field */
        var first = document.querySelector('.cf__field--error');
        if (first) {
            first.scrollIntoView({behavior: 'smooth', block: 'center'});
            var input = first.querySelector('input, select');
            if (input) input.focus({preventScroll: true});
        }
        /* Auto-dismiss error banner after 6s */
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
