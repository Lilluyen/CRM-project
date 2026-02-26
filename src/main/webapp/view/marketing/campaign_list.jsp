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
        <h6 class="mb-3">
            <i class="bi bi-funnel"></i> Tìm kiếm & Lọc
        </h6>

        <form method="GET"
              action="${pageContext.request.contextPath}/marketing/campaign"
              class="row g-3">

            <input type="hidden" name="action" value="list">

            <div class="col-md-5">
                <label class="form-label">Tên campaign</label>
                <input type="text"
                       class="form-control"
                       name="search"
                       value="${searchName}"
                       placeholder="Nhập tên campaign...">
            </div>

            <div class="col-md-4">
                <label class="form-label">Trạng thái</label>
                <select class="form-select" name="status">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="ACTIVE" ${filterStatus == 'ACTIVE' ? 'selected' : ''}>Đang chạy</option>
                    <option value="PLANNING" ${filterStatus == 'PLANNING' ? 'selected' : ''}>Lên kế hoạch</option>
                    <option value="PAUSED" ${filterStatus == 'PAUSED' ? 'selected' : ''}>Tạm dừng</option>
                    <option value="COMPLETED" ${filterStatus == 'COMPLETED' ? 'selected' : ''}>Kết thúc</option>
                </select>
            </div>

            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-search"></i> Tìm kiếm
                </button>
            </div>
        </form>
    </div>
</div>


<c:choose>

    <%-- Search nhưng không có kết quả --%>
    <c:when test="${empty campaigns and (not empty searchName or not empty filterStatus)}">
        <div class="alert alert-warning">
            Không tìm thấy campaign phù hợp.
        </div>
    </c:when>


    <%-- Có campaign --%>
    <c:when test="${not empty campaigns}">

        <div class="stats-card">
            <div class="card-body">
                <div class="stats-number">${campaigns.size()}</div>
                <div class="stats-label">
                    <c:choose>
                        <c:when test="${not empty searchName or not empty filterStatus}">
                            Campaign tìm thấy
                        </c:when>
                        <c:otherwise>
                            Tổng Campaign
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="card table-wrapper">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>Tên</th>
                            <th>Trạng thái</th>
                            <th>Ngân sách</th>
                            <th>Kênh</th>
                            <th>Thời gian</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>

                        <c:forEach var="campaign" items="${campaigns}">
                            <tr>
                                <td>
                                    <strong>${campaign.name}</strong><br>
                                    <small class="text-muted">${campaign.description}</small>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${campaign.status == 'ACTIVE'}">
                                            <span class="badge-status badge-active">Đang chạy</span>
                                        </c:when>
                                        <c:when test="${campaign.status == 'PLANNING'}">
                                            <span class="badge-status badge-planning">Lên kế hoạch</span>
                                        </c:when>
                                        <c:when test="${campaign.status == 'PAUSED'}">
                                            <span class="badge-status badge-paused">Tạm dừng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-completed">Kết thúc</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="budget-amount">
                                    <fmt:formatNumber value="${campaign.budget}"
                                                      type="currency"
                                                      currencySymbol="₫"
                                                      maxFractionDigits="0"/>
                                </td>

                                <td>
                                    <span class="channel-badge">${campaign.channel}</span>
                                </td>

                                <td class="date-range">
                                    ${campaign.startDate}<br>
                                    ${campaign.endDate}
                                </td>

                                <td>
                                    <a href="${pageContext.request.contextPath}/marketing/campaign?action=detail&id=${campaign.campaignId}"
                                       class="btn btn-sm btn-outline-info">
                                        Xem
                                    </a>

                                    <a href="${pageContext.request.contextPath}/marketing/campaign?action=edit&id=${campaign.campaignId}"
                                       class="btn btn-sm btn-outline-warning">
                                        Sửa
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>

                    </tbody>
                </table>
            </div>

            <c:if test="${not empty pagination}">
                <div class="p-3 d-flex justify-content-between align-items-center flex-wrap">
                    <div>
                        Hiển thị
                        ${pagination.getStartItemNumber()} -
                        ${pagination.getEndItemNumber()}
                        / ${pagination.totalItems}
                    </div>

                    <div>
                        <c:if test="${pagination.hasPreviousPage()}">
                            <a class="btn btn-sm btn-outline-secondary"
                               href="${pageContext.request.contextPath}/marketing/campaign?action=list&page=${pagination.currentPage - 1}">
                                Trước
                            </a>
                        </c:if>

                        <c:if test="${pagination.hasNextPage()}">
                            <a class="btn btn-sm btn-outline-secondary"
                               href="${pageContext.request.contextPath}/marketing/campaign?action=list&page=${pagination.currentPage + 1}">
                                Tiếp
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:if>

        </div>

    </c:when>


    <%-- Không có campaign nào --%>
    <c:otherwise>
        <div class="card border-0">
            <div class="empty-state text-center p-4">
                <i class="bi bi-inbox" style="font-size:40px"></i>
                <h5>Không có campaign nào</h5>
                <a href="${pageContext.request.contextPath}/marketing/campaign?action=create"
                   class="btn btn-primary mt-3">
                    Tạo Campaign
                </a>
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