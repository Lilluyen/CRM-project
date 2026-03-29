<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-eye me-2"></i>Lead Details</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/marketing/leads">Leads</a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">${lead.fullName}</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/customer-journey?type=lead&leadId=${lead.leadId}"
               class="btn btn-primary me-2">
                <i class="fas fa-route me-1"></i> Journey
            </a>
            <a href="${pageContext.request.contextPath}/marketing/leads"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to Leads
            </a>
        </div>

        <!-- Success Alert -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-1"></i>
                <strong>Thành công!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Lead Header Card -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <div class="row align-items-start">
                    <div class="col-md-8">
                        <h2 class="mb-3">${lead.fullName}</h2>
                        <div class="mb-3">
                            <c:choose>
                                <c:when test="${lead.status == 'NEW_LEAD'}">
                                    <span class="badge-status badge-new">
                                        <i class="fas fa-circle me-1"></i> New Lead
                                    </span>
                                </c:when>
                                <c:when test="${lead.status == 'CONTACTED'}">
                                    <span class="badge-status badge-contacted">
                                        <i class="fas fa-phone me-1"></i> Contacted
                                    </span>
                                </c:when>
                                <c:when test="${lead.status == 'QUALIFIED'}">
                                    <span class="badge-status badge-qualified">
                                        <i class="fas fa-check me-1"></i> Qualified
                                    </span>
                                </c:when>
                                <c:when test="${lead.status == 'DEAL_CREATED'}">
                                    <span class="badge-status badge-deal">
                                        <i class="fas fa-handshake me-1"></i> Deal Created
                                    </span>
                                </c:when>
                                <c:when test="${lead.status == 'LOST'}">
                                    <span class="badge-status badge-lost">
                                        <i class="fas fa-times me-1"></i> Lost
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status">${lead.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-4 text-end">
                        <div class="mb-3">
                            <span class="detail-label d-block mb-2">Score</span>
                            <c:choose>
                                <c:when test="${lead.score >= 70}">
                                    <span class="score-badge-lg score-hot">${lead.score}/100</span>
                                </c:when>
                                <c:when test="${lead.score >= 40}">
                                    <span class="score-badge-lg score-warm">${lead.score}/100</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="score-badge-lg score-cold">${lead.score}/100</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Lead Details -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-info-circle me-1"></i> Thông tin Lead</h5>
            </div>
            <div class="card-body">
                <div class="detail-section">
                    <h6><i class="fas fa-user me-1"></i> Contact Information</h6>
                    <div class="detail-row">
                        <span class="detail-label">Full Name:</span>
                        <span class="detail-value">${lead.fullName}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Email:</span>
                        <span class="detail-value">
                            <a href="mailto:${lead.email}" class="text-decoration-none">
                                <i class="fas fa-envelope me-1"></i>${lead.email}
                            </a>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Phone Number:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${not empty lead.phone}">
                                    <i class="fas fa-phone me-1"></i>${lead.phone}
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Interests / Preferences:</span>
                        <span class="detail-value">
                            ${not empty lead.interest ? lead.interest : '-'}
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="fas fa-bullhorn me-1"></i> Source & Campaign</h6>
                    <div class="detail-row">
                        <span class="detail-label">Lead Source:</span>
                        <span class="detail-value">
                            <span class="badge bg-light text-dark border">
                                ${not empty lead.source ? lead.source : '-'}
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Assigned To:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${lead.assignedTo > 0 && not empty lead.assignedToName}">
                                    <i class="fas fa-user-tie me-1"></i>${lead.assignedToName}
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Not assigned</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <!-- Danh sách campaigns mà lead tham gia -->
                    <div class="mt-3">
                        <span class="detail-label d-block mb-2">Campaigns joined:</span>
                        <c:choose>
                            <c:when test="${not empty leadCampaigns}">
                                <div class="table-responsive">
                                    <table class="table table-sm table-bordered table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>Campaign Name</th>
                                                <th>Channel</th>
                                                <th>Campaign Status</th>
                                                <th>Time</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="camp" items="${leadCampaigns}" varStatus="loop">
                                                <tr>
                                                    <td>${loop.count}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${camp.campaignId}"
                                                           class="text-decoration-none fw-semibold">
                                                            ${camp.name}
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border">
                                                            ${not empty camp.channel ? camp.channel : '-'}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${camp.status == 'ACTIVE' || camp.status == 'Running'}">
                                                                <span class="badge bg-success">Active</span>
                                                            </c:when>
                                                            <c:when test="${camp.status == 'PLANNING' || camp.status == 'Planned' || camp.status == 'PLANNED'}">
                                                                <span class="badge bg-info">Planning</span>
                                                            </c:when>
                                                            <c:when test="${camp.status == 'PAUSED' || camp.status == 'Paused'}">
                                                                <span class="badge bg-warning text-dark">Paused</span>
                                                            </c:when>
                                                            <c:when test="${camp.status == 'COMPLETED' || camp.status == 'Completed'}">
                                                                <span class="badge bg-secondary">Completed</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-light text-dark border">${camp.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-muted small">
                                                        ${camp.startDate} ~ ${camp.endDate}
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted mb-0">
                                    <i class="fas fa-info-circle me-1"></i> Not joined any campaigns.
                                </p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="fas fa-chart-line me-1"></i> Evaluation</h6>
                    <div class="detail-row">
                        <span class="detail-label">Status:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${lead.status == 'NEW_LEAD'}">
                                    <span class="badge-status badge-new">New Lead</span>
                                </c:when>
                                <c:when test="${lead.status == 'CONTACTED'}">
                                    <span class="badge-status badge-contacted">Contacted</span>
                                </c:when>
                                <c:when test="${lead.status == 'QUALIFIED'}">
                                    <span class="badge-status badge-qualified">Qualified</span>
                                </c:when>
                                <c:when test="${lead.status == 'DEAL_CREATED'}">
                                    <span class="badge-status badge-deal">Deal Created</span>
                                </c:when>
                                <c:when test="${lead.status == 'LOST'}">
                                    <span class="badge-status badge-lost">Lost</span>
                                </c:when>
                                <c:otherwise>${lead.status}</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Score:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${lead.score >= 70}">
                                    <span class="score-badge score-hot">${lead.score}</span>
                                    <small class="text-muted ms-2">Hot Lead</small>
                                </c:when>
                                <c:when test="${lead.score >= 40}">
                                    <span class="score-badge score-warm">${lead.score}</span>
                                    <small class="text-muted ms-2">Warm Lead</small>
                                </c:when>
                                <c:otherwise>
                                    <span class="score-badge score-cold">${lead.score}</span>
                                    <small class="text-muted ms-2">Cold Lead</small>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="fas fa-clock me-1"></i> Time Information</h6>
                    <div class="detail-row">
                        <span class="detail-label">Created at:</span>
                        <span class="detail-value">${lead.createdAt}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Updated at:</span>
                        <span class="detail-value">${lead.updatedAt}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="mb-3"><i class="fas fa-bolt me-1"></i> Action</h6>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/marketing/leads"
                       class="btn btn-large btn-secondary-custom">
                        <i class="fas fa-list me-1"></i> Back to List
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/form?id=${lead.leadId}"
                       class="btn btn-large btn-warning-custom">
                        <i class="fas fa-edit me-1"></i> Edit
                    </a>
                </div>
            </div>
        </div>

    </div>
</div>
