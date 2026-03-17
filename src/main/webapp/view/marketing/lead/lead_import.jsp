<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8" %> <%@ taglib uri="http://java.sun.com/jsp/jstl/core"
prefix="c" %>

<div class="">
  <div class="container-fluid py-4">
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h4 class="mb-1">
          <i class="fas fa-file-import me-2"></i>Import Leads
        </h4>
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item">
              <a href="${pageContext.request.contextPath}/marketing/leads"
                >Leads</a
              >
            </li>
            <li class="breadcrumb-item active" aria-current="page">Import</li>
          </ol>
        </nav>
      </div>
      <a
        href="${pageContext.request.contextPath}/marketing/leads"
        class="btn btn-outline-secondary"
      >
        <i class="fas fa-arrow-left me-1"></i> Quay lại
      </a>
    </div>

    <!-- Upload Card -->
    <div class="import-card mb-4">
      <h5 class="mb-4">
        <i class="fas fa-file-excel me-2"></i> Tải file Excel
      </h5>

      <!-- Upload Zone -->
      <div class="upload-zone" id="uploadZone">
        <i class="fas fa-cloud-upload-alt"></i>
        <h6>Kéo thả file hoặc click để chọn</h6>
        <p class="text-muted small">Hỗ trợ file .xlsx | Tối đa 5MB</p>
        <input
          type="file"
          id="fileInput"
          accept=".xlsx"
          style="display: none"
        />
      </div>

      <!-- Form -->
      <form id="importForm" class="mt-4">
        <div class="form-section">
          <h6><i class="fas fa-cog me-2"></i> Cấu hình Import</h6>

          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label required">Nguồn Lead</label>
                <select class="form-select" id="source" name="source" required>
                  <option value="">-- Chọn nguồn --</option>
                  <option value="Seminar">Seminar</option>
                  <option value="Facebook">Facebook</option>
                  <option value="Website">Website</option>
                  <option value="Referral">Referral</option>
                  <option value="Import">Import File</option>
                </select>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label">Campaign (Optional)</label>
                <select class="form-select" id="campaignId" name="campaignId">
                  <option value="">-- Không gắn Campaign --</option>
                  <c:forEach var="campaign" items="${campaigns}">
                    <option value="${campaign.campaignId}">
                      ${campaign.name} (${campaign.status})
                    </option>
                  </c:forEach>
                </select>
              </div>
            </div>
          </div>

          <!-- Assign To Sale Staff (checkboxes) -->
          <div class="row mt-2">
            <div class="col-12">
              <div class="mb-3">
                <label class="form-label">Assign To (Sale Staff)</label>
                <div class="assign-to-section">
                  <div class="assign-to-header">
                    <div class="form-check">
                      <input class="form-check-input" type="checkbox" id="selectAllSale" />
                      <label class="form-check-label fw-bold" for="selectAllSale">
                        Chọn tất cả
                      </label>
                    </div>
                    <input type="text" class="form-control form-control-sm assign-search" id="searchSale" placeholder="Tìm kiếm sale..." />
                  </div>
                  <div class="assign-to-list" id="saleList">
                    <c:forEach var="staff" items="${saleStaffs}">
                      <div class="form-check assign-to-item" data-name="${staff.fullName}" data-email="${staff.email}">
                        <input class="form-check-input sale-checkbox" type="checkbox" name="assignedToIds" value="${staff.userId}" id="sale_${staff.userId}" />
                        <label class="form-check-label" for="sale_${staff.userId}">
                          <span class="sale-name">${staff.fullName}</span>
                          <span class="sale-info">${staff.email} | ${staff.phone}</span>
                        </label>
                      </div>
                    </c:forEach>
                    <c:if test="${empty saleStaffs}">
                      <p class="text-muted small mb-0">Không có sale staff nào.</p>
                    </c:if>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Result Section (hidden initially) -->
        <div id="resultSection" style="display: none">
          <div class="form-section">
            <h6 id="resultTitle"></h6>

            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-number" id="importedCount">0</div>
                <div class="stat-label">Import thành công</div>
              </div>
              <div class="stat-item">
                <div class="stat-number" id="failedCount">0</div>
                <div class="stat-label">Import thất bại</div>
              </div>
            </div>

            <!-- Error Messages -->
            <div id="errorContainer"></div>
          </div>
        </div>

        <!-- Actions -->
        <div class="mt-4">
          <button type="submit" class="btn btn-primary" id="submitBtn">
            <i class="fas fa-upload me-1"></i> Import
          </button>
          <a
            href="${pageContext.request.contextPath}/marketing/leads"
            class="btn btn-secondary ms-2"
          >
            <i class="fas fa-arrow-left me-1"></i> Quay lại
          </a>
        </div>
      </form>
    </div>

    <!-- Template Info Card -->
    <div class="import-card">
      <h5><i class="fas fa-info-circle me-2"></i> Hướng dẫn Format File</h5>
      <p>File Excel phải có các cột sau (theo thứ tự):</p>
      <div class="table-responsive">
        <table class="table table-sm table-bordered">
          <thead class="table-light">
            <tr>
              <th>STT</th>
              <th>Tên cột</th>
              <th>Kiểu dữ liệu</th>
              <th>Bắt buộc</th>
              <th>Ví dụ</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>1</td>
              <td>fullName</td>
              <td>Text</td>
              <td><span class="badge bg-danger">Có</span></td>
              <td>Nguyễn Văn A</td>
            </tr>
            <tr>
              <td>2</td>
              <td>email</td>
              <td>Email</td>
              <td><span class="badge bg-danger">Có</span></td>
              <td>nguyenvana@company.com</td>
            </tr>
            <tr>
              <td>3</td>
              <td>phone</td>
              <td>Text (9-15 số)</td>
              <td><span class="badge bg-success">Không</span></td>
              <td>0901234567</td>
            </tr>
            <tr>
              <td>4</td>
              <td>source</td>
              <td>Text</td>
              <td><span class="badge bg-success">Không</span></td>
              <td>EVENT</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="alert alert-info mt-3">
        <i class="fas fa-lightbulb me-1"></i>
        <strong>Lưu ý:</strong> Mỗi lead sẽ được tự động chấm điểm (0-100) dựa
        trên:
        <ul class="mb-0 mt-2">
          <li>Email công ty: +20, Email cá nhân: +20</li>
          <li>Số điện thoại hợp lệ: +20</li>
          <li>
            Source (Event: +30, Referral: +25, Website: +15, Social: +10, Other:
            +5)
          </li>
          <li>Phân loại: Hot (≥70), Warm (40-69), Cold (&lt;40)</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<script>
  const uploadZone = document.getElementById("uploadZone");
  const fileInput = document.getElementById("fileInput");
  const importForm = document.getElementById("importForm");
  const submitBtn = document.getElementById("submitBtn");

  // ===== Upload Zone Events =====
  uploadZone.addEventListener("click", () => fileInput.click());

  uploadZone.addEventListener("dragover", (e) => {
    e.preventDefault();
    uploadZone.classList.add("dragover");
  });

  uploadZone.addEventListener("dragleave", () => {
    uploadZone.classList.remove("dragover");
  });

  uploadZone.addEventListener("drop", (e) => {
    e.preventDefault();
    uploadZone.classList.remove("dragover");
    fileInput.files = e.dataTransfer.files;
    updateFileName();
  });

  fileInput.addEventListener("change", updateFileName);

  function updateFileName() {
    if (fileInput.files.length > 0) {
      uploadZone.innerHTML =
        '<i class="fas fa-check-circle" style="color: #28a745; font-size: 3rem;"></i>' +
        "<h6>" +
        fileInput.files[0].name +
        "</h6>" +
        '<p class="text-muted small">' +
        (fileInput.files[0].size / 1024).toFixed(2) +
        " KB</p>";
    }
  }

  // ===== Form Submit =====
  importForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    if (!fileInput.files.length) {
      alert("Vui lòng chọn file");
      return;
    }

    const formData = new FormData();
    formData.append("file", fileInput.files[0]);
    formData.append("source", document.getElementById("source").value);

    const campaignId = document.getElementById("campaignId").value;
    if (campaignId) {
      formData.append("campaignId", campaignId);
    }

    // Append selected sale staff IDs
    document.querySelectorAll('.sale-checkbox:checked').forEach(cb => {
      formData.append("assignedToIds", cb.value);
    });

    submitBtn.disabled = true;
    submitBtn.innerHTML =
      '<span class="spinner-border spinner-border-sm me-2"></span>Đang import...';

    try {
      const response = await fetch(
        "${pageContext.request.contextPath}/marketing/leads/import",
        {
          method: "POST",
          body: formData,
        },
      );

      const result = await response.json();
      showResult(result);
    } catch (error) {
      alert("Lỗi: " + error.message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.innerHTML = '<i class="fas fa-upload me-1"></i> Import';
    }
  });

  function showResult(result) {
    const resultSection = document.getElementById("resultSection");
    const resultTitle = document.getElementById("resultTitle");
    const importedCount = document.getElementById("importedCount");
    const failedCount = document.getElementById("failedCount");
    const errorContainer = document.getElementById("errorContainer");

    resultSection.style.display = "block";

    if (result.success) {
      resultTitle.innerHTML =
        '<i class="fas fa-check-circle" style="color: #28a745;"></i> Import Thành công!';
      resultTitle.style.color = "#28a745";
    } else {
      resultTitle.innerHTML =
        '<i class="fas fa-exclamation-circle" style="color: #dc3545;"></i> Import Thất bại!';
      resultTitle.style.color = "#dc3545";
    }

    importedCount.textContent = result.totalImported || 0;
    failedCount.textContent = result.totalFailed || 0;

    // Show errors with better formatting
    errorContainer.innerHTML = "";
    if (result.errors && result.errors.length > 0) {
      // Group errors by type
      const duplicateErrors = result.errors.filter(e => e.includes("đã tồn tại"));
      const validationErrors = result.errors.filter(e => !e.includes("đã tồn tại"));

      let errorHtml = '<div class="error-list mt-3">';

      // Show duplicates prominently
      if (duplicateErrors.length > 0) {
        errorHtml += '<div class="alert alert-warning">';
        errorHtml += '<strong><i class="fas fa-exclamation-triangle me-1"></i> Các lead bị trùng (đã tồn tại trong campaign này):</strong>';
        errorHtml += '<ul class="mb-0 mt-2" style="max-height: 200px; overflow-y: auto;">';
        duplicateErrors.forEach(err => {
          errorHtml += '<li class="text-warning">' + err + '</li>';
        });
        errorHtml += '</ul></div>';
      }

      // Show validation errors
      if (validationErrors.length > 0) {
        errorHtml += '<div class="alert alert-danger mt-2">';
        errorHtml += '<strong><i class="fas fa-times-circle me-1"></i> Các lead có dữ liệu không hợp lệ:</strong>';
        errorHtml += '<ul class="mb-0 mt-2" style="max-height: 200px; overflow-y: auto;">';
        validationErrors.forEach(err => {
          errorHtml += '<li>' + err + '</li>';
        });
        errorHtml += '</ul></div>';
      }

      errorHtml += '</div>';
      errorContainer.innerHTML = errorHtml;
    }

    // Show message
    const msgDiv = document.createElement("div");
    msgDiv.className =
      "alert " + (result.success ? "alert-success" : "alert-danger") + " mt-3";
    msgDiv.textContent = result.message;
    errorContainer.appendChild(msgDiv);
  }

  // ===== Select All Checkbox =====
  const selectAllCb = document.getElementById("selectAllSale");
  if (selectAllCb) {
    selectAllCb.addEventListener("change", function () {
      const visible = document.querySelectorAll('.assign-to-item:not([style*="display: none"]) .sale-checkbox');
      visible.forEach(cb => cb.checked = this.checked);
    });
  }

  // ===== Search Sale Staff =====
  const searchSaleInput = document.getElementById("searchSale");
  if (searchSaleInput) {
    searchSaleInput.addEventListener("input", function () {
      const keyword = this.value.toLowerCase();
      document.querySelectorAll(".assign-to-item").forEach(item => {
        const name = (item.dataset.name || "").toLowerCase();
        const email = (item.dataset.email || "").toLowerCase();
        item.style.display = (name.includes(keyword) || email.includes(keyword)) ? "" : "none";
      });
    });
  }
</script>
