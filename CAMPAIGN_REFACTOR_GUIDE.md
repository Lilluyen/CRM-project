# 📋 TÀI LIỆU MODULE MARKETING — SWP391 CRM PROJECT

**Cập nhật:** 28/03/2026 | **Trạng thái:** ✅ Hoàn thành

---

## 1. TỔNG QUAN KIẾN TRÚC

### 1.1 Vị trí trong hệ thống

```
CRM System
├── Admin      → /admin/*
├── Manager    → /manager/*
├── Sale       → /sale/*
├── Marketing  → /marketing/*    ← Module này
└── CS         → /cs/*
```

### 1.2 Kiến trúc Pattern

**MVC + Service Layer + DAO Layer:**

```
Browser Request
      ↓
Controller (HttpServlet)     ← Nhận request, gọi Service, đặt attributes
      ↓
Service (Business Logic)       ← Validation, xử lý nghiệp vụ
      ↓
DAO (Data Access)              ← Truy vấn SQL, JDBC
      ↓
Database (SQL Server)
```

### 1.3 Các tính năng chính

| Tính năng               | Chi tiết                                                              |
| ----------------------- | --------------------------------------------------------------------- |
| **Quản lý Campaign**    | CRUD campaign, filter, phân trang                                     |
| **Quản lý Lead**        | CRUD lead, filter, phân trang, multi-campaign checkbox                |
| **Lead Scoring**        | Tính điểm tự động (0-80), tự động xác định status                     |
| **Import/Export Excel** | Nhập hàng loạt leads từ file .xlsx, xuất danh sách ra Excel           |
| **Dashboard**           | Tổng quan leads, campaigns, funnel, conversion rate                   |
| **Marketing Report**    | KPI tổng, Lead Source, Deal Result, Campaign Performance, Lead Funnel |
| **Activity Log**        | Tự động ghi log khi tạo/cập nhật lead                                 |

### 1.4 Đặc điểm thiết kế quan trọng

**1.4.1 Quan hệ Campaign ↔ Lead: Nhiều-Nhiều**

- Một Lead có thể tham gia **nhiều** Campaign (qua bảng `Campaign_Leads`)
- Một Campaign có thể chứa **nhiều** Leads
- `Leads.campaign_id` chỉ lưu campaign **đầu tiên** (không phản ánh đúng nhiều-nhiều)
- → **Luôn dùng `Campaign_Leads` để đếm leads theo campaign**

**1.4.2 Email làm định danh Lead (Deduplication)**

- UI hiển thị **1 dòng per email** (dùng `MIN(lead_id) GROUP BY email`)
- Import: cùng email = cùng 1 người
- Mỗi campaign có thể gán cùng email → lưu nhiều row `Campaign_Leads`

**1.4.3 PRG Pattern (Post-Redirect-Get)**

- Sau POST thành công → redirect về GET
- Flash message lưu trong `session`, đọc trong GET

**1.4.4 Path-Based Routing**

- URL dạng `/marketing/campaign`, không dùng `action` param
- Mỗi endpoint = 1 Controller riêng

---

## 2. CẤU TRÚC FILE ĐẦY ĐỦ

```
src/main/java/
├── model/
│   ├── Campaign.java            Entity chiến dịch
│   ├── Lead.java                Entity lead
│   ├── CampaignReport.java     Entity báo cáo chiến dịch
│   ├── CampaignLead.java        Entity quan hệ nhiều-nhiều
│   ├── ImportLeadRequest.java    DTO import request
│   └── ImportLeadResponse.java   DTO import response
│
├── dto/
│   ├── Pagination.java                      Phân trang dùng chung
│   └── report/
│       ├── CampaignPerformanceReportDTO.java Hiệu suất campaign
│       ├── LeadSourceReportDTO.java          Nguồn lead
│       ├── LeadFunnelReportDTO.java          Phễu lead
│       ├── DealResultReportDTO.java          Kết quả deal
│       ├── MarketingReportKpiDTO.java        KPI tổng
│       ├── RevenueForecastDTO.java           Dự báo doanh thu
│       └── SalesFunnelStageDTO.java          Giai đoạn funnel sale
│
├── dao/
│   ├── CampaignDAO.java         CRUD Campaign
│   ├── LeadDAO.java             CRUD Lead + search/pagination
│   ├── CampaignLeadDAO.java     Quản lý quan hệ campaign-lead
│   ├── CampaignReportDAO.java   Báo cáo (performance, source, funnel)
│   ├── LeadLookupDAO.java       Lookup leads cơ bản
│   └── DashboardDAO.java         Dữ liệu dashboard (global)
│
├── service/
│   ├── CampaignService.java      Business logic Campaign
│   ├── LeadService.java          Business logic Lead + validation
│   ├── ReportService.java        Business logic báo cáo
│   ├── LeadImportService.java    Logic import Excel
│   └── CampaignLeadService.java  Logic gán lead-campaign
│
├── controller/marketing/
│   ├── CampaignListController.java     /marketing/campaign
│   ├── CampaignFormController.java     /marketing/campaign/form
│   ├── CampaignDetailController.java   /marketing/campaign/detail
│   ├── CampaignReportController.java    /marketing/report
│   ├── LeadListController.java         /marketing/leads
│   ├── LeadFormController.java         /marketing/leads/form
│   ├── LeadDetailController.java       /marketing/leads/detail
│   ├── LeadImportController.java       /marketing/leads/import
│   ├── LeadExportController.java       /marketing/leads/export
│   ├── LeadScoreController.java        /marketing/leads/score (POST)
│   └── MarketingDashboardController.java /marketing/dashboard
│
└── util/
    ├── LeadScoringUtil.java    Thuật toán chấm điểm lead
    ├── LeadActivityUtil.java    Ghi log hoạt động lead
    ├── ExcelUtil.java          Đọc file Excel (.xlsx)
    ├── JsonUtility.java        Serialize JSON (Gson + LocalDateTime)
    ├── EmailCheck.java         Validate email
    ├── PhoneCheck.java         Validate phone VN
    └── DBContext.java          Connection factory

src/main/webapp/view/
├── layout.jsp                        Master layout (ALL modules)
├── components/
│   ├── header.jsp                   Top navigation
│   ├── sidebar.jsp                 Role-based sidebar menu
│   └── pagination.jsp               Reusable pagination component
└── marketing/
    ├── marketing_dashboard.jsp       Dashboard tổng quan
    ├── campaign/
    │   ├── campaign_list.jsp        Danh sách campaigns
    │   ├── campaign_form.jsp       Tạo/sửa campaign
    │   ├── campaign_detail.jsp      Chi tiết + stats campaign
    │   └── campaign_report.jsp      Báo cáo marketing (Chart.js)
    └── lead/
        ├── lead_list.jsp           Danh sách leads + score modal
        ├── lead_form.jsp           Tạo/sửa lead + multi-campaign checkbox
        ├── lead_detail.jsp         Chi tiết lead + danh sách campaigns đã tham gia
        └── lead_import.jsp         Form import Excel

src/main/webapp/assets/css/
├── campaign_list.css, campaign_form.css, campaign_detail.css
├── lead_list.css, lead_form.css, lead_detail.css, lead_import.css
├── marketing_dashboard.css          (Enterprise UI - Salesforce style)
└── marketing_report.css             (Report UI - KPI cards, charts)
```

---

## 3. DATA MODEL — CHI TIẾT

### 3.1 Campaign Entity

```java
Campaign {
    int campaignId              // PK, auto-increment
    String name                 // Tên campaign (max 255)
    String description           // Mô tả
    BigDecimal budget           // Ngân sách ( > 0)
    LocalDate startDate         // Ngày bắt đầu
    LocalDate endDate           // Ngày kết thúc
    String channel              // Kênh: Email | Facebook | Google | Google Display |
                               //       LinkedIn | SMS | SEO | Event | Referral | Multi-channel
    String status               // PLANNING | ACTIVE | PAUSED | COMPLETED
    int createdBy               // FK → User.userId
    LocalDateTime createdAt
    LocalDateTime updatedAt
}
```

**Status Aliases (DAO hỗ trợ cả UPPERCASE và PascalCase):**

```
"ACTIVE"    → ["ACTIVE", "Running"]
"PLANNING" → ["PLANNING", "Planned", "PLANNED"]
"PAUSED"   → ["PAUSED", "Paused"]
"COMPLETED"→ ["COMPLETED", "Completed"]
```

### 3.2 Lead Entity

```java
Lead {
    int leadId                  // PK
    String fullName             // Họ tên đầy đủ
    String email                // Email (unique per email deduplication)
    String phone                // SĐT VN (10 số)
    String interest             // Mức độ quan tâm
    String source               // Nguồn: Website | Facebook | LinkedIn |
                               //         Referral | Seminar | Email | Cold Call | Import | Other
    String status               // NEW_LEAD | CONTACTED | QUALIFIED | DEAL_CREATED | LOST
    int score                   // Điểm (0-80), auto-calculated
    int campaignId              // FK → Campaign (campaign đầu tiên, KHÔNG phản ánh nhiều-nhiều)
    String campaignNames        // [TRANSIENT] Danh sách campaigns, VD: "Summer | Black Friday"
    Integer assignedTo          // FK → User (nullable)
    String assignedToName       // [TRANSIENT] Tên người phụ trách
    LocalDateTime createdAt
    LocalDateTime updatedAt
    boolean isConverted         // Đã chuyển thành Customer?
    int convertedCustomerId     // FK → Customer (nếu converted)
}
```

### 3.3 CampaignLead Entity (Bảng quan hệ)

```java
CampaignLead {
    int campaignId              // FK → Campaign
    int leadId                  // FK → Lead
    String leadStatus            // Trạng thái lead trong campaign: NEW | CONTACTED | QUALIFIED | ...
    LocalDateTime assignedAt
    LocalDateTime updatedAt
}
```

### 3.4 CampaignReport Entity

```java
CampaignReport {
    int reportId
    int campaignId
    int totalLead               // Tổng leads (đếm từ Campaign_Leads)
    int qualifiedLead          // Leads QUALIFIED (đếm từ Campaign_Leads)
    int convertedLead          // Leads chuyển thành deal Won
    BigDecimal costPerLead     // budget / totalLead
    BigDecimal roi             // ROI %
    LocalDateTime createdAt
}
```

### 3.5 ERD

```
┌──────────────┐      1:N       ┌──────────────────┐
│    User      │───────────────→│    Campaign      │
│  (createdBy) │                │  (name, budget, │
└──────────────┘                │  start/end/     │
                                 │  channel, status)│
                                 └────────┬─────────┘
                                          │ 1:N
                                          ↓
                                  ┌───────────────┐
                                  │Campaign_Leads│  ← QUAN HỆ CHÍNH XÁC
                                  │(campaign_id,  │    giữa Campaign và Lead
                                  │ lead_id,      │
                                  │ lead_status)  │
                                  └───────┬───────┘
                                          │ N:1
                                          ↓ (email deduplication)
                                  ┌───────────────┐
                                  │     Lead      │
                                  │  (full_name,  │
                                  │   email,      │──→ 1:1 → Customer
                                  │   phone,       │     (is_converted=true)
                                  │   score,       │
                                  │   source,      │
                                  │   status)       │
                                  └───────────────┘
                                          │ N:1 (assignedTo)
                                          ↓
                                  ┌──────────────┐
                                  │    User      │
                                  └──────────────┘

NOTE: Leads.campaign_id chỉ lưu campaign ĐẦU TIÊN.
      → KHÔNG dùng Leads.campaign_id để đếm leads theo campaign.
      → Luôn dùng bảng Campaign_Leads.
```

---

## 4. URL MAPPING — TẤT CẢ ENDPOINTS

### 4.1 Campaign

| Mô tả          | Method | URL                                              | Controller                 |
| -------------- | ------ | ------------------------------------------------ | -------------------------- |
| Danh sách      | GET    | `/marketing/campaign`                            | `CampaignListController`   |
| Form tạo mới   | GET    | `/marketing/campaign/form`                       | `CampaignFormController`   |
| Lưu tạo mới    | POST   | `/marketing/campaign/form`                       | `CampaignFormController`   |
| Form chỉnh sửa | GET    | `/marketing/campaign/form?id=X`                  | `CampaignFormController`   |
| Chi tiết       | GET    | `/marketing/campaign/detail?id=X`                | `CampaignDetailController` |
| Xóa            | -      | Chưa có endpoint riêng trong controller hiện tại | -                          |

### 4.2 Lead

| Mô tả          | Method   | URL                            | Controller             |
| -------------- | -------- | ------------------------------ | ---------------------- |
| Danh sách      | GET      | `/marketing/leads`             | `LeadListController`   |
| Form tạo mới   | GET      | `/marketing/leads/form`        | `LeadFormController`   |
| Lưu tạo mới    | POST     | `/marketing/leads/form`        | `LeadFormController`   |
| Form chỉnh sửa | GET      | `/marketing/leads/form?id=X`   | `LeadFormController`   |
| Chi tiết       | GET      | `/marketing/leads/detail?id=X` | `LeadDetailController` |
| Nhập Excel     | GET/POST | `/marketing/leads/import`      | `LeadImportController` |
| Xuất Excel     | GET      | `/marketing/leads/export`      | `LeadExportController` |
| Chấm điểm      | POST     | `/marketing/leads/score`       | `LeadScoreController`  |

### 4.3 Dashboard & Report

| Mô tả        | Method | URL                    | Controller                     |
| ------------ | ------ | ---------------------- | ------------------------------ |
| Dashboard    | GET    | `/marketing/dashboard` | `MarketingDashboardController` |
| Báo cáo tổng | GET    | `/marketing/report`    | `CampaignReportController`     |

### 4.4 Filter/Pagination Params (tất cả list pages)

```
?search=...          Tìm kiếm (theo tên/email/phone)
?status=...         Lọc trạng thái
?campaignId=X       Lọc theo campaign (Lead only)
?interest=...       Lọc mức độ quan tâm (Lead only)
?page=1             Trang hiện tại
?pageSize=10        Bản ghi/trang (5 | 10 | 20)
```

---

## 5. LUỒNG XỬ LÝ CHI TIẾT

### 5.1 Campaign List

```
GET /marketing/campaign
  ├─ ?search=...      → LIKE %name%
  ├─ ?status=...     → IN (status aliases)
  └─ ?page=1&pageSize=10
       ↓
CampaignListController.doGet()
       ↓
CampaignDAO.countCampaigns(searchName, status)
  → SELECT COUNT(*) FROM Campaigns WHERE name LIKE ? AND status IN (?)
       ↓
new Pagination(page, pageSize, totalItems)
       ↓
CampaignDAO.searchCampaigns(searchName, status, page, pageSize)
  → SELECT * FROM Campaigns WHERE ... OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
       ↓
request.setAttribute: campaigns, pagination, searchName, filterStatus
Flash success/error từ session (PRG)
       ↓
forward("/view/layout.jsp")
  → campaign_list.jsp renders:
       ├─ Filter form (search + status select)
       ├─ Stats bar: Total campaigns count
       ├─ Table: name, status badge, budget, channel, dates
       ├─ Actions: View Detail | Edit
       └─ <jsp:include page="/view/components/pagination.jsp" />
```

### 5.2 Create Campaign

```
GET /marketing/campaign/form
       ↓
CampaignFormController.doGet()
  ├─ id == null → forward form trống
  └─ id != null → CampaignService.getCampaignById(id) → setAttribute("campaign")
       ↓
POST /marketing/campaign/form
       ↓
CampaignFormController.handleCreate()
  ├─ Validate: name ≠ null, budget > 0
  ├─ Validate: startDate ≥ today, endDate ≥ today, endDate > startDate
  ├─ Validate: channel ≠ null
  └─ Campaign created = new Campaign(...)
       ↓
CampaignDAO.insert(created)
  → INSERT INTO Campaigns OUTPUT inserted.campaign_id VALUES (...)
       ↓
session.setAttribute("successMessage", "...")
redirect /marketing/campaign  ← PRG
       ↓
GET /marketing/campaign (CampaignListController.doGet())
  → Hiển thị alert thành công
```

### 5.3 Update Campaign — Status/Date Cross-Validation

Khi update, ngoài basic validation còn có:

| Status      | Điều kiện ngày                        |
| ----------- | ------------------------------------- |
| `PLANNING`  | startDate ≥ today AND endDate ≥ today |
| `ACTIVE`    | startDate ≤ today AND endDate ≥ today |
| `COMPLETED` | endDate ≤ today                       |
| `PAUSED`    | endDate ≥ today                       |

### 5.4 Campaign Detail — Report Generation

```
GET /marketing/campaign/detail?id=X
       ↓
CampaignDetailController.doGet()
       ↓
CampaignDAO.getCampaignById(X)
ReportService.generateReport(X)
  ├─ CampaignLeadDAO.countTotalLeadsByCampaign(X)
  │   → SELECT COUNT(*) FROM Campaign_Leads WHERE campaign_id = X
  ├─ CampaignLeadDAO.countLeadByStatus(X, "QUALIFIED")
  │   → SELECT COUNT(*) FROM Campaign_Leads WHERE campaign_id = X AND lead_status = 'QUALIFIED'
  ├─ CampaignReportDAO.getDealResultReport(X)
  │   → Đếm deals Won/Lost liên quan leads của campaign
  └─ Tạo CampaignReport object
       ↓
request.setAttribute: campaign, report, dealsWon, dealsCreated, dealsLost, conversionRate
       ↓
forward → campaign_detail.jsp
```

### 5.5 Lead List — Email Deduplication

```
GET /marketing/leads
  ├─ ?search=... ?status=... ?campaignId=X ?interest=...
       ↓
LeadDAO.countLeads(keyword, status, campaignId, interest)
  -- FIX: GROUP BY email only (mỗi email = 1 người = 1 dòng UI)
  SELECT COUNT(*) FROM (
    SELECT MIN(lead_id) FROM Leads
    WHERE 1=1 ...
    GROUP BY email   ← QUAN TRỌNG: tránh trùng lặp
  ) AS base
       ↓
LeadDAO.searchLeads(...)
  SELECT l.*, campaign_names -- STUFF subquery lấy all campaigns
  FROM Leads l
  WHERE l.lead_id IN (SELECT MIN(lead_id) FROM Leads GROUP BY email)
  ...
  OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
       ↓
Lead.list: hiển thị fullName, email, score badge, status badge,
           campaignNames (multi-badge, phân cách " | ")
```

**Vấn đề đã fix:** `GROUP BY email, status, interest, full_name, phone` cũ sai vì cùng 1 email có nhiều row → tạo nhiều nhóm → COUNT sai.

### 5.6 Lead Form — Multi-Campaign Checkbox

**Create mode:**

- Checkbox dropdown: chỉ hiện ACTIVE campaigns
- Tích nhiều campaigns → gọi `LeadService.updateLeadCampaigns()`

**Edit mode:**

- Checkbox dropdown: hiện all ACTIVE campaigns, tích sẵn campaigns đã tham gia
- Tích/bỏ tích → cập nhật `Campaign_Leads`
- `getCampaignsByLeadEmail(leadId)` — trả về TẤT CẢ campaigns của email đó (query qua tất cả lead_id cùng email)

**Gán/bỏ gán campaign (updateLeadCampaigns):**

```
Campaign mới được tích, chưa có trong DB → INSERT Campaign_Leads
Campaign đang có, bị bỏ tích → DELETE Campaign_Leads
Campaign đầu tiên còn lại → update Leads.campaignId
```

### 5.7 Lead Scoring

```
LeadScoringUtil.calculateScore(fullName, email, phone, campaignId, interest)
  ================
  Có họ tên       → +20
  Có email        → +20
  Có phone hợp lệ → +20  (Validate: 10 chữ số, 0xxx)
  Có campaignId   → +10
  Có interest      → +10
  ──────────────────
  MAX              =  80 điểm

LeadScoringUtil.determineStatus(score)
  ================
  score < 20  → "LOST"
  score < 40  → "NEW_LEAD"
  score < 70  → "NURTURING"
  score ≥ 70  → "QUALIFIED"
```

**Auto-score trigger:** `createLead(lead, autoScore=true)`, `updateLead(lead, autoScore=true)`
**Note:** Status không tự đổi nếu lead đang `DEAL_CREATED`.

### 5.8 Lead Import — Chi tiết

```
POST /marketing/leads/import (multipart/form-data)
       ↓
ExcelUtil.readLeadsFromExcel(inputStream)
  → Dùng Apache POI (XSSFWorkbook)
  → Format Excel: fullName | email | phone | interest (4 cột)
  → Row 0 = header, bắt đầu từ Row 1
  → Numeric cell → giữ số 0 đầu VN phone (9 chữ số → thêm "0")
       ↓
LeadImportService.importLeads(leads, source, campaignId, assignedToIds)
       ↓
1. VALIDATE mỗi row:
   ├─ name ≠ null
   ├─ email hợp lệ (EmailCheck)
   ├─ không trùng trong file (emailsInBatch Set)
   ├─ không trùng trong campaign (emailsInCampaign Set)
   └─ không trùng trong DB (allExistingByEmail Map)
       ↓
2. PHÂN LOẠI:
   ├─ Email mới (DB) → tạo Lead mới → insert
   │   └─ Batch insert (PreparedStatement.addBatch)
   ├─ Email đã tồn tại → KHÔNG tạo mới
   │   └─ Chỉ INSERT Campaign_Leads
       ↓
3. ASSIGN:
   ├─ campaignLeadDAO.assignLeadToCampaign(campaignId, leadId, "NEW")
   └─ Round-robin assignedToIds (nếu có)
       ↓
4. LOG ACTIVITY:
   ├─ Chỉ log cho lead MỚI (newlyCreatedLeads) → LeadActivityUtil
   └─ Lead đã tồn tại → không log
       ↓
Return ImportLeadResponse: success, totalImported, totalFailed, errors[]
```

### 5.9 Lead Export

```
GET /marketing/leads/export?search=&status=&campaignId=&interest=
       ↓
LeadService.searchLeadsForExport(...)
  → Tương tự search nhưng LIMIT 10000, không phân trang
       ↓
XSSFWorkbook.createSheet("Leads")
  ├─ Header row: Mã Lead | Họ tên | Email | Phone | Điểm | Trạng thái | Quan tâm | Campaigns | Nguồn | Ngày tạo | Ngày cập nhật
  ├─ Freeze pane: cố định hàng tiêu đề
  └─ Auto-size columns
       ↓
response.setContentType("application/vnd.openxmlformats...")
response.setHeader("Content-Disposition", "attachment; filename=leads_YYYY-MM-DD.xlsx")
```

### 5.10 Marketing Dashboard

```
GET /marketing/dashboard
       ↓
MarketingDashboardController.doGet()
       ↓
Leads overview:
├─ totalLeads       = LeadService.countLeads(null, null, 0, null)
├─ newLeads         = LeadService.countLeads(null, "NEW", 0, null)
├─ contactedLeads    = LeadService.countLeads(null, "NURTURING", 0, null)
├─ qualifiedLeads   = LeadService.countLeads(null, "QUALIFIED", 0, null)
├─ dealCreatedLeads = LeadService.countLeads(null, "DEAL_CREATED", 0, null)
└─ lostLeads        = LeadService.countLeads(null, "LOST", 0, null)

Campaigns overview:
├─ totalCampaigns   = CampaignService.countCampaigns(null, null)
├─ activeCampaigns  = CampaignService.countCampaigns(null, "ACTIVE")
├─ planningCampaigns= CampaignService.countCampaigns(null, "PLANNING")
└─ completedCampaigns= CampaignService.countCampaigns(null, "COMPLETED")

Top 5 active campaigns:
└─ CampaignService.searchCampaigns(null, "ACTIVE", 1, 5)

5 recent leads:
└─ LeadService.searchLeads(null, null, 0, null, 1, 5)

Conversion rate:
└─ dealsWon * 100 / totalLeads
       ↓
marketing_dashboard.jsp renders:
  ├─ Lead Funnel visualization (4 stages)
  ├─ Top Active Campaigns table
  ├─ Recent Leads table
  └─ Quick Actions buttons
```

### 5.11 Marketing Report

```
GET /marketing/report
  ├─ ?campaignId=X ?source=Y ?fromDate=Z ?toDate=W
  └─ ?page=1&pageSize=10
       ↓
ReportService.getMarketingReportKpi(campaignId, fromDate, toDate)
  → 1 query: đếm leads, deals, revenue, cost
  → ConversionRate = dealsWon / totalLeads * 100
  → ROI = (revenue - cost) / cost * 100
  → Profit/Loss = revenue - cost

ReportService.getLeadSourceReport(campaignId, source, fromDate, toDate)
  → SELECT ISNULL(l.source, 'Unknown'), COUNT(*) GROUP BY source
  → Tính %: leadCount / total * 100

ReportService.getLeadFunnelReport(campaignId, fromDate, toDate)
  → SELECT COUNT(*) WHERE status IN (NEW_LEAD, CONTACTED, QUALIFIED, DEAL_CREATED, LOST)

ReportService.getDealResultReport(campaignId, fromDate, toDate)
  → Deals Won | Deals Lost | Total Deals

ReportService.getCampaignPerformancePaginated(campaignId, fromDate, toDate, offset, limit)
  → LEFT JOIN Campaigns → Leads → Deals
  → GROUP BY campaign: totalLeads, dealsWon, dealsLost, revenue, cost
  → ConversionRate = dealsWon / totalLeads * 100
  → ROI = (revenue - cost) / cost * 100
       ↓
campaign_report.jsp renders:
  ├─ Filter panel: campaign, source, fromDate, toDate
  ├─ 8 KPI cards: Total Leads, Deals Created, Deals Won, Conversion%, Revenue, Cost, ROI, Profit/Loss
  ├─ Lead Source doughnut chart (Chart.js)
  ├─ Deal Result bar chart (Chart.js) + Win rate bar
  ├─ Lead Funnel horizontal bars (5 stages)
  └─ Campaign Performance table + pagination
```

---

## 6. DAO LAYER — SQL QUERY REFERENCE

### 6.1 CampaignDAO

```sql
-- Search + Pagination (SQL Server OFFSET/FETCH)
SELECT * FROM Campaigns
WHERE 1=1
  AND name LIKE ?           -- '%searchName%'
  AND status IN (?,?)       -- status aliases (ACTIVE, Running)
ORDER BY updated_at DESC
OFFSET (page-1)*pageSize ROWS FETCH NEXT pageSize ROWS ONLY

-- Count for pagination
SELECT COUNT(*) FROM Campaigns WHERE 1=1 AND name LIKE ? AND status IN (...)

-- Status aliases (hỗ trợ cả UPPERCASE và PascalCase)
"ACTIVE"    → ["ACTIVE", "Running"]
"PLANNING"  → ["PLANNING", "Planned", "PLANNED"]
"PAUSED"    → ["PAUSED", "Paused"]
"COMPLETED" → ["COMPLETED", "Completed"]
```

### 6.2 LeadDAO

```sql
-- Search: mỗi email = 1 dòng (MIN lead_id per email)
SELECT l.*,
  (SELECT STUFF(
    (SELECT DISTINCT ' | ' + c.name
     FROM Campaign_Leads cl
     INNER JOIN Campaigns c ON cl.campaign_id = c.campaign_id
     WHERE cl.lead_id IN (SELECT lead_id FROM Leads WHERE email = l.email)
     FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, '')
  ) AS campaign_names
FROM Leads l
WHERE l.lead_id IN (SELECT MIN(lead_id) FROM Leads GROUP BY email)
  AND l.email IN (SELECT email FROM Leads INNER JOIN Campaign_Leads ON ... WHERE campaign_id = ?)  -- filter
  AND (l.full_name LIKE ? OR l.email LIKE ? OR l.phone LIKE ?)  -- keyword
  AND l.status = ?   -- status filter
ORDER BY l.updated_at DESC
OFFSET (page-1)*pageSize ROWS FETCH NEXT pageSize ROWS ONLY

-- Count: GROUP BY email only (đúng 1 nhóm per người)
SELECT COUNT(*) FROM (
  SELECT MIN(lead_id) FROM Leads
  WHERE 1=1 [filters]
  GROUP BY email
) AS base

-- Email deduplication: KHÔNG dùng GROUP BY email, status, full_name (sai)
-- Vì: cùng email có nhiều row với status khác nhau → COUNT ra nhiều hơn thực tế
```

### 6.3 CampaignLeadDAO

```sql
-- Đếm leads theo campaign (DÙNG BẢNG NÀY, không dùng Leads.campaign_id)
SELECT COUNT(*) FROM Campaign_Leads WHERE campaign_id = ?

-- Lấy campaigns của lead theo EMAIL (cho lead detail)
SELECT DISTINCT c.* FROM Campaign_Leads cl
INNER JOIN Campaigns c ON cl.campaign_id = c.campaign_id
WHERE cl.lead_id IN (
  SELECT lead_id FROM Leads WHERE email = (SELECT email FROM Leads WHERE lead_id = ?)
)
-- Vì: leadId trên URL có thể chỉ thuộc 1 campaign trong Campaign_Leads
-- (list dùng MIN(lead_id) per email → leadId đó chỉ có 1 row)
-- → Cần query qua TẤT CẢ lead_id cùng email để lấy đủ campaigns
```

### 6.4 CampaignReportDAO

```sql
-- Campaign Performance: LEFT JOIN Campaigns → Leads → Deals
SELECT
  c.name AS campaign_name,
  COUNT(DISTINCT l.lead_id) AS total_leads,
  COUNT(DISTINCT d.deal_id) AS deals_created,
  SUM(CASE WHEN d.stage='Closed Won' THEN 1 ELSE 0 END) AS deals_won,
  SUM(CASE WHEN d.stage='Closed Won' THEN ISNULL(d.actual_value,0) ELSE 0 END) AS revenue,
  SUM(c.budget) AS cost
FROM Campaigns c
LEFT JOIN Leads l ON l.campaign_id = c.campaign_id
LEFT JOIN Deals d ON d.lead_id = l.lead_id
WHERE 1=1 [campaignId, fromDate, toDate filters]
GROUP BY c.campaign_id, c.name

-- ConversionRate = dealsWon * 100 / totalLeads (%)
-- ROI = (revenue - cost) * 100 / cost (%)
```

---

## 7. SERVICE LAYER — METHOD REFERENCE

### 7.1 CampaignService

| Method                                          | Mô tả                      |
| ----------------------------------------------- | -------------------------- |
| `createCampaign(Campaign)`                      | Tạo mới + basic validation |
| `updateCampaign(Campaign)`                      | Cập nhật                   |
| `getCampaignById(int)`                          | Lấy 1 campaign             |
| `getAllCampaigns()`                             | Tất cả                     |
| `getActiveCampaigns()`                          | Lọc status = ACTIVE        |
| `searchCampaigns(name, status)`                 | Tìm không phân trang       |
| `searchCampaigns(name, status, page, pageSize)` | Tìm + phân trang           |
| `countCampaigns(name, status)`                  | Đếm (cho pagination)       |

### 7.2 LeadService

| Method                                       | Mô tả                              |
| -------------------------------------------- | ---------------------------------- |
| `searchLeads(...)`                           | Tìm + phân trang                   |
| `countLeads(...)`                            | Đếm                                |
| `searchLeadsForExport(...)`                  | Tìm cho export (LIMIT 10000)       |
| `createLead(Lead)`                           | Tạo + auto-score                   |
| `updateLead(Lead)`                           | Cập nhật + auto-score              |
| `updateLeadCampaigns(leadId, List<Integer>)` | Cập nhật multi-campaign membership |
| `validateLeadUniqueness(Lead)`               | Kiểm tra trùng email/phone         |
| `scoreLead(int, score)`                      | Cập nhật điểm + xác định status    |
| `getCampaignsByLeadId(int)`                  | Lấy campaigns của lead             |
| `getLeadById(int)`                           | Lấy 1 lead                         |

### 7.3 ReportService

| Method                                              | Mô tả                               |
| --------------------------------------------------- | ----------------------------------- |
| `generateReport(campaignId)`                        | Sinh CampaignReport cho 1 campaign  |
| `getMarketingReportKpi(campaignId, from, to)`       | KPI tổng                            |
| `getLeadSourceReport(campaignId, source, from, to)` | Nguồn leads                         |
| `getLeadFunnelReport(campaignId, from, to)`         | Phễu leads                          |
| `getDealResultReport(campaignId, from, to)`         | Deals Won/Lost                      |
| `getCampaignPerformance(campaignId, from, to)`      | Tất cả campaigns (không phân trang) |
| `getCampaignPerformancePaginated(...)`              | Có phân trang                       |

### 7.4 LeadImportService

| Method                                                       | Mô tả                                |
| ------------------------------------------------------------ | ------------------------------------ |
| `importLeads(List<Lead>, source, campaignId, assignedToIds)` | Import batch, trả ImportLeadResponse |

---

## 8. VALIDATION RULES

### 8.1 Campaign Create

| Field      | Rule                           | Error Message                                |
| ---------- | ------------------------------ | -------------------------------------------- |
| Name       | Not null, not blank            | "Campaign name is required"                  |
| Budget     | > 0, valid BigDecimal          | "Budget must be a positive number."          |
| Start Date | Not null, ≥ today              | "Start date must be today or a future date." |
| End Date   | Not null, ≥ today, > startDate | "End date must be after start date."         |
| Channel    | Not null                       | "Marketing channel is not empty."            |

### 8.2 Lead Create/Update

| Field     | Rule                        | Error Message                                                       |
| --------- | --------------------------- | ------------------------------------------------------------------- |
| Full Name | Not null, not blank         | "Full name is required."                                            |
| Email     | Valid format + uniqueness   | "Email is required." / "Email ... already exists in this campaign." |
| Phone     | Valid VN phone (10 digits)  | "Phone number must contain exactly 10 digits."                      |
| Score     | 0-100 (auto hoặc manual)    | "Score must be between 0-100"                                       |
| Campaign  | Valid campaignId (optional) | "Campaign does not exist."                                          |

### 8.3 Lead Import

| Row                  | Error                                                         |
| -------------------- | ------------------------------------------------------------- |
| Name rỗng            | "missing full name"                                           |
| Email rỗng           | "missing email"                                               |
| Email sai format     | "email is not in the correct format (e.g., name@company.com)" |
| Trùng trong file     | "Duplicate email in the file"                                 |
| Trùng trong campaign | "Customer already exists in the campaign"                     |
| Không hỗ trợ format  | "Only .xlsx files are supported"                              |

---

## 9. LAYOUT SYSTEM

### 9.1 Master Layout (`layout.jsp`)

```jsp
<!-- Dynamic attributes từ Controller -->
${pageTitle}         → <title>
${contentPage}       → <jsp:include page="${contentPage}" />
${pageCss}           → <link href="...${pageCss}?v=...">
${pageJs}            → <script src="...${pageJs}?v=...">
${page}              → active sidebar marker
```

```java
// Controller wiring pattern
request.setAttribute("pageTitle", "Danh sách Campaign");
request.setAttribute("contentPage", "marketing/campaign/campaign_list.jsp");
request.setAttribute("pageCss", "campaign_list.css");
request.setAttribute("page", "campaign-list");
request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
```

### 9.2 Sidebar — Role-Based

```jsp
<c:set var="userRole" value="${sessionScope.user.role.roleName}" />
<c:choose>
  <c:when test="${userRole eq 'MARKETING'}">
    <c:set var="rolePrefix" value="/marketing" />
  </c:when>
  ...
</c:choose>

<!-- Active highlight -->
<li>
  <a class="${page eq 'campaign-list' ? 'active' : ''}"
     href="${pageContext.request.contextPath}/marketing/campaign">
    Campaign List
  </a>
</li>
```

**Sidebar menu structure:**

```
Dashboard                          → /marketing/dashboard
Campaign
  ├─ Campaign List                → /marketing/campaign
  ├─ Add New Campaign            → /marketing/campaign/form
  └─ Campaign Update             → /marketing/campaign
Leads
  ├─ Leads List                  → /marketing/leads
  ├─ Add New Lead                → /marketing/leads/form
  └─ Import Leads                → /marketing/leads/import
Marketing Reports
  └─ View Reports                → /marketing/report
```

### 9.3 Pagination Component (`pagination.jsp`)

```jsp
<%-- Yêu cầu: request attribute "pagination" (Pagination DTO) --%>
<jsp:include page="/view/components/pagination.jsp" />

<script>
  // Giữ nguyên query params: page, pageSize
  function paginationGoToPage(page) { ... }
  function paginationChangePageSize(size) { ... }
</script>
```

---

## 10. CSS CLASS REFERENCE

### 10.1 Lead Score Badges

```html
.score-badge.score-hot (≥70) → Đỏ: #f8d7da / #721c24 .score-badge.score-warm
(40-69) → Vàng: #fff3cd / #856404 .score-badge.score-cold (<40) → Xanh: #d1ecf1
/ #0c5460
```

### 10.2 Lead Status Badges

```html
.badge-status.badge-new NEW_LEAD → Xanh nhạt .badge-status.badge-contacted
NURTURING → Vàng .badge-status.badge-qualified QUALIFIED → Xanh lá
.badge-status.badge-deal DEAL_CREATED → Xanh .badge-status.badge-lost LOST → Đỏ
```

### 10.3 Campaign Status Badges

```html
.badge-status.badge-active ACTIVE → Xanh lá .badge-status.badge-planning
PLANNING → Xanh dương .badge-status.badge-paused PAUSED → Vàng
.badge-status.badge-completed COMPLETED → Xám
```

### 10.4 Dashboard (Enterprise UI)

Custom design system (không dùng Bootstrap mặc định):

```html
.stat-card.stat-primary → Xanh dương (#0a66c2) .stat-card.stat-success → Xanh lá
(#15803d) .stat-card.stat-warning → Cam (#b45309) .stat-card.stat-danger → Đỏ
(#b91c1c) .stat-card.stat-info → Cyan (#0891b2) .stat-card.stat-purple → Tím
(#6d28d9)
```

---

## 11. CÁC CÂU HỎI PHẢN BIỆN THƯỜNG GẶP

### Q1: Tại sao dùng Service Layer? Sao không để logic trong Controller?

**A:**

- **Single Responsibility:** Controller chỉ nhận request → gọi service → trả response. Không chứa business logic.
- **Tái sử dụng:** Nếu có REST API (VD: mobile app), dùng chung Service với Web Controller
- **Dễ test:** Unit test Service không cần HTTP request, servlet container
- **Clean Controller:** Controller chỉ ~50-80 dòng, dễ đọc

### Q2: Phân biệt Campaign và Lead? Quan hệ giữa chúng?

**A:**

- **Campaign:** Chiến dịch marketing (VD: "Black Friday 2026", "Email Spring Sale")
- **Lead:** Người quan tâm thu được từ campaign (VD: email, phone khách đăng ký)
- **Quan hệ:** Nhiều-Nhiều qua bảng `Campaign_Leads`
  - 1 Campaign có N Leads
  - 1 Lead có thể tham gia N Campaigns (VD: cùng email đăng ký nhiều campaign)
- **Khác:** Lead sau chuyển thành Customer → Deal → Doanh thu

### Q3: Email deduplication là gì? Tại sao cần?

**A:**

- Trong DB, cùng 1 email có thể tồn tại nhiều row `Leads` (mỗi campaign tạo 1 row riêng)
- UI chỉ hiển thị 1 dòng per email (dùng `MIN(lead_id) GROUP BY email`)
- Import: cùng email = cùng 1 người → không tạo lead mới, chỉ gắn campaign
- Lợi ích: tránh spam danh sách, đúng 1 đại diện per khách hàng

### Q4: Lead Scoring hoạt động thế nào?

**A:**

- Dựa trên 5 tiêu chí: họ tên (+20), email (+20), phone (+20), campaign (+10), interest (+10)
- Max 80 điểm → tự động xác định status:
  - ≥70 → QUALIFIED (tiềm năng cao)
  - 40-69 → NURTURING (đang nuôi dưỡng)
  - 20-39 → NEW_LEAD (mới)
  - <20 → LOST (không tiềm năng)
- Điểm cập nhật khi: tạo mới, cập nhật, import, chấm điểm thủ công

### Q5: Tại sao đếm leads theo campaign phải qua bảng Campaign_Leads?

**A:**

- `Leads.campaign_id` chỉ lưu campaign **đầu tiên** (campaign được gán đầu tiên khi import)
- 1 Lead tham gia nhiều campaign → `Leads.campaign_id` chỉ phản ánh 1 trong N
- `Campaign_Leads`: mỗi row = 1 lead thuộc 1 campaign → đếm chính xác
- VD: Lead A tham gia campaign B và C → Leads.campaign_id = B, nhưng Campaign_Leads có 2 rows → đúng

### Q6: Tính năng nào làm em tự hào nhất?

**Gợi ý (chọn 1-2):**

1. **Lead Scoring tự động** — hệ thống chấm điểm lead 0-80 dựa trên thông tin đã cung cấp, tự động xác định status
2. **Import Excel thông minh** — nhận diện lead đã tồn tại, chỉ gắn campaign, tránh trùng lặp, log activity
3. **Multi-Campaign Assignment** — 1 lead có thể tham gia nhiều campaign, hiển thị đầy đủ danh sách campaigns
4. **Marketing Report có Chart.js** — KPI, Lead Source doughnut, Deal Result bar, Lead Funnel

---

## 12. TROUBLESHOOTING

### Pagination không hiển thị

```
1. Controller: request.setAttribute("pagination", pagination) đã chạy?
2. JSP: <jsp:include page="/view/components/pagination.jsp" /> có trong trang?
3. Condition: ${pagination.totalItems > 0} → = 0 thì không hiển thị
```

### Lead không hiện trong campaign

```
1. Đếm leads phải qua Campaign_Leads, không qua Leads.campaign_id
2. Kiểm tra: CampaignLeadDAO.countTotalLeadsByCampaign(campaignId)
3. Import: email đã tồn tại trong campaign chưa? (emailsInCampaign Set)
```

### Import Excel lỗi

```
1. File phải .xlsx (Apache POI XSSF), không hỗ trợ .xls
2. Header row: 4 cột (fullName | email | phone | interest)
3. Email phải unique trong file và trong campaign
4. Check: web.xml có <multipart-config>?
```

### Campaign Detail stats = 0

```
1. Kiểm tra: CampaignLeadDAO có data trong Campaign_Leads?
2. generateReport() dùng CampaignLeadDAO, không dùng Leads.campaign_id
3. Check: leads có được gắn vào campaign qua Campaign_Leads?
```

### Multi-campaign checkbox không lưu

```
1. Form: name="selectedCampaigns" (array checkbox)
2. Controller: request.getParameterValues("selectedCampaigns")
3. Service: updateLeadCampaigns() so sánh current vs new → INSERT/DELETE
```

---

## 13. NEXT STEPS — TODO

| #   | Mô tả                     | Ghi chú                                              |
| --- | ------------------------- | ---------------------------------------------------- |
| 1   | Implement Delete campaign | Xem campaign_detail.jsp có delete modal + JS         |
| 2   | Chuẩn hóa breadcrumbs     | campaign_detail có sẵn, form/list/chưa đủ            |
| 3   | Lead Score JSP view       | LeadScoreController đã có (POST API), cần page riêng |
| 4   | RESTful URL refactor      | Optional, hiện dùng path-based đủ tốt                |
| 5   | Unit tests                | Service layer dễ viết JUnit nhất                     |

---

**Created:** March 1, 2026
**Last Updated:** March 28, 2026
**Status:** ✅ MODULE COMPLETE — SẴN SÀNG PHẢN BIỆN
