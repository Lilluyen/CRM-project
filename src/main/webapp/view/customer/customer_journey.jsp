<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Activity" %>
<%
    String entityType = (String) request.getAttribute("entityType");
    String entityName = (String) request.getAttribute("entityName");
    Integer entityId = (Integer) request.getAttribute("entityId");
    String journeyTitle = (String) request.getAttribute("journeyTitle");
    String backUrl = (String) request.getAttribute("backUrl");
    List<Activity> activities = (List<Activity>) request.getAttribute("activities");
    if (activities == null) {
        activities = java.util.Collections.emptyList();
    }
%>

<div class="customer-journey mt-5">

<div class="page-header">
    <div class="page-title">
        <h4><%= journeyTitle != null ? journeyTitle : "Journey" %></h4>
        <h6>
            <%= entityType != null ? entityType : "" %>
            <%= entityName != null ? (" - " + entityName) : "" %>
            <%= entityId != null ? (" (ID: " + entityId + ")") : "" %>
        </h6>
    </div>
    <div class="d-flex gap-2">
        <c:if test="${not empty backUrl}">
            <a href="${backUrl}" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-1"></i> Back
            </a>
        </c:if>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <div class="d-flex justify-content-between mb-3">
            <div>
                <strong>Total activities:</strong> <%= activities.size() %>
            </div>
            <div>
                <small class="text-muted">Sorted by activity date
                    <c:choose>
                        <c:when test="${entityType == 'Lead'}">(ascending)</c:when>
                        <c:otherwise>(descending)</c:otherwise>
                    </c:choose>
                </small>
            </div>
        </div>

        <c:if test="${empty activities}">
            <div class="alert alert-info">
                Không có hoạt động nào.
            </div>
        </c:if>

        <c:if test="${not empty activities}">
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th style="width:60px;">#</th>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Subject</th>
                            <th>Related</th>
                            <th>Owner</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="act" items="${activities}" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td>
                                    <c:out value="${act.activityDate != null ? act.activityDate.toString().replace('T',' ').substring(0,16) : '-'}" />
                                </td>
                                <td>
                                    <span class="badge bg-secondary">
                                        <c:out value="${act.activityType}" />
                                    </span>
                                </td>
                                <td><c:out value="${act.subject}" /></td>
                                <td>
                                    <c:out value="${act.relatedType}" />
                                    <c:if test="${act.relatedId != null}">
                                        <span class="text-muted">(ID: ${act.relatedId})</span>
                                    </c:if>
                                </td>
                                <td>
                                    <c:out value="${act.createdBy != null ? act.createdBy.fullName : '-'}" />
                                </td>
                                <td style="white-space:pre-wrap;">
                                    <c:out value="${act.description}" />
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
</div>

</div>
