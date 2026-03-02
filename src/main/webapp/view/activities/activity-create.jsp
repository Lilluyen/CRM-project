<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div>
<div class="page-wrapper">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Create Activity</h4>
        <h6>Log a new activity</h6>
      </div>
      <a href="${pageContext.request.contextPath}/activities/list" class="btn btn-outline-secondary">
        <i class="fa fa-arrow-left me-1"></i> Back to List
      </a>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
      <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/activities/create">
          <div class="row g-3">

            <div class="col-md-6">
              <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
              <input type="text" name="subject" class="form-control" required
                     placeholder="Activity subject" maxlength="100">
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Activity Type <span class="text-danger">*</span></label>
              <select name="activityType" class="form-select" required>
                <option value="">-- Select --</option>
                <option value="Call">Call</option>
                <option value="Email">Email</option>
                <option value="Meeting">Meeting</option>
                <option value="Note">Note</option>
                <option value="Task">Task</option>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Date <span class="text-danger">*</span></label>
              <input type="datetime-local" name="activityDate" class="form-control" required>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Related Type</label>
              <select name="relatedType" class="form-select">
                <option value="">-- None --</option>
                <option value="customer">Customer</option>
                <option value="lead">Lead</option>
                <option value="deal">Deal</option>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold">Related ID</label>
              <input type="number" name="relatedId" class="form-control" min="1"
                     placeholder="e.g. 5">
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="4"
                        placeholder="Activity notes…"></textarea>
            </div>
          </div>

          <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-save me-1"></i> Create Activity
            </button>
            <a href="${pageContext.request.contextPath}/activities/list" class="btn btn-outline-secondary">
              Cancel
            </a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
</div>
