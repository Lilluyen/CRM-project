# 📋 TÀI LIỆU MODULE MARKETING - SWP391 CRM PROJECT

**Ngày cập nhật:** 28/03/2026
**Trạng thái:** ✅ Hoàn thành

---

## 1. TỔNG QUAN KIẾN TRÚC

### 1.1 Vị trí trong hệ thống

Module Marketing là **một trong 5 module** của hệ thống CRM:

```
CRM System
├── Admin Module     → /admin/*
├── Manager Module   → /manager/*
├── Sale Module      → /sale/*
├── Marketing Module → /marketing/*    ← ĐANG XEM
└── CS Module        → /cs/*
```

**Đặc điểm kiến trúc:**
- **Pattern:** MVC (Model-View-Controller) — mở rộng thêm Service Layer
- **Routing:** Path-based (không dùng `action` param)
- **Layout:** Master layout chung (`layout.jsp`) — tất cả module dùng chung header/sidebar
- **Session:** Lấy user từ `sessionScope.user` để xác định role prefix cho sidebar
- **PRG Pattern:** Post-Redirect-Get để tránh double-submit

### 1.2 Package Structure

```
src/main/java/
├── model/                 ← Entity classes
│   ├── Campaign.java
│   ├── Lead.java
│   ├── User.java
│   └── CampaignReport.java
├── dto/                   ← Data Transfer Objects
│   ├── Pagination.java
│   └── report/
│       └── DealResultReportDTO.java
├── service/               ← Business Logic Layer
│   ├── CampaignService.java
│   ├── LeadService.java
│   └── ReportService.java
├── dao/                   ← Data Access Layer
│   ├── CampaignDAO.java
│   └── LeadDAO.java
└── controller/marketing/  ← Presentation Layer
    ├── CampaignListController.java
    ├── CampaignFormController.java
    ├── CampaignDetailController.java
    ├── CampaignReportController.java
    ├── LeadListController.java
    ├── LeadFormController.java
    ├── LeadDetailController.java
    ├── LeadImportController.java
    ├── LeadExportController.java
    ├── LeadScoreController.java
    └── MarketingDashboardController.java
```

### 1.3 Luồng dữ liệu chung (Request Lifecycle)

```
Browser Request
     ↓
Servlet Container (Tomcat)
     ↓
Controller (doGet/doPost)
     ↓ ← Gọi Service (business logic)
Service
     ↓ ← Gọi DAO (truy vấn DB)
DAO / Database
     ↓
Service trả kết quả về Controller
     ↓
request.setAttribute(...)  ← Đặt data vào request
     ↓
request.getRequestDispatcher("/view/layout.jsp").forward(...)
     ↓
layout.jsp
  ├─ <jsp:include page="components/header.jsp" />
  ├─ <jsp:include page="components/sidebar.jsp" /> ← đọc session → role prefix
  └─ <jsp:include page="${contentPage}" />         ← trang cụ thể
     ↓
Browser nhận HTML + CSS + JS
```

---

## 2. DATA MODEL

### 2.1 Campaign Entity

```java
Campaign {
    int campaignId           // Primary Key, auto-increment
    String name             // Tên campaign (max 255)
    String description      // Mô tả
    BigDecimal budget       // Ngân sách (> 0)
    LocalDate startDate     // Ngày bắt đầu
    LocalDate endDate       // Ngày kết thúc
    String channel          // Kênh marketing: EMAIL, SOCIAL, SEO, PPC, CONTENT
    String status           // PLANNING | ACTIVE | PAUSED | COMPLETED
    int createdBy           // FK → User.userId
    LocalDateTime createdAt
    LocalDateTime updatedAt
}
```

### 2.2 Lead Entity

```java
Lead {
    int leadId               // Primary Key
    String firstName, lastName
    String email            // Unique
    String phone
    String company
    String position
    String status           // NEW | CONTACTED | QUALIFIED | CONVERTED | LOST
    String interest         // LOW | MEDIUM | HIGH
    int score               // 0-100, tính tự động
    int campaignId          // FK → Campaign (nullable)
    int assignedTo          // FK → User (nullable)
    LocalDateTime createdAt
    LocalDateTime updatedAt
}
```

### 2.3 CampaignReport Entity (Generated)

```java
CampaignReport {
    int reportId
    int campaignId
    int totalLead           // Tổng leads
    int qualifiedLead       // Leads QUALIFIED
    int convertedLead      // Leads CONVERTED
    BigDecimal totalRevenue
    BigDecimal totalCost
    BigDecimal roi          // (revenue - cost) / cost * 100
    LocalDate generatedAt
}
```

### 2.4 ERD Relationship

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │       │  Campaign   │       │    Lead     │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ userId (PK) │       │ campaignId  │       │ leadId (PK) │
│ roleId (FK) │──┐    │ name        │       │ email       │
└─────────────┘  │    │ budget      │       │ status      │
                 │    │ channel     │───┐   │ score       │
┌─────────────┐  │    │ status      │   │   │ campaignId  │
│    Role     │  └───→│ createdBy    │   ├───→│ (FK)        │
├─────────────┤       └─────────────┘   │   │ assignedTo  │
│ roleId (PK) │                             └───→│ (FK)        │
│ roleName    │                                 └─────────────┘
│             │
│ ADMIN       │    sidebar.jsp dùng user.role.roleName
│ MANAGER     │    để xác định rolePrefix → link đúng module
│ SALE        │
│ MARKETING   │    VD: Marketing user → rolePrefix="/marketing"
│ CS          │    → Sidebar chỉ hiện menu của module Marketing
└─────────────┘
```

---

## 3. URL MAPPING

### 3.1 Campaign URLs

| Mô tả | Method | URL | Controller |
|-------|--------|-----|------------|
| Danh sách | GET | `/marketing/campaign` | `CampaignListController.doGet()` |
| Tạo mới | GET | `/marketing/campaign/form` | `CampaignFormController.doGet()` |
| Lưu tạo mới | POST | `/marketing/campaign/form` | `CampaignFormController.doPost()` |
| Chỉnh sửa | GET | `/marketing/campaign/form?id=X` | `CampaignFormController.doGet()` |
| Chi tiết | GET | `/marketing/campaign/detail?id=X` | `CampaignDetailController.doGet()` |
| Báo cáo | GET | `/marketing/campaign/report` | `CampaignReportController.doGet()` |
| Xóa | GET | `/marketing/campaign/delete?id=X` | `CampaignListController.doGet()` |

### 3.2 Lead URLs

| Mô tả | Method | URL | Controller |
|-------|--------|-----|------------|
| Danh sách | GET | `/marketing/leads` | `LeadListController.doGet()` |
| Tạo mới | GET | `/marketing/leads/form` | `LeadFormController.doGet()` |
| Lưu tạo mới | POST | `/marketing/leads/form` | `LeadFormController.doPost()` |
| Chỉnh sửa | GET | `/marketing/leads/form?id=X` | `LeadFormController.doGet()` |
| Chi tiết | GET | `/marketing/leads/detail?id=X` | `LeadDetailController.doGet()` |
| Nhập Excel | GET | `/marketing/leads/import` | `LeadImportController.doGet()` |
| Xuất Excel | GET | `/marketing/leads/export` | `LeadExportController.doGet()` |
| Chấm điểm | GET | `/marketing/leads/score?id=X` | `LeadScoreController.doGet()` |

### 3.3 Dashboard & Report

| Mô tả | Method | URL | Controller |
|-------|--------|-----|------------|
| Dashboard | GET | `/marketing/dashboard` | `MarketingDashboardController.doGet()` |
| Báo cáo tổng | GET | `/marketing/report` | `CampaignReportController.doGet()` |

### 3.4 Filter & Pagination Params

Tất cả list pages hỗ trợ:

```
?search=...          → Tìm kiếm theo tên
?status=...          → Lọc theo trạng thái
?page=1              → Trang hiện tại
?pageSize=10         → Số bản ghi/trang (5 | 10 | 20)
```

Riêng Lead: thêm `?campaignId=X` (lọc theo campaign) và `?interest=X` (lọc theo mức độ quan tâm).

---

## 4. LOGIC FLOW CHI TIẾT

### 4.1 Campaign List

```
GET /marketing/campaign
  ├─ ?search=...    ← Tìm theo tên
  ├─ ?status=...    ← PLANNING | ACTIVE | PAUSED | COMPLETED
  └─ ?page=1&pageSize=10
       ↓
CampaignListController.doGet()
       ↓
CampaignService.countCampaigns(searchName, status)
  → SELECT COUNT(*) FROM Campaign WHERE ...
       ↓
new Pagination(page, pageSize, totalItems)
  → Tính: startItem, endItem, totalPages, hasPrev, hasNext
       ↓
CampaignService.searchCampaigns(searchName, status, page, pageSize)
  → SELECT * FROM Campaign WHERE ... LIMIT offset, pageSize
       ↓
request.setAttribute:
  ├─ "campaigns"        ← Danh sách campaigns
  ├─ "pagination"       ← Pagination object
  ├─ "searchName"       ← Giữ lại search value
  ├─ "filterStatus"    ← Giữ lại filter value
  └─ "success"         ← Flash message (đọc từ session)
       ↓
forward("/view/layout.jsp")
  → layout.jsp + marketing/campaign/campaign_list.jsp
       ↓
campaign_list.jsp renders:
  ├─ Page Header + Create button
  ├─ Alert success/error (từ flash)
  ├─ Filter form (search input + status select)
  ├─ Stats cards (Tổng số campaigns)
  ├─ Campaign table (name, channel, status badge, budget, dates)
  └─ <jsp:include page="/view/components/pagination.jsp" />
```

### 4.2 Create Campaign

```
GET /marketing/campaign/form
       ↓
CampaignFormController.doGet()
  ├─ id == null → forward form trống
  └─ id != null → CampaignService.getCampaignById(id)
                  → request.setAttribute("campaign", campaign)
       ↓
forward → layout.jsp + marketing/campaign/campaign_form.jsp
       ↓
campaign_form.jsp renders:
  ├─ Breadcrumb
  ├─ Form action="${pageContext.request.contextPath}/marketing/campaign/form"
  └─ Input fields: name, description, budget, startDate, endDate, channel

POST /marketing/campaign/form
       ↓
CampaignFormController.doPost()
       ↓
handleCreate(request)
  ├─ Validate: name ≠ null, budget > 0
  ├─ Validate: startDate ≥ today, endDate ≥ today, endDate > startDate
  ├─ Validate: channel ≠ null
  └─ Campaign created = new Campaign(...)
       ↓
CampaignService.createCampaign(created)
  → CampaignDAO.insert(created)
  → INSERT INTO Campaign VALUES (...)
       ↓
session.setAttribute("successMessage", "...")
       ↓
redirect /marketing/campaign  ← PRG Pattern
       ↓
GET /marketing/campaign (CampaignListController.doGet())
  ├─ successMsg = session.getAttribute("successMessage")
  ├─ request.setAttribute("success", successMsg)
  └─ Hiển thị alert thành công
```

### 4.3 Campaign Detail + Report Generation

```
GET /marketing/campaign/detail?id=X
       ↓
CampaignDetailController.doGet()
       ↓
CampaignService.getCampaignById(X)
  → SELECT * FROM Campaign WHERE campaignId = X
       ↓
ReportService.generateReport(X)   ← SINH BÁO CÁO
  → Đếm leads: total, qualified, converted
  → Tính revenue từ Deal liên quan đến leads của campaign
  → Tính ROI = (revenue - cost) / cost * 100
  → Trả về CampaignReport object
       ↓
ReportService.getDealResultReport(X, null, null)
  → dealsWon, dealsLost, totalDeals của campaign
       ↓
Tính conversionRate = dealsWon * 100 / totalLead (nếu totalLead > 0)
       ↓
request.setAttribute:
  ├─ "campaign"          ← Campaign entity
  ├─ "report"            ← CampaignReport (stats)
  ├─ "dealsWon"          ← Số deals thắng
  ├─ "dealsCreated"      ← Tổng deals
  ├─ "dealsLost"         ← Số deals thua
  └─ "conversionRate"    ← "X.X%" (String)
       ↓
forward → layout.jsp + marketing/campaign/campaign_detail.jsp
       ↓
campaign_detail.jsp renders:
  ├─ Breadcrumb
  ├─ Campaign header (name, status badge, description)
  ├─ Info grid: kênh, ngân sách, ngày bắt đầu/kết thúc
  ├─ Stats 4 cards: Total Leads | Qualified | Converted | Conversion Rate
  ├─ Action buttons: Back | Edit | View Leads
  └─ Delete confirmation modal
```

### 4.4 Lead List (với Campaign Filter)

```
GET /marketing/leads
  ├─ ?search=...
  ├─ ?status=...
  ├─ ?campaignId=X   ← Optional: từ Campaign Detail → "View Leads"
  ├─ ?interest=...
  └─ ?page=1&pageSize=10
       ↓
LeadListController.doGet()
       ↓
LeadService.countLeads(keyword, status, campaignId, interest)
  → SELECT COUNT(*) FROM Lead WHERE ...
       ↓
new Pagination(page, pageSize, totalItems)
       ↓
LeadService.searchLeads(keyword, status, campaignId, interest, page, pageSize)
       ↓
if campaignId > 0:
  Campaign campaign = CampaignService.getCampaignById(campaignId)
  → request.setAttribute("filterCampaign", campaign)
  → Hiển thị "Danh sách leads của campaign: [tên]"
       ↓
forward → layout.jsp + marketing/lead/lead_list.jsp
```

**Ý nghĩa campaign filter:**
- Từ `campaign_detail.jsp`, click "View Leads" → chuyển đến `/marketing/leads?campaignId=X`
- Hiển thị tất cả leads thuộc campaign đó
- Có thể export riêng leads của campaign

### 4.5 Lead Import (Excel)

```
GET /marketing/leads/import
       ↓
LeadImportController.doGet()
  → forward → layout.jsp + marketing/lead/lead_import.jsp

POST /marketing/leads/import
       ↓
LeadImportController.doPost()
  ├─ Lấy file Excel từ request ( multipart/form-data)
  ├─ Dùng Apache POI đọc file .xlsx / .xls
  ├─ Parse từng row → tạo Lead object
  ├─ Validate: email hợp lệ, required fields không null
  ├─ LeadService.batchInsertLeads(list)
  │   → INSERT nhiều leads cùng lúc
  └─ session.setAttribute("successMessage", "Đã nhập X leads thành công")
     redirect /marketing/leads
```

### 4.6 Lead Export (Excel)

```
GET /marketing/leads/export
  ├─ ?search=...       ← Giữ filter hiện tại
  ├─ ?status=...
  ├─ ?campaignId=...
       ↓
LeadExportController.doGet()
  ├─ LeadService.searchLeads(...) → lấy danh sách theo filter
  ├─ Tạo Excel workbook (Apache POI)
  ├─ Header row: Name | Email | Phone | Company | Status | Score | Campaign
  ├─ Data rows từ danh sách leads
  ├─ Format: filename = "leads_export_YYYYMMDD.xlsx"
  └─ response.setContentType("application/vnd.openxmlformats...")
     response.setHeader("Content-Disposition", "attachment; ...")
     → Gửi file về browser để download
```

### 4.7 Lead Score (Chấm điểm)

```
GET /marketing/leads/score?id=X
       ↓
LeadScoreController.doGet()
  ├─ Load Lead entity
  ├─ Tính score theo thuật toán:
  │   score = f(email_exists, phone_exists, company_filled,
  │             interest_level, campaign_assigned, assigned_to_staff)
  │   → Mỗi yếu tố có trọng số, tổng = 0-100
  ├─ LeadService.updateLeadScore(leadId, newScore)
  └─ redirect về lead_detail?id=X
       ↓
lead_detail.jsp hiển thị score:
  ├─ Score badge: 0-30 (Đỏ/yếu) | 31-60 (Vàng/trung bình) | 61-100 (Xanh/mạnh)
  └─ <a href="/marketing/leads/score?id=X">Cập nhật điểm</a>
```

---

## 5. SERVICE LAYER

### 5.1 CampaignService

| Method | Mô tả |
|--------|-------|
| `getAllCampaigns()` | Lấy tất cả campaigns |
| `getCampaignById(int id)` | Lấy 1 campaign theo ID |
| `searchCampaigns(search, status, page, pageSize)` | Tìm kiếm + phân trang |
| `countCampaigns(search, status)` | Đếm tổng bản ghi (cho pagination) |
| `createCampaign(Campaign)` | Tạo mới campaign |
| `updateCampaign(Campaign)` | Cập nhật campaign |
| `deleteCampaign(int id)` | Xóa campaign |

### 5.2 LeadService

| Method | Mô tả |
|--------|-------|
| `searchLeads(keyword, status, campaignId, interest, page, pageSize)` | Tìm kiếm + phân trang |
| `countLeads(...)` | Đếm tổng bản ghi |
| `getLeadById(int id)` | Lấy 1 lead |
| `createLead(Lead)` | Tạo mới lead |
| `updateLead(Lead)` | Cập nhật lead |
| `batchInsertLeads(List<Lead>)` | Nhập nhiều leads từ Excel |
| `calculateScore(Lead)` | Tính điểm lead (0-100) |

### 5.3 ReportService

| Method | Mô tả |
|--------|-------|
| `generateReport(int campaignId)` | Sinh CampaignReport cho 1 campaign |
| `getDealResultReport(campaignId, dateFrom, dateTo)` | Lấy deals metrics |
| `getDashboardStats()` | Lấy stats tổng cho dashboard |

---

## 6. LAYOUT SYSTEM

### 6.1 layout.jsp — Master Layout

**Path:** `/view/layout.jsp`

Tất cả pages trong hệ thống đều render qua `layout.jsp`. Controller truyền dynamic attributes:

```java
request.setAttribute("pageTitle", "Danh sách Campaign");
request.setAttribute("contentPage", "marketing/campaign/campaign_list.jsp");
request.setAttribute("pageCss", "campaign_list.css");
request.setAttribute("page", "campaign-list");  // Sidebar active marker
request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
```

### 6.2 Sidebar — Multi-Module

`sidebar.jsp` dùng `sessionScope.user.role.roleName` để xác định module:

```jsp
<c:set var="userRole" value="${sessionScope.user.role.roleName}" />
<c:choose>
  <c:when test="${userRole eq 'MARKETING'}">
    <c:set var="rolePrefix" value="/marketing" />
  </c:when>
  <c:when test="${userRole eq 'ADMIN'}">
    <c:set var="rolePrefix" value="/admin" />
  </c:when>
  ...
</c:choose>
```

Sidebar hiển thị menu tương ứng role + highlight active page:

```jsp
<li>
  <a class="${page eq 'campaign-list' ? 'active' : ''}"
     href="${pageContext.request.contextPath}/marketing/campaign">
    Campaign List
  </a>
</li>
```

### 6.3 Pagination Component

**Path:** `/view/components/pagination.jsp`

Reusable component cho tất cả list pages:

```jsp
<jsp:include page="/view/components/pagination.jsp" />
```

Yêu cầu: request attribute `"pagination"` phải tồn tại.

Hỗ trợ:
- Previous / Next navigation
- Trang hiện tại + các trang lân cận (1 2 [3] 4 5 ...)
- Dấu ... cho danh sách dài
- Chọn pageSize (5 / 10 / 20)
- Giữ nguyên tất cả query params hiện tại (search, status, ...)

---

## 7. VALIDATION RULES

### 7.1 Campaign Create

| Field | Rule | Error Message |
|-------|------|---------------|
| Name | Not null, not blank, max 255 | "Name of campaign is not empty." |
| Budget | Not null, > 0, valid BigDecimal | "Budget must be a positive number." |
| Start Date | Not null, >= today | "Start date must be today or a future date." |
| End Date | Not null, >= today, > startDate | "End date must be after start date." |
| Channel | Not null, not blank | "Marketing channel is not empty." |

### 7.2 Campaign Update — Status/Date Cross-Validation

Khi **chỉnh sửa**, ngoài rules trên, status phải khớp với date logic:

| Status | Rule |
|--------|------|
| `PLANNING` | startDate ≥ today AND endDate ≥ today |
| `ACTIVE` | startDate ≤ today AND endDate ≥ today |
| `COMPLETED` | endDate ≤ today |
| `PAUSED` | endDate ≥ today |

Ví dụ lỗi: "Campaign is in ACTIVE status: end date must be today or later."

### 7.3 Lead Create/Update

| Field | Rule | Error |
|-------|------|-------|
| FirstName | Not null | "First name is required." |
| Email | Valid email format, unique | "Email is invalid or already exists." |
| Phone | Valid format (optional) | "Phone format is invalid." |
| Campaign | Valid campaignId (optional) | "Campaign does not exist." |
| Status | In: NEW, CONTACTED, QUALIFIED, CONVERTED, LOST | "Invalid status." |
| Score | 0-100, auto-calculated hoặc manual | "Score must be between 0 and 100." |

---

## 8. CSS CLASSES — DESIGN SYSTEM

### 8.1 Status Badges

```html
<span class="badge-status badge-active">  Đang chạy (ACTIVE)  </span>
<span class="badge-status badge-planning"> Lên kế hoạch (PLANNING) </span>
<span class="badge-status badge-paused">   Tạm dừng (PAUSED)   </span>
<span class="badge-status badge-completed">Kết thúc (COMPLETED) </span>
```

Lead status badges (dùng Bootstrap mặc định):
```html
<span class="badge bg-secondary">NEW</span>
<span class="badge bg-info">CONTACTED</span>
<span class="badge bg-warning text-dark">QUALIFIED</span>
<span class="badge bg-success">CONVERTED</span>
<span class="badge bg-danger">LOST</span>
```

### 8.2 Lead Score Badges

```html
<span class="badge-score badge-low">    0-30  → Đỏ / Yếu    </span>
<span class="badge-score badge-medium"> 31-60 → Vàng / TB   </span>
<span class="badge-score badge-high">   61-100 → Xanh / Mạnh </span>
```

### 8.3 Buttons

```html
<!-- Primary -->
<button class="btn btn-primary">Primary</button>

<!-- Custom Large -->
<button class="btn-large btn-primary-custom">Large Primary</button>

<!-- Save -->
<button class="btn-large btn-save">Save</button>

<!-- Delete -->
<button class="btn-delete">Delete</button>
<button class="btn-large btn-danger-custom">Danger</button>

<!-- Cancel / Secondary -->
<button class="btn-cancel">Cancel</button>
<button class="btn-secondary-custom">Secondary</button>
```

### 8.4 Cards & Layout

```html
<!-- Filter Card (search bar) -->
<div class="filter-card"><div class="card-body">...</div></div>

<!-- Stats Card (số liệu tổng quan) -->
<div class="stats-card">
  <div class="stats-number">10</div>
  <div class="stats-label">Total Campaigns</div>
</div>

<!-- Table Wrapper -->
<div class="card table-wrapper">
  <div class="table-responsive">
    <table class="table table-hover">...</table>
  </div>
</div>

<!-- Detail Card -->
<div class="card">
  <div class="card-header"><h5>Section Title</h5></div>
  <div class="card-body">...</div>
</div>
```

### 8.5 Detail Page Layout

```html
<div class="detail-row">
  <span class="detail-label">Channel</span>
  <span class="detail-value">${campaign.channel}</span>
</div>

<!-- Responsive: 1 col (mobile) → 2 cols (desktop) -->
```

---

## 9. CẤU TRÚC FILE ĐẦY ĐỦ

```
src/main/webapp/
├── view/
│   ├── layout.jsp                              ← Master layout (ALL modules)
│   └── components/
│       ├── header.jsp                         ← Top navigation
│       ├── sidebar.jsp                        ← Role-based sidebar
│       └── pagination.jsp                     ← Reusable pagination
│
└── marketing/
    ├── marketing_dashboard.jsp                 ← Dashboard view
    ├── marketing_report.jsp                    ← Tổng báo cáo
    ├── campaign/
    │   ├── campaign_list.jsp
    │   ├── campaign_form.jsp
    │   ├── campaign_detail.jsp
    │   └── campaign_report.jsp
    └── lead/
        ├── lead_list.jsp
        ├── lead_form.jsp
        ├── lead_detail.jsp
        └── lead_import.jsp

src/main/java/
├── model/
│   ├── Campaign.java
│   ├── Lead.java
│   ├── CampaignReport.java
│   ├── User.java
│   └── Role.java
├── dto/
│   ├── Pagination.java
│   └── report/
│       └── DealResultReportDTO.java
├── service/
│   ├── CampaignService.java
│   ├── LeadService.java
│   └── ReportService.java
├── dao/
│   ├── CampaignDAO.java
│   └── LeadDAO.java
└── controller/marketing/
    ├── CampaignListController.java
    ├── CampaignFormController.java
    ├── CampaignDetailController.java
    ├── CampaignReportController.java
    ├── LeadListController.java
    ├── LeadFormController.java
    ├── LeadDetailController.java
    ├── LeadImportController.java
    ├── LeadExportController.java
    ├── LeadScoreController.java
    └── MarketingDashboardController.java

src/main/webapp/assets/css/
├── campaign_list.css
├── campaign_form.css
├── campaign_detail.css
├── lead_list.css
├── lead_form.css
├── lead_detail.css
├── lead_import.css
├── marketing_dashboard.css
└── marketing_report.css
```

---

## 10. RESPONSIVE BREAKPOINTS

```css
/* Mobile first */
@media (min-width: 576px) { /* Tablet */ }
@media (min-width: 768px) { /* Desktop */ }

/* Detail row: single col mobile → 2 cols desktop */
.detail-row {
  grid-template-columns: 1fr;
}
@media (min-width: 768px) {
  .detail-row { grid-template-columns: 200px 1fr; }
}
```

---

## 11. TROUBLESHOOTING

### CSS not loading
```
1. Check: ${pageContext.request.contextPath}/assets/css/<pageCss> tồn tại
2. layout.jsp: <link href="...${pageCss}?v=<%= System.currentTimeMillis() %>">
3. Browser cache: Ctrl+Shift+Delete
4. Dev Tools → Network → tìm file CSS status 200/404
```

### Bootstrap JS not working (modal, dropdown)
```
1. layout.jsp: bootstrap.bundle.min.js load ở cuối <body>
2. Không có script chạy trước khi DOM ready
```

### Form validation not triggered
```
1. Form có id="campaignForm" hoặc id="leadForm"
2. Input name="" khớp với request.getParameter("...")
3. validateDates() hoặc validateForm() được gọi onsubmit
```

### Pagination không hiển thị
```
1. request.setAttribute("pagination", pagination) có chạy không?
2. ${pagination.totalItems > 0} → nếu 0 thì không hiển thị
3. Pagination object có method: hasPreviousPage, hasNextPage, totalPages
```

### Lead Import lỗi
```
1. File phải .xlsx hoặc .xls (không hỗ trợ .csv trực tiếp)
2. Header row phải đúng format: FirstName | LastName | Email | Phone | ...
3. Email phải unique (không trùng trong DB)
4. File size limit: kiểm tra web.xml <multipart-config>
```

---

## 12. CÁC CÂU HỎI THƯỜNG GẶP KHI PHẢN BIỆN

### Q: Tại sao dùng Service Layer? Sao không để logic trong Controller?
**A:** Controller chỉ nhận request và trả response. Service chứa business logic để:
1. Tái sử dụng giữa nhiều Controller (VD: cả API và Web đều dùng)
2. Dễ unit test — test Service không cần HTTP request
3. Controller gọn, clean, chỉ routing

### Q: PRG Pattern là gì? Tại sao cần?
**A:** Post-Redirect-Get — sau khi POST thành công, redirect về GET.
- Ngăn double-submit (user F5 không tạo 2 campaign)
- Flash message lưu trong session, đọc trong GET

### Q: Phân biệt Campaign ↔ Lead?
**A:**
- **Campaign:** Chiến dịch marketing (VD: "Black Friday 2026")
- **Lead:** Người quan tâm thu được từ campaign (VD: email khách hàng đăng ký)
- Một Campaign có N Leads, một Lead thuộc 1 Campaign

### Q: Tính năng nào làm em tự hào nhất?
**Gợi ý:**
1. **Lead Scoring tự động** — hệ thống chấm điểm lead dựa trên nhiều yếu tố
2. **Import/Export Excel** — nhập hàng loạt leads, xuất báo cáo
3. **Report Generation** — tự động sinh ROI, conversion rate cho mỗi campaign
4. **Multi-role sidebar** — cùng 1 layout, hiển thị menu phù hợp role

---

## 13. NEXT STEPS

| # | Mô tả | Trạng thái |
|---|-------|-----------|
| 1 | Implement Delete campaign | TODO |
| 2 | Chuẩn hóa breadcrumbs cho mọi trang | TODO |
| 3 | Tạo JSP view cho LeadScoreController | TODO |
| 4 | RESTful URL refactor (optional) | TODO |
| 5 | Unit tests cho Service layer | TODO |
| 6 | Email notification khi lead mới được tạo | TODO |

---

**Created:** March 1, 2026
**Last Updated:** March 28, 2026
**Status:** ✅ MODULE COMPLETE
