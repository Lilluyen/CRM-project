-- ============================================================
-- FILE 07: TASK + ACTIVITIES + NOTIFICATION IMPROVEMENT
-- Phiên bản: Hợp nhất v2.0
-- Mô tả: Giải quyết tất cả vấn đề trùng lặp, tối ưu thiết kế
--         theo kịch bản CRM trong crm_scenarios_and_constraints.txt
--
-- MỤC TIÊU THIẾT KẾ:
--   1. Task Management: related_type/related_id, cancelled_at, comments
--   2. Activity Timeline: source tracking, performed_by, metadata
--   3. Notification: automation với Rule Engine + Queue
--   4. Xóa trùng lặp: Notification_Rules cũ, duplicate indexes
--   5. Idempotent: chạy nhiều lần không lỗi
--
-- QUY TẮC ÁP DỤNG:
--   → IF NOT EXISTS trước mọi ALTER/CREATE
--   → DROP FK/constraint trước → rồi mới DROP column/table/index
--   → Không DROP dữ liệu hiện có
-- ============================================================

USE [CRM_System]
GO

-- ============================================================
-- PHẦN A: XÓA DUPLICATE INDEXES (Từ file 07 cũ)
-- ============================================================
-- Vấn đề: Trong file 03, hai cặp index bị tạo trùng:
--   1) Customer_Measurements: IX_Customer_Measurements_customer_measured (thừa)
--   2) Customer_Style_Map: IX_Customer_Style_Map_customer (thừa)
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

PRINT 'Hoàn tất Phần A: Xóa duplicate indexes';
GO


-- ============================================================
-- PHẦN B: XÓA BẢNG TRÙNG LẶP - Notification_Rules (cũ)
-- ============================================================
-- Vấn đề: Notification_Rules (từ file 01) thiếu template, escalation,
--          trigger — trùng mục đích với Notification_Rule_Engine
-- Giải pháp: DROP bảng cũ, dùng bảng mới
-- ============================================================

-- B1. Xóa FK trỏ vào Notifications
DECLARE @FKName NVARCHAR(200);
SELECT @FKName = name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('dbo.Notification_Rules')
  AND referenced_object_id = OBJECT_ID('dbo.Notifications');

IF @FKName IS NOT NULL
BEGIN
    EXEC ('ALTER TABLE [dbo].[Notification_Rules] DROP CONSTRAINT [' + @FKName + ']');
    PRINT 'Đã xóa FK: ' + @FKName;
END
GO

-- B2. DROP bảng Notification_Rules
IF OBJECT_ID('dbo.Notification_Rules', 'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[Notification_Rules];
    PRINT 'Đã DROP bảng Notification_Rules (cũ)';
END
ELSE
    PRINT 'Bảng Notification_Rules không tồn tại — bỏ qua.';
GO

PRINT 'Hoàn tất Phần B: Xóa Notification_Rules cũ';
GO


-- ============================================================
-- PHẦN C: BẢNG Tasks — BỔ SUNG related + cancelled_at
-- ============================================================
-- Mục đích (từ Scenario 1):
--   - related_type + related_id: kết task với customer/lead/deal
--   - cancelled_at: timestamp khi task bị hủy (Scenario 10)
--   - CHECK constraint: giới hạn giá trị hợp lệ
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

-- C3. Thêm cancelled_at (Scenario 10: hủy task)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'cancelled_at'
)
    ALTER TABLE [dbo].[Tasks]
        ADD [cancelled_at] DATETIME NULL;
GO

-- C4. CHECK constraint cho related_type
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Tasks_RelatedType'
      AND parent_object_id = OBJECT_ID('dbo.Tasks')
)
    ALTER TABLE [dbo].[Tasks]
        ADD CONSTRAINT [CK_Tasks_RelatedType]
        CHECK ([related_type] IN ('customer', 'lead', 'deal') OR [related_type] IS NULL);
GO

-- C5. Index: query tasks theo entity (Scenario 1, 14)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'IX_Tasks_Related'
)
    CREATE NONCLUSTERED INDEX [IX_Tasks_Related]
        ON [dbo].[Tasks] ([related_type] ASC, [related_id] ASC)
        INCLUDE ([task_id], [title], [status], [priority], [due_date], [created_by], [created_at]);
GO

-- C6. Index: scheduler kiểm tra task overdue (Scenario 9, Reminder)
-- Dùng filtered index — chỉ chứa task chưa hoàn thành
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Tasks')
      AND name = 'IX_Tasks_DueDate_Status'
)
    CREATE NONCLUSTERED INDEX [IX_Tasks_DueDate_Status]
        ON [dbo].[Tasks] ([due_date] ASC, [status] ASC)
        INCLUDE ([task_id], [title], [related_type], [related_id])
        WHERE [status] <> 'completed'
  AND [status] <> 'cancelled';
GO

PRINT 'Hoàn tất Phần C: Tasks';
GO


-- ============================================================
-- PHẦN D: BẢNG Activities — BỔ SUNG source tracking
-- ============================================================
-- Mục đích (từ Scenario Activity Timeline):
--   - source_type + source_id: trace nguồn event (task/deal/ticket)
--   - performed_by: người thực sự thực hiện (khác với created_by)
--   - metadata: JSON context động (call duration, deal value...)
--   - updated_at: audit timestamp
-- ============================================================

-- D1. Thêm source_type
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'source_type'
)
    ALTER TABLE [dbo].[Activities]
        ADD [source_type] VARCHAR(50) NULL;
GO

-- D2. Thêm source_id
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'source_id'
)
    ALTER TABLE [dbo].[Activities]
        ADD [source_id] INT NULL;
GO

-- D3. Thêm performed_by (FK → Users)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'performed_by'
)
    ALTER TABLE [dbo].[Activities]
        ADD [performed_by] INT NULL;
GO

-- D4. Thêm metadata (JSON context)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'metadata'
)
    ALTER TABLE [dbo].[Activities]
        ADD [metadata] NVARCHAR(MAX) NULL;
GO

-- D5. Thêm updated_at
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'updated_at'
)
    ALTER TABLE [dbo].[Activities]
        ADD [updated_at] DATETIME NULL;
GO

-- D6. CHECK constraint cho source_type
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Activities_SourceType'
      AND parent_object_id = OBJECT_ID('dbo.Activities')
)
    ALTER TABLE [dbo].[Activities]
        ADD CONSTRAINT [CK_Activities_SourceType]
        CHECK ([source_type] IN ('task', 'deal', 'lead', 'customer', 'system', 'manual') OR [source_type] IS NULL);
GO

-- D7. FK: performed_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_activities_performed_by'
      AND parent_object_id = OBJECT_ID('dbo.Activities')
)
    ALTER TABLE [dbo].[Activities]
        ADD CONSTRAINT [fk_activities_performed_by]
        FOREIGN KEY ([performed_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- D8. Index: timeline query theo related entity (Scenario 14, 16)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'IX_Activities_Related_Date'
)
    CREATE NONCLUSTERED INDEX [IX_Activities_Related_Date]
        ON [dbo].[Activities] ([related_type] ASC, [related_id] ASC, [activity_date] DESC)
        INCLUDE ([activity_id], [activity_type], [subject], [created_by]);
GO

-- D9. Index: tra cứu ngược từ source (Scenario 18: automation)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Activities')
      AND name = 'IX_Activities_Source'
)
    CREATE NONCLUSTERED INDEX [IX_Activities_Source]
        ON [dbo].[Activities] ([source_type] ASC, [source_id] ASC)
        INCLUDE ([activity_id], [activity_type], [activity_date])
        WHERE [source_type] IS NOT NULL;
GO

PRINT 'Hoàn tất Phần D: Activities';
GO


-- ============================================================
-- PHẦN E: BẢNG Task_History — BỔ SUNG action + note
-- ============================================================
-- Mục đích (Scenario 1-6):
--   - action: loại thay đổi (created, assigned, completed, cancelled...)
--   - note: ghi chú thêm từ người thực hiện
-- ============================================================

-- E1. Thêm action
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_History')
      AND name = 'action'
)
    ALTER TABLE [dbo].[Task_History]
        ADD [action] VARCHAR(50) NOT NULL
            CONSTRAINT [DF_TaskHistory_Action] DEFAULT 'update';
GO

-- E2. Thêm note
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_History')
      AND name = 'note'
)
    ALTER TABLE [dbo].[Task_History]
        ADD [note] NVARCHAR(500) NULL;
GO

-- E3. CHECK constraint cho action
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_TaskHistory_Action'
      AND parent_object_id = OBJECT_ID('dbo.Task_History')
)
    ALTER TABLE [dbo].[Task_History]
        ADD CONSTRAINT [CK_TaskHistory_Action]
        CHECK ([action] IN (
            'created', 'status_changed', 'assigned', 'unassigned',
            'progress_updated', 'completed', 'cancelled',
            'due_date_changed', 'priority_changed', 'reopened', 'update'
        ) OR [action] IS NULL);
GO

-- E4. Index: query lịch sử task theo thời gian (Scenario 15)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_History')
      AND name = 'IX_TaskHistory_Task_Time'
)
    CREATE NONCLUSTERED INDEX [IX_TaskHistory_Task_Time]
        ON [dbo].[Task_History] ([task_id] ASC, [changed_at] DESC)
        INCLUDE ([action], [changed_by]);
GO

PRINT 'Hoàn tất Phần E: Task_History';
GO


-- ============================================================
-- PHẦN F: BẢNG Task_Assignees — BỔ SUNG assigned_by + is_primary
-- ============================================================
-- Mục đích (Scenario 2, 8):
--   - assigned_by: ai giao task (manager)
--   - is_primary: phân biệt người phụ trách chính
--   - removed_at: soft delete khi unassign
-- ============================================================

-- F1. Thêm assigned_by
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'assigned_by'
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD [assigned_by] INT NULL;
GO

-- F2. Thêm is_primary
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'is_primary'
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD [is_primary] BIT NOT NULL
            CONSTRAINT [DF_TaskAssignees_IsPrimary] DEFAULT 0;
GO

-- F3. Thêm removed_at
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'removed_at'
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD [removed_at] DATETIME NULL;
GO

-- F4. FK: assigned_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_ta_assigned_by'
      AND parent_object_id = OBJECT_ID('dbo.Task_Assignees')
)
    ALTER TABLE [dbo].[Task_Assignees]
        ADD CONSTRAINT [fk_ta_assigned_by]
        FOREIGN KEY ([assigned_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- F5. Index: query "các task đang giao cho user X" (Dashboard)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Assignees')
      AND name = 'IX_TaskAssignees_ActiveUser'
)
    CREATE NONCLUSTERED INDEX [IX_TaskAssignees_ActiveUser]
        ON [dbo].[Task_Assignees] ([user_id] ASC, [is_primary] ASC, [removed_at] ASC)
        INCLUDE ([task_id], [assigned_at], [assigned_by]);
GO

PRINT 'Hoàn tất Phần F: Task_Assignees';
GO


-- ============================================================
-- PHẦN G: BẢNG Notifications — BỔ SUNG scheduling + priority
-- ============================================================
-- Mục đích (Notification Scenarios):
--   - priority: độ ưu tiên (low/normal/high/urgent)
--   - status: vòng đời (draft/pending/sent/failed/cancelled)
--   - scheduled_at: gửi theo lịch
--   - created_by: ai tạo notification
--   - expires_at: hết hạn
-- ============================================================

-- G1. Thêm priority
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'priority'
)
    ALTER TABLE [dbo].[Notifications]
        ADD [priority] VARCHAR(20) NOT NULL DEFAULT 'normal';
GO

-- G2. Thêm status
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'status'
)
    ALTER TABLE [dbo].[Notifications]
        ADD [status] VARCHAR(20) NOT NULL DEFAULT 'pending';
GO

-- G3. Thêm scheduled_at
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'scheduled_at'
)
    ALTER TABLE [dbo].[Notifications]
        ADD [scheduled_at] DATETIME NULL;
GO

-- G4. Thêm created_by
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'created_by'
)
    ALTER TABLE [dbo].[Notifications]
        ADD [created_by] INT NULL;
GO

-- G5. Thêm expires_at
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'expires_at'
)
    ALTER TABLE [dbo].[Notifications]
        ADD [expires_at] DATETIME NULL;
GO

-- G6. CHECK constraint cho priority
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Notifications_Priority'
      AND parent_object_id = OBJECT_ID('dbo.Notifications')
)
    ALTER TABLE [dbo].[Notifications]
        ADD CONSTRAINT [CK_Notifications_Priority]
        CHECK ([priority] IN ('low', 'normal', 'high', 'urgent'));
GO

-- G7. CHECK constraint cho status
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Notifications_Status'
      AND parent_object_id = OBJECT_ID('dbo.Notifications')
)
    ALTER TABLE [dbo].[Notifications]
        ADD CONSTRAINT [CK_Notifications_Status]
        CHECK ([status] IN ('draft', 'pending', 'sent', 'failed', 'cancelled'));
GO

-- G8. FK: created_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_notifications_created_by'
      AND parent_object_id = OBJECT_ID('dbo.Notifications')
)
    ALTER TABLE [dbo].[Notifications]
        ADD CONSTRAINT [fk_notifications_created_by]
        FOREIGN KEY ([created_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- G9. Index: scheduler poll notification (Reminder, Condition-based)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notifications')
      AND name = 'IX_Notifications_Scheduler'
)
    CREATE NONCLUSTERED INDEX [IX_Notifications_Scheduler]
        ON [dbo].[Notifications] ([status] ASC, [scheduled_at] ASC)
        WHERE [status] IN ('pending', 'failed');
GO

PRINT 'Hoàn tất Phần G: Notifications';
GO


-- ============================================================
-- PHẦN H: BẢNG Task_Comments — TẠO MỚI HOẶC CẬP NHẬT
-- ============================================================
-- Mục đích (Scenario 5, Scenario 6):
--   - Comment trong task để collaboration
--   - Soft delete (is_deleted)
--   - Reply support (parent_comment_id)
--   - Tương thích với file 08: assigned_to, is_completed, completed_at
-- ============================================================

-- H1. Tạo bảng mới nếu chưa tồn tại
IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[Task_Comments] (
        [comment_id]          INT IDENTITY(1,1) NOT NULL,
        [task_id]             INT NOT NULL,
        [created_by]          INT NOT NULL,           -- Đổi từ user_id để nhất quán
        [content]             NVARCHAR(MAX) NOT NULL,
        [parent_comment_id]   INT NULL,
        [is_deleted]          BIT NOT NULL DEFAULT 0,  -- Soft delete
        [created_at]         DATETIME NOT NULL DEFAULT GETDATE(),
        [updated_at]          DATETIME NULL,

        CONSTRAINT [PK_Task_Comments] PRIMARY KEY CLUSTERED ([comment_id] ASC)
    );
    PRINT 'Đã tạo bảng Task_Comments';
END
ELSE
    PRINT 'Bảng Task_Comments đã tồn tại — bỏ qua tạo mới.';
GO

-- H2. Thêm cột assigned_to (từ file 08)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'assigned_to'
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD [assigned_to] INT NULL;
GO

-- H3. Thêm cột is_completed (từ file 08)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'is_completed'
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD [is_completed] BIT NOT NULL DEFAULT 0;
GO

-- H4. Thêm cột completed_at (từ file 08)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'completed_at'
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD [completed_at] DATETIME NULL;
GO

-- H5. FK: task_id → Tasks
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_task'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_task]
        FOREIGN KEY ([task_id]) REFERENCES [dbo].[Tasks] ([task_id]);
GO

-- H6. FK: created_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_user'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_user]
        FOREIGN KEY ([created_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- H7. FK: parent_comment_id → Task_Comments (self-reference)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tc_parent'
      AND parent_object_id = OBJECT_ID('dbo.Task_Comments')
)
    ALTER TABLE [dbo].[Task_Comments]
        ADD CONSTRAINT [fk_tc_parent]
        FOREIGN KEY ([parent_comment_id]) REFERENCES [dbo].[Task_Comments] ([comment_id]);
GO

-- H8. Index: query comments của một task (Scenario 5)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'IX_TaskComments_Task'
)
    CREATE NONCLUSTERED INDEX [IX_TaskComments_Task]
        ON [dbo].[Task_Comments] ([task_id] ASC, [created_at] ASC)
        WHERE [is_deleted] = 0;
GO

-- H9. Index: progress calculation (từ file 08)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Comments')
      AND name = 'IX_TaskComments_Progress'
)
    CREATE NONCLUSTERED INDEX [IX_TaskComments_Progress]
        ON [dbo].[Task_Comments] ([task_id], [is_deleted], [is_completed]);
GO

PRINT 'Hoàn tất Phần H: Task_Comments';
GO


-- ============================================================
-- PHẦN I: BẢNG Task_Reminders — TẠO MỚI
-- ============================================================
-- Mục đích (Reminder Notification Scenario):
--   - Lưu lịch nhắc cụ thể cho từng task
--   - Hỗ trợ nhiều reminder/task (vd: nhắc 1 ngày trước VÀ 2 giờ trước)
--   - Không thay thế bằng Rule Engine — dùng cho reminder cá nhân
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.Task_Reminders')
      AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[Task_Reminders] (
        [reminder_id]            INT IDENTITY(1,1) NOT NULL,
        [task_id]                INT NOT NULL,
        [remind_before_value]    INT NOT NULL,
        [remind_before_unit]     VARCHAR(20) NOT NULL DEFAULT 'day',
        [remind_at]              DATETIME NOT NULL,
        [is_sent]                BIT NOT NULL DEFAULT 0,
        [sent_at]                DATETIME NULL,
        [created_by]             INT NULL,
        [created_at]             DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT [PK_Task_Reminders] PRIMARY KEY CLUSTERED ([reminder_id] ASC)
    );
    PRINT 'Đã tạo bảng Task_Reminders';
END
ELSE
    PRINT 'Bảng Task_Reminders đã tồn tại — bỏ qua tạo mới.';
GO

-- I1. FK: task_id → Tasks
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tr_task'
      AND parent_object_id = OBJECT_ID('dbo.Task_Reminders')
)
    ALTER TABLE [dbo].[Task_Reminders]
        ADD CONSTRAINT [fk_tr_task]
        FOREIGN KEY ([task_id]) REFERENCES [dbo].[Tasks] ([task_id]);
GO

-- I2. FK: created_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_tr_created_by'
      AND parent_object_id = OBJECT_ID('dbo.Task_Reminders')
)
    ALTER TABLE [dbo].[Task_Reminders]
        ADD CONSTRAINT [fk_tr_created_by]
        FOREIGN KEY ([created_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- I3. CHECK constraint cho unit
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_TR_Unit'
      AND parent_object_id = OBJECT_ID('dbo.Task_Reminders')
)
    ALTER TABLE [dbo].[Task_Reminders]
        ADD CONSTRAINT [CK_TR_Unit]
        CHECK ([remind_before_unit] IN ('minute', 'hour', 'day'));
GO

-- I4. Index: scheduler poll reminder chưa gửi (Reminder Scenario)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Task_Reminders')
      AND name = 'IX_TaskReminders_Poll'
)
    CREATE NONCLUSTERED INDEX [IX_TaskReminders_Poll]
        ON [dbo].[Task_Reminders] ([is_sent] ASC, [remind_at] ASC)
        WHERE [is_sent] = 0;
GO

PRINT 'Hoàn tất Phần I: Task_Reminders';
GO


-- ============================================================
-- PHẦN J: BẢNG Notification_Queue — TẠO MỚI
-- ============================================================
-- Mục đích (Notification Scenarios):
--   - Tách tạo notification khỏi gửi notification
--   - Async processing với retry logic
--   - Self-contained: lưu đủ thông tin để gửi mà không cần JOIN
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.Notification_Queue')
      AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[Notification_Queue] (
        [queue_id]           INT IDENTITY(1,1) NOT NULL,
        [notification_id]    INT NULL,                    -- Có thể NULL nếu tạo trực tiếp
        [title]              NVARCHAR(200) NOT NULL,      -- Self-contained
        [content]            NVARCHAR(MAX) NULL,
        [type]               VARCHAR(30) NULL,
        [related_type]       VARCHAR(50) NULL,
        [related_id]         INT NULL,
        [recipient_user_id]  INT NOT NULL,
        [status]             VARCHAR(20) NOT NULL DEFAULT 'pending',
        [priority]           VARCHAR(20) NOT NULL DEFAULT 'normal',
        [scheduled_at]      DATETIME NOT NULL DEFAULT GETDATE(),
        [sent_at]            DATETIME NULL,
        [failed_at]          DATETIME NULL,
        [retry_count]        INT NOT NULL DEFAULT 0,
        [max_retries]        INT NOT NULL DEFAULT 3,
        [error_message]     NVARCHAR(500) NULL,
        [created_at]         DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT [PK_Notification_Queue] PRIMARY KEY CLUSTERED ([queue_id] ASC)
    );
    PRINT 'Đã tạo bảng Notification_Queue';
END
ELSE
    PRINT 'Bảng Notification_Queue đã tồn tại — bỏ qua tạo mới.';
GO

-- J1. FK: notification_id → Notifications (nullable)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_NotificationQueue_Notifications'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Queue')
)
    ALTER TABLE [dbo].[Notification_Queue]
        ADD CONSTRAINT [FK_NotificationQueue_Notifications]
        FOREIGN KEY ([notification_id]) REFERENCES [dbo].[Notifications] ([notification_id]);
GO

-- J2. FK: recipient_user_id → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_NotificationQueue_User'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Queue')
)
    ALTER TABLE [dbo].[Notification_Queue]
        ADD CONSTRAINT [FK_NotificationQueue_User]
        FOREIGN KEY ([recipient_user_id]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- J3. CHECK constraint cho status
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_NQueue_Status'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Queue')
)
    ALTER TABLE [dbo].[Notification_Queue]
        ADD CONSTRAINT [CK_NQueue_Status]
        CHECK ([status] IN ('pending', 'sent', 'failed', 'cancelled'));
GO

-- J4. CHECK constraint cho priority
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_NQueue_Priority'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Queue')
)
    ALTER TABLE [dbo].[Notification_Queue]
        ADD CONSTRAINT [CK_NQueue_Priority]
        CHECK ([priority] IN ('low', 'normal', 'high', 'urgent'));
GO

-- J5. Index: poll pending items cho background job (Realtime, Reminder)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notification_Queue')
      AND name = 'IX_NQueue_Poll'
)
    CREATE NONCLUSTERED INDEX [IX_NQueue_Poll]
        ON [dbo].[Notification_Queue] ([status] ASC, [scheduled_at] ASC, [priority] DESC)
        WHERE [status] = 'pending';
GO

-- J6. Index: retry job cho failed items
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notification_Queue')
      AND name = 'IX_NQueue_Retry'
)
    CREATE NONCLUSTERED INDEX [IX_NQueue_Retry]
        ON [dbo].[Notification_Queue] ([status] ASC, [retry_count] ASC)
        WHERE [status] = 'failed';
GO

-- J7. Index: lịch sử notification của user
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notification_Queue')
      AND name = 'IX_NQueue_Recipient'
)
    CREATE NONCLUSTERED INDEX [IX_NQueue_Recipient]
        ON [dbo].[Notification_Queue] ([recipient_user_id] ASC, [created_at] DESC)
        INCLUDE ([status], [title], [type]);
GO

PRINT 'Hoàn tất Phần J: Notification_Queue';
GO


-- ============================================================
-- PHẦN K: BẢNG Notification_Rule_Engine — TẠO MỚI
-- ============================================================
-- Mục đích (Automation Scenarios - giải quyết Weakness 4,5,6):
--   - Event Trigger: khi event xảy ra → gửi notification
--   - Schedule: cron-based (daily digest, weekly summary)
--   - Condition: kiểm tra định kỳ (customer không contact 7 ngày, deal stuck...)
--   - Escalation: nếu chưa đọc sau N phút → gửi cho manager
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
      AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[Notification_Rule_Engine] (
        [rule_id]                       INT IDENTITY(1,1) NOT NULL,

        -- Mô tả rule
        [rule_name]                     NVARCHAR(100) NOT NULL,
        [rule_type]                     VARCHAR(30) NOT NULL,
        [description]                   NVARCHAR(500) NULL,

        -- Event Trigger fields
        [trigger_event]                 VARCHAR(50) NULL,
        -- VD: 'task_created', 'task_completed', 'deal_won', 'lead_converted'

        -- Condition fields (rule_type = 'condition')
        [entity_type]                   VARCHAR(50) NULL,
        [condition_field]               VARCHAR(50) NULL,
        [condition_operator]            VARCHAR(30) NULL,
        [condition_value]               INT NULL,
        [condition_unit]                VARCHAR(20) NULL DEFAULT 'day',

        -- Schedule fields (rule_type = 'schedule')
        [cron_expression]               VARCHAR(100) NULL,
        [next_run_at]                   DATETIME NULL,
        [last_run_at]                   DATETIME NULL,

        -- Notification template
        [notification_title_template]   NVARCHAR(200) NULL,
        [notification_content_template] NVARCHAR(MAX) NULL,
        [notification_type]             VARCHAR(30) NULL,
        [notification_priority]         VARCHAR(20) NOT NULL DEFAULT 'normal',

        -- Recipient config
        [recipient_type]               VARCHAR(30) NULL,
        [recipient_user_id]             INT NULL,

        -- Escalation config
        [escalate_after_minutes]        INT NULL,
        [escalate_to_user_id]           INT NULL,

        -- Control
        [is_active]                    BIT NOT NULL DEFAULT 1,
        [created_by]                    INT NULL,
        [created_at]                    DATETIME NOT NULL DEFAULT GETDATE(),
        [updated_at]                    DATETIME NULL,

        CONSTRAINT [PK_Notification_Rule_Engine] PRIMARY KEY CLUSTERED ([rule_id] ASC)
    );
    PRINT 'Đã tạo bảng Notification_Rule_Engine';
END
ELSE
    PRINT 'Bảng Notification_Rule_Engine đã tồn tại — bỏ qua tạo mới.';
GO

-- K1. FK: created_by → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_nre_created_by'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [fk_nre_created_by]
        FOREIGN KEY ([created_by]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- K2. FK: recipient_user_id → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_nre_recipient_user'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [fk_nre_recipient_user]
        FOREIGN KEY ([recipient_user_id]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- K3. FK: escalate_to_user_id → Users
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'fk_nre_escalate_to'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [fk_nre_escalate_to]
        FOREIGN KEY ([escalate_to_user_id]) REFERENCES [dbo].[Users] ([user_id]);
GO

-- K4. CHECK constraint cho rule_type
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_NRE_RuleType'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [CK_NRE_RuleType]
        CHECK ([rule_type] IN ('event_trigger', 'schedule', 'condition'));
GO

-- K5. CHECK constraint cho notification_priority
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_NRE_Priority'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [CK_NRE_Priority]
        CHECK ([notification_priority] IN ('low', 'normal', 'high', 'urgent'));
GO

-- K6. CHECK constraint cho recipient_type
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_NRE_RecipientType'
      AND parent_object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
)
    ALTER TABLE [dbo].[Notification_Rule_Engine]
        ADD CONSTRAINT [CK_NRE_RecipientType]
        CHECK ([recipient_type] IN ('assignee', 'owner', 'manager', 'specific_user') OR [recipient_type] IS NULL);
GO

-- K7. Index: event dispatcher tra cứu theo trigger_event
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
      AND name = 'IX_NRE_TriggerEvent'
)
    CREATE NONCLUSTERED INDEX [IX_NRE_TriggerEvent]
        ON [dbo].[Notification_Rule_Engine] ([trigger_event] ASC, [is_active] ASC)
        WHERE [rule_type] = 'event_trigger' AND [is_active] = 1;
GO

-- K8. Index: scheduler poll cho schedule/condition rules
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Notification_Rule_Engine')
      AND name = 'IX_NRE_Scheduler'
)
    CREATE NONCLUSTERED INDEX [IX_NRE_Scheduler]
        ON [dbo].[Notification_Rule_Engine] ([is_active] ASC, [next_run_at] ASC)
        WHERE [rule_type] IN ('schedule', 'condition') AND [is_active] = 1;
GO

PRINT 'Hoàn tất Phần K: Notification_Rule_Engine';
GO


-- ============================================================
-- PHẦN L: SEED DATA CHO Rule Engine
-- ============================================================
-- Mục đích: Cung cấp 5 rules mẫu để hệ thống hoạt động ngay
-- Lưu ý: Dùng IF NOT EXISTS để tránh duplicate khi chạy lại
-- ============================================================

-- L1. Rule: Notify khi Task được tạo
IF NOT EXISTS (SELECT 1 FROM [dbo].[Notification_Rule_Engine] WHERE [rule_name] = N'Notify khi Task được tạo')
BEGIN
    INSERT INTO [dbo].[Notification_Rule_Engine] (
        [rule_name], [rule_type], [description], [trigger_event],
        [notification_title_template], [notification_content_template],
        [notification_type], [notification_priority], [recipient_type], [is_active]
    )
    VALUES (
        N'Notify khi Task được tạo',
        'event_trigger',
        N'Khi 1 task mới được tạo và assign, gửi thông báo cho người nhận',
        'task_created',
        N'[Task mới] {{task_title}}',
        N'Bạn được giao task: {{task_title}}. Deadline: {{due_date}}.',
        'alert', 'normal', 'assignee', 1
    );
END
GO

-- L2. Rule: Notify khi Task hoàn thành
IF NOT EXISTS (SELECT 1 FROM [dbo].[Notification_Rule_Engine] WHERE [rule_name] = N'Notify khi Task hoàn thành')
BEGIN
    INSERT INTO [dbo].[Notification_Rule_Engine] (
        [rule_name], [rule_type], [description], [trigger_event],
        [notification_title_template], [notification_content_template],
        [notification_type], [notification_priority], [recipient_type], [is_active]
    )
    VALUES (
        N'Notify khi Task hoàn thành',
        'event_trigger',
        N'Khi task được đánh dấu completed, notify người tạo task',
        'task_completed',
        N'[Hoàn thành] {{task_title}}',
        N'Task "{{task_title}}" đã được hoàn thành bởi {{assignee_name}}.',
        'alert', 'normal', 'owner', 1
    );
END
GO

-- L3. Rule: Cảnh báo Task quá hạn
IF NOT EXISTS (SELECT 1 FROM [dbo].[Notification_Rule_Engine] WHERE [rule_name] = N'Cảnh báo Task quá hạn')
BEGIN
    INSERT INTO [dbo].[Notification_Rule_Engine] (
        [rule_name], [rule_type], [description], [trigger_event],
        [notification_title_template], [notification_content_template],
        [notification_type], [notification_priority], [recipient_type], [is_active]
    )
    VALUES (
        N'Cảnh báo Task quá hạn',
        'event_trigger',
        N'Khi task bị overdue, cảnh báo assignee và escalate cho manager',
        'task_overdue',
        N'[OVERDUE] {{task_title}} đã quá hạn',
        N'Task "{{task_title}}" đã quá deadline {{due_date}}. Vui lòng xử lý ngay.',
        'escalation', 'high', 'assignee', 1
    );
END
GO

-- L4. Rule: Condition - Customer không được contact 7 ngày
IF NOT EXISTS (SELECT 1 FROM [dbo].[Notification_Rule_Engine] WHERE [rule_name] = N'Customer không được contact 7 ngày')
BEGIN
    INSERT INTO [dbo].[Notification_Rule_Engine] (
        [rule_name], [rule_type], [description],
        [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit],
        [notification_title_template], [notification_content_template],
        [notification_type], [notification_priority], [recipient_type], [is_active]
    )
    VALUES (
        N'Customer không được contact 7 ngày',
        'condition',
        N'Nếu customer chưa có activity nào trong 7 ngày, nhắc owner follow up',
        'customer', 'last_activity_date', 'no_activity_for', 7, 'day',
        N'[Follow up] {{customer_name}} chưa được liên hệ',
        N'Customer {{customer_name}} chưa có tương tác trong 7 ngày. Hãy liên hệ ngay.',
        'reminder', 'normal', 'owner', 1
    );
END
GO

-- L5. Rule: Schedule - Daily digest lúc 8h sáng
IF NOT EXISTS (SELECT 1 FROM [dbo].[Notification_Rule_Engine] WHERE [rule_name] = N'Daily Task Digest')
BEGIN
    INSERT INTO [dbo].[Notification_Rule_Engine] (
        [rule_name], [rule_type], [description],
        [cron_expression], [next_run_at],
        [notification_title_template], [notification_content_template],
        [notification_type], [notification_priority], [recipient_type], [is_active]
    )
    VALUES (
        N'Daily Task Digest',
        'schedule',
        N'Mỗi sáng 8h gửi tóm tắt task trong ngày cho từng user',
        '0 8 * * *',
        DATEADD(DAY, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),
        N'[Daily Digest] Task hôm nay của bạn',
        N'Bạn có {{task_count}} task cần xử lý hôm nay. Deadline gần nhất: {{nearest_due}}.',
        'digest', 'low', 'assignee', 1
    );
END
GO

PRINT 'Hoàn tất Phần L: Seed data';
GO


-- ============================================================
-- TỔNG KẾT CÁC KỊCH BẢN ĐƯỢC HỖ TRỢ
-- ============================================================
/*
┌─────────────────────────────────────────────────────────────────────┐
│                    KỊCH BẢN ĐƯỢC COVER                             │
└─────────────────────────────────────────────────────────────────────┘

TASK MANAGEMENT (Scenario 1-6):
────────────────────────────────
✓ Scenario 1: Create Task      → Tasks(related_type/related_id) + Activities
✓ Scenario 2: Assign Task       → Task_Assignees(assigned_by, is_primary) + Task_History
✓ Scenario 3: Start Task        → Tasks.status + Task_History(action='started')
✓ Scenario 4: Update Progress  → Task_History_Detail + Task_History(action='progress')
✓ Scenario 5: Task Comments    → Task_Comments + IX_TaskComments_Task
✓ Scenario 6: Complete Task    → Tasks.completed_at + Task_History(action='completed')
+ Scenario 7: Task Reopened    → Tasks.reopened_at + Task_History(action='reopened')
+ Scenario 8: Task Reassigned  → Task_Assignees(is_primary=0/1) + assigned_by
+ Scenario 9: Task Overdue     → IX_Tasks_DueDate_Status + Activity + Rule Engine
+ Scenario 10: Task Cancelled  → Tasks.cancelled_at + Task_History(action='cancelled')

ACTIVITY TIMELINE (Scenario Activity):
─────────────────────────────────────────
✓ entity_type + entity_id     → Activities(source_type/source_id)
✓ Timeline query              → IX_Activities_Related_Date
✓ Source lookup               → IX_Activities_Source
✓ performed_by                → Activities(performed_by)
✓ metadata                    → Activities(metadata) cho JSON context
✓ updated_at                  → Activities(updated_at)

NOTIFICATION SYSTEM (Scenario Notification):
────────────────────────────────────────────
✓ Realtime Notification      → Notifications + Notification_Queue (ngay)
✓ Reminder Notification       → Task_Reminders + IX_TaskReminders_Poll
✓ Condition-Based            → Notification_Rule_Engine (rule_type='condition')
✓ Escalation Notification    → Notification_Rule_Engine (escalate_after_minutes)
✓ Digest Notification        → Notification_Rule_Engine (rule_type='schedule')
✓ Background Job Poll        → IX_NQueue_Poll (pending) + IX_NQueue_Retry (failed)

WEAKNESS ĐƯỢC GIẢI QUYẾT:
────────────────────────────────
✓ Weakness 1: Tasks không reference CRM entities  → related_type/related_id
✓ Weakness 2: Activities thiếu source reference  → source_type/source_id
✓ Weakness 3: Thiếu task comments                 → Task_Comments
✓ Weakness 4: Notification thiếu automation      → Notification_Rule_Engine
✓ Weakness 5: Không có notification aggregation  → Rule Engine (schedule/digest)
✓ Weakness 6: Thiếu condition monitoring          → Rule Engine (condition)

TRÙNG LẶP ĐƯỢC XÓA:
────────────────────────────────
✓ Duplicate index: Customer_Measurements
✓ Duplicate index: Customer_Style_Map
✓ Bảng trùng: Notification_Rules (cũ)
*/

PRINT '============================================================';
PRINT 'HOÀN TẤT FILE 07 - HỢP NHẤT V2.0';
PRINT 'Tất cả các thay đổi đã được áp dụng.';
PRINT 'Chạy lại không lỗi (idempotent).';
PRINT '============================================================';
GO
