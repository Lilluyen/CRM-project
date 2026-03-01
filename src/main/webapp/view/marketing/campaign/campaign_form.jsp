<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${campaign.campaignId != null ? 'Chỉnh sửa' : 'Tạo'} Campaign - CRM</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    
    <!-- Campaign CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/campaign.css">
</head>

<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">
                <i class="bi bi-briefcase-fill"></i> CRM-Project
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/marketing/campaign?action=list">
                            <i class="bi bi-megaphone"></i> Campaign
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/lead?action=list">
                            <i class="bi bi-people"></i> Leads
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/marketing/report">
                            <i class="bi bi-graph-up"></i> Reports
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container-fluid">
            <h1>
                <c:if test="${campaign.campaignId != null}">
                    <i class="bi bi-pencil-square"></i> Chỉnh sửa Campaign
                </c:if>
                <c:if test="${campaign.campaignId == null}">
                    <i class="bi bi-plus-circle"></i> Tạo Campaign Mới
                </c:if>
            </h1>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/marketing/campaign?action=list">Campaign</a></li>
                <li class="breadcrumb-item active" aria-current="page">
                    <c:if test="${campaign.campaignId != null}">Chỉnh sửa</c:if>
                    <c:if test="${campaign.campaignId == null}">Tạo mới</c:if>
                </li>
            </ol>
        </nav>

        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-circle"></i>
                <strong>Lỗi!</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Form -->
        <div class="form-container">
            <form id="campaignForm" method="POST"
            action="${pageContext.request.contextPath}/marketing/campaign"
            novalidate>
                <c:choose>
    <c:when test="${not empty campaign.campaignId}">
        <input type="hidden" name="action" value="update">
    </c:when>
    <c:otherwise>
        <input type="hidden" name="action" value="create">
    </c:otherwise>
</c:choose>
                <c:if test="${campaign.campaignId != null}">
                    <input type="hidden" name="campaignId" value="${campaign.campaignId}">
                </c:if>

                <!-- Section 1: Campaign Information -->
                <div class="form-section">
                    <h5><i class="bi bi-info-circle"></i> Thông tin Chiến dịch</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="name" class="form-label required">Tên Campaign</label>
                                <input type="text" class="form-control" id="name" name="name" 
                                       value="${campaign.name}" placeholder="VD: Campaign Q1 2026"
                                       maxlength="255" required>
                                <div class="invalid-feedback">Vui lòng nhập tên campaign.</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="channel" class="form-label required">Kênh Marketing</label>
                                <select class="form-select" id="channel" name="channel" required>
                                    <option value="">-- Chọn kênh --</option>
                                    <option value="EMAIL" ${campaign.channel == 'EMAIL' ? 'selected' : ''}>
                                        <i class="bi bi-envelope"></i> Email
                                    </option>
                                    <option value="SOCIAL_MEDIA" ${campaign.channel == 'SOCIAL_MEDIA' ? 'selected' : ''}>
                                        <i class="bi bi-share"></i> Social Media
                                    </option>
                                    <option value="SMS" ${campaign.channel == 'SMS' ? 'selected' : ''}>
                                        <i class="bi bi-chat-dots"></i> SMS
                                    </option>
                                    <option value="DIRECT_MAIL" ${campaign.channel == 'DIRECT_MAIL' ? 'selected' : ''}>
                                        <i class="bi bi-mailbox"></i> Direct Mail
                                    </option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn kênh marketing.</div>
                            </div>
                        </div>
                    </div>

                    <div class="field-group">
                        <label for="description" class="form-label">Mô tả</label>
                        <textarea class="form-control" id="description" name="description" 
                                  rows="4" placeholder="Nhập mô tả chi tiết về campaign..."
                                  maxlength="500">${campaign.description}</textarea>
                        <small class="form-text">Độ dài tối đa: 500 ký tự</small>
                    </div>
                </div>

                <!-- Section 2: Budget & Timeline -->
                <div class="form-section">
                    <h5><i class="bi bi-calendar2-event"></i> Ngân sách & Thời gian</h5>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label for="budget" class="form-label required">Ngân sách (₫)</label>
                                <input type="number" class="form-control" id="budget" name="budget"
                                       value="${campaign.budget}" placeholder="VD: 50000000"
                                       min="0" step="1000" required>
                                <span class="currency-helper">Nhập số tiền dự kiến cho campaign</span>
                                <div class="invalid-feedback">Vui lòng nhập ngân sách hợp lệ.</div>
                            </div>
                        </div>
                    </div>

                    <div class="date-input-group">
                        <div class="field-group">
                            <label for="startDate" class="form-label required">Ngày bắt đầu</label>
                            <input type="date" class="form-control" id="startDate" name="startDate"
                                   value="${campaign.startDate}" required>
                            <div class="invalid-feedback">Vui lòng chọn ngày bắt đầu.</div>
                        </div>

                        <div class="field-group">
                            <label for="endDate" class="form-label required">Ngày kết thúc</label>
                            <input type="date" class="form-control" id="endDate" name="endDate"
                                   value="${campaign.endDate}" required>
                            <div class="invalid-feedback">Vui lòng chọn ngày kết thúc.</div>
                        </div>
                    </div>
                </div>

                <!-- Section 3: Status (only for edit) -->
                <c:if test="${campaign.campaignId != null}">
                    <div class="form-section">
                        <h5><i class="bi bi-toggles"></i> Trạng thái</h5>

                        <div class="field-group">
                            <label for="status" class="form-label required">Trạng thái Campaign</label>
                            <select class="form-select" id="status" name="status" required>
                                <option value="">-- Chọn trạng thái --</option>
                                <option value="PLANNING" ${campaign.status == 'PLANNING' ? 'selected' : ''}>
                                    <i class="bi bi-hourglass"></i> Lên kế hoạch
                                </option>
                                <option value="ACTIVE" ${campaign.status == 'ACTIVE' ? 'selected' : ''}>
                                    <i class="bi bi-play-fill"></i> Đang chạy
                                </option>
                                <option value="PAUSED" ${campaign.status == 'PAUSED' ? 'selected' : ''}>
                                    <i class="bi bi-pause-fill"></i> Tạm dừng
                                </option>
                                <option value="COMPLETED" ${campaign.status == 'COMPLETED' ? 'selected' : ''}>
                                    <i class="bi bi-check-circle"></i> Kết thúc
                                </option>
                            </select>
                            <div class="invalid-feedback">Vui lòng chọn trạng thái.</div>
                        </div>
                    </div>
                </c:if>

                <!-- Actions -->
                <div class="form-actions">
                    <div class="form-actions">

    <!-- Cancel -->
    <a href="${pageContext.request.contextPath}/marketing/campaign?action=list"
       class="btn btn-large btn-cancel">
        <i class="bi bi-x-circle"></i> Hủy
    </a>

   

    <!-- Create / Update Button -->
    <c:choose>
        <c:when test="${not empty campaign.campaignId}">
            <button type="submit" class="btn btn-large btn-save">
                <i class="bi bi-check-circle"></i> Cập nhật
            </button>
        </c:when>
        <c:otherwise>
             <!-- Reset Form -->
    <button type="reset" class="btn btn-large btn-delete">
        <i class="bi bi-eraser"></i> Làm trống
    </button>
            <button type="submit" class="btn btn-large btn-save">
                <i class="bi bi-plus-circle"></i> Tạo mới
            </button>
        </c:otherwise>
    </c:choose>

</div>
                </div>
            </form>
        </div>
    </div>

<script>
    const form = document.getElementById('campaignForm');
    let deleteModal;
    let campaignId;

    document.addEventListener('DOMContentLoaded', function() {
        campaignId = <c:out value="${campaign.campaignId != null ? campaign.campaignId : 'null'}"/>;
        deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
        
        // Form validation
        form.addEventListener('submit', function(event) {
            event.preventDefault();
            event.stopPropagation();
            
            // Kiểm tra validation
            if (validateForm()) {
                // Nếu hợp lệ, thì submit form
                form.submit();
            } else {
                // Nếu không hợp lệ, hiển thị lỗi
                form.classList.add('was-validated');
                scrollToFirstError();
            }
        }, false);

        // Date validation real-time
        validateDates();
        document.getElementById('startDate').addEventListener('change', validateDates);
        document.getElementById('endDate').addEventListener('change', validateDates);
        
        // Budget validation
        document.getElementById('budget').addEventListener('input', function() {
            if (this.value) {
                this.value = Math.abs(this.value);
            }
        });
    });

    function validateForm() {
        // Lấy tất cả required fields
        const name = document.getElementById('name').value.trim();
        const channel = document.getElementById('channel').value;
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        const budget = document.getElementById('budget').value;
        
        // Kiểm tra required fields
        if (!name) {
            showFieldError('name', 'Vui lòng nhập tên campaign.');
            return false;
        }
        
        if (!channel) {
            showFieldError('channel', 'Vui lòng chọn kênh marketing.');
            return false;
        }
        
        if (!startDate) {
            showFieldError('startDate', 'Vui lòng chọn ngày bắt đầu.');
            return false;
        }
        
        if (!endDate) {
            showFieldError('endDate', 'Vui lòng chọn ngày kết thúc.');
            return false;
        }
        
        if (!budget || parseFloat(budget) <= 0) {
            showFieldError('budget', 'Vui lòng nhập ngân sách hợp lệ (> 0).');
            return false;
        }
        
        // Kiểm tra date logic
        const startDateObj = new Date(startDate);
        const endDateObj = new Date(endDate);
        
        if (endDateObj <= startDateObj) {
            showFieldError('endDate', 'Ngày kết thúc phải sau ngày bắt đầu.');
            return false;
        }
        
        // Edit mode: check status
        if (campaignId != null) {
            const status = document.getElementById('status').value;
            if (!status) {
                showFieldError('status', 'Vui lòng chọn trạng thái.');
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

    function validateDates() {
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        const endDateField = document.getElementById('endDate');
        
        if (startDate && endDate) {
            const startDateObj = new Date(startDate);
            const endDateObj = new Date(endDate);
            
            if (endDateObj <= startDateObj) {
                endDateField.classList.add('is-invalid');
                const feedback = endDateField.parentElement.querySelector('.invalid-feedback');
                if (feedback) {
                    feedback.textContent = 'Ngày kết thúc phải sau ngày bắt đầu.';
                }
            } else {
                endDateField.classList.remove('is-invalid');
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

    <!-- Footer -->
    <footer class="footer">
        <div class="container-fluid">
            <p class="mb-0">&copy; 2026 CRM-Project v1.0 | Marketing Module</p>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>