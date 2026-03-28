<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="mt-5">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1"><i class="fas fa-eye me-2"></i>Campaign Details</h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/marketing/campaign">Campaign</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${campaign.name}</li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/campaign"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to List
            </a>
        </div>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle"></i>
                <strong>Error!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- SUCCESS Alert -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i>
                <strong>Success!</strong> ${success}
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
                                        <i class="bi bi-play-fill"></i> Active
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PLANNING'}">
                                    <span class="badge-status badge-planning">
                                        <i class="bi bi-hourglass"></i> Planning
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PAUSED'}">
                                    <span class="badge-status badge-paused">
                                        <i class="bi bi-pause-fill"></i> Paused
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'COMPLETED'}">
                                    <span class="badge-status badge-completed">
                                        <i class="bi bi-check-circle"></i> Completed
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
                                <span class="detail-label d-block mb-2">Budget</span>
                                <span class="budget-amount">
                                    <fmt:formatNumber value="${campaign.budget}" type="currency" 
                                                      currencySymbol="₫" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="mb-3">
                                <span class="channel-badge">
                                    <c:choose>
                                        <c:when test="${campaign.channel == 'Email'}">
                                            <i class="bi bi-envelope"></i> Email
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Facebook'}">
                                            <i class="bi bi-facebook"></i> Facebook
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Google'}">
                                            <i class="bi bi-google"></i> Google Ads
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Google Display'}">
                                            <i class="bi bi-display"></i> Google Display
                                        </c:when>
                                        <c:when test="${campaign.channel == 'LinkedIn'}">
                                            <i class="bi bi-linkedin"></i> LinkedIn
                                        </c:when>
                                        <c:when test="${campaign.channel == 'SMS'}">
                                            <i class="bi bi-chat-dots"></i> SMS
                                        </c:when>
                                        <c:when test="${campaign.channel == 'SEO'}">
                                            <i class="bi bi-search"></i> SEO
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Event'}">
                                            <i class="bi bi-calendar-event"></i> Event
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Referral'}">
                                            <i class="bi bi-people"></i> Referral
                                        </c:when>
                                        <c:when test="${campaign.channel == 'Multi-channel'}">
                                            <i class="bi bi-diagram-3"></i> Multi-channel
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
                <h5><i class="bi bi-info-circle"></i> Campaign Information</h5>
            </div>
            <div class="card-body">
                <div class="detail-section">
                    <h6><i class="bi bi-calendar2-event"></i> Campaign Timeline</h6>
                    <div class="detail-row">
                        <span class="detail-label">Start Date:</span>
                        <span class="detail-value">
                            <i class="bi bi-calendar"></i>
                            ${campaign.startDate}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">End Date:</span>
                        <span class="detail-value">
                            <i class="bi bi-calendar"></i>
                            ${campaign.endDate}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Campaign Duration:</span>
                        <span class="detail-value">
                        <c:if test="${not empty campaign.startDate and not empty campaign.endDate}">
                            ${campaign.endDate.toEpochDay() - campaign.startDate.toEpochDay()} days
                        </c:if>
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="bi bi-briefcase"></i> Budget Information</h6>
                    <div class="detail-row">
                        <span class="detail-label">Total Budget:</span>
                        <span class="detail-value budget-amount">
                            <fmt:formatNumber value="${campaign.budget}" type="currency" 
                                              currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Marketing Channel:</span>
                        <span class="detail-value">
                            <span class="channel-badge">
                                <c:choose>
                                    <c:when test="${campaign.channel == 'Email'}">
                                        <i class="bi bi-envelope"></i> Email
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Facebook'}">
                                        <i class="bi bi-facebook"></i> Facebook
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Google'}">
                                        <i class="bi bi-google"></i> Google Ads
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Google Display'}">
                                        <i class="bi bi-display"></i> Google Display
                                    </c:when>
                                    <c:when test="${campaign.channel == 'LinkedIn'}">
                                        <i class="bi bi-linkedin"></i> LinkedIn
                                    </c:when>
                                    <c:when test="${campaign.channel == 'SMS'}">
                                        <i class="bi bi-chat-dots"></i> SMS
                                    </c:when>
                                    <c:when test="${campaign.channel == 'SEO'}">
                                        <i class="bi bi-search"></i> SEO
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Event'}">
                                        <i class="bi bi-calendar-event"></i> Event
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Referral'}">
                                        <i class="bi bi-people"></i> Referral
                                    </c:when>
                                    <c:when test="${campaign.channel == 'Multi-channel'}">
                                        <i class="bi bi-diagram-3"></i> Multi-channel
                                    </c:when>
                                    <c:otherwise>
                                        <span class="channel-badge">${campaign.channel}</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Status:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${campaign.status == 'ACTIVE'}">
                                    <span class="badge-status badge-active">
                                        <i class="bi bi-play-fill"></i> Active
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PLANNING'}">
                                    <span class="badge-status badge-planning">
                                        <i class="bi bi-hourglass"></i> Planning
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'PAUSED'}">
                                    <span class="badge-status badge-paused">
                                        <i class="bi bi-pause-fill"></i> Paused
                                    </span>
                                </c:when>
                                <c:when test="${campaign.status == 'COMPLETED'}">
                                    <span class="badge-status badge-completed">
                                        <i class="bi bi-check-circle"></i> Completed
                                    </span>
                                </c:when>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <hr>

                <div class="detail-section">
                    <h6><i class="bi bi-clock-history"></i> Creation & Update Information</h6>
                    <div class="detail-row">
                        <span class="detail-label">Created At:</span>
                        <span class="detail-value">
                            ${campaign.createdAt}
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Updated At:</span>
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
                <h5><i class="bi bi-graph-up"></i> Campaign Statistics</h5>
            </div>
            <div class="card-body">
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.totalLead : 0}</div>
                        <div class="stat-label">Total Leads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${report != null ? report.qualifiedLead : 0}</div>
                        <div class="stat-label">Qualified Leads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${dealsCreated}</div>
                        <div class="stat-label">Deals Created</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${dealsWon}</div>
                        <div class="stat-label">Deals Won</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <c:choose>
                                <c:when test="${report != null && report.totalLead > 0}">
                                    ${conversionRate}%
                                </c:when>
                                <c:otherwise>0%</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="stat-label">Conversion Rate</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="card">
            <div class="card-body">
                <h6 class="mb-3"><i class="bi bi-lightning"></i> Action Buttons</h6>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/marketing/campaign" class="btn btn-large btn-secondary-custom">
                        <i class="bi bi-list"></i> Back to List
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/campaign/form?id=${campaign.campaignId}" class="btn btn-large btn-warning-custom">
                        <i class="bi bi-pencil"></i> Edit
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads?campaignId=${campaign.campaignId}" class="btn btn-large btn-primary-custom">
                        <i class="bi bi-people"></i> View Leads
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
                <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Confirm Delete</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p><strong>Warning!</strong> Are you sure you want to delete this campaign?</p>
                <p class="text-danger small"><strong>${campaign.name}</strong></p>
                <p class="text-danger small">This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
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