<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Campaign - CRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --success-color: #198754;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
        }

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

        .page-header p {
            font-size: 1.1rem;
            margin-bottom: 0;
            opacity: 0.95;
        }

        .filter-card {
            border: none;
            box-shadow: 0 2px 8px rgba(0,0,0,.08);
            border-radius: 8px;
        }

        .table-wrapper {
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,.08);
        }

        .table thead {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
            font-weight: 600;
            color: #495057;
        }

        .table tbody tr {
            transition: background-color 0.2s ease;
            border-bottom: 1px solid #dee2e6;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .badge-status {
            padding: 0.5rem 0.75rem;
            font-size: 0.85rem;
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

        .budget-amount {
            color: #0d6efd;
            font-weight: 600;
        }

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.875rem;
            margin: 0 2px;
            border-radius: 4px;
        }

        .btn-action {
            transition: all 0.2s ease;
        }

        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,.15);
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
        }

        .empty-state i {
            font-size: 4rem;
            color: #ccc;
            margin-bottom: 1rem;
        }

        .empty-state h5 {
            color: #6c757d;
            font-weight: 500;
        }

        .empty-state p {
            color: #999;
            margin-bottom: 1rem;
        }

        .channel-badge {
            display: inline-block;
            padding: 0.35rem 0.6rem;
            background-color: #e9ecef;
            border-radius: 4px;
            font-size: 0.85rem;
            color: #495057;
        }

        .date-range {
            font-size: 0.9rem;
            color: #6c757d;
            line-height: 1.6;
        }

        .stats-card {
            border: none;
            box-shadow: 0 2px 8px rgba(0,0,0,.08);
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .stats-card .card-body {
            padding: 1.5rem;
        }

        .stats-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
        }

        .stats-label {
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 0.5rem;
        }

        .footer {
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            padding: 2rem 0;
            margin-top: 3rem;
            color: #6c757d;
            text-align: center;
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
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1><i class="bi bi-megaphone"></i> Quản lý Campaign</h1>
                    <p>Tạo, cập nhật, và theo dõi hiệu quả chiến dịch marketing</p>
                </div>
                <div class="col-md-4 text-end">
                    <a href="${pageContext.request.contextPath}/marketing/campaign?action=create" class="btn btn-light btn-lg fw-bold">
                        <i class="bi bi-plus-circle"></i> Tạo Campaign Mới
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Alertas -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> <strong>Thành công!</strong> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle"></i> <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="filter-card mb-4">
            <div class="card-body">
                <h6 class="mb-3"><i class="bi bi-funnel"></i> Tìm kiếm & Lọc</h6>
                <form method="GET" action="/marketing/campaign" class="row g-3">
                    <input type="hidden" name="action" value="list">

                    <div class="col-md-5">
                        <label for="searchName" class="form-label">Tên campaign</label>
                        <input type="text" class="form-control" id="searchName" name="search"
                               placeholder="Nhập tên campaign..." value="${param.search}">
                    </div>

                    <div class="col-md-4">
                        <label for="filterStatus" class="form-label">Trạng thái</label>
                        <select class="form-select" id="filterStatus" name="status">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>Đang chạy</option>
                            <option value="PLANNING" ${param.status == 'PLANNING' ? 'selected' : ''}>Lên kế hoạch</option>
                            <option value="PAUSED" ${param.status == 'PAUSED' ? 'selected' : ''}>Tạm dừng</option>
                            <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Kết thúc</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-search"></i> Tìm kiếm
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Content -->
        <c:choose>
            <c:when test="${empty campaigns}">
                <!-- Empty State -->
                <div class="card border-0">
                    <div class="empty-state">
                        <i class="bi bi-inbox"></i>
                        <h5>Không có campaign nào</h5>
                        <p>Bắt đầu bằng cách <a href="${pageContext.request.contextPath}/marketing/campaign?action=create" class="fw-bold">tạo campaign mới</a></p>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <!-- Statistics -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stats-card">
                            <div class="card-body">
                                <div class="stats-number">${campaigns.size()}</div>
                                <div class="stats-label">Tổng Campaign</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Table -->
                <div class="card table-wrapper">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 20%;">Tên Campaign</th>
                                    <th style="width: 12%;">Trạng thái</th>
                                    <th style="width: 12%;">Ngân sách</th>
                                    <th style="width: 12%;">Kênh</th>
                                    <th style="width: 20%;">Thời gian</th>
                                    <th style="width: 24%;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="campaign" items="${campaigns}">
                                    <tr>
                                        <!-- Name & Description -->
                                        <td>
                                            <div class="fw-bold">${campaign.name}</div>
                                            <small class="text-muted d-block text-truncate">${campaign.description}</small>
                                        </td>

                                        <!-- Status Badge -->
                                        <td>
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
                                        </td>

                                        <!-- Budget -->
                                        <td>
                                            <span class="budget-amount">
                                                <fmt:formatNumber value="${campaign.budget}" type="currency" 
                                                                  currencySymbol="₫" maxFractionDigits="0"/>
                                            </span>
                                        </td>

                                        <!-- Channel -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${campaign.channel == 'EMAIL'}">
                                                    <span class="channel-badge"><i class="bi bi-envelope"></i> Email</span>
                                                </c:when>
                                                <c:when test="${campaign.channel == 'SOCIAL_MEDIA'}">
                                                    <span class="channel-badge"><i class="bi bi-share"></i> Social</span>
                                                </c:when>
                                                <c:when test="${campaign.channel == 'SMS'}">
                                                    <span class="channel-badge"><i class="bi bi-chat-dots"></i> SMS</span>
                                                </c:when>
                                                <c:when test="${campaign.channel == 'DIRECT_MAIL'}">
                                                    <span class="channel-badge"><i class="bi bi-mailbox"></i> Mail</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="channel-badge">${campaign.channel}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Date Range -->
                                        <td>
                                            <div class="date-range">
                                                <i class="bi bi-calendar2-event"></i>
                                                ${campaign.startDate} 
                                                <br>
                                                <i class="bi bi-calendar2-x"></i>
                                                ${campaign.endDate}
                                            </div>
                                        </td>

                                        <!-- Actions -->
                                        <td>
                                            <div class="btn-group btn-group-sm" role="group">
                                                <a href="${pageContext.request.contextPath}/marketing/campaign?action=detail&id=${campaign.campaignId}"
                                                   class="btn btn-outline-info btn-action" title="Xem chi tiết">
                                                    <i class="bi bi-eye"></i> Xem
                                                </a>
                                                <a href="${pageContext.request.contextPath}/marketing/campaign?action=edit&id=${campaign.campaignId}"
                                                   class="btn btn-outline-warning btn-action" title="Chỉnh sửa">
                                                    <i class="bi bi-pencil"></i> Sửa
                                                </a>
                                        
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Pagination Info and Controls -->
                <div style="background-color: #f8f9fa; padding: 15px; border-top: 1px solid #dee2e6; border-radius: 0 0 8px 8px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                    <div style="font-size: 14px; color: #495057;">
                        Hiển thị <strong>${pagination.getStartItemNumber()}-${pagination.getEndItemNumber()}</strong> 
                        của <strong>${pagination.totalItems}</strong> campaigns
                    </div>
                    <div style="display: flex; gap: 5px; flex-wrap: wrap; align-items: center;">
                        <c:if test="${pagination.hasPreviousPage()}">
                            <a href="<c:url value='/marketing/campaign?action=list&page=${pagination.currentPage - 1}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}'/>" 
                               style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #0066cc; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px;">
                                <i class="bi bi-chevron-left"></i> Trước
                            </a>
                        </c:if>
                        <c:if test="${!pagination.hasPreviousPage()}">
                            <button style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #999; cursor: not-allowed; border-radius: 4px; font-size: 13px; opacity: 0.5;" disabled>
                                <i class="bi bi-chevron-left"></i> Trước
                            </button>
                        </c:if>

                        <!-- Page Numbers -->
                        <c:set var="totalPages" value="${pagination.getTotalPages()}"/>
                        <c:set var="currentPage" value="${pagination.currentPage}"/>
                        <c:set var="startPage" value="${Math.max(1, currentPage - 2)}"/>
                        <c:set var="endPage" value="${Math.min(totalPages, currentPage + 2)}"/>

                        <c:if test="${startPage > 1}">
                            <a href="<c:url value='/marketing/campaign?action=list&page=1${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}'/>" 
                               style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #0066cc; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px;">1</a>
                            <c:if test="${startPage > 2}">
                                <span style="padding: 6px 10px;">...</span>
                            </c:if>
                        </c:if>

                        <c:forEach var="page" begin="${startPage}" end="${endPage}">
                            <c:choose>
                                <c:when test="${page == currentPage}">
                                    <span style="padding: 6px 10px; border: 1px solid #0066cc; background-color: #0066cc; color: white; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px; font-weight: 500;">${page}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="<c:url value='/marketing/campaign?action=list&page=${page}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}'/>" 
                                       style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #0066cc; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px;">${page}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${endPage < totalPages}">
                            <c:if test="${endPage < totalPages - 1}">
                                <span style="padding: 6px 10px;">...</span>
                            </c:if>
                            <a href="<c:url value='/marketing/campaign?action=list&page=${totalPages}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}'/>" 
                               style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #0066cc; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px;">${totalPages}</a>
                        </c:if>

                        <c:if test="${pagination.hasNextPage()}">
                            <a href="<c:url value='/marketing/campaign?action=list&page=${pagination.currentPage + 1}${not empty param.search ? '&search='.concat(param.search) : ''}${not empty param.status ? '&status='.concat(param.status) : ''}'/>" 
                               style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #0066cc; cursor: pointer; border-radius: 4px; text-decoration: none; font-size: 13px;">
                                Tiếp <i class="bi bi-chevron-right"></i>
                            </a>
                        </c:if>
                        <c:if test="${!pagination.hasNextPage()}">
                            <button style="padding: 6px 10px; border: 1px solid #dee2e6; background: white; color: #999; cursor: not-allowed; border-radius: 4px; font-size: 13px; opacity: 0.5;" disabled>
                                Tiếp <i class="bi bi-chevron-right"></i>
                            </button>
                        </c:if>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
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
        let campaignIdToDelete;

        document.addEventListener('DOMContentLoaded', function() {
            deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
            document.getElementById('confirmDeleteBtn').addEventListener('click', performDelete);
        });

        function confirmDelete(campaignId) {
            campaignIdToDelete = campaignId;
            deleteModal.show();
        }

        function performDelete() {
            if (campaignIdToDelete) {
                window.location.href = "${pageContext.request.contextPath}/marketing/campaign?action=delete&id=" + campaignIdToDelete;
            }
        }
    </script>
</body>
</html>