<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<div class="col-10">
    <div class="container-fluid py-4">

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1">
                    <c:choose>
                        <c:when test="${lead.leadId > 0}">
                            <i class="fas fa-edit me-2"></i>Chỉnh sửa Lead
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-plus-circle me-2"></i>Tạo Lead Mới
                        </c:otherwise>
                    </c:choose>
                </h4>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/marketing/leads">Leads</a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">
                            <c:choose>
                                <c:when test="${lead.leadId > 0}">Chỉnh sửa</c:when>
                                <c:otherwise>Tạo mới</c:otherwise>
                            </c:choose>
                        </li>
                    </ol>
                </nav>
            </div>
            <a href="${pageContext.request.contextPath}/marketing/leads"
               class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i> Quay lại
            </a>
        </div>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-1"></i>
                <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Form -->
        <div class="form-container">
            <form id="leadForm" method="POST"
                  action="${pageContext.request.contextPath}/marketing/leads/form"
                  novalidate>
                <c:if test="${lead.leadId > 0}">
                    <input type="hidden" name="leadId" value="${lead.leadId}">
                </c:if>

                <!-- Section 1: Thông tin cơ bản -->
                <div class="form-section">
                    <h5><i class="fas fa-user me-1"></i> Thông tin Lead</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="fullName" class="form-label required">Họ tên</label>
                                <input type="text" class="form-control" id="fullName" name="fullName"
                                       value="${lead.fullName}" placeholder="VD: Nguyễn Văn A"
                                       maxlength="100" required>
                                <div class="invalid-feedback">Vui lòng nhập họ tên.</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="email" class="form-label required">Email</label>
                                <input type="email" class="form-control" id="email" name="email"
                                       value="${lead.email}" placeholder="VD: nguyenvana@company.com"
                                       maxlength="100" required>
                                <div class="invalid-feedback">Vui lòng nhập email hợp lệ.</div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="phone" class="form-label">Số điện thoại</label>
                                <input type="text" class="form-control" id="phone" name="phone"
                                       value="${lead.phone}" placeholder="VD: 0901234567"
                                       maxlength="20">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="interest" class="form-label">Sở thích / Quan tâm</label>
                                <input type="text" class="form-control" id="interest" name="interest"
                                       value="${lead.interest}" placeholder="VD: Sản phẩm A, Dịch vụ B"
                                       maxlength="255">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 2: Nguồn & Campaign -->
                <div class="form-section">
                    <h5><i class="fas fa-bullhorn me-1"></i> Nguồn & Campaign</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="source" class="form-label">Nguồn Lead</label>
                                <select class="form-select" id="source" name="source">
                                    <option value="">-- Chọn nguồn --</option>
                                    <option value="WEBSITE"      ${lead.source == 'WEBSITE'      ? 'selected' : ''}>Website</option>
                                    <option value="SOCIAL_MEDIA" ${lead.source == 'SOCIAL_MEDIA' ? 'selected' : ''}>Social Media</option>
                                    <option value="REFERRAL"     ${lead.source == 'REFERRAL'     ? 'selected' : ''}>Referral</option>
                                    <option value="EVENT"        ${lead.source == 'EVENT'        ? 'selected' : ''}>Event</option>
                                    <option value="EMAIL"        ${lead.source == 'EMAIL'        ? 'selected' : ''}>Email Campaign</option>
                                    <option value="COLD_CALL"    ${lead.source == 'COLD_CALL'    ? 'selected' : ''}>Cold Call</option>
                                    <option value="IMPORT"       ${lead.source == 'IMPORT'       ? 'selected' : ''}>Import File</option>
                                    <option value="OTHER"        ${lead.source == 'OTHER'        ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="campaignId" class="form-label">Campaign</label>
                                <select class="form-select" id="campaignId" name="campaignId">
                                    <option value="0">-- Không thuộc campaign --</option>
                                    <c:forEach var="campaign" items="${campaigns}">
                                        <option value="${campaign.campaignId}"
                                            ${lead.campaignId == campaign.campaignId ? 'selected' : ''}>
                                            ${campaign.name}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Section 3: Trạng thái & Điểm (chỉ cho edit mode) -->
                <c:if test="${lead.leadId > 0}">
                    <div class="form-section">
                        <h5><i class="fas fa-chart-line me-1"></i> Trạng thái & Điểm số</h5>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="field-group">
                                    <label for="status" class="form-label required">Trạng thái</label>
                                    <select class="form-select" id="status" name="status" required>
                                        <option value="NEW_LEAD"     ${lead.status == 'NEW_LEAD'     ? 'selected' : ''}>New Lead</option>
                                        <option value="CONTACTED"    ${lead.status == 'CONTACTED'    ? 'selected' : ''}>Contacted</option>
                                        <option value="QUALIFIED"    ${lead.status == 'QUALIFIED'    ? 'selected' : ''}>Qualified</option>
                                        <option value="DEAL_CREATED" ${lead.status == 'DEAL_CREATED' ? 'selected' : ''}>Deal Created</option>
                                        <option value="LOST"         ${lead.status == 'LOST'         ? 'selected' : ''}>Lost</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <div class="field-group">
                                    <label for="score" class="form-label">Điểm số (0 - 100)</label>
                                    <input type="number" class="form-control" id="score" name="score"
                                           value="${lead.score}" min="0" max="100">
                                    <small class="form-text text-muted">Lead tự động Qualified nếu điểm >= 50</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Actions -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/marketing/leads"
                       class="btn btn-large btn-cancel">
                        <i class="fas fa-times-circle me-1"></i> Hủy
                    </a>

                    <c:choose>
                        <c:when test="${lead.leadId > 0}">
                            <button type="submit" class="btn btn-large btn-save">
                                <i class="fas fa-check-circle me-1"></i> Cập nhật
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="reset" class="btn btn-large btn-delete">
                                <i class="fas fa-eraser me-1"></i> Làm trống
                            </button>
                            <button type="submit" class="btn btn-large btn-save">
                                <i class="fas fa-plus-circle me-1"></i> Tạo mới
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>

    <script>
        const form = document.getElementById('leadForm');

        document.addEventListener('DOMContentLoaded', function () {
            form.addEventListener('submit', function (event) {
                event.preventDefault();
                event.stopPropagation();

                if (validateForm()) {
                    form.submit();
                } else {
                    form.classList.add('was-validated');
                    scrollToFirstError();
                }
            }, false);
        });

        function validateForm() {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();

            if (!fullName) {
                showFieldError('fullName', 'Vui lòng nhập họ tên.');
                return false;
            }
            if (!email) {
                showFieldError('email', 'Vui lòng nhập email.');
                return false;
            }
            // Simple email format check
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showFieldError('email', 'Email không đúng định dạng.');
                return false;
            }

            const scoreField = document.getElementById('score');
            if (scoreField) {
                const score = parseInt(scoreField.value);
                if (scoreField.value !== '' && (isNaN(score) || score < 0 || score > 100)) {
                    showFieldError('score', 'Điểm số phải từ 0 đến 100.');
                    return false;
                }
            }

            return true;
        }

        function showFieldError(fieldId, message) {
            const field = document.getElementById(fieldId);
            if (field) {
                field.classList.add('is-invalid');
                const feedback = field.parentElement.querySelector('.invalid-feedback');
                if (feedback) {
                    feedback.textContent = message;
                }
            }
        }

        function scrollToFirstError() {
            const firstError = document.querySelector('.is-invalid');
            if (firstError) {
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                firstError.focus();
            }
        }
    </script>
</div>
