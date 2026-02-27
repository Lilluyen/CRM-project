<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>

<div class="cf col-10 mt-5">
    <div class="cf__container ">

        <div class="cf__header">
            <h2 class="cf__title">New Customer Profile</h2>
        </div>

        <form class="cf__form"
              method="post"
              action="${pageContext.request.contextPath}/customers/add-customer">

            <!-- BASIC -->
            <section class="cf__section">
                <h3 class="cf__section-title">Basic Information</h3>

                <div class="cf__grid cf__grid--2">
                    <div class="cf__field">
                        <label class="cf__label">Full Name *</label>
                        <input class="cf__input" type="text" name="name" placeholder="Ex: Nguyen Lan Anh" required>
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Phone Number *</label>
                        <input class="cf__input" type="tel" name="phone" placeholder="Ex: 0987654321" required>
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Gender *</label>
                        <select class="cf__input" name="gender" required>
                            <option value="">Select gender</option>
                            <option value="MALE">Male</option>
                            <option value="FEMALE">Female</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                </div>

                <div class="cf__grid cf__grid--2">
                    <div class="cf__field">
                        <label class="cf__label">Email</label>
                        <input class="cf__input" type="email" name="email" placeholder="Ex: example@gmail.com">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Date of Birth</label>
                        <input class="cf__input" type="date" name="birthday">
                    </div>
                </div>

                <div class="cf__field">
                    <label class="cf__label">Social Link</label>
                    <input class="cf__input" type="text" name="socialLink" placeholder="Ex: https://www.facebook.com/username">
                </div>

                <div class="cf__field">
                    <label class="cf__label">Address</label>
                    <input class="cf__input" type="text" name="address" placeholder="Ex: 123 Nguyen Van Linh, District 7, Ho Chi Minh City">
                </div>
            </section>

            <!-- FIT -->
            <section class="cf__section">
                <h3 class="cf__section-title">Fit Profile</h3>

                <div class="cf__grid cf__grid--3">
                    <div class="cf__field">
                        <label class="cf__label">Height (cm)</label>
                        <input class="cf__input" type="number" name="height" placeholder="Ex: 170">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Weight (kg)</label>
                        <input class="cf__input" type="number" name="weight" placeholder="Ex: 65">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Preferred Size</label>
                        <select class="cf__input" name="preferred_size">
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
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
                        <input class="cf__input" type="number" step="0.1" name="bust" placeholder="Ex: 90.5">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Waist (cm)</label>
                        <input class="cf__input" type="number" step="0.1" name="waist" placeholder="Ex: 75.0">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Hips (cm)</label>
                        <input class="cf__input" type="number" step="0.1" name="hips" placeholder="Ex: 95.5">
                    </div>

                    <div class="cf__field">
                        <label class="cf__label">Shoulder (cm)</label>
                        <input class="cf__input" type="number" step="0.1" name="shoulder" placeholder="Ex: 40.0">
                    </div>

                </div>
                     <div class="cf__field">
                        <label class="cf__label">Body Shape</label>
                        <select name="bodyShape" class="cf__input">
                            <option value="HOURGLASS">Hourglass</option>
                            <option value="PEAR">Pear</option>
                            <option value="APPLE">Apple</option>
                            <option value="RECTANGLE">Rectangle</option>
                            <option value="INVERTED_TRIANGLE">Inverted Triangle</option>
                        </select>
                    </div>
            </section>

            <!-- STYLE -->
            <section class="cf__section">
                <h3 class="cf__section-title">Preferences & Style</h3>

                <div class="cf__tags">
                    <c:forEach items="${styleTagList}" var="s">
                        <label class="cf__tag">
                            <input type="checkbox" name="styleTags" value="${s.tagId}">
                            <span>${s.tagName}</span>
                        </label>
                    </c:forEach>
                </div>
            </section>

            <div class="cf__footer">
                <button type="button"
                        class="cf__btn cf__btn--secondary"
                        _attach
                        onclick="window.location.href = '${pageContext.request.contextPath}/customers'">
                    Cancel
                </button>

                <button type="submit" class="cf__btn cf__btn--primary">
                    Save Profile
                </button>
            </div>

        </form>
    </div>
</div>
