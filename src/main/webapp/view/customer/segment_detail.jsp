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
            <form method="post" action="${pageContext.request.contextPath}/customers/config-segment">
                <div class="tab-content" id="config">
                    <input type="hidden" name="segmentId" value="${segmentInfo.segmentId}">
                    <div class="card">
                        <button type="submit"
                                style="background-color: #0a58ca;
                                width: 70px;
                                padding: 5px;
                                 border-radius: 5px;
                                border: none;
                                margin-left: 80%">
                            <i class="fas fa-save" style="color: white"></i>
                            <span style="margin-left: 5px; color: white">Save</span>
                        </button>

                        <button type="submit" class="reload_btn" style=" "><i
                                class="fas fa-sync"></i></button>
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
                                            <select class="field" name="field">
                                                <option value="last_purchase" data-type="date"
                                                        <c:if test="${f.field eq 'last_purchase'}">selected</c:if>>Last
                                                    Purchase
                                                </option>

                                                <option value="birthday" data-type="date" <c:if test="${f.field eq
                                            'birthday'}">selected</c:if>>Birth Day
                                                </option>

                                                    <%--                                                <option value="return_rate" data-type="number" <c:if test="${f.field eq--%>
                                                    <%--                                            'return_rate'}">selected</c:if>>Return Rate--%>
                                                    <%--                                                </option>--%>

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
                                            <select class="operator" name="operator">
                                                <option value="=" <c:if test="${f.operator eq '='}">selected</c:if>>
                                                    Equal
                                                </option>
                                                <option value=">" <c:if test="${f.operator eq '>'}">selected</c:if>>
                                                    Greater
                                                </option>
                                                <option value="<" <c:if test="${f.operator eq '<'}">selected</c:if>>Less
                                                </option>
                                                <option value="LIKE"
                                                        <c:if test="${f.operator eq 'LIKE'}">selected</c:if>>
                                                    Contains
                                                </option>
                                            </select>


                                            <c:choose>
                                                <c:when test="${f.field eq 'last_purchase' or f.field eq 'birthday'}">
                                                    <input class="value" type="date" value="${f.value}" name="value"
                                                           style="width: 110px;"/>
                                                </c:when>

                                                <c:when test="${f.field eq 'return_rate'}">
                                                    <input class="value" type="number" step="any" value="${f.value}"
                                                           name="value"
                                                           style="width: 110px;"/>
                                                </c:when>

                                                <c:when test="${f.field eq 'source'}">
                                                    <select style=" width: 110px" class="value" name="value">
                                                        <option value="">--Select--</option>
                                                        <c:forEach items="${sources}" var="s">
                                                            <option value="${s}"
                                                                    <c:if test="${f.value eq s}">selected</c:if>>${s}</option>
                                                        </c:forEach>
                                                    </select>
                                                </c:when>

                                                <c:otherwise>
                                                    <select style=" width: 110px" class="value" name="value">
                                                        <option value="">--Select--</option>
                                                        <c:forEach items="${ranks}" var="r">
                                                            <option value="${r}"
                                                                    <c:if test="${f.value eq r}">selected</c:if>>${r}</option>
                                                        </c:forEach>
                                                    </select>
                                                </c:otherwise>
                                            </c:choose>

                                            <!-- LOGIC -->

                                            <select class="logic-operator" name="logic">
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
                                        <select class="field" name="field">
                                            <option value="last_purchase" data-type="date">Last Purchase</option>

                                            <option value="birthday" data-type="date">Birth Day</option>

                                            <%--                                            <option value="return_rate" data-type="number">Return Rate</option>--%>

                                            <option value="source" data-input="select" data-source="source-options">
                                                Source
                                            </option>

                                            <option value="loyalty_tier" data-input="select"
                                                    data-source="loyalty-options">
                                                Loyalty Tier
                                            </option>
                                        </select>

                                        <!-- OPERATOR -->
                                        <select class="operator" name="operator">
                                            <option value="=">Equal</option>
                                            <option value=">">Greater</option>
                                            <option value="<">Less</option>
                                            <option value="LIKE">Contains</option>
                                        </select>

                                        <!-- VALUE -->
                                        <select id="source-options" style="display: none; width: 115px" name="value">
                                            <option value="">--Select--</option>
                                            <c:forEach items="${sources}" var="s">
                                                <option value="${s}">${s}</option>
                                            </c:forEach>
                                        </select>

                                        <select id="loyalty-options" style="display: none; width: 115px" name="value">
                                            <option value="">--Select--</option>
                                            <c:forEach items="${ranks}" var="r" varStatus="loop">
                                                <option value="${r}"
                                                >${r}</option>
                                            </c:forEach>
                                        </select>

                                        <!-- LOGIC -->

                                        <select class="logic-operator" name="logic">
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
                        <select class="method" name="assignmentType">

                            <option value="ROUND_ROBIN"
                                    <c:if test="${segmentInfo.assignType eq 'ROUND_ROBIN' }">selected
                            </c:if>>Default
                            </option>
                            <option value="LEAST_CUSTOMERS"
                                    <c:if test="${segmentInfo.assignType eq 'LEAST_CUSTOMERS' }">selected
                            </c:if> >Least Customer is Assign first
                            </option>
                        </select>

                    </div>

                </div>
            </form>


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
                           id="searchInput"
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
                                <a href="${pageContext.request.contextPath}/customers/detail?customerId=${c.customerId}"> ${c.name}</a>
                            </td>

                            <td> ${c.owner}</td>
                            <td> <span class="loyalty-badge ${c.loyaltyTier}">
                                    ${c.loyaltyTier}
                            </span></td>
                            <td> ${c.email}</td>
                            <td> ${c.source}</td>
                            <td class="action-cell">
                                <form action="${pageContext.request.contextPath}/customers/segment/remove-customer"
                                      method="post">
                                    <button class="btn-delete" data-id="" title="Remove from segment" type="submit">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                    <input type="hidden" value="${c.customerId}" name="customer_id"/>
                                    <input type="hidden" value="${segmentInfo.segmentId}" name="segment_id"/>
                                </form>

                                <button class="btn-assign" data-id="${c.customerId}" title="Change owner">
                                    <i class="fas fa-user-edit"></i>
                                </button>

                            </td>
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

<form method="post"
      action="${pageContext.request.contextPath}/customers/segment/change-owner">
    <div id="assignModal" class="modal">
        <div class="modal-content">

            <div class="modal-header">
                <h3>Assign Owner</h3>
                <span class="close-btn" id="closeAssignModal">&times;</span>
            </div>

            <input type="text" id="staffSearch" placeholder="Search staff..."
                   class="modal-search">

            <div class="staff-list" id="staffList">
                <c:forEach var="u" items="${staffs}">
                    <label class="staff-item">

                        <!-- radio ẩn -->
                        <input type="radio" name="user_id" value="${u.userId}" class="staff-radio">

                        <div class="staff-info">
                            <span><strong>${u.fullName}</strong></span>
                            <p>${u.email}</p>
                        </div>

                    </label>
                </c:forEach>
            </div>

            <div class="modal-footer">
                <button id="confirmAssign" disabled type="submit">Confirm</button>
                <button class="btn-primary" onclick="closeChangeOwnerModal()" type="button">Cancel</button>

            </div>

        </div>
    </div>

    <%--    <input type="hidden" value="${c.customerId}" name="customer_id"/>--%>
    <input type="hidden" value="${segmentInfo.segmentId}" name="segment_id"/>
</form>


<script>
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.segmentId = "${segmentInfo.segmentId}";
    window.__PAGE_STATUS__ = "<c:out value='${param.status}' default='' />";
</script>