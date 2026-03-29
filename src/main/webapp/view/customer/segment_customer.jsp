<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page isELIgnored="false" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-users me-2"></i>Customer Segment List</h4>
                <p class="text-muted mb-0">List, search, and manage customer segments.</p>
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-primary" onclick="openCreateModal()">
                    <i class="fas fa-plus-circle me-1"></i> Add New Segment
                </button>
            </div>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-1"></i> <strong>Thành công!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-1"></i> <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="card shadow-sm mb-4 filter-card">
            <div class="card-body">
                <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
                <div class="row g-3">

                    <div class="col-md-4">
                        <label class="form-label">Search</label>
                        <input type="text" class="form-control" id="searchInput"
                               placeholder="Search..."
                               value="${keyword}"/>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">Segment Type</label>
                        <select class="form-select segment_type" name="segment_type">
                            <option value="">-- All --</option>
                            <option value="STATIC" <c:if test="${segmentType eq 'STATIC'}">selected</c:if>>Static
                            </option>
                            <option value="DYNAMIC" <c:if test="${segmentType eq 'DYNAMIC'}">selected</c:if>>Dynamic
                            </option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Creator</label>
                        <select class="form-select created_by" name="created_by">
                            <option value="">-- All --</option>
                            <c:forEach items="${staffs}" var="s">
                                <option value="${s.userId}"
                                        <c:if test="${creator eq s.userId}">selected</c:if>>${s.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Updater</label>
                        <select class="form-select updated_by" name="updated_by">
                            <option value="">-- All --</option>
                            <c:forEach items="${staffs}" var="s">
                                <option value="${s.userId}"
                                        <c:if test="${updater eq s.userId}">selected</c:if>>${s.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">From Date</label>
                        <input type="date" class="form-control from-date" name="from_date" value="${fromDate}"/>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">To Date</label>
                        <input type="date" class="form-control to-date" name="to_date" value="${toDate}"/>
                    </div>

                    <div class="col-5 d-flex gap-2">
                        <button style="height: 43px;
    margin-top: 24px;" type="button" class="btn btn-primary" onclick="filterSegment()">
                            <i class="fas fa-search me-1"></i> Search
                        </button>
                        <a style="height: 43px;
    margin-top: 24px; padding-top: 10px" href="${pageContext.request.contextPath}/customers/segments"
                           class="btn btn-outline-secondary">
                            <i class="fas fa-redo me-1"></i> Reset
                        </a>
                    </div>

                </div>
            </div>
        </div>

        <!-- Results -->
        <c:choose>

            <c:when test="${empty customerSegments}">
                <div class="card shadow-sm text-center py-5">
                    <div class="card-body empty-state">
                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No segments</h5>
                        <p class="text-muted">There are no segments yet. Please create a new one using the button above.</p>
                        <button class="btn btn-primary" onclick="openCreateModal()">
                            <i class="fas fa-plus me-1"></i> Add New Segment
                        </button>
                    </div>
                </div>
            </c:when>

            <c:otherwise>

                <!-- Stats Banner -->
                <div class="card shadow-sm mb-3 border-0 stats-card bg-total-lead"
                     style="border-radius: 10px;">
                    <div class="card-body py-3 px-4">
                        <span class="fs-2 fw-bold text-white">${pagination.totalItems}</span>
                        <span class="ms-2 text-white"> Segments</span>
                    </div>
                </div>

                <!-- Table -->
                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Segment Name</th>
                                <th>Type</th>
                                <th>Data Number</th>
                                <th>Created At</th>
                                <th>Last Updated At</th>
                                <th class="text-center">Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${customerSegments}" var="c" varStatus="loop">
                                <tr>
                                    <td class="text-muted">${loop.index + 1}</td>

                                    <td>
                                        <a class="seg-name fw-semibold text-primary text-decoration-none"
                                           href="${pageContext.request.contextPath}/customers/segment-detail?segment_id=${c.segmentId}">
                                                ${c.segmentName}
                                        </a>
                                        <div class="seg-desc text-muted small mt-1">${c.criteriaLogic}</div>
                                    </td>

                                    <td>
                                        <span class="badge-status
                                            <c:choose>
                                                <c:when test="${c.segmentType eq 'STATIC'}">badge-type-static</c:when>
                                                <c:otherwise>badge-type-dynamic</c:otherwise>
                                            </c:choose>">
                                            <span class="status-dot
                                                <c:choose>
                                                    <c:when test="${c.segmentType eq 'STATIC'}">dot-static</c:when>
                                                    <c:otherwise>dot-dynamic</c:otherwise>
                                                </c:choose>">
                                            </span>
                                            ${c.segmentType}
                                        </span>
                                    </td>

                                    <td>
                                        <span class="seg-count fw-bold">${c.numberData}</span>
                                        <span class="text-muted small ms-1">customers</span>
                                    </td>

                                    <td>
                                        <div class="small">
                                            <div><i class="fas fa-calendar-alt me-1 text-muted"></i>${c.createdAt}</div>
                                            <div class="text-muted"><i class="fas fa-user me-1"></i>${c.createdBy}</div>
                                        </div>
                                    </td>

                                    <td>
                                        <div class="small">
                                            <div><i class="fas fa-clock me-1 text-muted"></i>${c.updatedAt}</div>
                                            <div class="text-muted"><i class="fas fa-user-edit me-1"></i>${c.updatedBy}
                                            </div>
                                        </div>
                                    </td>

                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/customers/segment-detail?segment_id=${c.segmentId}"
                                           class="btn btn-sm btn-outline-info btn-action" title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button class="btn btn-sm btn-outline-danger ms-1 btn-action"
                                                title="Xóa segment"
                                                onclick="removeSegment(${c.segmentId})">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <jsp:include page="/view/components/pagination.jsp"/>
                </div>

            </c:otherwise>

        </c:choose>

    </div>
</div>

<!-- Toast -->
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

<!-- Create Segment Modal -->
<form method="post" action="${pageContext.request.contextPath}/customers/create-segment">
    <div id="createModal" class="seg-modal">
        <div class="seg-modal-content">

            <div class="modal-header">
                <h5 class="modal-title-text">
                    <i class="fas fa-layer-group me-2"></i>Create a new Segmentation
                </h5>
                <span class="seg-close-btn" onclick="closeCreateModal()">
                    <i class="fas fa-times"></i>
                </span>
            </div>

            <div class="modal-body">

                <div class="mb-3">
                    <label class="form-label-modal">Segmentation's name <span class="text-danger">*</span></label>
                    <input type="text" class="form-input-modal" maxlength="50"
                           name="segment_name" placeholder="Enter segment name..." required/>
                </div>

                <div class="mb-3">
                    <label class="form-label-modal">Description</label>
                    <textarea class="form-input-modal" maxlength="500"
                              name="criteria_logic" rows="3"
                              placeholder="Description of segmentation criteria..."></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label-modal">Segment Type</label>
                    <div class="radio-group">
                        <label class="radio-pill">
                            <input type="radio" name="type" value="STATIC"/>
                            <i class="fas fa-lock me-1"></i> Static
                        </label>
                        <label class="radio-pill">
                            <input type="radio" name="type" value="DYNAMIC" checked/>
                            <i class="fas fa-sync-alt me-1"></i> Dynamic
                        </label>
                    </div>
                </div>

            </div>

            <div class="modal-footer-custom">
                <button class="btn btn-outline-secondary" onclick="closeCreateModal()" type="button">
                    <i class="fas fa-times me-1"></i> Cancel
                </button>
                <button class="btn btn-primary" type="submit">
                    <i class="fas fa-check me-1"></i> Submit
                </button>
            </div>

        </div>
    </div>
</form>

<script>
    window.__CTX__ = "${pageContext.request.contextPath}";
    window.__PAGE_STATUS__ = "<c:out value='${param.created}' default='' />";
</script>
