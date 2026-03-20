<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-user-plus me-2"></i>Quản lý Leads</h4>
                <p class="text-muted mb-0">Danh sách, tìm kiếm và quản lý leads trong hệ thống</p>
            </div>
            <div class="d-flex gap-2">
                <form method="GET" action="${pageContext.request.contextPath}/marketing/leads/export" class="d-inline">
                    <input type="hidden" name="search" value="${searchKeyword}"/>
                    <input type="hidden" name="status" value="${filterStatus}"/>
                    <c:if test="${not empty filterCampaignId}">
                        <input type="hidden" name="campaignId" value="${filterCampaignId}"/>
                    </c:if>
                    <button type="submit" class="btn btn-outline-success">
                        <i class="fas fa-file-excel me-1"></i> Export Excel
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/marketing/leads/import"
                   class="btn btn-outline-primary">
                    <i class="fas fa-file-import me-1"></i> Import Leads
                </a>
                <a href="${pageContext.request.contextPath}/marketing/leads/form${not empty filterCampaignId ? '?campaignId='.concat(filterCampaignId) : ''}"
                   class="btn btn-primary">
                    <i class="fas fa-plus-circle me-1"></i> Tạo Lead Mới
                </a>
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

        <%-- Banner: đang lọc theo campaign --%>
        <c:if test="${not empty filterCampaign}">
            <div class="alert alert-info d-flex justify-content-between align-items-center mb-3" role="alert">
                <div>
                    <i class="fas fa-bullhorn me-2"></i>
                    Đang xem leads của campaign:
                    <strong>
                        <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${filterCampaign.campaignId}"
                           class="text-decoration-none">
                                ${filterCampaign.name}
                        </a>
                    </strong>
                </div>
                <a href="${pageContext.request.contextPath}/marketing/leads" class="btn btn-sm btn-outline-info">
                    <i class="fas fa-times me-1"></i> Xóa bộ lọc
                </a>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="card shadow-sm mb-4 filter-card">
            <div class="card-body">
                <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Tìm kiếm & Lọc</h6>
                <form method="GET" action="${pageContext.request.contextPath}/marketing/leads" class="row g-3">
                    <%-- Giữ campaignId khi search/filter --%>
                    <c:if test="${not empty filterCampaignId}">
                        <input type="hidden" name="campaignId" value="${filterCampaignId}"/>
                    </c:if>

                    <div class="col-md-5">
                        <label class="form-label">Tìm kiếm (tên, email, SĐT)</label>
                        <input type="text" class="form-control" name="search"
                               value="${searchKeyword}" placeholder="Nhập tên, email hoặc số điện thoại...">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="NEW_LEAD"     ${filterStatus == 'NEW_LEAD'     ? 'selected' : ''}>New Lead</option>
                            <option value="CONTACTED"    ${filterStatus == 'CONTACTED'    ? 'selected' : ''}>Contacted</option>
                            <option value="QUALIFIED"    ${filterStatus == 'QUALIFIED'    ? 'selected' : ''}>Qualified</option>
                            <option value="DEAL_CREATED" ${filterStatus == 'DEAL_CREATED' ? 'selected' : ''}>Deal Created</option>
                            <option value="LOST"         ${filterStatus == 'LOST'         ? 'selected' : ''}>Lost</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Sở thích</label>
                        <input type="text" class="form-control" name="interest"
                               value="${filterInterest}" placeholder="Nhập sở thích...">
                    </div>
                    <div class="col-md-3 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-1"></i> Tìm kiếm
                        </button>
                        <a href="${pageContext.request.contextPath}/marketing/leads"
                           class="btn btn-outline-secondary w-100">
                            <i class="fas fa-redo me-1"></i> Đặt lại
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Results -->
        <c:choose>

            <%-- Tìm nhưng không có kết quả --%>
            <c:when test="${empty leads and (not empty searchKeyword or not empty filterStatus)}">
                <div class="alert alert-warning">
                    <i class="fas fa-search me-1"></i> Không tìm thấy lead phù hợp.
                </div>
            </c:when>

            <%-- Có leads --%>
            <c:when test="${not empty leads}">

                <div class="card shadow-sm mb-3 border-0 bg-primary text-white stats-card bg-total-lead"
                     style="border-radius: 10px;">
                    <div class="card-body py-3 px-4">
                        <span class="fs-2 fw-bold">${pagination.totalItems}</span>
                        <span class="ms-2">
                            <c:choose>
                                <c:when test="${not empty searchKeyword or not empty filterStatus}">Lead tìm thấy</c:when>
                                <c:otherwise>Tổng Lead</c:otherwise>
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
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>Điện thoại</th>
                                <th>Điểm số</th>
                                <th>Interest</th>
                                <th>Trạng thái</th>
                                <th>Campaigns</th><%-- ĐÃ ĐỔI: "Campaign" → "Campaigns" --%>
                                <th class="text-center">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="lead" items="${leads}" varStatus="loop">
                                <tr>
                                    <td class="text-muted">${pagination.offset + loop.count}</td>

                                    <td>
                                        <strong>${lead.fullName}</strong>
                                    </td>

                                    <td>
                                        <a href="mailto:${lead.email}" class="text-decoration-none">
                                                ${lead.email}
                                        </a>
                                    </td>

                                    <td>${lead.phone != null ? lead.phone : '-'}</td>

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
                                        <c:out value="${lead.interest != null ? lead.interest : '-'}"/>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${lead.status == 'New' || lead.status == 'NEW'}">
                                                <span class="badge-status badge-new">New</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'Qualified' || lead.status == 'QUALIFIED'}">
                                                <span class="badge-status badge-qualified">Qualified</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'Contacted' || lead.status == 'CONTACTED'}">
                                                <span class="badge-status badge-contacted">Contacted</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'Converted' || lead.status == 'CONVERTED'}">
                                                <span class="badge-status badge-deal">Converted</span>
                                            </c:when>
                                            <c:when test="${lead.status == 'Lost' || lead.status == 'LOST'}">
                                                <span class="badge-status badge-lost">Lost</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status">${lead.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- CỘT CAMPAIGNS: hiển thị badge dọc, mỗi campaign 1 dòng --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty lead.campaignNames}">
                                                <div class="d-flex flex-column gap-1">
                                                    <c:forEach var="campName"
                                                               items="${fn:split(lead.campaignNames, '|')}">
                                                        <span class="badge bg-info text-dark"
                                                              style="font-size: 0.75rem; white-space: nowrap; display: block;">
                                                            <i class="fas fa-bullhorn me-1"></i>${fn:trim(campName)}
                                                        </span>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/marketing/leads/detail?id=${lead.leadId}"
                                           class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/marketing/leads/form?id=${lead.leadId}"
                                           class="btn btn-sm btn-outline-warning ms-1" title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/sale/deal/create?relatedId=${lead.leadId}&relatedType=LEAD"
                                           class="btn btn-sm btn-outline-warning ms-1" title="Tạo Deal">
                                            <i class="fas fa-plus"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination (reusable component) --%>
                    <jsp:include page="/view/components/pagination.jsp"/>
                </div>

            </c:when>

            <%-- Không có lead nào --%>
            <c:otherwise>
                <div class="card shadow-sm text-center py-5">
                    <div class="card-body empty-state">
                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">Không có lead nào</h5>
                        <p class="text-muted">Hệ thống chưa có lead nào. Bạn có thể tạo mới hoặc import từ file Excel.</p>
                        <div class="d-flex justify-content-center gap-2">
                            <a href="${pageContext.request.contextPath}/marketing/leads/import"
                               class="btn btn-outline-primary">
                                <i class="fas fa-file-import me-1"></i> Import Leads
                            </a>
                            <a href="${pageContext.request.contextPath}/marketing/leads/form${not empty filterCampaignId ? '?campaignId='.concat(filterCampaignId) : ''}"
                               class="btn btn-primary">
                                <i class="fas fa-plus me-1"></i> Tạo Lead
                            </a>
                        </div>
                    </div>
                </div>
            </c:otherwise>

        </c:choose>

    </div>
</div>

<!-- Score Modal -->
<div class="modal fade" id="scoreModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-star me-1"></i> Chấm điểm Lead</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label for="scoreInput" class="form-label">Điểm số (0 - 100)</label>
                    <input type="number" class="form-control" id="scoreInput" min="0" max="100" required>
                    <small class="form-text text-muted">Lead sẽ tự động thành Qualified nếu điểm >= 50</small>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-primary" id="saveScoreBtn">
                    <i class="fas fa-save me-1"></i> Lưu điểm
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    let scoreModal;
    let currentLeadId;

    document.addEventListener('DOMContentLoaded', function () {
        scoreModal = new bootstrap.Modal(document.getElementById('scoreModal'));

        document.getElementById('saveScoreBtn').addEventListener('click', function () {
            const score = document.getElementById('scoreInput').value;
            if (score === '' || score < 0 || score > 100) {
                alert('Điểm số phải từ 0 đến 100');
                return;
            }
            submitScore(currentLeadId, score);
        });
    });

    function openScoreModal(leadId, currentScore) {
        currentLeadId = leadId;
        document.getElementById('scoreInput').value = currentScore;
        scoreModal.show();
    }

    function submitScore(leadId, score) {
        fetch('${pageContext.request.contextPath}/marketing/leads/score', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'leadId=' + leadId + '&score=' + score
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    scoreModal.hide();
                    location.reload();
                } else {
                    alert(data.message || 'Cập nhật thất bại');
                }
            })
            .catch(error => {
                alert('Lỗi kết nối: ' + error.message);
            });
    }
</script>
