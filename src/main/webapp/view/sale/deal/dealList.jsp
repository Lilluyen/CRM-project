<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-handshake me-2"></i>Deal Management</h4>
            <p class="text-muted mb-0">Manage sales deals</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/sale/deal/export?search=${param.search}&stage=${param.stage}"
               class="btn btn-outline-success">
                <i class="fas fa-file-excel me-1"></i> Export Excel
            </a>
            <a href="${pageContext.request.contextPath}/sale/deal/create" class="btn btn-primary">
                <i class="fas fa-plus-circle me-1"></i> Add Deal
            </a>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h6 class="card-title mb-3"><i class="fas fa-filter me-1"></i> Search & Filter</h6>
            <form method="get" action="${pageContext.request.contextPath}/sale/deal/list" class="row g-3">

                <div class="col-md-5">
                    <label class="form-label">Search</label>
                    <input type="text" name="search" value="${param.search}" class="form-control"
                           placeholder="Search deal name..." />
                </div>

                <div class="col-md-4">
                    <label class="form-label">Stage</label>
                    <select name="stage" class="form-select">
                        <option value="">-- All Stages --</option>
                        <c:forEach var="s" items="${stages}">
                            <option value="${s}" <c:if test="${param.stage == s}">selected</c:if>>${s}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-3 d-flex align-items-end gap-2">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-search me-1"></i> Search
                    </button>
                </div>

            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                    <tr>
                        <th>STT</th>
                        <th>Deal Name</th>
                        <th>Stage</th>
                        <th>Probability</th>
                        <th>Expected Value</th>
                        <th>Actual Value</th>
                        <th>Close Date</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="d" items="${dealList}" varStatus="loop">
                        <tr>
                            <td>${(currentPage - 1) * 10 + loop.index + 1}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/sale/deal/detail?id=${d.dealId}">${d.dealName}</a>
                            </td>
                            <td>${d.stage}</td>
                            <td>${d.probability}%</td>
                            <td>${d.expectedValue}</td>
                            <td>${d.actualValue}</td>
                            <td>${d.expectedCloseDate}</td>
                            <td>
                                <a class="btn btn-sm btn-info" href="${pageContext.request.contextPath}/sale/deal/detail?id=${d.dealId}">View</a>
                                <a class="btn btn-sm btn-warning" href="${pageContext.request.contextPath}/sale/deal/edit?id=${d.dealId}">Edit</a>
                                <a class="btn btn-sm btn-danger" href="${pageContext.request.contextPath}/sale/deal/delete?id=${d.dealId}"
                                   onclick="return confirm('Delete this deal?')">Delete</a>

                                <form method="post" action="${pageContext.request.contextPath}/sale/deal/stage" style="display:inline-block;">
                                    <input type="hidden" name="id" value="${d.dealId}" />
                                    <select name="stage" class="form-select form-select-sm" style="width:auto; display:inline-block;">
                                        <c:forEach var="s" items="${stages}">
                                            <option value="${s}" <c:if test="${d.stage == s}">selected</c:if>>${s}</option>
                                        </c:forEach>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-outline-primary">Move</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty dealList}">
                        <tr>
                            <td colspan="8" class="text-center">No deals found</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-center mt-3">
                <ul class="pagination">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                            <a class="page-link" href="${pageContext.request.contextPath}/sale/deal/list?page=${i}&search=${param.search}&stage=${param.stage}">${i}</a>
                        </li>
                    </c:forEach>
                </ul>
            </div>

        </div>
    </div>

</div>
