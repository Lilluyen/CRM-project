<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="md-page-header">
            <div class="page-header-icon">
                <i class="fas fa-chart-pie"></i>
            </div>
            <div>
                <h4>Marketing Dashboard</h4>
                <p class="md-subtitle">Marketing performance overview</p>
            </div>
        </div>

        <!-- Summary Cards Row 1: Leads -->
        <p class="section-label"><i class="fas fa-user-plus"></i> Leads Overview</p>
        <div class="row g-3 mb-4">
            <div class="col-md-2">
                <div class="stat-card stat-primary">
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                    <div class="stat-number">${totalLeads}</div>
                    <div class="stat-label">Total Leads</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-info">
                    <div class="stat-icon"><i class="fas fa-user-plus"></i></div>
                    <div class="stat-number">${newLeads}</div>
                    <div class="stat-label">New Leads</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-warning">
                    <div class="stat-icon"><i class="fas fa-phone"></i></div>
                    <div class="stat-number">${contactedLeads}</div>
                    <div class="stat-label">Nurturing Leads</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-success">
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                    <div class="stat-number">${qualifiedLeads}</div>
                    <div class="stat-label">Qualified Leads</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-purple">
                    <div class="stat-icon"><i class="fas fa-handshake"></i></div>
                    <div class="stat-number">${dealsCreated}</div>
                    <div class="stat-label">Deals Created</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-success">
                    <div class="stat-icon"><i class="fas fa-trophy"></i></div>
                    <div class="stat-number">${dealsWon}</div>
                    <div class="stat-label">Deals Won</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card stat-danger">
                    <div class="stat-icon"><i class="fas fa-times-circle"></i></div>
                    <div class="stat-number">${lostLeads}</div>
                    <div class="stat-label">Lost</div>
                </div>
            </div>
        </div>

        <!-- Summary Cards Row 2: Campaigns & Conversion -->
        <p class="section-label"><i class="fas fa-bullhorn"></i> Campaigns Overview</p>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card stat-primary">
                    <div class="stat-icon"><i class="fas fa-bullhorn"></i></div>
                    <div class="stat-number">${totalCampaigns}</div>
                    <div class="stat-label">Total Campaigns</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card stat-success">
                    <div class="stat-icon"><i class="fas fa-play-circle"></i></div>
                    <div class="stat-number">${activeCampaigns}</div>
                    <div class="stat-label">Active Campaigns</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card stat-info">
                    <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                    <div class="stat-number">${planningCampaigns}</div>
                    <div class="stat-label">Planning Campaigns</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card stat-warning">
                    <div class="stat-icon"><i class="fas fa-percentage"></i></div>
                    <div class="stat-number">${conversionRate}%</div>
                    <div class="stat-label">Conversion Rate</div>
                </div>
            </div>
        </div>

        <!-- Lead Funnel -->
        <div class="funnel-card card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-filter me-2 text-primary"></i>Lead Funnel</h5>
            </div>
            <div class="card-body p-0">
                <div class="funnel-track">
                    <div class="funnel-step step-new">
                        <div class="funnel-pct">Stage 1</div>
                        <div class="funnel-number">${newLeads}</div>
                        <div class="funnel-label">New Leads</div>
                    </div>
                    <div class="funnel-connector"><i class="fas fa-chevron-right"></i></div>
                    <div class="funnel-step step-contacted">
                        <div class="funnel-pct">Stage 2</div>
                        <div class="funnel-number">${contactedLeads}</div>
                        <div class="funnel-label">Nurturing Leads</div>
                    </div>
                    <div class="funnel-connector"><i class="fas fa-chevron-right"></i></div>
                    <div class="funnel-step step-qualified">
                        <div class="funnel-pct">Stage 3</div>
                        <div class="funnel-number">${qualifiedLeads}</div>
                        <div class="funnel-label">Qualified Leads</div>
                    </div>
                    <div class="funnel-connector"><i class="fas fa-chevron-right"></i></div>
                    <div class="funnel-step step-deal">
                        <div class="funnel-pct">Stage 4</div>
                        <div class="funnel-number">${dealCreatedLeads}</div>
                        <div class="funnel-label">Deal Created</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Top Active Campaigns -->
            <div class="col-md-6">
                <div class="data-card card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-fire text-danger me-2"></i>Top Active Campaigns</h5>
                        <a href="${pageContext.request.contextPath}/marketing/campaign?status=ACTIVE"
                           class="md-card-action">View All <i class="fas fa-arrow-right ms-1"></i></a>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${not empty topCampaigns}">
                                <div class="table-responsive">
                                    <table class="table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Campaign Name</th>
                                                <th>Channel</th>
                                                <th>Budget</th>
                                                <th>End Date</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="c" items="${topCampaigns}">
                                                <tr>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/marketing/campaign/detail?id=${c.campaignId}"
                                                           class="campaign-name-link">
                                                            ${c.name}
                                                        </a>
                                                    </td>
                                                    <td><span class="channel-tag">${c.channel}</span></td>
                                                    <td class="budget-text">
                                                        <fmt:formatNumber value="${c.budget}" type="currency"
                                                                          currencySymbol="₫" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="end-date-text">${c.endDate}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-icon"><i class="fas fa-bullhorn"></i></div>
                                    <p>No active campaigns at the moment</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Recent Leads -->
            <div class="col-md-6">
                <div class="data-card card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-user-clock text-primary me-2"></i>Recent Leads</h5>
                        <a href="${pageContext.request.contextPath}/marketing/leads"
                           class="md-card-action">View All <i class="fas fa-arrow-right ms-1"></i></a>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${not empty recentLeads}">
                                <div class="table-responsive">
                                    <table class="table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Email</th>
                                                <th>Score</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="lead" items="${recentLeads}">
                                                <tr>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/marketing/leads/detail?id=${lead.leadId}"
                                                           class="lead-name-link text-decoration-none">
                                                            ${lead.fullName}
                                                        </a>
                                                    </td>
                                                    <td class="lead-email-text">${lead.email}</td>
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
                                                                <span class="lead-badge new">New</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'Nurturing' || lead.status == 'NURTURING'}">
                                                                <span class="lead-badge contacted">Nurturing</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'QUALIFIED'}">
                                                                <span class="lead-badge qualified">Qualified</span>
                                                            </c:when>
                                                            <c:when test="${lead.status == 'DEAL_CREATED'}">
                                                                <span class="lead-badge deal">Deal</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="lead-badge lost">Lost</span>
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
                                <div class="empty-state">
                                    <div class="empty-icon"><i class="fas fa-inbox"></i></div>
                                    <p>No leads available</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions-card card">
            <div class="card-body">
                <p class="qa-label"><i class="fas fa-bolt me-1"></i> Quick Actions</p>
                <div class="d-flex gap-2 flex-wrap">
                    <a href="${pageContext.request.contextPath}/marketing/campaign/form" class="btn btn-primary">
                        <i class="fas fa-plus me-1"></i> Create Campaign
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/form" class="btn btn-success">
                        <i class="fas fa-user-plus me-1"></i> Create Lead
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads/import" class="btn btn-outline-primary">
                        <i class="fas fa-file-import me-1"></i> Import Leads
                    </a>
                    <a href="${pageContext.request.contextPath}/marketing/leads?status=QUALIFIED" class="btn btn-outline-success">
                        <i class="fas fa-star me-1"></i> View Qualified Leads
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>