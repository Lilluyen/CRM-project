-- ============================================================
-- FILE 07: TASK & ACTIVITIES IMPROVEMENT
-- ============================================================
-- Mục tiêu:
--   A. Loại bỏ duplicate indexes (trùng lặp cột, tốn bộ nhớ vô ích)
--   B. Bổ sung Activities: entity_type + entity_id (liên kết task/deal/ticket)
--   C. Bổ sung Tasks: related_type + related_id + cancelled_at
--   D. Bổ sung Task_History: cột action (nhãn sự kiện audit)
--   E. Bổ sung Task_Assignees: assigned_by + is_active (hỗ trợ reassign)
--   F. Tạo mới bảng Task_Comments (kịch bản comment task)
--   G. Tạo indexes tối ưu cho timeline query và audit
--
-- Quy tắc áp dụng:
--   → Gỡ CONSTRAINT / FK trước → rồi mới DROP cột / bảng / index
--   → Không DROP dữ liệu hiện có, chỉ ALTER / ADD
-- ============================================================

USE [CRM_System]
GO

-- ============================================================
-- A. XÓA DUPLICATE INDEXES
-- ============================================================
-- Vấn đề:
--   Trong file 03, hai cặp index bị tạo hai lần với cùng key columns:
--
--   1) Customer_Measurements:
--      IX_Customer_Measurements_customer_measured  ← trùng
--      IX_Measurements_Latest                      ← giữ lại (tên rõ nghĩa hơn,
--                                                              được dùng trong stored procs)
--
--   2) Customer_Style_Map:
--      IX_Customer_Style_Map_customer              ← trùng
--      IX_StyleMap                                 ← giữ lại
--
-- → Mỗi index thừa làm tốn write I/O mỗi khi INSERT/UPDATE mà không
--   tăng thêm coverage hay performance cho SELECT nào.
-- ============================================================

-- A1. Xóa duplicate index trên Customer_Measurements
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Customer_Measurements')
      AND name = 'IX_Customer_Measurements_customer_measured'
)
    DROP INDEX [IX_Customer_Measurements_customer_measured]
        ON [dbo].[Customer_Measurements];
GO

-- A2. Xóa duplicate index trên Customer_Style_Map
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Customer_Style_Map')
      AND name = 'IX_Customer_Style_Map_customer'
)
    DROP INDEX [IX_Customer_Style_Map_customer]
        ON [dbo].[Customer_Style_Map];
GO


-- ============================================================
-- B. BẢNG Activities — BỔ SUNG entity_type + entity_id
-- ============================================================
-- Vấn đề hiện tại:
--   Activities chỉ có related_type/related_id (entity CRM context: customer/lead)
--   nhưng KHÔNG có cách nào biết activity này phát sinh từ Task nào,
--   Deal nào, hay Ticket nào → không thể render đúng timeline.
--
-- Ví dụ kịch bản yêu cầu:
--   activity_type = 'task_created'
--   related_type  = 'customer',  related_id = 5    ← khách hàng liên quan
--   entity_type   = 'task',      entity_id  = 42   ← task phát sinh activity
--
--   activity_type = 'deal_created'
--   related_type  = 'customer',  related_id = 5
--   entity_type   = 'deal',      entity_id  = 7
--
--   activity_type = 'ticket_opened'
--   related_type  = 'customer',  related_id = 5
--   entity_type   = 'ticket',    entity_id  = 3
--
-- Thiết kế:
--   entity_type VARCHAR(50): 'task' | 'deal' | 'ticket' | 'lead' | NULL
--   entity_id   INT        : PK của entity tương ứng (polymorphic, không FK cứng)
--   Không đặt FK vật lý vì entity_type là polymorphic; tính toàn vẹn
--   được bảo đảm ở tầng application / stored procedure.
-- ============================================================

-- B1. Thêm entity_type
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'entity_type'
)
    ALTER TABLE [dbo].[Activities]
        ADD [entity_type] VARCHAR(50) NULL;
GO

-- B2. Thêm entity_id
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'entity_id'
)
    ALTER TABLE [dbo].[Activities]
        ADD [entity_id] INT NULL;
GO

-- B3. Index cho timeline query (Kịch bản 14 & 16)
--   Query: WHERE related_type = ? AND related_id = ? ORDER BY created_at DESC
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'IX_Activities_Timeline'
)
    CREATE NONCLUSTERED INDEX [IX_Activities_Timeline]
        ON [dbo].[Activities] ([related_type] ASC, [related_id] ASC, [created_at] DESC)
        INCLUDE ([activity_type], [subject], [entity_type], [entity_id], [created_by]);
GO

-- B4. Index tra cứu ngược: từ entity về activities (ví dụ: all activities của task_id = X)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'IX_Activities_EntityLookup'
)
    CREATE NONCLUSTERED INDEX [IX_Activities_EntityLookup]
        ON [dbo].[Activities] ([entity_type] ASC, [entity_id] ASC, [created_at] DESC)
        WHERE [entity_type] IS NOT NULL;
GO


-- ============================================================
-- C. BẢNG Tasks — BỔ SUNG related_type, related_id, cancelled_at
-- ============================================================
-- Vấn đề hiện tại:
--   Tasks không có cột liên kết về entity CRM context → không biết
--   task này phục vụ customer nào / lead nào / deal nào.
--   → Không thể query "tasks của customer 5", không thể tạo đúng
--     Activity khi tạo task (vì không biết related_type/related_id).
--
--   Thêm cancelled_at: Kịch bản 10 (hủy task) cần timestamp hủy
--   nhưng Tasks chỉ có completed_at; trạng thái 'cancelled' không có
--   thời điểm tương ứng để audit chính xác.
--
-- Thiết kế:
--   related_type VARCHAR(50): 'customer' | 'lead' | 'deal' | NULL
--   related_id   INT        : ID tương ứng (polymorphic, không FK cứng)
--   cancelled_at DATETIME   : NULL cho đến khi task bị cancelled
-- ============================================================

-- C1. Thêm related_type
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'related_type'
)
    ALTER TABLE [dbo].[Tasks]
        ADD [related_type] VARCHAR(50) NULL;
GO

-- C2. Thêm related_id
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'related_id'
)
    ALTER TABLE [dbo].[Tasks]
        ADD [related_id] INT NULL;
GO

-- C3. Thêm cancelled_at
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'cancelled_at'
)
    ALTER TABLE [dbo].[Tasks]
        ADD [cancelled_at] DATETIME NULL;
GO

-- C4. Index để query tasks theo entity liên quan
--   Query: WHERE related_type = 'customer' AND related_id = 5
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'IX_Tasks_Related'
)
    CREATE NONCLUSTERED INDEX [IX_Tasks_Related]
        ON [dbo].[Tasks] ([related_type] ASC, [related_id] ASC)
        INCLUDE ([title], [status], [priority], [due_date], [created_by], [created_at]);
GO

-- C5. Index hỗ trợ scheduler kiểm tra task overdue (Kịch bản 9)
--   Query: WHERE due_date < GETDATE() AND status NOT IN ('done','cancelled')
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'IX_Tasks_OverdueCheck'
)
    CREATE NONCLUSTERED INDEX [IX_Tasks_OverdueCheck]
        ON [dbo].[Tasks] ([due_date] ASC, [status] ASC)
        INCLUDE ([task_id], [title], [related_type], [related_id]);
GO


-- ============================================================
-- D. BẢNG Task_History — BỔ SUNG cột action
-- ============================================================
-- Vấn đề hiện tại:
--   Task_History chỉ ghi (task_id, changed_by, changed_at) — không có
--   nhãn sự kiện → không thể biết đây là hành động gì chỉ nhìn vào
--   bảng header; phải luôn JOIN Task_History_Detail mới đọc được.
--
--   Kịch bản yêu cầu ghi rõ:
--     task_created / task_assigned / task_started / task_progress_update /
--     task_completed / task_reopened / task_reassigned / task_overdue /
--     task_cancelled
--
-- Thiết kế:
--   action VARCHAR(50): nhãn sự kiện, NOT NULL với DEFAULT 'update' để
--   tương thích ngược với dữ liệu đã có (các row cũ chưa có nhãn cụ thể).
-- ============================================================

-- D1. Thêm cột action
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_History')
      AND name = 'action'
)
    ALTER TABLE [dbo].[Task_History]
        ADD [action] VARCHAR(50) NOT NULL
            CONSTRAINT [DF_TaskHistory_Action] DEFAULT 'update';
GO

-- D2. Index để query lịch sử của một task theo thời gian (Kịch bản 15)
--   Query: WHERE task_id = ? ORDER BY changed_at DESC
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_History')
      AND name = 'IX_TaskHistory_TaskAudit'
)
    CREATE NONCLUSTERED INDEX [IX_TaskHistory_TaskAudit]
        ON [dbo].[Task_History] ([task_id] ASC, [changed_at] DESC)
        INCLUDE ([action], [changed_by]);
GO


-- ============================================================
-- E. BẢNG Task_Assignees — BỔ SUNG assigned_by + is_active
-- ============================================================
-- Vấn đề hiện tại:
--   Task_Assignees chỉ có (task_id, user_id, assigned_at).
--   Khi reassign (Kịch bản 8):
--     - Không biết ai là người thực hiện giao (assigned_by)
--     - Không phân biệt được assignee hiện tại vs assignee cũ
--       (vì PK là (task_id, user_id) → UPDATE overwrite mất lịch sử)
--
-- Giải pháp:
--   assigned_by INT: FK → Users — người thực hiện giao việc
--   is_active   BIT DEFAULT 1:
--     → 1 = đang được giao (assignee hiện tại)
--     → 0 = đã được unassign / reassign (lịch sử, không xóa)
--
-- Lưu ý: PK (task_id, user_id) đã tồn tại → không thay đổi PK.
--   Trường hợp cùng user được assign lại sau khi unassign: INSERT row
--   mới sẽ bị conflict PK. App cần UPDATE is_active = 1 thay vì INSERT.
--   Nếu cần lịch sử đầy đủ hơn, có thể tách sang bảng Task_Assignee_Log
--   ở giai đoạn sau. Hiện tại is_active đủ cho yêu cầu kịch bản.
-- ============================================================

-- E1. Thêm cột assigned_by
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'assigned_by'
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD [assigned_by] INT NULL;
GO

-- E2. Thêm cột is_active
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'is_active'
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD [is_active] BIT NOT NULL
            CONSTRAINT [DF_TaskAssignees_IsActive] DEFAULT 1;
GO

-- E3. Thêm FK: Task_Assignees.assigned_by → Users
--   (Gỡ FK cũ nếu đã tồn tại tên khác trước khi ADD)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_ta_assigned_by'
      AND parent_object_id = OBJECT_ID('dbo.Task_Assignees')
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD CONSTRAINT [fk_ta_assigned_by]
        FOREIGN KEY ([assigned_by])
        REFERENCES [dbo].[Users] ([user_id]);
GO

-- E4. Index hỗ trợ query "các task đang giao cho user X" (Dashboard)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'IX_TaskAssignees_ActiveUser'
)
    CREATE NONCLUSTERED INDEX [IX_TaskAssignees_ActiveUser]
        ON [dbo].[Task_Assignees] ([user_id] ASC, [is_active] ASC)
        INCLUDE ([task_id], [assigned_at], [assigned_by]);
GO


-- ============================================================
-- F. TẠO MỚI BẢNG Task_Comments
-- ============================================================
-- Kịch bản 5: User thêm comment vào task → cần bảng Task_Comments.
-- Bảng này CHƯA tồn tại trong schema hiện tại.
--
-- Thiết kế:
--   comment_id  : PK identity
--   task_id     : FK → Tasks
--   content     : nội dung comment (NVARCHAR MAX)
--   created_by  : FK → Users (ai comment)
--   created_at  : thời điểm tạo (DEFAULT GETDATE)
--   updated_at  : thời điểm edit lần cuối (NULL = chưa bao giờ edit)
--   parent_id   : FK tự tham chiếu → Task_Comments (hỗ trợ reply comment,
--                 NULL = comment gốc) — tuỳ chọn, để sẵn cho tương lai
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[Task_Comments] (
        [comment_id]  INT            IDENTITY(1,1) NOT NULL,
        [task_id]     INT            NOT NULL,
        [content]     NVARCHAR(MAX)  NOT NULL,
        [created_by]  INT            NOT NULL,
        [created_at]  DATETIME       NOT NULL  CONSTRAINT [DF_TaskComments_CreatedAt] DEFAULT GETDATE(),
        [updated_at]  DATETIME       NULL,
        [parent_id]   INT            NULL,   -- NULL = comment gốc, non-NULL = reply

        CONSTRAINT [PK_Task_Comments] PRIMARY KEY CLUSTERED ([comment_id] ASC)
    );
END
GO

-- F1. FK: Task_Comments.task_id → Tasks
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_task'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_task]
        FOREIGN KEY ([task_id])
        REFERENCES [dbo].[Tasks] ([task_id]);
GO

-- F2. FK: Task_Comments.created_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_user'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_user]
        FOREIGN KEY ([created_by])
        REFERENCES [dbo].[Users] ([user_id]);
GO

-- F3. FK: Task_Comments.parent_id → Task_Comments (self-reference, reply)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_parent'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_parent]
        FOREIGN KEY ([parent_id])
        REFERENCES [dbo].[Task_Comments] ([comment_id]);
GO

-- F4. Index chính: list comments của một task, mới nhất trên cùng
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'IX_TaskComments_Task'
)
    CREATE NONCLUSTERED INDEX [IX_TaskComments_Task]
        ON [dbo].[Task_Comments] ([task_id] ASC, [created_at] ASC)
        INCLUDE ([created_by], [parent_id]);
GO


-- ============================================================
-- TỔNG KẾT CÁC THAY ĐỔI
-- ============================================================
--
-- [DROP]  IX_Customer_Measurements_customer_measured  ← trùng IX_Measurements_Latest
-- [DROP]  IX_Customer_Style_Map_customer               ← trùng IX_StyleMap
--
-- [ALTER] Activities
--           + entity_type  VARCHAR(50) NULL
--           + entity_id    INT NULL
--           + INDEX IX_Activities_Timeline   (related_type, related_id, created_at DESC)
--           + INDEX IX_Activities_EntityLookup (entity_type, entity_id, created_at DESC)
--
-- [ALTER] Tasks
--           + related_type  VARCHAR(50) NULL
--           + related_id    INT NULL
--           + cancelled_at  DATETIME NULL
--           + INDEX IX_Tasks_Related       (related_type, related_id)
--           + INDEX IX_Tasks_OverdueCheck  (due_date, status)
--
-- [ALTER] Task_History
--           + action  VARCHAR(50) NOT NULL DEFAULT 'update'
--           + INDEX IX_TaskHistory_TaskAudit (task_id, changed_at DESC)
--
-- [ALTER] Task_Assignees
--           + assigned_by  INT NULL  FK → Users
--           + is_active    BIT NOT NULL DEFAULT 1
--           + INDEX IX_TaskAssignees_ActiveUser (user_id, is_active)
--
-- [CREATE] Task_Comments
--           comment_id, task_id FK, content, created_by FK, created_at,
--           updated_at, parent_id FK (self-ref)
--           + INDEX IX_TaskComments_Task (task_id, created_at)
--
-- Kịch bản được cover:
--   1  Task created        → Tasks(related_type/related_id) + Activities(entity_type/entity_id)
--   2  Task assigned       → Task_Assignees(assigned_by) + Task_History(action='task_assigned')
--   3  Task started        → Task_History(action='task_started')
--   4  Task progress       → Task_History(action='task_progress_update')
--   5  Task comment        → Task_Comments (bảng mới)
--   6  Task completed      → Task_History(action='task_completed')
--   7  Task reopened       → Task_History(action='task_reopened')
--   8  Task reassigned     → Task_Assignees(is_active=0 old, =1 new) + assigned_by
--   9  Task overdue        → IX_Tasks_OverdueCheck + Task_History(action='task_overdue')
--   10 Task cancelled      → Tasks(cancelled_at) + Task_History(action='task_cancelled')
--   11 Manual activity     → Activities (đã đủ)
--   12 Deal activity       → Activities(entity_type='deal', entity_id=deal_id)
--   13 Ticket activity     → Activities(entity_type='ticket', entity_id=ticket_id)
--   14 Timeline query      → IX_Activities_Timeline
--   15 Task audit          → IX_TaskHistory_TaskAudit + Task_History_Detail
--   16 Dashboard           → Activities ORDER BY created_at DESC
--   17 Notification        → Notifications + Notification_Recipients (đã có)
--   18 Automation          → Task_History(action) + Activities(entity_type/entity_id)
-- ============================================================
