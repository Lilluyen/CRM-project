-- ============================================================
-- SCHEMA ADDITIONS – Task_Comments as Work Items
-- Run once against CRM_System
-- ============================================================

-- Người được giao work item (supporter được tag vào)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments') AND name = 'assigned_to'
)
    ALTER TABLE dbo.Task_Comments
        ADD assigned_to INT NULL REFERENCES dbo.Users(user_id);
GO

-- Đánh dấu work item đã hoàn thành
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments') AND name = 'is_completed'
)
    ALTER TABLE dbo.Task_Comments
        ADD is_completed BIT NOT NULL DEFAULT 0;
GO

-- Thời điểm hoàn thành
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Task_Comments') AND name = 'completed_at'
)
    ALTER TABLE dbo.Task_Comments
        ADD completed_at DATETIME NULL;
GO

-- Index hỗ trợ tính progress nhanh
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TaskComments_progress')
    CREATE INDEX IX_TaskComments_progress
        ON dbo.Task_Comments (task_id, is_deleted, is_completed);
GO
ALTER TABLE Task_Assignees add is_active bit;