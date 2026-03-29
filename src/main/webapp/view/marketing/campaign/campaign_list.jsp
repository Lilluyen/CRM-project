<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-bullhorn me-2"></i>Campaign Management</h4>
                <p class="text-muted mb-0">Create, update, and track the effectiveness of marketing campaigns</p>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/campaign/form"
               class="btn btn-primary">
                <i class="fas fa-plus-circle me-1"></i> Create New Campaign
            </a>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-1"></i> <strong>Success!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-1"></i> <strong>Error!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
                <form method="GET" action="${pageContext.request.contextPath}/marketing/campaign" class="row g-3">

                    <div class="col-md-5">
                        <label class="form-label">Campaign Name</label>
                        <input type="text" class="form-control" name="search"
                               value="${searchName}" placeholder="Enter campaign name...">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="">-- All Status --</option>
                            <option value="ACTIVE"    ${filterStatus == 'ACTIVE'    ? 'selected' : ''}>Active</option>
                            <option value="PLANNING"  ${filterStatus == 'PLANNING'  ? 'selected' : ''}>Planning</option>
                            <option value="PAUSED"    ${filterStatus == 'PAUSED'    ? 'selected' : ''}>Paused</option>
                            <option value="COMPLETED" ${filterStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        </select>
                    </div>

                    <div class="col-md-3 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-1"></i> Search
                        </button>
                        <a href="${pageContext.request.contextPath}/marketing/campaign"
                           class="btn btn-outline-secondary w-100">
                            <i class="fas fa-redo me-1"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Results -->
        <c:choose>

            <%-- Tìm nhưng không có kết quả --%>
            <c:when test="${empty campaigns and (not empty searchName or not empty filterStatus)}">
                <div class="alert alert-warning">
                    <i class="fas fa-search me-1"></i> No matching campaigns found.
                </div>
            </c:when>

            <%-- Có campaign --%>
            <c:when test="${not empty campaigns}">

                <div class="card shadow-sm mb-3 border-0 bg-primary text-white total-campaign" style="border-radius: 10px;">
                    <div class="card-body py-3 px-4">
                        <span class="fs-2 fw-bold">${pagination.totalItems}</span>
                        <span class="ms-2">
                            <c:choose>
                                <c:when test="${not empty searchName or not empty filterStatus}">Campaign found</c:when>
                                <c:otherwise>Total Campaigns</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>#</th>
                                    <th>Campaign Name</th>
                                    <th>Status</th>
                                    <th>Budget</th>
                                    <th>Channel</th>
                                    <th>Duration</th>
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="campaign" items="${campaigns}" varStatus="loop">
                                    <tr>
                                        <td class="text-muted">${pagination.offset + loop.count}</td>

                                        <td>
                                            <strong>${campaign.name}</strong><br>
                                            <small class="text-muted">${campaign.description}</small>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${campaign.status == 'ACTIVE'}">
                                                    <span class="badge bg-success">Active</span>
                                                </c:when>
                                                <c:when test="${campaign.status == 'PLANNING'}">
                                                    <span class="badge bg-info text-dark">Planning</span>
                                                </c:when>
                                                <c:when test="${campaign.status == 'PAUSED'}">
                                                    <span class="badge bg-warning text-dark">Paused</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Completed</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="fw-semibold text-success">
                                            <fmt:formatNumber value="${campaign.budget}"
                                                              type="currency"
                                                              currencySymbol="₫"
                                                              maxFractionDigits="0"/>
                                        </td>

                                        <td>
                                            <span class="badge bg-light text-dark border">${campaign.channel}</span>
                                        </td>

                                        <td class="small text-muted">
                                            <i class="fas fa-calendar-alt me-1"></i>${campaign.startDate}<br>
                                            <i class="fas fa-calendar-check me-1"></i>${campaign.endDate}
                                        </td>

                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${campaign.campaignId}"
                                               class="btn btn-sm btn-outline-info" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/marketing/campaign/form?id=${campaign.campaignId}"
                                               class="btn btn-sm btn-outline-warning ms-1" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination (reusable component) --%>
                    <jsp:include page="/view/components/pagination.jsp" />
                </div>

            </c:when>

            <%-- Không có campaign nào --%>
            <c:otherwise>
                <div class="card shadow-sm text-center py-5">
                    <div class="card-body">
                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No campaigns found</h5>
                        <a href="${pageContext.request.contextPath}/marketing/campaign/form"
                           class="btn btn-primary mt-2">
                            <i class="fas fa-plus me-1"></i> Create Campaign
                        </a>
                    </div>
                </div>
            </c:otherwise>

        </c:choose>

    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle me-1"></i> Confirm Delete</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p><strong>Warning!</strong> Are you sure you want to delete this campaign?</p>
                <p class="text-danger small">This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
    let deleteModal;
    let campaignIdToDelete;

    document.addEventListener('DOMContentLoaded', function () {
        deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
        document.getElementById('confirmDeleteBtn').addEventListener('click', performDelete);
    });

    function confirmDelete(campaignId) {
        campaignIdToDelete = campaignId;
        deleteModal.show();
    }

    function performDelete() {
        if (campaignIdToDelete) {
            window.location.href =
                "${pageContext.request.contextPath}/marketing/campaign/delete?id=" + campaignIdToDelete;
        }
    }
</script>
