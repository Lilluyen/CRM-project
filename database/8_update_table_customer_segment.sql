USE CRM_System;
GO

/* ================================
   1. ADD COLUMNS TO Customer_Segments
================================ */

ALTER TABLE Customer_Segments
ADD 
    segment_type NVARCHAR(10) NOT NULL DEFAULT 'STATIC',
    [status] NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    created_by INT,
    updated_at DATETIME,
    updated_by INT,
    assignment_type NVARCHAR(20) NOT NULL DEFAULT 'ROUND_ROBIN',
    last_assigned_user_id INT,
    customer_count INT DEFAULT 0;
GO


/* ================================
   2. CHECK CONSTRAINTS
================================ */

ALTER TABLE Customer_Segments
ADD CONSTRAINT chk_segment_type
CHECK (segment_type IN ('STATIC','DYNAMIC'));
GO

ALTER TABLE Customer_Segments
ADD CONSTRAINT chk_segment_status
CHECK ([status] IN ('ACTIVE','INACTIVE'));
GO

ALTER TABLE Customer_Segments
ADD CONSTRAINT chk_assignment_type
CHECK (assignment_type IN ('ROUND_ROBIN','LEAST_CUSTOMERS'));
GO


/* ================================
   3. FOREIGN KEYS
================================ */

ALTER TABLE Customer_Segments
ADD CONSTRAINT fk_segment_created_by
FOREIGN KEY (created_by)
REFERENCES Users(user_id);
GO

ALTER TABLE Customer_Segments
ADD CONSTRAINT fk_segment_updated_by
FOREIGN KEY (updated_by)
REFERENCES Users(user_id);
GO

ALTER TABLE Customer_Segments
ADD CONSTRAINT fk_segment_last_user
FOREIGN KEY (last_assigned_user_id)
REFERENCES Users(user_id);
GO


/* ================================
   4. UNIQUE CONSTRAINT
================================ */

ALTER TABLE Customer_Segments
ADD CONSTRAINT uq_segment_name
UNIQUE (segment_name);
GO


/* ================================
   5. CREATE SEGMENT UPDATE HISTORY
================================ */

CREATE TABLE Segment_Update_History (
    history_id INT IDENTITY PRIMARY KEY,
    segment_id INT NOT NULL,
    updated_by INT,
    updated_at DATETIME DEFAULT GETDATE(),
    change_description NVARCHAR(MAX),

    CONSTRAINT fk_history_segment
        FOREIGN KEY (segment_id)
        REFERENCES Customer_Segments(segment_id),

    CONSTRAINT fk_history_user
        FOREIGN KEY (updated_by)
        REFERENCES Users(user_id)
);
GO


/* ================================
   6. UPDATE Customer_Segment_Map
================================ */

ALTER TABLE Customer_Segment_Map
ADD assigned_by INT;
GO

ALTER TABLE Customer_Segment_Map
ADD CONSTRAINT fk_map_user
FOREIGN KEY (assigned_by)
REFERENCES Users(user_id);
GO



/* ================================
   7. INDEXES
================================ */

CREATE INDEX idx_customer_owner
ON Customers(owner_id);
GO

CREATE INDEX idx_customer_source
ON Customers(source);
GO

CREATE INDEX idx_customer_loyalty
ON Customers(loyalty_tier);
GO

CREATE INDEX idx_history_segment
ON Segment_Update_History(segment_id);
GO

CREATE INDEX idx_segment_map_segment
ON Customer_Segment_Map(segment_id);
GO

