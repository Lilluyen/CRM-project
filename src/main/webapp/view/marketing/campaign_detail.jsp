<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Campaign - CRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .navbar {
            box-shadow: 0 2px 4px rgba(0,0,0,.1);
        }

        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 10px 10px;
        }

        .page-header h1 {
            font-weight: 700;
            font-size: 2rem;
        }

        .breadcrumb {
            background-color: transparent;
            padding: 0;
            margin-bottom: 1.5rem;
        }

        .breadcrumb-item.active {
            color: #667eea;
            font-weight: 500;
        }

        .card {
            border: none;
            box-shadow: 0 2px 8px rgba(0,0,0,.08);
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .card-header {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
            border-radius: 8px 8px 0 0;
            padding: 1.5rem;
        }

        .card-header h5 {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 0;
        }

        .card-body {
            padding: 2rem;
        }

        .detail-section {
            margin-bottom: 2rem;
        }

        .detail-section h6 {
            color: #495057;
            font-weight: 600;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e9ecef;
        }

        .detail-row {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 2rem;
            margin-bottom: 1rem;
            align-items: start;
        }

        .detail-label {
            color: #6c757d;
            font-weight: 500;
            font-size: 0.95rem;
        }

        .detail-value {
            color: #212529;
            font-size: 1rem;
            font-weight: 500;
        }

        .badge-status {
            display: inline-block;
            padding: 0.6rem 1rem;
            font-size: 0.9rem;
            font-weight: 500;
            border-radius: 4px;
        }

        .badge-active {
            background-color: #d4edda;
            color: #155724;
        }

        .badge-planning {
            background-color: #d1ecf1;
            color: #0c5460;
        }

        .badge-paused {
            background-color: #fff3cd;
            color: #856404;
        }

        .badge-completed {
            background-color: #e2e3e5;
            color: #383d41;
        }

        .channel-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            background-color: #e9ecef;
            border-radius: 4px;
            font-size: 0.9rem;
            color: #495057;
            font-weight: 500;
        }

        .budget-amount {
            color: #0d6efd;
            font-weight: 700;
            font-size: 1.3rem;
        }

        .date-range {
            font-size: 0.95rem;
            color: #495057;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .timeline {
            position: relative;
            padding-left: 2rem;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(to bottom, #667eea, transparent);
        }

        .timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
            padding-left: 2rem;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: -2.25rem;
            top: 0.25rem;
            width: 12px;
            height: 12px;
            background: #667eea;
            border-radius: 50%;
            box-shadow: 0 0 0 4px #f8f9fa;
        }

        .timeline-date {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .timeline-text {
            color: #495057;
            margin-top: 0.25rem;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .btn-large {
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            border-radius: 4px;
            transition: all 0.2s ease;
            flex: 1;
            min-width: 150px;
        }

        .btn-large:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,.15);
        }

        .btn-primary-custom {
            background-color: #0d6efd;
            color: white;
            border: none;
        }

        .btn-primary-custom:hover {
            background-color: #0b5ed7;
            color: white;
        }

        .btn-warning-custom {
            background-color: #ffc107;
            color: #000;
            border: none;
        }

        .btn-warning-custom:hover {
            background-color: #ffb800;
            color: #000;
        }

        .btn-danger-custom {
            background-color: #dc3545;
            color: white;
            border: none;
        }

        .btn-danger-custom:hover {
            background-color: #bb2d3b;
            color: white;
        }

        .btn-secondary-custom {
            background-color: #6c757d;
            color: white;
            border: none;
        }

        .btn-secondary-custom:hover {
            background-color: #5a6268;
            color: white;
        }

        .progress-bar-custom {
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        }

        .footer {
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            padding: 2rem 0;
            margin-top: 3rem;
            color: #6c757d;
            text-align: center;
        }

        .description-box {
            background-color: #f8f9fa;
            padding: 1.5rem;
            border-left: 4px solid #667eea;
            border-radius: 4px;
            color: #495057;
            line-height: 1.6;
        }

        .alert {
            border-radius: 4px;
            border: none;
        }

        @media (max-width: 768px) {
            .detail-row {
                grid-template-columns: 1fr;
                gap: 0.5rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-large {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">
                <i class="bi bi-briefcase-fill"></i> CRM-Project
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/marketing/campaign?action=list">
                            <i class="bi bi-megaphone"></i> Campaign
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/lead?action=list">
                            <i class="bi bi-people"></i> Leads
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/report">
                            <i class="bi bi-graph-up"></i> Reports
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container-fluid">
            <h1>
                <i class="bi bi-eye"></i> Chi tiết Campaign
            </h1>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/marketing/campaign?action=list">Campaign</a></li>
                <li class="breadcrumb-item active" aria-current="page">${campaign.name}</li>
            </ol>
        </nav>

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
                        <div class="stat-number">0</div>
                        <div class="stat-label">Tổng Leads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">0</div>
                        <div class="stat-label">Leads Qualified</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">0</div>
                        <div class="stat-label">Deals Created</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">0%</div>
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
                    <a href="${pageContext.request.contextPath}/marketing/campaign?action=list" class="btn btn-large btn-secondary-custom">
                        <i class="bi bi-list"></i> Quay lại Danh sách
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/campaign?action=edit&id=${campaign.campaignId}" class="btn btn-large btn-warning-custom">
                        <i class="bi bi-pencil"></i> Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/lead?action=list&campaignId=${campaign.campaignId}" class="btn btn-large btn-primary-custom">
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

    <!-- Footer -->
    <footer class="footer">
        <div class="container-fluid">
            <p class="mb-0">&copy; 2026 CRM-Project v1.0 | Phòng Marketing</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let deleteModal;
        const currentCampaignId = '${campaign.campaignId}';
        const campaignName = '${campaign.name}';

        document.addEventListener('DOMContentLoaded', function() {
            deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
            
            document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
                window.location.href = '${pageContext.request.contextPath}/marketing/campaign?action=delete&id=' + currentCampaignId;
            });
        });

        function confirmDelete() {
            deleteModal.show();
        }
    </script>
</body>
</html>