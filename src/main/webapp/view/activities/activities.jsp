<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.Activity, java.util.ArrayList" %>
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
    int currentPage  = request.getAttribute("currentPage")  != null ? (Integer)request.getAttribute("currentPage")  : 1;
    int totalPages   = request.getAttribute("totalPages")   != null ? (Integer)request.getAttribute("totalPages")   : 1;
    int totalRecords = request.getAttribute("totalRecords") != null ? (Integer)request.getAttribute("totalRecords") : 0;
    int pageSize     = request.getAttribute("pageSize")     != null ? (Integer)request.getAttribute("pageSize")     : 10;

    String p_subject      = request.getParameter("subject")      != null ? request.getParameter("subject")      : "";
    String p_activityType = request.getParameter("activityType") != null ? request.getParameter("activityType") : "";
    String p_relatedType  = request.getParameter("relatedType")  != null ? request.getParameter("relatedType")  : "";
    String p_sortF        = request.getParameter("sortField")    != null ? request.getParameter("sortField")    : "";
    String p_sortD        = request.getParameter("sortDir")      != null ? request.getParameter("sortDir")      : "";
%>
<div>
<div class="page-wrapper">
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
            <div class="col-lg-3 col-md-4">
              <label class="form-label fw-semibold">Subject</label>
              <input type="text" name="subject" class="form-control"
                     placeholder="Search subject…" value="<%= e(p_subject) %>">
            </div>
            <div class="col-lg-3 col-md-4">
              <label class="form-label fw-semibold">Activity Type</label>
              <select name="activityType" class="form-select">
                <option value="">All Types</option>
                <% for (String t : new String[]{"Call","Email","Meeting","Note","Task"}) { %>
                <option value="<%= t %>" <%= t.equals(p_activityType) ? "selected" : "" %>><%= t %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-3 col-md-4">
              <label class="form-label fw-semibold">Related To</label>
              <select name="relatedType" class="form-select">
                <option value="">All</option>
                <% for (String t : new String[]{"customer","lead","deal"}) { %>
                <option value="<%= t %>" <%= t.equalsIgnoreCase(p_relatedType) ? "selected" : "" %>><%= t %></option>
                <% } %>
              </select>
            </div>
            <div class="col-auto d-flex gap-2">
              <button type="submit" class="btn btn-primary">
                <i class="fa fa-search me-1"></i> Search
              </button>
              <a href="${pageContext.request.contextPath}/activities/list" class="btn btn-outline-secondary">
                <i class="fa fa-times me-1"></i> Reset
              </a>
              <span class="text-muted small align-self-center ms-2"><%= totalRecords %> record<%= totalRecords != 1 ? "s" : "" %></span>
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
                <th>#</th>
                <th class="sortable-th" onclick="toggleSort('subject')">
                  Subject <%= "subject".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th class="sortable-th" onclick="toggleSort('type')">
                  Type <%= "type".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Related</th>
                <th class="sortable-th" onclick="toggleSort('activityDate')">
                  Date <%= "activityDate".equals(p_sortF) ? ("ASC".equals(p_sortD) ? "↑" : "↓") : "" %>
                </th>
                <th>Created By</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%
              if (activities.isEmpty()) { %>
              <tr>
                <td colspan="7" class="text-center text-muted py-4">
                  <i class="fa fa-inbox fa-2x d-block mb-2"></i>No activities found.
                </td>
              </tr>
              <% } else {
                  int rowNum = (currentPage - 1) * pageSize + 1;
                  for (Activity a : activities) {
                      String typeBadge = "bg-secondary";
                      String at = a.getActivityType() != null ? a.getActivityType() : "-";
                      if ("Call".equals(at))    typeBadge = "bg-info text-dark";
                      else if ("Email".equals(at))   typeBadge = "bg-primary";
                      else if ("Meeting".equals(at)) typeBadge = "bg-success";
                      else if ("Note".equals(at))    typeBadge = "bg-warning text-dark";
                      else if ("Task".equals(at))    typeBadge = "bg-danger";
              %>
              <tr>
                <td><%= rowNum++ %></td>
                <td>
                  <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>">
                    <strong><%= e(a.getSubject()) %></strong>
                  </a>
                </td>
                <td><span class="badge <%= typeBadge %>"><%= e(at) %></span></td>
                <td>
                  <%= a.getRelatedType() != null ? e(a.getRelatedType()) : "-" %>
                  <% if (a.getRelatedId() != null && a.getRelatedId() > 0) { %>
                    <small class="text-muted">#<%= a.getRelatedId() %></small>
                  <% } %>
                </td>
                <td><%= a.getActivityDate() != null ? a.getActivityDate().toString().replace("T"," ").substring(0,16) : "-" %></td>
                <td><%= a.getCreatedBy() != null && a.getCreatedBy().getFullName() != null
                        ? e(a.getCreatedBy().getFullName()) : "-" %></td>
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
        <div class="mt-3">
          <%@ include file="/view/components/paging.jsp" %>
        </div>
      </div>
    </div>
  </div>
</div>
<style>.sortable-th{cursor:pointer;} .sortable-th:hover{background:rgba(0,0,0,.04);}</style>
<script>
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
</script>
</div>
