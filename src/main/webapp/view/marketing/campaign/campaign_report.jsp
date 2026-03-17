<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"      prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"       prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>

<!-- Chart.js (layout không load; load tại đây cho trang report) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<%-- CSS: assets/css/marketing_report.css (load qua layout.jsp pageCss) --%>

<div class="rpt-page">

  <!-- ── Page header ───────────────────────────────────────────── -->
  <div class="rpt-header">
    <h1><i class="fas fa-chart-bar"></i> Marketing Reports</h1>
    <span class="rpt-header-meta">
      <i class="far fa-clock"></i>&nbsp;
      Generated: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd MMM yyyy, HH:mm" />
      <c:if test="${not empty filterFromDate or not empty filterToDate}">
        &nbsp;|&nbsp;
        <c:if test="${not empty filterFromDate}">From: ${filterFromDate}&nbsp;</c:if>
        <c:if test="${not empty filterToDate}">To: ${filterToDate}</c:if>
      </c:if>
    </span>
  </div>

  <!-- ── Filter panel ──────────────────────────────────────────── -->
  <div class="rpt-filter-card">
    <div class="filter-title"><i class="fas fa-filter"></i> Filter Reports</div>
    <form method="get" action="${pageContext.request.contextPath}/marketing/report">
      <input type="hidden" name="page" value="1" />
      <div class="rpt-filter-row">

        <!-- Campaign -->
        <div>
          <label for="campaignId">Campaign</label>
          <select id="campaignId" name="campaignId">
            <option value="">All Campaigns</option>
            <c:forEach var="camp" items="${allCampaigns}">
              <option value="${camp[0]}"
                <c:if test="${filterCampaignId eq camp[0].toString()}">selected</c:if>>
                ${camp[1]}
              </option>
            </c:forEach>
          </select>
        </div>

        <!-- Source -->
        <div>
          <label for="source">Lead Source</label>
          <select id="source" name="source">
            <option value="">All Sources</option>
            <c:forEach var="src" items="${allSources}">
              <option value="${src}"
                <c:if test="${filterSource eq src}">selected</c:if>>${src}</option>
            </c:forEach>
          </select>
        </div>

        <!-- From date -->
        <div>
          <label for="fromDate">From Date</label>
          <input type="date" id="fromDate" name="fromDate" value="${filterFromDate}" />
        </div>

        <!-- To date -->
        <div>
          <label for="toDate">To Date</label>
          <input type="date" id="toDate" name="toDate" value="${filterToDate}" />
        </div>

        <!-- Actions -->
        <div class="filter-actions">
          <button type="submit" class="btn-filter">
            <i class="fas fa-search"></i> Apply
          </button>
          <a href="${pageContext.request.contextPath}/marketing/report" class="btn-reset">
            <i class="fas fa-undo"></i> Reset
          </a>
        </div>
      </div>
    </form>
  </div>

  <!-- ── KPI summary row ───────────────────────────────────────── -->
  <div class="rpt-kpi-row">
    <div class="rpt-kpi kpi-blue">
      <div class="rpt-kpi-icon"><i class="fas fa-users"></i></div>
      <div class="rpt-kpi-body">
        <div class="rpt-kpi-value">${reportKpi.totalLeads}</div>
        <div class="rpt-kpi-label">Total Leads</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-purple">
      <div class="rpt-kpi-icon"><i class="fas fa-handshake"></i></div>
      <div class="rpt-kpi-body">
        <div class="rpt-kpi-value">${reportKpi.dealsCreated}</div>
        <div class="rpt-kpi-label">Deals Created</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-teal">
      <div class="rpt-kpi-icon"><i class="fas fa-trophy"></i></div>
      <div class="rpt-kpi-body">
        <div class="rpt-kpi-value">${reportKpi.dealsWon}</div>
        <div class="rpt-kpi-label">Deals Won</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-amber">
      <div class="rpt-kpi-icon"><i class="fas fa-percentage"></i></div>
      <div class="rpt-kpi-body">
        <div class="rpt-kpi-value">
          <fmt:formatNumber value="${reportKpi.conversionRate}" maxFractionDigits="1"/>%
        </div>
        <div class="rpt-kpi-label">Conversion Rate</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-green">
      <div class="rpt-kpi-icon"><i class="fas fa-coins"></i></div>
      <div class="rpt-kpi-body">
        <fmt:formatNumber value="${reportKpi.revenue}" type="currency" currencySymbol="₫" maxFractionDigits="0" var="revenueFmt"/>
        <div class="rpt-kpi-value">
          <span title="${revenueFmt}">${revenueFmt}</span>
        </div>
        <div class="rpt-kpi-label">Revenue</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-red">
      <div class="rpt-kpi-icon"><i class="fas fa-wallet"></i></div>
      <div class="rpt-kpi-body">
        <fmt:formatNumber value="${reportKpi.cost}" type="currency" currencySymbol="₫" maxFractionDigits="0" var="costFmt"/>
        <div class="rpt-kpi-value">
          <span title="${costFmt}">${costFmt}</span>
        </div>
        <div class="rpt-kpi-label">Cost</div>
      </div>
    </div>

    <div class="rpt-kpi kpi-green">
      <div class="rpt-kpi-icon"><i class="fas fa-chart-line"></i></div>
      <div class="rpt-kpi-body">
        <div class="rpt-kpi-value">
          <fmt:formatNumber value="${reportKpi.roi}" maxFractionDigits="1"/>%
        </div>
        <div class="rpt-kpi-label">ROI</div>
      </div>
    </div>
  </div>

  <!-- ── Charts row: Lead Source + Lead Funnel ─────────────────── -->
  <div class="rpt-charts-grid">

    <!-- Lead Source doughnut -->
    <div class="rpt-card">
      <div class="rpt-card-header">
        <div class="rpt-section-title">
          <i class="fas fa-chart-pie"></i> Lead Source Breakdown
          <span class="badge-count">${fn:length(leadSources)}</span>
        </div>
      </div>
      <c:choose>
        <c:when test="${not empty leadSources}">
          <div class="rpt-chart-wrap">
            <canvas id="leadSourceChart"></canvas>
          </div>
        </c:when>
        <c:otherwise>
          <div class="rpt-empty"><i class="fas fa-chart-pie"></i><p>No lead source data for the selected filters.</p></div>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Deal Result + Win-rate -->
    <div class="rpt-card">
      <div class="rpt-card-header">
        <div class="rpt-section-title">
          <i class="fas fa-chart-bar"></i> Deal Results
        </div>
      </div>

      <div class="deal-pills">
        <div class="deal-pill deal-pill-total">
          <div class="deal-pill-value">${dealResult.totalDeals}</div>
          <div class="deal-pill-label">Total Deals</div>
        </div>
        <div class="deal-pill deal-pill-won">
          <div class="deal-pill-value">${dealResult.dealsWon}</div>
          <div class="deal-pill-label">Won</div>
        </div>
        <div class="deal-pill deal-pill-lost">
          <div class="deal-pill-value">${dealResult.dealsLost}</div>
          <div class="deal-pill-label">Lost</div>
        </div>
      </div>

      <div class="win-rate-bar">
        <label>
          <span>Win Rate</span>
          <span>
            <c:choose>
              <c:when test="${dealResult.totalDeals > 0}">
                <fmt:formatNumber value="${dealResult.dealsWon * 100.0 / dealResult.totalDeals}" maxFractionDigits="1" />%
              </c:when>
              <c:otherwise>0%</c:otherwise>
            </c:choose>
          </span>
        </label>
        <div class="win-rate-track">
          <div class="win-rate-fill" id="winRateFill" style="width:0%"></div>
        </div>
      </div>

      <div class="rpt-chart-wrap" style="height:200px; margin-top:20px;">
        <canvas id="dealResultChart"></canvas>
      </div>
    </div>
  </div>

  <!-- ── Lead Funnel (full width) ──────────────────────────────── -->
  <div class="rpt-card" style="margin-bottom:28px;">
    <div class="rpt-card-header">
      <div class="rpt-section-title">
        <i class="fas fa-filter"></i> Lead Funnel
      </div>
    </div>

    <%-- Compute total for percentage bars --%>
    <c:set var="funnelTotal"
           value="${leadFunnel.newCount + leadFunnel.contactedCount + leadFunnel.qualifiedCount + leadFunnel.convertedCount + leadFunnel.lostCount}" />

    <div class="funnel-bars">

      <c:set var="fStages" value="New Lead,Contacted,Qualified,Converted,Lost" />
      <%-- We'll do each row individually for clarity --%>

      <div class="funnel-row">
        <div class="funnel-label">New Lead</div>
        <div class="funnel-bar-track">
          <div class="funnel-bar-fill fb-new"
               style="width:<c:choose><c:when test="${funnelTotal>0}">${leadFunnel.newCount*100/funnelTotal}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
            <c:if test="${funnelTotal > 0 && leadFunnel.newCount * 100 / funnelTotal > 8}">
              <fmt:formatNumber value="${leadFunnel.newCount * 100.0 / funnelTotal}" maxFractionDigits="0"/>%
            </c:if>
          </div>
        </div>
        <div class="funnel-count">${leadFunnel.newCount}</div>
      </div>

      <div class="funnel-row">
        <div class="funnel-label">Contacted</div>
        <div class="funnel-bar-track">
          <div class="funnel-bar-fill fb-contacted"
               style="width:<c:choose><c:when test="${funnelTotal>0}">${leadFunnel.contactedCount*100/funnelTotal}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
            <c:if test="${funnelTotal > 0 && leadFunnel.contactedCount * 100 / funnelTotal > 8}">
              <fmt:formatNumber value="${leadFunnel.contactedCount * 100.0 / funnelTotal}" maxFractionDigits="0"/>%
            </c:if>
          </div>
        </div>
        <div class="funnel-count">${leadFunnel.contactedCount}</div>
      </div>

      <div class="funnel-row">
        <div class="funnel-label">Qualified</div>
        <div class="funnel-bar-track">
          <div class="funnel-bar-fill fb-qualified"
               style="width:<c:choose><c:when test="${funnelTotal>0}">${leadFunnel.qualifiedCount*100/funnelTotal}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
            <c:if test="${funnelTotal > 0 && leadFunnel.qualifiedCount * 100 / funnelTotal > 8}">
              <fmt:formatNumber value="${leadFunnel.qualifiedCount * 100.0 / funnelTotal}" maxFractionDigits="0"/>%
            </c:if>
          </div>
        </div>
        <div class="funnel-count">${leadFunnel.qualifiedCount}</div>
      </div>

      <div class="funnel-row">
        <div class="funnel-label">Deal Created</div>
        <div class="funnel-bar-track">
          <div class="funnel-bar-fill fb-converted"
               style="width:<c:choose><c:when test="${funnelTotal>0}">${leadFunnel.convertedCount*100/funnelTotal}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
            <c:if test="${funnelTotal > 0 && leadFunnel.convertedCount * 100 / funnelTotal > 8}">
              <fmt:formatNumber value="${leadFunnel.convertedCount * 100.0 / funnelTotal}" maxFractionDigits="0"/>%
            </c:if>
          </div>
        </div>
        <div class="funnel-count">${leadFunnel.convertedCount}</div>
      </div>

      <div class="funnel-row">
        <div class="funnel-label">Lost</div>
        <div class="funnel-bar-track">
          <div class="funnel-bar-fill fb-lost"
               style="width:<c:choose><c:when test="${funnelTotal>0}">${leadFunnel.lostCount*100/funnelTotal}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
            <c:if test="${funnelTotal > 0 && leadFunnel.lostCount * 100 / funnelTotal > 8}">
              <fmt:formatNumber value="${leadFunnel.lostCount * 100.0 / funnelTotal}" maxFractionDigits="0"/>%
            </c:if>
          </div>
        </div>
        <div class="funnel-count">${leadFunnel.lostCount}</div>
      </div>
    </div>
  </div>

  <!-- ── Campaign Performance Table (full width) ───────────────── -->
  <div class="rpt-card" style="margin-bottom:28px;">
    <div class="rpt-card-header">
      <div class="rpt-section-title">
        <i class="fas fa-table"></i> Campaign Performance
        <c:if test="${not empty pagination}">
          <span class="badge-count">${pagination.totalItems}</span>
        </c:if>
      </div>
    </div>

    <c:choose>
      <c:when test="${not empty campaignPerformance}">
        <div class="rpt-table-wrap">
          <table class="rpt-table" id="campaignPerfTable">
            <thead>
              <tr>
                <th>#</th>
                <th>Campaign Name</th>
                <th style="text-align:right">Total Leads</th>
                <th style="text-align:right">Deals Created</th>
                <th style="text-align:right">Deals Won</th>
                <th style="text-align:right">Deals Lost</th>
                <th style="text-align:center">Conversion Rate</th>
                <th style="text-align:center">ROI</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="cp" items="${campaignPerformance}" varStatus="st">
                <tr>
                  <td class="td-number" style="color:var(--rpt-muted)">${not empty pagination ? pagination.startItemNumber + st.index : st.index + 1}</td>
                  <td class="td-name">${cp.campaignName}</td>
                  <td class="td-number">${cp.totalLeads}</td>
                  <td class="td-number">${cp.dealsCreated}</td>
                  <td class="td-number" style="color:var(--rpt-success)">${cp.dealsWon}</td>
                  <td class="td-number" style="color:var(--rpt-danger)">${cp.dealsLost}</td>
                  <td class="td-center">
                    <span class="conv-badge
                      <c:choose>
                        <c:when test="${cp.conversionRate >= 50}">conv-high</c:when>
                        <c:when test="${cp.conversionRate >= 20}">conv-mid</c:when>
                        <c:otherwise>conv-low</c:otherwise>
                      </c:choose>">
                      <fmt:formatNumber value="${cp.conversionRate}" maxFractionDigits="1"/>%
                    </span>
                  </td>
                  <td class="td-center">
                    <span class="conv-badge">
                      <fmt:formatNumber value="${cp.roi}" maxFractionDigits="1"/>%
                    </span>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
        <%-- Phân trang (Pagination.java + pagination.jsp) --%>
        <jsp:include page="/view/components/pagination.jsp" />
      </c:when>
      <c:otherwise>
        <div class="rpt-empty">
          <i class="fas fa-table"></i>
          <p>No campaign data found for the selected filters.</p>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</div><!-- /rpt-page -->


<!-- ══════════════════════════════════════════════════════════════
     JavaScript – build Chart.js charts from JSP-rendered data
     ══════════════════════════════════════════════════════════════ -->
<script>
(function () {
  /* ── 1. Lead Source doughnut ── */
  (function buildLeadSourceChart() {
    const canvas = document.getElementById('leadSourceChart');
    if (!canvas) return;

    const rawLabels  = [];
    const rawData    = [];
    const rawPercent = [];

    <c:forEach var="ls" items="${leadSources}">
      rawLabels.push('${fn:escapeXml(ls.sourceName)}');
      rawData.push(${ls.leadCount});
      rawPercent.push(${ls.percent});
    </c:forEach>

    if (rawData.length === 0) return;

    const palette = [
      '#3b82f6','#8b5cf6','#f59e0b','#10b981',
      '#ef4444','#06b6d4','#ec4899','#84cc16'
    ];

    new Chart(canvas, {
      type: 'doughnut',
      data: {
        labels: rawLabels,
        datasets: [{
          data: rawData,
          backgroundColor: palette.slice(0, rawLabels.length),
          borderWidth: 2,
          borderColor: '#ffffff',
          hoverOffset: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '65%',
        plugins: {
          legend: { position: 'right', labels: { font: { size: 12 }, padding: 14 } },
          tooltip: {
            callbacks: {
              label: ctx => {
                const idx = ctx.dataIndex;
                return ` ${rawLabels[idx]}: ${rawData[idx]} (${rawPercent[idx]}%)`;
              }
            }
          }
        }
      }
    });
  })();

  /* ── 2. Deal Result bar ── */
  (function buildDealResultChart() {
    const canvas = document.getElementById('dealResultChart');
    if (!canvas) return;

    const won  = ${dealResult.dealsWon};
    const lost = ${dealResult.dealsLost};
    const pending = Math.max(0, ${dealResult.totalDeals} - won - lost);

    new Chart(canvas, {
      type: 'bar',
      data: {
        labels: ['Won', 'Lost', 'Pending'],
        datasets: [{
          data: [won, lost, pending],
          backgroundColor: ['#10b981','#ef4444','#f59e0b'],
          borderRadius: 7,
          borderSkipped: false,
          maxBarThickness: 54
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          y: {
            beginAtZero: true, ticks: { stepSize: 1 },
            grid: { color: '#f1f5f9' }
          },
          x: { grid: { display: false } }
        }
      }
    });
  })();

  /* ── 3. Win-rate fill animation ── */
  (function animateWinRate() {
    const fill = document.getElementById('winRateFill');
    if (!fill) return;
    const total = ${dealResult.totalDeals};
    const won   = ${dealResult.dealsWon};
    const rate  = total > 0 ? (won / total * 100) : 0;
    setTimeout(() => { fill.style.width = rate.toFixed(1) + '%'; }, 200);
  })();

})();
</script>
