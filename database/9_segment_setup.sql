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