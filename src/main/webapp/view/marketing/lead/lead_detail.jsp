<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="col-10">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-eye me-2"></i>Chi tiết Lead</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/marketing/leads">Leads</a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">${lead.fullName}</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/leads"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Quay lại
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
                            <span class="detail-label d-block mb-2">Điểm số</span>
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
                    <h6><i class="fas fa-user me-1"></i> Thông tin liên hệ</h6>
                    <div class="detail-row">
                        <span class="detail-label">Họ tên:</span>
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
                        <span class="detail-label">Số điện thoại:</span>
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
                        <span class="detail-label">Sở thích / Quan tâm:</span>
                        <span class="detail-value">
                            ${not empty lead.interest ? lead.interest : '-'}
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="fas fa-bullhorn me-1"></i> Nguồn & Campaign</h6>
                    <div class="detail-row">
                        <span class="detail-label">Nguồn Lead:</span>
                        <span class="detail-value">
                            <span class="badge bg-light text-dark border">
                                ${not empty lead.source ? lead.source : '-'}
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Campaign ID:</span>
                        <span class="detail-value">
                            ${lead.campaignId > 0 ? lead.campaignId : 'Không thuộc campaign'}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Assigned To:</span>
                        <span class="detail-value">
                            ${lead.assignedTo > 0 ? lead.assignedTo : 'Chưa phân công'}
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="fas fa-chart-line me-1"></i> Đánh giá</h6>
                    <div class="detail-row">
                        <span class="detail-label">Trạng thái:</span>
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
                        <span class="detail-label">Điểm số:</span>
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
                    <h6><i class="fas fa-clock me-1"></i> Thông tin thời gian</h6>
                    <div class="detail-row">
                        <span class="detail-label">Tạo lúc:</span>
                        <span class="detail-value">${lead.createdAt}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Cập nhật lúc:</span>
                        <span class="detail-value">${lead.updatedAt}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="mb-3"><i class="fas fa-bolt me-1"></i> Hành động</h6>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/marketing/leads"
                       class="btn btn-large btn-secondary-custom">
                        <i class="fas fa-list me-1"></i> Quay lại Danh sách
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/form?id=${lead.leadId}"
                       class="btn btn-large btn-warning-custom">
                        <i class="fas fa-edit me-1"></i> Chỉnh sửa
                    </a>
                </div>
            </div>
        </div>

    </div>
</div>
