<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<div class="customer-detail col-10 mt-5">

    <!-- HEADER -->
    <div class="customer-detail__header">

        <div class="customer-detail__profile">

            <div class="customer-detail__avatar">
                ${customerDetail.name.substring(0,1)}
            </div>

            <div class="customer-detail__info">
                <h2 class="customer-detail__name">
                    ${customerDetail.name}
                </h2>

                <p class="customer-detail__meta">
                    ${customerDetail.phone} • ${customerDetail.email}
                </p>

                <p class="customer-detail__owner">
                    Owner: ${customerDetail.ownerName}
                </p>
            </div>
        </div>

        <div class="customer-detail__actions">
            <a href="${pageContext.request.contextPath}/customers/edit?customerId=${customerDetail.customerId}"
               class="customer-detail__btn customer-detail__btn--outline">
                Edit
            </a>

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
                <h3 class="customer-detail__card-title">
                    Basic Information
                </h3>

                <div class="customer-detail__row">
                    <span>Gender</span>
                    <strong>${customerDetail.gender}</strong>
                </div>

                <div class="customer-detail__row">
                    <span>Birthday</span>
                    <strong>
                        <fmt:formatDate value="${customerDetail.birthday}"
                                        pattern="dd/MM/yyyy"/>
                    </strong>
                </div>

                <div class="customer-detail__row">
                    <span>Address</span>
                    <strong>${customerDetail.address}</strong>
                </div>

                <div class="customer-detail__row">
                    <span>Social</span>
                    <strong>
                        <a href="${customerDetail.socialLink}" target="_blank">
                            View Profile
                        </a>
                    </strong>
                </div>
            </div>


            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">
                    Style Preferences
                </h3>

                <div class="customer-detail__tags">
                    <c:forEach var="tag" items="${customerDetail.styleTags}">
                        <span class="customer-detail__tag">
                            ${tag.tagName}
                        </span>
                    </c:forEach>

                    <c:if test="${empty customerDetail.styleTags}">
                        <span class="customer-detail__empty">
                            No style tags
                        </span>
                    </c:if>
                </div>
            </div>

        </div>


        <!-- MAIN CONTENT -->
        <div class="customer-detail__main">

            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">
                    Customer Metrics
                </h3>

                <div class="customer-detail__metrics">

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            Customer Type
                        </span>
                        <span class="customer-detail__metric-value">
                            ${customerDetail.customerType}
                        </span>
                    </div>

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            Status
                        </span>
                        <span class="customer-detail__metric-value customer-detail__badge">
                            ${customerDetail.status}
                        </span>
                    </div>

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            Loyalty Tier
                        </span>
                        <span class="customer-detail__metric-value">
                            ${customerDetail.loyaltyTier}
                        </span>
                    </div>

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            RFM Score
                        </span>
                        <span class="customer-detail__metric-value">
                            ${customerDetail.rfmScore}
                        </span>
                    </div>

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            Return Rate
                        </span>
                        <span class="customer-detail__metric-value">
                            ${customerDetail.returnRate}%
                        </span>
                    </div>

                    <div class="customer-detail__metric">
                        <span class="customer-detail__metric-label">
                            Last Purchase
                        </span>
                        <span class="customer-detail__metric-value">
                            ${customerDetail.lastPurchase}
                        </span>
                    </div>

                </div>
            </div>


            <div class="customer-detail__card">
                <h3 class="customer-detail__card-title">
                    Latest Body Measurement
                </h3>

                <c:if test="${customerDetail.latestMeasurement != null}">
                    <div class="customer-detail__measurements">

                        <div class="customer-detail__measurement">
                            <span>Height</span>
                            <strong>${customerDetail.latestMeasurement.height} cm</strong>
                        </div>

                        <div class="customer-detail__measurement">
                            <span>Weight</span>
                            <strong>${customerDetail.latestMeasurement.weight} kg</strong>
                        </div>

                        <div class="customer-detail__measurement">
                            <span>Bust</span>
                            <strong>${customerDetail.latestMeasurement.bust} cm</strong>
                        </div>

                        <div class="customer-detail__measurement">
                            <span>Waist</span>
                            <strong>${customerDetail.latestMeasurement.waist} cm</strong>
                        </div>

                        <div class="customer-detail__measurement">
                            <span>Hips</span>
                            <strong>${customerDetail.latestMeasurement.hips} cm</strong>
                        </div>

                        <div class="customer-detail__measurement">
                            <span>Shoulder</span>
                            <strong>${customerDetail.latestMeasurement.shoulder} cm</strong>
                        </div>

                    </div>
                </c:if>

                <c:if test="${customerDetail.latestMeasurement == null}">
                    <div class="customer-detail__empty">
                        No measurement data available
                    </div>
                </c:if>

            </div>

        </div>

    </div>

</div>