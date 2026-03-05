<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>

<div class="cf mt-5">
    <div class="cf__container">

        <div class="cf__header">
            <h2 class="cf__title">Edit Customer Profile</h2>
        </div>

        <!-- ERROR BOX -->
        <c:if test="${not empty errors}">
            <div class="cf__error-box">
                <ul>
                    <c:forEach items="${errors}" var="e">
                        <li style="color: red;">${e}</li>
                        </c:forEach>
                </ul>
            </div>
        </c:if>

        <form class="cf__form"
              method="post"
              action="${pageContext.request.contextPath}/customers/edit">

            <input type="hidden" name="customerId"
                   value="${customerDetail.customerId}"/>

            <!-- BASIC -->
            <section class="cf__section">
                <h3 class="cf__section-title">Basic Information</h3>

                <div class="cf__grid cf__grid--2">
                    <div class="cf__field">
                        <label class="cf__label">Full Name *</label>
                        <input class="cf__input"
                               type="text"
                               name="name"
                               value="${customerDetail.name}"
                               required>
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Phone Number *</label>
                        <input class="cf__input"
                               type="tel"
                               name="phone"
                               value="${customerDetail.phone}"
                               required>
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Gender *</label>
                        <select class="cf__input" name="gender" required>
                            <option value="">Select gender</option>
                            <option value="MALE"
                                    <c:if test="${customerDetail.gender == 'MALE'}">selected</c:if>>
                                        Male
                                    </option>
                                    <option value="FEMALE"
                                    <c:if test="${customerDetail.gender == 'FEMALE'}">selected</c:if>>
                                        Female
                                    </option>
                                    <option value="OTHER"
                                    <c:if test="${customerDetail.gender == 'OTHER'}">selected</c:if>>
                                        Other
                                    </option>
                            </select>
                        </div>
                    </div>

                    <div class="cf__grid cf__grid--2">
                        <div class="cf__field">
                            <label class="cf__label">Email</label>
                            <input class="cf__input"
                                   type="email"
                                   name="email"
                                   value="${customerDetail.email}">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Date of Birth</label>
                        <input class="cf__input"
                               type="date"
                               name="birthday"
                               value="${customerDetail.birthday}">
                    </div>
                </div>

                <div class="cf__field">
                    <label class="cf__label">Source</label>
                    <input class="cf__input"
                           type="text"
                           name="source"
                           value="${customerDetail.source}">
                </div>

                <div class="cf__field">
                    <label class="cf__label">Address</label>
                    <input class="cf__input"
                           type="text"
                           name="address"
                           value="${customerDetail.address}">
                </div>
            </section>

            <!-- FIT -->
            <section class="cf__section">
                <h3 class="cf__section-title">Fit Profile</h3>

                <div class="cf__grid cf__grid--3">
                    <div class="cf__field">
                        <label class="cf__label">Height (cm)</label>
                        <input class="cf__input"
                               type="number"
                               name="height"
                               value="${customerDetail.latestMeasurement.height}">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Weight (kg)</label>
                        <input class="cf__input"
                               type="number"
                               name="weight"
                               value="${customerDetail.latestMeasurement.weight}">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Preferred Size</label>
                        <select class="cf__input" name="preferred_size">
                            <option value="S" <c:if test="${customerDetail.latestMeasurement.preferredSize == 'S'}">selected</c:if>>S</option>
                            <option value="M" <c:if test="${customerDetail.latestMeasurement.preferredSize == 'M'}">selected</c:if>>M</option>
                            <option value="L" <c:if test="${customerDetail.latestMeasurement.preferredSize == 'L'}">selected</c:if>>L</option>
                            <option value="XL" <c:if test="${customerDetail.latestMeasurement.preferredSize == 'XL'}">selected</c:if>>XL</option>
                            </select>
                        </div>
                    </div>
                </section>

                <!-- BODY MEASUREMENT -->
                <section class="cf__section">
                    <h3 class="cf__section-title">Body Measurement</h3>

                    <div class="cf__grid cf__grid--4">
                        <div class="cf__field">
                            <label class="cf__label">Bust (cm)</label>
                            <input class="cf__input" type="number" step="0.1" name="bust" value="${customerDetail.latestMeasurement.bust}" placeholder="Bust"></div>
                    <div class="cf__field"><label class="cf__label">Waist (cm)</label><input class="cf__input" type="number" step="0.1" name="waist" value="${customerDetail.latestMeasurement.waist}" placeholder="Waist"></div>
                    <div class="cf__field"><label class="cf__label">Hips (cm)</label><input class="cf__input" type="number" step="0.1" name="hips" value="${customerDetail.latestMeasurement.hips}" placeholder="Hips"></div>
                    <div class="cf__field"><label class="cf__label">Shoulder (cm)</label><input class="cf__input" type="number" step="0.1" name="shoulder" value="${customerDetail.latestMeasurement.shoulder}" placeholder="Shoulder"></div>
                </div>

                <div class="cf__field">
                    <label class="cf__label">Body Shape</label>
                    <select name="bodyShape" class="cf__input">
                        <option value="HOURGLASS" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'HOURGLASS'}">selected</c:if>>Hourglass</option>
                        <option value="PEAR" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'PEAR'}">selected</c:if>>Pear</option>
                        <option value="APPLE" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'APPLE'}">selected</c:if>>Apple</option>
                        <option value="RECTANGLE" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'RECTANGLE'}">selected</c:if>>Rectangle</option>
                        <option value="INVERTED TRIANGLE" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'INVERTED TRIANGLE'}">selected</c:if>>Inverted Triangle</option>
                        <option value="SLENDER" <c:if test="${customerDetail.latestMeasurement.bodyShape == 'SLENDER'}">selected</c:if>>Slender</option>
                        </select>
                    </div>
                </section>

                <!-- STYLE -->
                <section class="cf__section">
                    <h3 class="cf__section-title">Preferences & Style</h3>

                    <div class="cf__tags">
                    <c:forEach items="${allStyleTags}" var="s">

                        <c:set var="checked" value="false"/>

                        <!-- duyệt danh sách style của customer -->
                        <c:forEach items="${customerDetail.styleTags}" var="st">
                            <c:if test="${st.tagId == s.tagId}">
                                <c:set var="checked" value="true"/>
                            </c:if>
                        </c:forEach>

                        <label class="cf__tag">
                            <input type="checkbox"
                                   name="tagIds"
                                   value="${s.tagId}"
                                   <c:if test="${checked}">checked</c:if>>
                            <span>${s.tagName}</span>
                        </label>

                    </c:forEach>
                </div>
            </section>

            <div class="cf__footer">
                <button type="button"
                        class="cf__btn cf__btn--secondary"
                        onclick="window.location.href = '${pageContext.request.contextPath}/customers'">
                    Cancel
                </button>

                <button type="submit" class="cf__btn cf__btn--primary">
                    Update Profile
                </button>

            </div>

        </form>
    </div>
</div>