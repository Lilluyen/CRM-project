<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-user-plus me-2"></i>Leads Management</h4>
                <p class="text-muted mb-0">List, search, and manage leads in the system</p>
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
                <c:if test="${campaign.status=='ACTIVE'}">
                    <a href="${pageContext.request.contextPath}/marketing/leads/form?campaignId=${filterCampaignId}" class="btn btn-primary">
                        <i class="fas fa-plus-circle me-1"></i> Create New Lead
                    </a>
                </c:if>
            </div>
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

        <%-- Banner: đang lọc theo campaign --%>
        <c:if test="${not empty filterCampaign}">
            <div class="alert alert-info d-flex justify-content-between align-items-center mb-3" role="alert">
                <div>
                    <i class="fas fa-bullhorn me-2"></i>
                    Viewing leads for campaign:
                    <strong>
                        <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${filterCampaign.campaignId}"
                           class="text-decoration-none">
                                ${filterCampaign.name}
                        </a>
                    </strong>
                </div>
                <a href="${pageContext.request.contextPath}/marketing/leads" class="btn btn-sm btn-outline-info">
                    <i class="fas fa-times me-1"></i> Clear Filter
                </a>
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="card shadow-sm mb-4 filter-card">
            <div class="card-body">
                <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
                <form method="GET" action="${pageContext.request.contextPath}/marketing/leads" class="row g-3">
                    <%-- Giữ campaignId khi search/filter --%>
                    <c:if test="${not empty filterCampaignId}">
                        <input type="hidden" name="campaignId" value="${filterCampaignId}"/>
                    </c:if>

                    <div class="col-md-5">
                        <label class="form-label">Search (name, email, phone)</label>
                        <input type="text" class="form-control" name="search"
                               value="${searchKeyword}" placeholder="Enter name, email, or phone number...">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="">-- All Status --</option>
                            <option value="NEW"     ${filterStatus == 'NEW'     ? 'selected' : ''}>New Lead</option>
                            <option value="NURTURING"    ${filterStatus == 'NURTURING'    ? 'selected' : ''}>Nurturing</option>
                            <option value="QUALIFIED"    ${filterStatus == 'QUALIFIED'    ? 'selected' : ''}>Qualified</option>
                            <option value="LOST"         ${filterStatus == 'LOST'         ? 'selected' : ''}>Lost</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Interests</label>
                        <input type="text" class="form-control" name="interest"
                               value="${filterInterest}" placeholder="Enter interests...">
                    </div>
                    <div class="col-md-3 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-1"></i> Search
                        </button>
                        <a href="${pageContext.request.contextPath}/marketing/leads"
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
            <c:when test="${empty leads and (not empty searchKeyword or not empty filterStatus)}">
                <div class="alert alert-warning">
                    <i class="fas fa-search me-1"></i> No matching leads found.
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
                                <c:when test="${not empty searchKeyword or not empty filterStatus}">Matching Leads</c:when>
                                <c:otherwise>Total Leads</c:otherwise>
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
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Score</th>
                                <th>Interests</th>
                                <th>Status</th>
                                <th>Campaigns</th><%-- ĐÃ ĐỔI: "Campaign" → "Campaigns" --%>
                                <th class="text-center">Actions</th>
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
                                            <c:when test="${lead.status == 'Nurturing' || lead.status == 'NURTURING'}">
                                                <span class="badge-status badge-contacted">Nurturing</span>
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

                                    <td>
                                        <a href="${pageContext.request.contextPath}/marketing/leads/detail?id=${lead.leadId}"
                                           class="btn btn-sm btn-outline-info" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <c:if test="${empty filterCampaignId}">
                                            <a href="${pageContext.request.contextPath}/marketing/leads/form?id=${lead.leadId}"
                                               class="btn btn-sm btn-outline-warning ms-1" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                        </c:if>
                                        <c:if test="${lead.score >= 80}">
                                            <a href="${pageContext.request.contextPath}/sale/deal/create?relatedId=${lead.leadId}&relatedType=LEAD&campaignId=${filterCampaignId}"
                                               class="btn btn-sm btn-outline-warning ms-1" title="Create Deal">
                                                <i class="fas fa-plus"></i>
                                            </a>
                                        </c:if>
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
                        <h5 class="text-muted">No leads found</h5>
                        <p class="text-muted">The system has no leads. You can create a new one or import from an Excel file.</p>
                        <div class="d-flex justify-content-center gap-2">
                            <a href="${pageContext.request.contextPath}/marketing/leads/import"
                               class="btn btn-outline-primary">
                                <i class="fas fa-file-import me-1"></i> Import Leads
                            </a>
                            <a href="${pageContext.request.contextPath}/marketing/leads/form${not empty filterCampaignId ? '?campaignId='.concat(filterCampaignId) : ''}"
                               class="btn btn-primary">
                                <i class="fas fa-plus me-1"></i> Create Lead
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
                <h5 class="modal-title"><i class="fas fa-star me-1"></i> Score Lead</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label for="scoreInput" class="form-label">Score (0 - 100)</label>
                    <input type="number" class="form-control" id="scoreInput" min="0" max="100" required>
                    <small class="form-text text-muted">Lead will automatically become Qualified if score >= 50</small>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="saveScoreBtn">
                    <i class="fas fa-save me-1"></i> Save Score
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
                alert('Score must be between 0 and 100');
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
                    alert(data.message || 'Failed to update score');
                }
            })
            .catch(error => {
                alert('Connection error: ' + error.message);
            });
    }
</script>
