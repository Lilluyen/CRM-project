<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--<!DOCTYPE html>--%>
<%--<html lang="en">--%>
<%--<head>--%>
<%--    <meta charset="utf-8">--%>
<%--    <title>Deal Detail</title>--%>

<%--    <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/img/favicon.jpg">--%>
<%--    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">--%>
<%--    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">--%>
<%--</head>--%>

<%--<body>--%>

<%--<div class="main-wrapper">--%>

<%--    <div class="header d-flex align-items-center justify-content-between px-3">--%>
<%--        <div class="header-left">--%>
<%--            <a href="#" class="logo">CRM System</a>--%>
<%--        </div>--%>

<%--        <div class="d-flex align-items-center">--%>
<%--            <div class="me-3">--%>
<%--                Welcome, <strong>${sessionScope.user.fullName}</strong>--%>
<%--            </div>--%>

<%--            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger">Logout</a>--%>
<%--        </div>--%>
<%--    </div>--%>

<%--    <div class="sidebar" id="sidebar">--%>
<%--        <div class="sidebar-inner">--%>
<%--            <div id="sidebar-menu" class="sidebar-menu">--%>
<%--                <ul>--%>
<%--                    <li class="submenu">--%>
<%--                        <a href="javascript:void(0);"><span>Deals</span></a>--%>
<%--                        <ul>--%>
<%--                            <li><a href="list">Deal List</a></li>--%>
<%--                            <li><a href="create">Create Deal</a></li>--%>
<%--                        </ul>--%>
<%--                    </li>--%>
<%--                </ul>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>

<div class="">
    <div class="content">

        <div class="page-header">
            <div class="page-title">
                <h4>Deal Detail</h4>
                <h6>${deal.dealName}</h6>
            </div>
        </div>

        <div class="card">
            <div class="card-body">

                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Stage:</strong> ${deal.stage}</p>
                        <p><strong>Probability:</strong> ${deal.probability}%</p>
                        <p><strong>Expected Close Date:</strong> ${deal.expectedCloseDate}</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Expected Value:</strong> ${deal.expectedValue}</p>
                        <p><strong>Actual Value:</strong> ${deal.actualValue}</p>
                        <p><strong>Owner ID:</strong> ${deal.ownerId}</p>
                    </div>
                </div>

                <hr/>

                <p><strong>Customer:</strong>
                    <c:choose>
                        <c:when test="${customer != null}">${customer.name} (${customer.phone})</c:when>
                        <c:otherwise>-- None --</c:otherwise>
                    </c:choose>
                </p>

                <p><strong>Lead:</strong>
                    <c:choose>
                        <c:when test="${lead != null}">${lead.fullName} (${lead.email})</c:when>
                        <c:otherwise>-- None --</c:otherwise>
                    </c:choose>
                </p>

                <hr/>

                <h5>Deal Products</h5>

                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead class="table-light">
                        <tr>
                            <th>Product</th>
                            <th>SKU</th>
                            <th>Qty</th>
                            <th>Unit Price</th>
                            <th>Discount</th>
                            <th>Total</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="it" items="${items}">
                            <tr>
                                <td>${it.productName}</td>
                                <td>${it.sku}</td>
                                <td>${it.quantity}</td>
                                <td>${it.unitPrice}</td>
                                <td>${it.discount}%</td>
                                <td>${it.totalPrice}</td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty items}">
                            <tr>
                                <td colspan="6" class="text-center">No products in this deal</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="d-flex gap-2">
                    <a class="btn btn-warning"
                       href="edit?id=${deal.dealId}">Edit</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/deal/list">Back</a>
                </div>

            </div>
        </div>

    </div>
</div>

<%--</div>--%>

<%--<script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>--%>
<%--<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>--%>

<%--</body>--%>
<%--</html>--%>
