<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8" %> <%@ taglib uri="http://java.sun.com/jsp/jstl/core"
prefix="c" %>

<div class="col-10">
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
                  <option value="EVENT">Event</option>
                  <option value="FACEBOOK">Facebook</option>
                  <option value="WEBSITE">Website</option>
                  <option value="REFERRAL">Referral</option>
                  <option value="IMPORT">Import File</option>
                </select>
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label">Campaign (Optional)</label>
                <input
                  type="number"
                  class="form-control"
                  id="campaignId"
                  name="campaignId"
                  placeholder="ID campaign"
                />
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
              <td>companyName</td>
              <td>Text</td>
              <td><span class="badge bg-success">Không</span></td>
              <td>ABC Company</td>
            </tr>
            <tr>
              <td>5</td>
              <td>interest</td>
              <td>Text</td>
              <td><span class="badge bg-success">Không</span></td>
              <td>Product Manager</td>
            </tr>
            <tr>
              <td>6</td>
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
          <li>Email công ty: +20, Email cá nhân: +10</li>
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

    // Show errors
    errorContainer.innerHTML = "";
    if (result.errors && result.errors.length > 0) {
      let errorItems = result.errors
        .map((err) => "<li>" + err + "</li>")
        .join("");
      const errorHtml =
        '<div class="error-list">' +
        '<strong><i class="fas fa-exclamation-triangle me-1"></i> Chi tiết lỗi:</strong>' +
        "<ul>" +
        errorItems +
        "</ul>" +
        "</div>";
      errorContainer.innerHTML = errorHtml;
    }

    // Show message
    const msgDiv = document.createElement("div");
    msgDiv.className =
      "alert " + (result.success ? "alert-success" : "alert-danger") + " mt-3";
    msgDiv.textContent = result.message;
    errorContainer.appendChild(msgDiv);
  }
</script>
