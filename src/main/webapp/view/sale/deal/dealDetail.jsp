<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-1"><i class="fas fa-handshake me-2"></i>Deal Detail</h4>
            <p class="text-muted mb-0">${deal.dealName}</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-warning" href="${pageContext.request.contextPath}/sale/deal/edit?id=${deal.dealId}">
                <i class="fas fa-edit me-1"></i> Edit
            </a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/sale/deal/list">
                <i class="fas fa-arrow-left me-1"></i> Back to List
            </a>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
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

            <hr />

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

        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <h5><i class="fas fa-boxes me-1"></i> Deal Products</h5>

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

        </div>
    </div>

</div>
