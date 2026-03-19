-- Bảng cache anchor cho mỗi "session" phân trang
CREATE TABLE Pagination_Anchors (
    session_id    UNIQUEIDENTIFIER NOT NULL,
    page_number   INT              NOT NULL,
    anchor_rfm    DECIMAL(10,4)    NOT NULL,
    anchor_id     INT              NOT NULL,
    created_at    DATETIME2        DEFAULT GETUTCDATE(),
    CONSTRAINT PK_PaginationAnchors 
        PRIMARY KEY (session_id, page_number)
);

CREATE INDEX IX_Anchors_Session_Page 
    ON Pagination_Anchors (session_id, page_number);

-- Tự xóa session cũ sau 30 phút (chạy qua SQL Agent Job)
-- DELETE FROM Pagination_Anchors WHERE created_at < DATEADD(MINUTE, -30, GETUTCDATE());