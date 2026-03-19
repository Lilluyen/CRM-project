<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.Activity, java.util.ArrayList, com.google.gson.Gson" %>
<%!
    private String e(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    List<Activity> activities = request.getAttribute("activities") != null
            ? (List<Activity>) request.getAttribute("activities") : new ArrayList<>();

    String p_subject      = request.getParameter("subject")      != null ? request.getParameter("subject")      : "";
    String p_activityType = request.getParameter("activityType") != null ? request.getParameter("activityType") : "";
    String p_relatedType  = request.getParameter("relatedType")  != null ? request.getParameter("relatedType")  : "";
    String p_relatedId    = request.getParameter("relatedId")    != null ? request.getParameter("relatedId")    : "";
    String p_description  = request.getParameter("description")  != null ? request.getParameter("description")  : "";
    String p_sortF        = request.getParameter("sortField")    != null ? request.getParameter("sortField")    : "";
    String p_sortD        = request.getParameter("sortDir")      != null ? request.getParameter("sortDir")      : "";

    // Activity types
    String[] activityTypes = {"CALL", "EMAIL", "MEETING", "NOTE", "TASK",
                             "task_started", "task_completed", "task_reopened",
                             "task_cancelled", "task_overdue", "task_updated", "task_comment"};
    // Related types
    String[] relatedTypes = {"CUSTOMER", "LEAD", "DEAL", "TASK", "INTERNAL"};
%>

<style>
  @media (min-width: 992px){
        .mini-sidebar .badge { display: inline-block !important; }
        .mini-sidebar.expand-menu .badge { display: inline-block !important; }
    }
</style>
<div>
<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Activities</h4>
        <h6>View and manage all activities</h6>
      </div>
      <a href="${pageContext.request.contextPath}/activities/create" class="btn btn-added">
        <i class="fa fa-plus me-1"></i> Create Activity
      </a>
    </div>

    <!-- Search -->
    <div class="card">
      <div class="card-body">
        <form id="searchForm" method="get" action="${pageContext.request.contextPath}/activities/list">
          <input type="hidden" name="page"      id="h_page"      value="1">
          <input type="hidden" name="sortField" id="h_sortField" value="<%= e(p_sortF) %>">
          <input type="hidden" name="sortDir"   id="h_sortDir"   value="<%= e(p_sortD) %>">
          <div class="row g-2 align-items-end">
            <div class="col-lg-2 col-md-3">
              <label class="form-label fw-semibold">Subject</label>
              <input type="text" name="subject" class="form-control"
                     placeholder="Search subject..." value="<%= e(p_subject) %>">
            </div>
            <div class="col-lg-2 col-md-3">
              <label class="form-label fw-semibold">Activity Type</label>
              <select name="activityType" class="form-select" id="filterActivityType">
                <option value="">All Types</option>
                <% for (String t : activityTypes) { %>
                <option value="<%= t %>" <%= t.equals(p_activityType) ? "selected" : "" %>><%= t %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-2 col-md-3">
              <label class="form-label fw-semibold">Related Type</label>
              <select name="relatedType" class="form-select" id="filterRelatedType" onchange="loadRelatedEntities()">
                <option value="">All</option>
                <% for (String t : relatedTypes) { %>
                <option value="<%= t %>" <%= t.equalsIgnoreCase(p_relatedType) ? "selected" : "" %>><%= t %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-2 col-md-3">
              <label class="form-label fw-semibold">Related Name</label>
              <select name="relatedId" class="form-select" id="filterRelatedId" disabled>
                <option value="">Select type first</option>
              </select>
            </div>
            <div class="col-lg-2 col-md-3">
              <label class="form-label fw-semibold">Description</label>
              <input type="text" name="description" class="form-control"
                     placeholder="Search description..." value="<%= e(p_description) %>">
            </div>
            <div class="col-auto d-flex gap-2">
              <button type="submit" class="btn btn-primary">
                <i class="fa fa-search me-1"></i> Search
              </button>
              <a href="${pageContext.request.contextPath}/activities/list" class="btn btn-outline-secondary">
                <i class="fa fa-times me-1"></i> Reset
              </a>
              <span class="text-muted small align-self-center ms-2">
                ${pagination.totalItems} record${pagination.totalItems != 1 ? 's' : ''}
              </span>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead>
              <tr>
                <th>ID</th>
                <th class="sortable-th" onclick="toggleSort('subject')">
                  Subject <%= "subject".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th class="sortable-th" onclick="toggleSort('type')">
                  Type <%= "type".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Related</th>
                <th>Description</th>
                <th>Created By</th>
                <th>Performed By</th>
                <th class="sortable-th" onclick="toggleSort('activityDate')">
                  Date <%= "activityDate".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Metadata</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%
              if (activities.isEmpty()) { %>
              <tr>
                <td colspan="10" class="text-center text-muted py-4">
                  <i class="fa fa-inbox fa-2x d-block mb-2"></i>No activities found.
                </td>
              </tr>
              <% } else {
                  for (Activity a : activities) {
                      String typeBadge = "bg-secondary";
                      String at = (a.getActivityType() != null ? a.getActivityType() : "-").toUpperCase();
                      if ("CALL".equals(at))         typeBadge = "bg-info text-dark";
                      else if ("EMAIL".equals(at))   typeBadge = "bg-primary";
                      else if ("MEETING".equals(at)) typeBadge = "bg-success";
                      else if ("NOTE".equals(at))    typeBadge = "bg-warning text-dark";
                      else if ("TASK".equals(at))    typeBadge = "bg-danger";
                      else if (at.startsWith("TASK_")) typeBadge = "bg-purple";
              %>
              <tr>
                <td><%= a.getActivityId() %></td>
                <td>
                  <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>">
                    <strong><%= e(a.getSubject()) %></strong>
                  </a>
                </td>
                <td><span class="badge <%= typeBadge %>"><%= e(at) %></span></td>
                <td>
                  <% if (a.getRelatedType() != null) { %>
                    <span class="text-uppercase"><%= e(a.getRelatedType()) %></span>
                    <% if (a.getRelatedName() != null) { %>
                      <small class="text-muted d-block"><%= e(a.getRelatedName()) %></small>
                    <% } else if (a.getRelatedId() != null && a.getRelatedId() > 0) { %>
                      <small class="text-muted d-block">#<%= a.getRelatedId() %></small>
                    <% } %>
                  <% } else { %>
                    -
                  <% } %>
                </td>
                <td><%= a.getDescription() != null ? e(a.getDescription().length() > 50 ? a.getDescription().substring(0, 50) + "..." : a.getDescription()) : "-" %></td>
                <td><%= a.getCreatedBy() != null && a.getCreatedBy().getFullName() != null
                        ? e(a.getCreatedBy().getFullName()) : "-" %></td>
                <td><%= a.getPerformedBy() != null && a.getPerformedBy().getFullName() != null
                        ? e(a.getPerformedBy().getFullName()) : "-" %></td>
                <td><%= a.getActivityDate() != null ? a.getActivityDate().toString().replace("T"," ").substring(0,16) : "-" %></td>
                <td>
                  <% if (a.getMetadata() != null && !a.getMetadata().isBlank()) { %>
                    <button type="button" class="btn btn-sm btn-outline-secondary"
                            onclick="showMetadata('<%= e(a.getMetadata().replace("'", "\\'")) %>')">
                      <i class="fa fa-code"></i>
                    </button>
                  <% } else { %>
                    -
                  <% } %>
                </td>
                <td>
                  <div class="d-flex gap-1">
                    <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>"
                       class="btn btn-sm btn-outline-info"><i class="fa fa-eye"></i></a>
                    <a href="${pageContext.request.contextPath}/activities/edit?id=<%= a.getActivityId() %>"
                       class="btn btn-sm btn-outline-warning"><i class="fa fa-edit"></i></a>
                    <button type="button" class="btn btn-sm btn-outline-danger"
                            onclick="deleteActivity(<%= a.getActivityId() %>)">
                      <i class="fa fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <% } } %>
            </tbody>
          </table>
        </div>

        <%-- Dung jsp:include de component con thay request attribute "pagination" --%>
        <jsp:include page="/view/components/pagination.jsp" />

      </div>
    </div>
  </div>
</div>

<!-- Metadata Modal -->
<div class="modal fade" id="metadataModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Metadata</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <pre id="metadataContent" class="bg-light p-3 rounded"></pre>
      </div>
    </div>
  </div>
</div>

<style>.sortable-th{cursor:pointer;} .sortable-th:hover{background:rgba(0,0,0,.04);}</style>
<script>
var currentRelatedType = '<%= p_relatedType %>';
var currentRelatedId = '<%= p_relatedId %>';

function toggleSort(field) {
    var sf = document.getElementById('h_sortField');
    var sd = document.getElementById('h_sortDir');
    if (sf.value === field) sd.value = sd.value === 'ASC' ? 'DESC' : 'ASC';
    else { sf.value = field; sd.value = 'ASC'; }
    document.getElementById('h_page').value = '1';
    document.getElementById('searchForm').submit();
}

function deleteActivity(id) {
    if (!confirm('Delete this activity?')) return;
    fetch('${pageContext.request.contextPath}/activities/delete', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body:'id=' + id
    }).then(r=>r.json()).then(res => {
        if (res.success) location.reload(); else alert('Delete failed');
    });
}

function showMetadata(jsonStr) {
    try {
        var obj = JSON.parse(jsonStr);
        document.getElementById('metadataContent').textContent = JSON.stringify(obj, null, 2);
    } catch (e) {
        document.getElementById('metadataContent').textContent = jsonStr;
    }
    var modal = new bootstrap.Modal(document.getElementById('metadataModal'));
    modal.show();
}

function loadRelatedEntities() {
    var typeSelect = document.getElementById('filterRelatedType');
    var idSelect = document.getElementById('filterRelatedId');
    var selectedType = typeSelect.value;

    idSelect.innerHTML = '<option value="">Loading...</option>';
    idSelect.disabled = true;

    if (!selectedType) {
        idSelect.innerHTML = '<option value="">Select type first</option>';
        return;
    }

    // Map to API type
    var apiType = selectedType.toLowerCase();
    if (apiType === 'internal') {
        idSelect.innerHTML = '<option value="">No entities</option>';
        return;
    }

    fetch('${pageContext.request.contextPath}/api/related-entities?type=' + apiType)
        .then(r => r.json())
        .then(data => {
            idSelect.innerHTML = '<option value="">-- All ' + selectedType + 's --</option>';
            data.forEach(function(item) {
                var opt = document.createElement('option');
                opt.value = item.id;
                opt.textContent = item.name;
                idSelect.appendChild(opt);
            });
            idSelect.disabled = false;

            // Restore selected value
            if (currentRelatedId) {
                idSelect.value = currentRelatedId;
            }
        })
        .catch(err => {
            idSelect.innerHTML = '<option value="">Error loading</option>';
        });
}

// On page load
document.addEventListener('DOMContentLoaded', function() {
    if (currentRelatedType) {
        loadRelatedEntities();
    }
});
</script>
</div>
