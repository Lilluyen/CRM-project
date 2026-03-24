CREATE TABLE Segment_Filters (
    filter_id INT IDENTITY PRIMARY KEY,
    segment_id INT NOT NULL,
    
    field_name NVARCHAR(50) NOT NULL,
    operator NVARCHAR(20) NOT NULL,
    value NVARCHAR(255),

    logic_operator NVARCHAR(10) DEFAULT 'AND',

    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT fk_filter_segment
        FOREIGN KEY (segment_id)
        REFERENCES Customer_Segments(segment_id)
);

ALTER TABLE Segment_Filters
ADD CONSTRAINT chk_filter_operator
CHECK (operator IN ('=','>','<','>=','<=','LIKE','IN'));

ALTER TABLE Segment_Filters
ADD CONSTRAINT chk_filter_logic
CHECK (logic_operator IN ('AND','OR'));

CREATE INDEX idx_filter_segment
ON Segment_Filters(segment_id);

ALTER TABLE Customers
ADD CONSTRAINT chk_loyalty_tier
CHECK (loyalty_tier IN ('GOLD','SILVER','BRONZE', 'PLATINUM', 'DIAMOND', 'BLACKLIST'));

DECLARE @constraintName NVARCHAR(200);

SELECT @constraintName = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON dc.parent_object_id = c.object_id 
    AND dc.parent_column_id = c.column_id
WHERE c.name = 'rfm_score'
AND OBJECT_NAME(dc.parent_object_id) = 'Customers';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Customers DROP CONSTRAINT ' + @constraintName);
END

DROP INDEX IX_Customers_Filter ON Customers;

DROP INDEX IX_Customers_rfm_customer ON Customers;

ALTER TABLE Customers
ADD total_spent DECIMAL(18,2) DEFAULT 0;

ALTER TABLE Customers
DROP COLUMN rfm_score;

DROP TABLE [dbo].[Customer_Measurements];

Alter table Customers
Add Constraint uq_customer_email UNIQUE (email)

CREATE TABLE customer_contact (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('EMAIL', 'PHONE')),
    value VARCHAR(255) NOT NULL,
    is_primary BIT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME ,
    
    CONSTRAINT FK_customer_contact_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE customer_note (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    note NVARCHAR(MAX),
    created_by INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT FK_customer_note_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

ALTER TABLE Customers
DROP CONSTRAINT UQ_customer_phone;

ALTER TABLE Customers
DROP CONSTRAINT uq_customer_email;

CREATE TABLE customer_merge_request (
    id INT IDENTITY(1,1) PRIMARY KEY,

    source_id INT NOT NULL,   -- customer bị merge vào target
    target_id INT NOT NULL,   -- customer được giữ lại

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    -- PENDING | APPROVED | REJECTED | MERGED

    field_overrides NVARCHAR(MAX), -- JSON
    reason NVARCHAR(MAX),
    reject_reason NVARCHAR(MAX),

    created_by INT NOT NULL,
    reviewed_by INT,

    created_at DATETIME2 DEFAULT GETDATE(),
    reviewed_at DATETIME2,

   CONSTRAINT FK_cmr_source FOREIGN KEY (source_id)
        REFERENCES Customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_cmr_target FOREIGN KEY (target_id)
        REFERENCES Customers(customer_id)
);
