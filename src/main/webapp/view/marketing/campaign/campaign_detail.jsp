<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="col-10">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-eye me-2"></i>Chi tiết Campaign</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/marketing/campaign">Campaign</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${campaign.name}</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/campaign"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Quay lại
            </a>
        </div>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle"></i>
                <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- SUCCESS Alert -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i>
                <strong>Thành công!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Campaign Header Card -->
        <div class="card">
            <div class="card-body">
                <div class="row align-items-start">
                    <div class="col-md-8">
                        <h2 class="mb-3">${campaign.name}</h2>
                        <div class="mb-3">
                            <c:choose>
                                <c:when test="${campaign.status == 'ACTIVE'}">
                                    <span class="badge-status badge-active">
                                        <i class="bi bi-play-fill"></i> Đang chạy
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PLANNING'}">
                                    <span class="badge-status badge-planning">
                                        <i class="bi bi-hourglass"></i> Lên kế hoạch
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PAUSED'}">
                                    <span class="badge-status badge-paused">
                                        <i class="bi bi-pause-fill"></i> Tạm dừng
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'COMPLETED'}">
                                    <span class="badge-status badge-completed">
                                        <i class="bi bi-check-circle"></i> Kết thúc
                                    </span>
                                </c:when>
                            </c:choose>
                        </div>
                        <c:if test="${not empty campaign.description}">
                            <div class="description-box">
                                ${campaign.description}
                            </div>
                        </c:if>
                    </div>

                    <div class="col-md-4">
                        <div class="text-end">
                            <div class="mb-3">
                                <span class="detail-label d-block mb-2">Ngân sách</span>
                                <span class="budget-amount">
                                    <fmt:formatNumber value="${campaign.budget}" type="currency" 
                                                      currencySymbol="₫" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="mb-3">
                                <span class="channel-badge">
                                    <c:choose>
                                        <c:when test="${campaign.channel == 'EMAIL'}">
                                            <i class="bi bi-envelope"></i> Email
                                        </c:when>
                                        <c:when test="${campaign.channel == 'SOCIAL_MEDIA'}">
                                            <i class="bi bi-share"></i> Social Media
                                        </c:when>
                                        <c:when test="${campaign.channel == 'SMS'}">
                                            <i class="bi bi-chat-dots"></i> SMS
                                        </c:when>
                                        <c:when test="${campaign.channel == 'DIRECT_MAIL'}">
                                            <i class="bi bi-mailbox"></i> Direct Mail
                                        </c:when>
                                        <c:otherwise>
                                            ${campaign.channel}
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Campaign Details -->
        <div class="card">
            <div class="card-header">
                <h5><i class="bi bi-info-circle"></i> Thông tin Campaign</h5>
            </div>
            <div class="card-body">
                <div class="detail-section">
                    <h6><i class="bi bi-calendar2-event"></i> Thời gian Chiến dịch</h6>
                    <div class="detail-row">
                        <span class="detail-label">Ngày bắt đầu:</span>
                        <span class="detail-value">
                            <i class="bi bi-calendar"></i>
                            ${campaign.startDate}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Ngày kết thúc:</span>
                        <span class="detail-value">
                            <i class="bi bi-calendar"></i>
                            ${campaign.endDate}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Thời gian chạy:</span>
                        <span class="detail-value">
                        <c:if test="${not empty campaign.startDate and not empty campaign.endDate}">
                            ${campaign.endDate.toEpochDay() - campaign.startDate.toEpochDay()} ngày
                        </c:if>
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="bi bi-briefcase"></i> Thông tin Ngân sách</h6>
                    <div class="detail-row">
                        <span class="detail-label">Ngân sách tổng:</span>
                        <span class="detail-value budget-amount">
                            <fmt:formatNumber value="${campaign.budget}" type="currency" 
                                              currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Kênh Marketing:</span>
                        <span class="detail-value">
                            <span class="channel-badge">
                                <c:choose>
                                    <c:when test="${campaign.channel == 'EMAIL'}">
                                        <i class="bi bi-envelope"></i> Email
                                    </c:when>
                                    <c:when test="${campaign.channel == 'SOCIAL_MEDIA'}">
                                        <i class="bi bi-share"></i> Social Media
                                    </c:when>
                                    <c:when test="${campaign.channel == 'SMS'}">
                                        <i class="bi bi-chat-dots"></i> SMS
                                    </c:when>
                                    <c:when test="${campaign.channel == 'DIRECT_MAIL'}">
                                        <i class="bi bi-mailbox"></i> Direct Mail
                                    </c:when>
                                     <c:otherwise>
                                                    <span class="channel-badge">${campaign.channel}</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Trạng thái:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${campaign.status == 'ACTIVE'}">
                                    <span class="badge-status badge-active">
                                        <i class="bi bi-play-fill"></i> Đang chạy
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PLANNING'}">
                                    <span class="badge-status badge-planning">
                                        <i class="bi bi-hourglass"></i> Lên kế hoạch
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PAUSED'}">
                                    <span class="badge-status badge-paused">
                                        <i class="bi bi-pause-fill"></i> Tạm dừng
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'COMPLETED'}">
                                    <span class="badge-status badge-completed">
                                        <i class="bi bi-check-circle"></i> Kết thúc
                                    </span>
                                </c:when>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="bi bi-clock-history"></i> Thông tin Tạo & Cập nhật</h6>
                    <div class="detail-row">
                        <span class="detail-label">Tạo lúc:</span>
                        <span class="detail-value">
                            ${campaign.createdAt}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Cập nhật lúc:</span>
                        <span class="detail-value">
                            ${campaign.updatedAt}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Campaign Stats Card -->
        <div class="card">
            <div class="card-header">
                <h5><i class="bi bi-graph-up"></i> Thống kê Campaign</h5>
            </div>
            <div class="card-body">
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.totalLead : 0}</div>
                        <div class="stat-label">Tổng Leads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.qualifiedLead : 0}</div>
                        <div class="stat-label">Leads Qualified</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.convertedLead : 0}</div>
                        <div class="stat-label">Deals Created</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.roi : 0}%</div>
                        <div class="stat-label">Conversion Rate</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="card">
            <div class="card-body">
                <h6 class="mb-3"><i class="bi bi-lightning"></i> Hành động</h6>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/marketing/campaign" class="btn btn-large btn-secondary-custom">
                        <i class="bi bi-list"></i> Quay lại Danh sách
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/campaign/form?id=${campaign.campaignId}" class="btn btn-large btn-warning-custom">
                        <i class="bi bi-pencil"></i> Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads?campaignId=${campaign.campaignId}" class="btn btn-large btn-primary-custom">
                        <i class="bi bi-people"></i> Xem Leads
                    </a>
                </div>
            </div>
        </div>
    </div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Xác nhận xóa</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p><strong>Cảnh báo!</strong> Bạn chắc chắn muốn xóa campaign này?</p>
                <p class="text-danger small"><strong>${campaign.name}</strong></p>
                <p class="text-danger small">Hành động này không thể hoàn tác.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Xóa</button>
            </div>
        </div>
    </div>
</div>

<script>
    let deleteModal;
    const currentCampaignId = '${campaign.campaignId}';
    const campaignName = '${campaign.name}';

    document.addEventListener('DOMContentLoaded', function() {
        deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
        
        document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
            window.location.href = '${pageContext.request.contextPath}/marketing/campaign/delete?id=' + currentCampaignId;
        });
    });

    function confirmDelete() {
        deleteModal.show();
    }
</script>

    </div>
</div>