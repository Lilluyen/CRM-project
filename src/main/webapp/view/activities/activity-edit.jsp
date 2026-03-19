<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.Activity" %>
<%
    Activity a = (Activity) request.getAttribute("activity");
    if (a == null) { response.sendError(404); return; }
    String dateVal = a.getActivityDate() != null
            ? a.getActivityDate().toString().substring(0, 16) : "";
    String desc = a.getDescription() != null ? a.getDescription() : "";
%>

<div>
<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Edit Activity</h4>
        <h6><%= a.getSubject() %></h6>
      </div>
      <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>"
         class="btn btn-outline-secondary">
        <i class="fa fa-arrow-left me-1"></i> Back
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
      <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/activities/edit" id="activityForm">
          <input type="hidden" name="activityId" value="<%= a.getActivityId() %>">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
              <input type="text" name="subject" class="form-control" required
                     value="<%= a.getSubject() != null ? a.getSubject() : "" %>">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Activity Type <span class="text-danger">*</span></label>
              <select name="activityType" class="form-select" required>
                <% for (String t : new String[]{"CALL","EMAIL","MEETING","NOTE","TASK"}) { %>
                <option value="<%= t %>" <%=t.equals(a.getActivityType()) ? "selected" : ""%>><%= t %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Activity Date <span class="text-danger">*</span></label>
              <input type="datetime-local" name="activityDate" class="form-control" required
                     value="<%= dateVal %>">
            </div>

            <!-- Related Entity -->
            <div class="col-md-3">
              <label class="form-label fw-semibold">Related Type</label>
              <select name="relatedType" class="form-select" id="relatedType" onchange="loadRelatedEntities()">
                <option value="">-- None --</option>
                <% for (String t : new String[]{"CUSTOMER","LEAD","DEAL","TASK","INTERNAL"}) { %>
                <option value="<%= t %>" <%=t.equalsIgnoreCase(a.getRelatedType()) ? "selected" : ""%>><%= t %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Related Name</label>
              <select name="relatedId" class="form-select" id="relatedId">
                <option value="">Loading...</option>
              </select>
            </div>

            <!-- Source Entity -->
            <div class="col-md-3">
              <label class="form-label fw-semibold">Source Type</label>
              <select name="sourceType" class="form-select" id="sourceType" onchange="loadSourceEntities()">
                <option value="">-- None --</option>
                <% for (String t : new String[]{"CUSTOMER","LEAD","DEAL","TASK"}) { %>
                <option value="<%= t %>" <%=t.equalsIgnoreCase(a.getSourceType()) ? "selected" : ""%>><%= t %></option>
                <% } %>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Source Name</label>
              <select name="sourceId" class="form-select" id="sourceId">
                <option value="">Loading...</option>
              </select>
            </div>

            <!-- Performed By -->
            <div class="col-md-3">
              <label class="form-label fw-semibold">Performed By</label>
              <select name="performedBy" class="form-select" id="performedBy">
                <option value="">-- Select User --</option>
              </select>
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="4"><%= desc %></textarea>
            </div>
          </div>

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i> Save Changes
            </button>
            <a href="${pageContext.request.contextPath}/activities/details?id=<%= a.getActivityId() %>"
               class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
</div>

<script>
var currentRelatedType = '<%= a.getRelatedType() != null ? a.getRelatedType() : "" %>';
var currentRelatedId = '<%= a.getRelatedId() != null ? a.getRelatedId() : "" %>';
var currentSourceType = '<%= a.getSourceType() != null ? a.getSourceType() : "" %>';
var currentSourceId = '<%= a.getSourceId() != null ? a.getSourceId() : "" %>';
var currentPerformedBy = '<%= a.getPerformedBy() != null && a.getPerformedBy().getUserId() != null ? a.getPerformedBy().getUserId() : "" %>';

function loadRelatedEntities() {
    var typeSelect = document.getElementById('relatedType');
    var idSelect = document.getElementById('relatedId');
    var selectedType = typeSelect.value;

    idSelect.innerHTML = '<option value="">Loading...</option>';
    idSelect.disabled = true;

    if (!selectedType) {
        idSelect.innerHTML = '<option value="">Select type first</option>';
        return;
    }

    if (selectedType === 'INTERNAL') {
        idSelect.innerHTML = '<option value="">No entities</option>';
        return;
    }

    var apiType = selectedType.toLowerCase();
    fetch('${pageContext.request.contextPath}/api/related-entities?type=' + apiType)
        .then(r => r.json())
        .then(data => {
            idSelect.innerHTML = '<option value="">-- Select --</option>';
            data.forEach(function(item) {
                var opt = document.createElement('option');
                opt.value = item.id;
                opt.textContent = item.name;
                idSelect.appendChild(opt);
            });
            idSelect.disabled = false;
            if (currentRelatedId) {
                idSelect.value = currentRelatedId;
            }
        })
        .catch(err => {
            idSelect.innerHTML = '<option value="">Error loading</option>';
        });
}

function loadSourceEntities() {
    var typeSelect = document.getElementById('sourceType');
    var idSelect = document.getElementById('sourceId');
    var selectedType = typeSelect.value;

    idSelect.innerHTML = '<option value="">Loading...</option>';
    idSelect.disabled = true;

    if (!selectedType) {
        idSelect.innerHTML = '<option value="">Select type first</option>';
        return;
    }

    var apiType = selectedType.toLowerCase();
    fetch('${pageContext.request.contextPath}/api/related-entities?type=' + apiType)
        .then(r => r.json())
        .then(data => {
            idSelect.innerHTML = '<option value="">-- Select --</option>';
            data.forEach(function(item) {
                var opt = document.createElement('option');
                opt.value = item.id;
                opt.textContent = item.name;
                idSelect.appendChild(opt);
            });
            idSelect.disabled = false;
            if (currentSourceId) {
                idSelect.value = currentSourceId;
            }
        })
        .catch(err => {
            idSelect.innerHTML = '<option value="">Error loading</option>';
        });
}

function loadUsers() {
    fetch('${pageContext.request.contextPath}/api/related-entities?type=user')
        .then(r => r.json())
        .then(data => {
            var select = document.getElementById('performedBy');
            select.innerHTML = '<option value="">-- Select User --</option>';
            data.forEach(function(item) {
                var opt = document.createElement('option');
                opt.value = item.id;
                opt.textContent = item.name + (item.email ? ' (' + item.email + ')' : '');
                select.appendChild(opt);
            });
            if (currentPerformedBy) {
                select.value = currentPerformedBy;
            }
        })
        .catch(err => console.error('Error loading users:', err));
}

// Load data on page load
document.addEventListener('DOMContentLoaded', function() {
    loadUsers();
    if (currentRelatedType) {
        loadRelatedEntities();
    }
    if (currentSourceType) {
        loadSourceEntities();
    }
});
</script>
