<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="segment-detail">

    <!-- HEADER -->
    <div class="segment-header-card">

        <div class="segment-header-left">
            <h2 class="segment-name">${requestScope.segmentInfo.segmentName}</h2>

            <div class="segment-meta">

                <span class="status-badge active">
                    ● Active
                </span>

                <span class="customer-count">
                    <strong>${segmentInfo.numberData}</strong> customers
                </span>

            </div>
        </div>

    </div>


    <!-- TABS -->
    <div class="segment-tabs">

        <button class="tab-btn active" data-tab="general">
            General Information
        </button>
        <c:if test="${segmentInfo.segmentType eq 'DYNAMIC'}">
            <button class="tab-btn" data-tab="config">
                Configuration
            </button>
        </c:if>
        <button class="tab-btn" data-tab="history">
            History
        </button>

    </div>


    <div class="segment-layout">

        <!-- LEFT PANEL -->
        <div class="segment-left">

            <!-- GENERAL -->
            <div class="tab-content active" id="general">

                <div class="card">
                    <button id="editBtn"
                            style="background-color: #0a58ca;
                                width: 70px;
                                padding: 5px;
                                 border-radius: 5px;
                                border: none;
                                margin-left: 80%">
                        <i class="fas fa-pen" style="color: white"></i>
                        <span style="margin-left: 5px; color: white">Edit</span>
                    </button>
                    <div class="info-grid">

                        <div class="info-item">
                            <label><strong>Name</strong>:</label>
                            <span>${segmentInfo.segmentName}</span>
                        </div>

                        <div class="info-item">
                            <label><strong>Segment Type:</strong> </label>
                            <span>${segmentInfo.segmentType}</span>
                        </div>

                        <div class="info-item">
                            <label><strong>Description:</strong></label>
                            <span>${segmentInfo.criteriaLogic}</span>
                        </div>

                        <div class="info-item">
                            <label><strong>Total Customers:</strong></label>
                            <span>${segmentInfo.numberData}</span>
                        </div>

                        <div class="info-item">
                            <label><strong>Last Updated:</strong></label>
                            <span>${segmentInfo.updatedAt}</span>
                        </div>

                        <div class="info-item">
                            <label><strong>Created By:</strong></label>
                            <span>${segmentInfo.createdBy}</span>
                        </div>

                    </div>

                </div>

            </div>


            <!-- CONFIG -->
            <div class="tab-content" id="config">

                <div class="card">
                    <button
                            style="background-color: #0a58ca;
                                width: 70px;
                                padding: 5px;
                                 border-radius: 5px;
                                border: none;
                                margin-left: 80%">
                        <i class="fas fa-save" style="color: white"></i>
                        <span style="margin-left: 5px; color: white">Save</span>
                    </button>
                    <div class="config-row" style="padding: 5px 0">
                        <strong style="font-size: 18px">FILTER</strong>

                    </div>


                    <div class="config-row btn-add-filter" style="">

                        <div class="group-condition">

                            <!-- template điều kiện -->
                            <div id="conditions-container">

                                <c:forEach items="${configs}" var="f">
                                    <div class="condition-row">

                                        <!-- FIELD -->
                                        <select class="field">
                                            <option value="last_purchase" data-type="date"
                                                    <c:if test="${f.field eq 'last_purchase'}">selected</c:if>>Last
                                                Purchase
                                            </option>

                                            <option value="birthday" data-type="date" <c:if test="${f.field eq
                                            'birthday'}">selected</c:if>>Birth Day
                                            </option>

                                            <option value="return_rate" data-type="number" <c:if test="${f.field eq
                                            'return_rate'}">selected</c:if>>Return Rate
                                            </option>

                                            <option value="source" data-input="select" data-source="source-options"
                                                    <c:if test="${f.field eq 'source'}">selected</c:if>>
                                                Source
                                            </option>

                                            <option value="loyalty_tier" data-input="select"
                                                    data-source="loyalty-options"
                                                    <c:if test="${f.field eq 'loyalty_tier'}">selected</c:if>>
                                                Loyalty Tier
                                            </option>
                                        </select>

                                        <!-- OPERATOR -->
                                        <select class="operator">
                                            <option value="=" <c:if test="${f.operator eq '='}">selected</c:if>>Equal
                                            </option>
                                            <option value=">" <c:if test="${f.operator eq '>'}">selected</c:if>>
                                                Greater
                                            </option>
                                            <option value="<" <c:if test="${f.operator eq '<'}">selected</c:if>>Less
                                            </option>
                                            <option value="LIKE" <c:if test="${f.operator eq 'LIKE'}">selected</c:if>>
                                                Contains
                                            </option>
                                        </select>

                                        <!-- VALUE -->

                                        <c:choose>
                                            <c:when test="${f.field eq 'last_purchase' or f.field eq 'birthday'}">
                                                <input class="value" type="date" value="${f.value}"
                                                       style="width: 110px;"/>
                                            </c:when>

                                            <c:when test="${f.field eq 'return_rate'}">
                                                <input class="value" type="number" step="any" value="${f.value}"
                                                       style="width: 110px;"/>
                                            </c:when>

                                            <c:when test="${f.field eq 'source'}">
                                                <select style=" width: 110px" class="value">
                                                    <c:forEach items="${sources}" var="s">
                                                        <option value="${s}"
                                                                <c:if test="${f.value eq s}">selected</c:if>>${s}</option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>

                                            <c:otherwise>
                                                <select style=" width: 110px" class="value">
                                                    <c:forEach items="${ranks}" var="r">
                                                        <option value="${r}"
                                                                <c:if test="${f.value eq r}">selected</c:if>>${r}</option>
                                                    </c:forEach>
                                                </select>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- LOGIC -->

                                        <select class="logic-operator">
                                            <option value="AND" <c:if test="${f.logic eq 'AND'}">selected</c:if>>AND
                                            </option>
                                            <option value="OR" <c:if test="${f.logic eq 'OR'}">selected</c:if>>OR
                                            </option>
                                        </select>
                                        <button type="button" class="delete-condition">🗑</button>
                                    </div>
                                </c:forEach>
                            </div>

                            <button type="button" id="add-condition">+ Add Condition</button>

                            <template id="condition-template">
                                <div class="condition-row">

                                    <!-- FIELD -->
                                    <select class="field">
                                        <option value="last_purchase" data-type="date">Last Purchase</option>

                                        <option value="birthday" data-type="date">Birth Day</option>

                                        <option value="return_rate" data-type="number">Return Rate</option>

                                        <option value="source" data-input="select" data-source="source-options">
                                            Source
                                        </option>

                                        <option value="loyalty_tier" data-input="select" data-source="loyalty-options">
                                            Loyalty Tier
                                        </option>
                                    </select>

                                    <!-- OPERATOR -->
                                    <select class="operator">
                                        <option value="=">Equal</option>
                                        <option value=">">Greater</option>
                                        <option value="<">Less</option>
                                        <option value="LIKE">Contains</option>
                                    </select>

                                    <!-- VALUE -->
                                    <select id="source-options" style="display: none; width: 115px">

                                        <c:forEach items="${sources}" var="s">
                                            <option value="${s}">${s}</option>
                                        </c:forEach>
                                    </select>

                                    <select id="loyalty-options" style="display: none; width: 115px">

                                        <c:forEach items="${ranks}" var="r">
                                            <option value="${r}">${r}</option>
                                        </c:forEach>
                                    </select>

                                    <!-- LOGIC -->

                                    <select class="logic-operator">
                                        <option value="AND">AND</option>
                                        <option value="OR">OR</option>
                                    </select>
                                    <button type="button" class="delete-condition">🗑</button>
                                </div>

                            </template>
                        </div>
                    </div>
                    <div class="config-row">

                        <div>
                            <strong style="font-size: 18px">Auto Assignment</strong>
                            <p class="config-desc">
                                Automatically assign customers to staff
                            </p>
                        </div>

                        <label class="switch">
                            <input type="checkbox"
                                   <c:if test="${segmentInfo.segmentType eq 'DYNAMIC'}">checked</c:if>>
                            <span class="slider"></span>


                        </label>


                    </div>
                    <span class="method">Method assign customer to staff</span>
                    <select class="method">

                        <option value="ROUND_ROBIN" <c:if test="${segmentInfo.assignType eq 'ROUND_ROBIN'}">checked
                        </c:if>>Default
                        </option>
                        <option value="LEAST_CUSTOMERS"
                                <c:if test="${segmentInfo.assignType eq 'LEAST_CUSTOMERS'}">checked
                        </c:if> >Least Customer is Assign first
                        </option>
                    </select>

                </div>

            </div>


            <!-- HISTORY -->
            <div class="tab-content" id="history">

                <div class="card">

                    <div class="history-timeline">

                        <c:forEach var="h" items="${history}">

                            <div class="history-item">

                                <div class="history-dot"></div>

                                <div class="history-content">

                                    <div class="history-desc">
                                            ${h.changeDescription}
                                    </div>

                                    <div class="history-meta">
                                            ${h.updatedByName}
                                    </div>
                                    <div class="history-meta">
                                            ${h.updatedAt}
                                    </div>

                                </div>

                            </div>

                        </c:forEach>

                        <c:if test="fesf">
                            <div class="empty">
                                No change history
                            </div>
                        </c:if>

                    </div>

                </div>

            </div>

        </div>


        <!-- RIGHT PANEL -->
        <div class="segment-right">

            <div class="card">

                <div class="customer-header">

                    <p><strong style="font-size: 21px">Customers</strong></p>

                    <input type="text"
                           placeholder="Search customer..."
                           class="customer-search">
                    <button onclick=""
                            style="font-size: 15px; padding: 3px; border: none; background-color: transparent">🔍
                    </button>

                </div>

                <table class="customer-table">

                    <thead>
                    <tr>
                        <th>Name</th>
                        <th>Owner</th>
                        <th>Loyalty</th>
                        <th>Email</th>
                        <th>Source</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>

                    <c:forEach var="c" items="${listCustomer}">
                        <tr>

                            <td class="customer-name">
                                    ${c.name}
                            </td>

                            <td> ${c.owner}</td>
                            <td> ${c.loyaltyTier}</td>
                            <td> ${c.email}</td>
                            <td> ${c.source}</td>
                            <td></td>
                        </tr>
                    </c:forEach>

                    </tbody>

                </table>

            </div>

        </div>

    </div>

</div>

<div id="toast" class="toast">
    <div class="toast-left">
        <div id="toastIcon" class="toast-icon"></div>
    </div>

    <div class="toast-content">
        <div id="toastMessage" class="toast-message"></div>
    </div>

    <button class="toast-close" id="toastCloseBtn">×</button>

    <div class="toast-progress">
        <div id="toastBar"></div>
    </div>
</div>


<script>
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.segmentId = "${segmentInfo.segmentId}";
    window.__PAGE_STATUS__ = "<c:out value='${param.status}' default='' />";
</script>