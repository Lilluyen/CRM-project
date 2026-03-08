-- ============================================================
-- PHẦN 4: STORED PROCEDURES VÀ TRIGGERS
-- ============================================================

USE [CRM_System]
GO

/****** Object:  StoredProcedure [dbo].[sp_Calculate_RFM]    Script Date: 3/3/2026 8:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[sp_Calculate_RFM]

AS
BEGIN
    SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
    ;WITH RFM_BASE AS (
    SELECT 
        c.customer_id,

        -- Recency
        ISNULL(
            DATEDIFF(DAY, MAX(d.updated_at), GETDATE()),
            9999   -- nếu chưa mua bao giờ → rất lâu
        ) AS recency_days,

        -- Frequency
        COUNT(d.deal_id) AS frequency,

        -- Monetary
        ISNULL(SUM(d.actual_value), 0) AS monetary

    FROM Customers c
    LEFT JOIN Deals d 
        ON c.customer_id = d.customer_id
        AND d.stage = 'Won'

    GROUP BY c.customer_id
),

    RFM_SCORE AS (
        SELECT *,
            -- R: mua càng gần đây → điểm càng cao
            NTILE(6) OVER (ORDER BY recency_days DESC) - 1 AS R_score,

            -- F: mua càng nhiều → điểm càng cao
            NTILE(6) OVER (ORDER BY frequency ASC) - 1 AS F_score,

            -- M: chi càng nhiều → điểm càng cao
            NTILE(6) OVER (ORDER BY monetary ASC) - 1 AS M_score
        FROM RFM_BASE
    )

    UPDATE c
    SET c.rfm_score = (s.R_score*100 + s.F_score*10 + s.M_score)
    FROM Customers c
    JOIN RFM_SCORE s 
        ON c.customer_id = s.customer_id;

END;
GO
/****** Object:  StoredProcedure [dbo].[sp_FilterCustomersAdvanced]    Script Date: 3/3/2026 8:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_FilterCustomersAdvanced]
(
    @PageNumber INT,
    @PageSize   INT,

    @Keyword NVARCHAR(100) = NULL,

    @LoyaltyTiers dbo.StringList READONLY,
    @BodyShapes   dbo.StringList READONLY,
    @Sizes        dbo.StringList READONLY,
    @TagIds       dbo.IntList    READONLY,

    @ReturnRateMode NVARCHAR(10) = NULL
)
AS
BEGIN
SET NOCOUNT ON;

-- =====================================================
-- 1. LỌC CUSTOMER TRƯỚC → ĐƯA VÀO TEMP TABLE
-- =====================================================
CREATE TABLE #FilteredCustomers (
    customer_id INT PRIMARY KEY
);

INSERT INTO #FilteredCustomers(customer_id)
SELECT c.customer_id
FROM Customers c
WHERE 1=1

AND (
    @Keyword IS NULL
    OR c.name LIKE '%' + @Keyword + '%'
    OR c.phone LIKE '%' + @Keyword + '%'
)

AND (
    NOT EXISTS (SELECT 1 FROM @LoyaltyTiers)
    OR c.loyalty_tier IN (SELECT value FROM @LoyaltyTiers)
)

AND (
    @ReturnRateMode IS NULL
    OR (@ReturnRateMode = 'HIGH'   AND c.return_rate > 40.0)
    OR (@ReturnRateMode = 'NORMAL' AND c.return_rate <= 40.0)
)

AND (
    NOT EXISTS (SELECT 1 FROM @TagIds)
    OR EXISTS (
        SELECT 1
        FROM Customer_Style_Map sm
        WHERE sm.customer_id = c.customer_id
        AND sm.tag_id IN (SELECT value FROM @TagIds)
    )
);

-- =====================================================
-- 2. COUNT TOTAL → dùng cho pagination
-- =====================================================
SELECT COUNT(*) AS TotalRecords FROM #FilteredCustomers;

-- =====================================================
-- 3. JOIN dữ liệu để render UI
-- =====================================================
WITH LatestMeasurement AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY measured_at DESC) AS rn
    FROM Customer_Measurements
),
TagAgg AS (
    SELECT
        csm.customer_id,
        STRING_AGG(t.tag_name, ', ') AS style_tags
    FROM Customer_Style_Map csm
    JOIN Style_Tags t ON csm.tag_id = t.tag_id
    GROUP BY csm.customer_id
)

SELECT
    c.customer_id,
    c.name,
    c.phone,
    c.email,
    c.gender,
    c.loyalty_tier,
    c.rfm_score,

    CASE
        WHEN m.preferred_size IS NULL THEN NULL
        ELSE CONCAT(
            m.preferred_size,
            ' (',
            CAST(m.height AS INT),
            'cm - ',
            CAST(m.weight AS INT),
            'kg)'
        )
    END AS fit_profile,

    m.body_shape,
    m.height,
    m.weight,

    ta.style_tags,

    c.return_rate,
    c.last_purchase AS last_purchase_date,
    c.status

FROM #FilteredCustomers fc
JOIN Customers c ON c.customer_id = fc.customer_id

LEFT JOIN LatestMeasurement m
       ON m.customer_id = c.customer_id AND m.rn = 1

LEFT JOIN TagAgg ta
       ON ta.customer_id = c.customer_id

WHERE 1=1

AND (
    NOT EXISTS (SELECT 1 FROM @BodyShapes)
    OR m.body_shape IN (SELECT value FROM @BodyShapes)
)

AND (
    NOT EXISTS (SELECT 1 FROM @Sizes)
    OR m.preferred_size IN (SELECT value FROM @Sizes)
)

ORDER BY c.rfm_score DESC, c.customer_id DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomersPaged]    Script Date: 3/3/2026 8:01:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[sp_GetCustomersPaged]
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tổng record (để tính total page)
    SELECT COUNT(*) AS TotalRecords
    FROM Customers;

    WITH TagAgg AS (
        SELECT
            csm.customer_id,
            STRING_AGG(t.tag_name, ', ') AS style_tags
        FROM Customer_Style_Map csm
        JOIN Style_Tags t ON csm.tag_id = t.tag_id
        GROUP BY csm.customer_id
    ),
    LatestMeasurement AS (
        SELECT *
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY customer_id
                       ORDER BY measured_at DESC
                   ) rn
            FROM Customer_Measurements
        ) x
        WHERE rn = 1
    )

    SELECT
        c.customer_id,
        c.name,
        c.phone,
        c.email,
        c.gender,
        c.loyalty_tier,
        c.rfm_score,

        CASE
            WHEN m.preferred_size IS NULL THEN NULL
            ELSE CONCAT(
                m.preferred_size,
                ' (',
                CAST(m.height AS INT),
                'cm - ',
                CAST(m.weight AS INT),
                'kg)'
            )
        END AS fit_profile,

        m.body_shape,
        m.height,
        m.weight,

        ta.style_tags,

        c.return_rate,
        c.last_purchase AS last_purchase_date,
        c.status

    FROM Customers c
    LEFT JOIN LatestMeasurement m ON m.customer_id = c.customer_id
    LEFT JOIN TagAgg ta ON ta.customer_id = c.customer_id

    ORDER BY c.rfm_score DESC, c.customer_id DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
GO

-- Khôi phục database về READ_WRITE
USE [master]
GO
ALTER DATABASE [CRM_System] SET  READ_WRITE
GO
