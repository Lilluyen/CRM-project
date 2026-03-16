<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>


<div class="seg-page mt-5">

    <!-- Header -->
    <div class="seg-header">
        <div class="seg-title">
            <i style="font-size: 30px" class="fas fa-users"></i>
            <span>
                <h3 style="
                font-weight: 600;">
                Customer Segment List
                </h3>
            </span>
        </div>

        <button class="btn-create" onclick="openCreateModal()">
            + Add new segment
        </button>
    </div>


    <!-- Filters -->
    <div class="seg-filters">
        <label class="filter-group">
            <i class="fas fa-folder-open filter-icon"></i>
            <select class="filter-select segment_type" name="segment_type">

                <option value="" selected>Segment Type</option>
                <option value="STATIC" <c:if test="${segmentType eq 'STATIC'}">selected</c:if>>Static</option>
                <option value="DYNAMIC" <c:if test="${segmentType eq 'DYNAMIC'}">selected</c:if>>Dynamic</option>
            </select>
        </label>

        <label class="filter-group">
            <i class="fas fa-user filter-icon"></i>
            <select class="filter-select created_by" name="created_by">
                <option value="" selected>Creator</option>
                <c:forEach items="${staffs}" var="s">
                    <option value="${s.userId}"
                            <c:if test="${creator eq s.userId}">selected</c:if>>${s.fullName}</option>
                </c:forEach>
            </select>
        </label>

        <label class="filter-group">
            <i class="fas fa-user filter-icon"></i>
            <select class="filter-select updated_by" name="updated_by">
                <option value="" selected>Updater</option>
                <c:forEach items="${staffs}" var="s">
                    <option
                            value="${s.userId}"
                            <c:if test="${updater eq s.userId}">selected</c:if>>${s.fullName}</option>
                </c:forEach>
            </select>
        </label>

        <label class="filter-date-label">
            <span><strong>From Date: </strong></span>
            <input type="date" class="filter-date from-date" name="from_date" value="${fromDate}">
        </label>
        <label class="filter-date-label">
            <span><strong>To Date: </strong></span>
            <input type="date" class="filter-date to-date" name="to_date" value="${toDate}">
        </label>


    </div>


    <!-- Search -->
    <div class="seg-search">
        <input type="text" placeholder="Tìm kiếm danh sách" value="${keyword}">
        <button onclick="filterSegment()">🔍</button>


    </div>
    <div style="position: absolute; right: 74px; top: 257px;">
        <a href="${pageContext.request.contextPath}/customers/segments"
           class="btn btn-outline-secondary w-100">
            <i class="fas fa-redo me-1"></i> Reset
        </a>
    </div>

    <!-- Table -->
    <table class="seg-table">

        <thead>
        <tr>
            <th><strong>Segment Name</strong></th>
            <th><strong>Segment Type</strong></th>
            <th><strong>Data Number</strong></th>
            <th><strong>Created At</strong></th>
            <th><strong>Last Updated At</strong></th>
            <th><strong>Action</strong></th>
        </tr>
        </thead>

        <tbody>
        <c:if test="${empty customerSegments}">
            <div class="alert alert-warning">
                <i class="fas fa-search me-1"></i> No suitable segmentation found.
            </div>
        </c:if>
        <c:if test="${not empty customerSegments}">
            <c:forEach items="${customerSegments}" var="c">
                <tr>
                    <td>
                        <div
                                class="seg-name"><a class="seg-name"
                                                    href="${pageContext.request.contextPath}/customers/segment-detail?segment_id=${c.segmentId}">
                                ${c.segmentName}
                        </a></div>
                        <div class="seg-desc">
                                ${c.criteriaLogic}
                        </div>
                    </td>


                    <td>
                        <span class="status-dot"></span> ${c.segmentType}
                    </td>

                    <td>${c.numberData}</td>

                    <td>
                        Created at: ${c.createdAt}<br>
                        Created by: ${c.createdBy}
                    </td>
                    <td>
                        Updated at: ${c.updatedAt}<br>
                        Updated by: ${c.updatedBy}
                    </td>
                    <td>
                        <button class="btn-delete" onclick="removeSegment(${c.segmentId})">Xóa</button>
                    </td>
                </tr>
            </c:forEach>
        </c:if>

        </tbody>

    </table>
    <jsp:include page="/view/components/pagination.jsp"/>
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


<!-- Modal -->
<form method="post" action="${pageContext.request.contextPath}/customers/create-segment">
    <div id="createModal" class="seg-modal">

        <div class="seg-modal-content">

            <div class="modal-header">
                <h3>Create a new Segmentation</h3>
                <span class="close-btn" onclick="closeCreateModal()">×</span>
            </div>


            <div class="modal-body">

                <label>Segmentation's name *</label>
                <input type="text" maxlength="50" name="segment_name" required>


                <label>Description</label>
                <textarea maxlength="500" name="criteria_logic"></textarea>


                <label>Choose the type of segmentation you want to create.</label>

                <div class="radio-group">
                    <label>
                        <input type="radio" name="type" value="STATIC">
                        Static
                    </label>

                    <label>
                        <input type="radio" name="type" value="DYNAMIC" checked>
                        Dynamic
                    </label>
                </div>

            </div>


            <div class="modal-footer">

                <button class="btn-cancel" onclick="closeCreateModal()" type="button">
                    Hủy
                </button>

                <button class="btn-submit" type="submit">
                    Đồng ý
                </button>

            </div>

        </div>
    </div>
</form>

<script>
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.__PAGE_STATUS__ = "<c:out value='${param.created}' default='' />";
</script>
