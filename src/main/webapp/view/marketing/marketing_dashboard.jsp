<!-- filepath: d:\Kì 5\SWP391\project\CRM-project\src\main\webapp\view\marketing\dashboard.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="col-10">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-chart-pie me-2"></i>Marketing Dashboard</h4>
                <p class="text-muted mb-0">Tổng quan hiệu quả marketing</p>
            </div>
        </div>

        <!-- Summary Cards Row 1: Leads -->
        <h6 class="text-muted mb-3"><i class="fas fa-user-plus me-1"></i> Tổng quan Leads</h6>
        <div class="row g-3 mb-4">
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-primary">${totalLeads}</div>
                    <small class="text-muted">Tổng Leads</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-info">${newLeads}</div>
                    <small class="text-muted">New</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-warning">${contactedLeads}</div>
                    <small class="text-muted">Contacted</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-success">${qualifiedLeads}</div>
                    <small class="text-muted">Qualified</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold" style="color: #6f42c1;">${dealCreatedLeads}</div>
                    <small class="text-muted">Deal Created</small>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-danger">${lostLeads}</div>
                    <small class="text-muted">Lost</small>
                </div>
            </div>
        </div>

        <!-- Summary Cards Row 2: Campaigns & Conversion -->
        <h6 class="text-muted mb-3"><i class="fas fa-bullhorn me-1"></i> Tổng quan Campaigns</h6>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-primary">${totalCampaigns}</div>
                    <small class="text-muted">Tổng Campaign</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-success">${activeCampaigns}</div>
                    <small class="text-muted">Đang chạy</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-info">${planningCampaigns}</div>
                    <small class="text-muted">Lên kế hoạch</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center py-3">
                    <div class="fs-2 fw-bold text-warning">${conversionRate}%</div>
                    <small class="text-muted">Conversion Rate</small>
                </div>
            </div>
        </div>

        <!-- Lead Funnel (Visual Pipeline) -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-filter me-1"></i> Lead Funnel</h5>
            </div>
            <div class="card-body">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="text-center flex-fill">
                        <div class="bg-info bg-opacity-10 rounded p-3">
                            <div class="fs-3 fw-bold text-info">${newLeads}</div>
                            <small>New Lead</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-right text-muted"></i>
                    <div class="text-center flex-fill">
                        <div class="bg-warning bg-opacity-10 rounded p-3">
                            <div class="fs-3 fw-bold text-warning">${contactedLeads}</div>
                            <small>Contacted</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-right text-muted"></i>
                    <div class="text-center flex-fill">
                        <div class="bg-success bg-opacity-10 rounded p-3">
                            <div class="fs-3 fw-bold text-success">${qualifiedLeads}</div>
                            <small>Qualified</small>
                        </div>
                    </div>
                    <i class="fas fa-chevron-right text-muted"></i>
                    <div class="text-center flex-fill">
                        <div class="rounded p-3" style="background: rgba(111,66,193,0.1);">
                            <div class="fs-3 fw-bold" style="color:#6f42c1;">${dealCreatedLeads}</div>
                            <small>Deal Created</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Top Active Campaigns -->
            <div class="col-md-6">
                <div class="card shadow-sm h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-fire me-1"></i> Campaign đang chạy</h5>
                        <a href="${pageContext.request.contextPath}/marketing/campaign?status=ACTIVE"
                           class="btn btn-sm btn-outline-primary">Xem tất cả</a>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${not empty topCampaigns}">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Tên</th>
                                                <th>Kênh</th>
                                                <th>Ngân sách</th>
                                                <th>Kết thúc</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="c" items="${topCampaigns}">
                                                <tr>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${c.campaignId}"
                                                           class="text-decoration-none fw-semibold">
                                                            ${c.name}
                                                        </a>
                                                    </td>
                                                    <td><span class="badge bg-light text-dark border">${c.channel}</span></td>
                                                    <td class="text-success fw-semibold">
                                                        <fmt:formatNumber value="${c.budget}" type="currency"
                                                                          currencySymbol="₫" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="small text-muted">${c.endDate}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-bullhorn fa-2x mb-2"></i>
                                    <p>Chưa có campaign nào đang chạy</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Recent Leads -->
            <div class="col-md-6">
                <div class="card shadow-sm h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-user-clock me-1"></i> Leads mới nhất</h5>
                        <a href="${pageContext.request.contextPath}/marketing/leads"
                           class="btn btn-sm btn-outline-primary">Xem tất cả</a>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${not empty recentLeads}">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Họ tên</th>
                                                <th>Email</th>
                                                <th>Điểm</th>
                                                <th>Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="lead" items="${recentLeads}">
                                                <tr>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/marketing/leads/detail?id=${lead.leadId}"
                                                           class="text-decoration-none fw-semibold">
                                                            ${lead.fullName}
                                                        </a>
                                                    </td>
                                                    <td class="small">${lead.email}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${lead.score >= 70}">
                                                                <span class="badge bg-danger">${lead.score}</span>
                                                            </c:when>
                                                            <c:when test="${lead.score >= 40}">
                                                                <span class="badge bg-warning text-dark">${lead.score}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${lead.score}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${lead.status == 'NEW_LEAD'}">
                                                                <span class="badge bg-info text-dark">New</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'CONTACTED'}">
                                                                <span class="badge bg-warning text-dark">Contacted</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'QUALIFIED'}">
                                                                <span class="badge bg-success">Qualified</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'DEAL_CREATED'}">
                                                                <span class="badge" style="background:#6f42c1;">Deal</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-danger">Lost</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-inbox fa-2x mb-2"></i>
                                    <p>Chưa có lead nào</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="card shadow-sm mt-4">
            <div class="card-body">
                <h6 class="mb-3"><i class="fas fa-bolt me-1"></i> Thao tác nhanh</h6>
                <div class="d-flex gap-2 flex-wrap">
                    <a href="${pageContext.request.contextPath}/marketing/campaign/form" class="btn btn-primary">
                        <i class="fas fa-plus me-1"></i> Tạo Campaign
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/form" class="btn btn-success">
                        <i class="fas fa-user-plus me-1"></i> Tạo Lead
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/import" class="btn btn-outline-primary">
                        <i class="fas fa-file-import me-1"></i> Import Leads
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads?status=QUALIFIED" class="btn btn-outline-success">
                        <i class="fas fa-star me-1"></i> Xem Lead Qualified
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>