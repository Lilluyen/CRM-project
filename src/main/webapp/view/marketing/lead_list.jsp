<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Leads - CRM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4e73df;
            --secondary-color: #858796;
            --light-bg: #f8f9fc;
        }

        body {
            background-color: var(--light-bg);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .navbar {
            background: rgba(33, 37, 41, 1);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .navbar-brand {
            font-weight: bold;
            font-size: 20px;
        }

        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .page-header h1 {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .page-header p {
            margin: 0;
            font-size: 14px;
            opacity: 0.9;
        }

        .filter-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            padding: 20px;
        }

        .filter-card .card-body {
            padding: 0;
        }

        .table-wrapper {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .table {
            margin-bottom: 0;
        }

        .table thead {
            background-color: #f8f9fc;
            border-bottom: 2px solid #e3e6f0;
        }

        .table thead th {
            font-weight: 600;
            color: #333;
            padding: 15px;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .table tbody tr {
            border-bottom: 1px solid #e3e6f0;
            transition: background-color 0.2s ease;
        }

        .table tbody tr:hover {
            background-color: #f8f9fc;
        }

        .table tbody td {
            padding: 15px;
            vertical-align: middle;
            font-size: 13px;
        }

        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-new {
            background-color: #e7f3ff;
            color: #0066cc;
        }

        .badge-qualified {
            background-color: #f0f9ff;
            color: #0066cc;
        }

        .badge-contacted {
            background-color: #fff4e6;
            color: #cc6600;
        }

        .badge-deal-created {
            background-color: #e6ffe6;
            color: #009900;
        }

        .badge-lost {
            background-color: #ffe6e6;
            color: #cc0000;
        }

        .score-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 12px;
        }

        .score-hot {
            background-color: #ff6b6b;
            color: white;
        }

        .score-warm {
            background-color: #fca311;
            color: white;
        }

        .score-cold {
            background-color: #6c757d;
            color: white;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
        }

        .btn-detail {
            background-color: var(--primary-color);
            color: white;
            border: none;
        }

        .btn-detail:hover {
            background-color: #3d5fd4;
            color: white;
        }

        .btn-score {
            background-color: #6c757d;
            color: white;
            border: none;
        }

        .btn-score:hover {
            background-color: #5a6268;
            color: white;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .empty-state i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }

        .empty-state h4 {
            color: #333;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #666;
            margin-bottom: 20px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            text-align: center;
        }

        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: var(--primary-color);
        }

        .stat-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 8px;
        }

        .footer {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
            margin-top: 40px;
            font-size: 12px;
        }

        .pagination {
            margin-top: 20px;
        }

        .pagination .page-link {
            color: var(--primary-color);
            border-color: #ddd;
        }

        .pagination .page-link:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .pagination .page-item.active .page-link {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/marketing/campaign?action=list">
                <i class="bi bi-graph-up"></i> CRM System
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/campaign?action=list">
                            <i class="bi bi-megaphone"></i> Campaigns
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/marketing/lead?action=list">
                            <i class="bi bi-people"></i> Leads
                        </a>
                    </li>
                     <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/report">
                            <i class="bi bi-graph-up"></i> Reports
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle"></i> Marketing
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container-fluid">
            <h1><i class="bi bi-people"></i> Quản lý Leads</h1>
            <p>Danh sách tất cả leads và quản lý chúng</p>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">${totalLeads != null ? totalLeads : 0}</div>
                <div class="stat-label">Tổng Leads</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${qualifiedLeads != null ? qualifiedLeads : 0}</div>
                <div class="stat-label">Leads Qualified</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${contactedLeads != null ? contactedLeads : 0}</div>
                <div class="stat-label">Đã Liên Hệ</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${dealLeads != null ? dealLeads : 0}</div>
                <div class="stat-label">Deal Created</div>
            </div>
        </div>

        <!-- Filter Card -->
        <div class="filter-card mb-4">
            <div class="card-body">
                <form method="GET" action="${pageContext.request.contextPath}/marketing/lead" class="row g-3">
                    <input type="hidden" name="action" value="list">
                    
                    <div class="col-md-4">
                        <label for="searchName" class="form-label">Tìm kiếm theo tên/email</label>
                        <input type="text" class="form-control" id="searchName" name="searchName" placeholder="Nhập tên hoặc email...">
                    </div>
                    
                    <div class="col-md-3">
                        <label for="filterStatus" class="form-label">Trạng thái</label>
                        <select class="form-select" id="filterStatus" name="filterStatus">
                            <option value="">-- Tất cả --</option>
                            <option value="NEW_LEAD">New Lead</option>
                            <option value="CONTACTED">Contacted</option>
                            <option value="QUALIFIED">Qualified</option>
                            <option value="DEAL_CREATED">Deal Created</option>
                            <option value="LOST">Lost</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label for="filterScore" class="form-label">Điểm số</label>
                        <select class="form-select" id="filterScore" name="filterScore">
                            <option value="">-- Tất cả --</option>
                            <option value="HOT">Hot (70+)</option>
                            <option value="WARM">Warm (40-69)</option>
                            <option value="COLD">Cold (&lt;40)</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search"></i> Tìm kiếm
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Leads Table -->
        <c:choose>
            <%-- Không có leads --%>
            <c:when test="${empty leads}">
                <div class="empty-state">
                    <i class="bi bi-inbox"></i>
                    <h4>Không có Leads</h4>
                    <p>Hiện chưa có leads nào trong hệ thống. Vui lòng import leads từ tệp Excel.</p>
                    <a href="${pageContext.request.contextPath}/marketing/lead-import" class="btn btn-primary">
                        <i class="bi bi-upload"></i> Import Leads
                    </a>
                </div>
            </c:when>

            <%-- Có leads --%>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 5%;">ID</th>
                                <th style="width: 15%;">Họ tên</th>
                                <th style="width: 15%;">Email</th>
                                <th style="width: 12%;">Điện thoại</th>
                                <th style="width: 12%;">Công ty</th>
                                <th style="width: 8%;">Điểm số</th>
                                <th style="width: 12%;">Trạng thái</th>
                                <th style="width: 12%;">Nguồn</th>
                                <th style="width: 9%;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="lead" items="${leads}">
                                <tr>
                                    <td>${lead.leadId}</td>
                                    <td>
                                        <strong>${lead.fullName}</strong>
                                    </td>
                                    <td>
                                        <a href="mailto:${lead.email}" style="text-decoration: none; color: var(--primary-color);">
                                            ${lead.email}
                                        </a>
                                    </td>
                                    <td>${lead.phone}</td>
                                    <td>${lead.companyName != null ? lead.companyName : '-'}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${lead.score >= 70}">
                                                <span class="score-badge score-hot">${lead.score}</span>
                                            </c:when>
                                            <c:when test="${lead.score >= 40}">
                                                <span class="score-badge score-warm">${lead.score}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="score-badge score-cold">${lead.score}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${lead.status == 'NEW_LEAD'}">
                                                <span class="badge-status badge-new">New</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'QUALIFIED'}">
                                                <span class="badge-status badge-qualified">Qualified</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'CONTACTED'}">
                                                <span class="badge-status badge-contacted">Contacted</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'DEAL_CREATED'}">
                                                <span class="badge-status badge-deal-created">Deal</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'LOST'}">
                                                <span class="badge-status badge-lost">Lost</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status">${lead.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${lead.source != null ? lead.source : '-'}</td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="btn btn-sm btn-detail" onclick="viewLeadDetail(${lead.leadId})" title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                            <button class="btn btn-sm btn-score" onclick="scoreModal(${lead.leadId}, ${lead.score})" title="Chấm điểm">
                                                <i class="bi bi-star"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

            <%-- Pagination --%>
                <nav aria-label="Page navigation" class="d-flex justify-content-center">
                    <ul class="pagination">
                        <li class="page-item"><a class="page-link" href="#">Previous</a></li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">Next</a></li>
                    </ul>
                </nav>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Score Modal -->
    <div class="modal fade" id="scoreModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Chấm điểm Lead</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="scoreForm" method="POST" action="${pageContext.request.contextPath}/marketing/lead">
                    <input type="hidden" name="action" value="score">
                    <input type="hidden" id="leadId" name="leadId">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="score" class="form-label">Điểm số (0-100)</label>
                            <input type="number" class="form-control" id="score" name="score" min="0" max="100" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="footer">
        <p>&copy; 2026 CRM System. All rights reserved.</p>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewLeadDetail(leadId) {
            // Chuyển đến trang chi tiết lead nếu có
            window.location.href = '${pageContext.request.contextPath}/marketing/lead?action=detail&leadId=' + leadId;
        }

        function scoreModal(leadId, currentScore) {
            document.getElementById('leadId').value = leadId;
            document.getElementById('score').value = currentScore;
            new bootstrap.Modal(document.getElementById('scoreModal')).show();
        }
    </script>
</body>
</html>