USE [CRM_System]
GO

IF COL_LENGTH('dbo.Deals', 'campaign_id') IS NULL
BEGIN
    ALTER TABLE dbo.Deals
    ADD campaign_id INT NULL;
END
GO

IF COL_LENGTH('dbo.Deals', 'campaign_id') IS NOT NULL
BEGIN
    UPDATE d
    SET d.campaign_id = l.campaign_id
    FROM dbo.Deals d
    INNER JOIN dbo.Leads l ON l.lead_id = d.lead_id
    WHERE d.campaign_id IS NULL;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Deals_campaign_id'
      AND object_id = OBJECT_ID('dbo.Deals')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Deals_campaign_id
    ON dbo.Deals (campaign_id);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'fk_deals_campaign'
      AND parent_object_id = OBJECT_ID('dbo.Deals')
)
BEGIN
    ALTER TABLE dbo.Deals
    ADD CONSTRAINT fk_deals_campaign
        FOREIGN KEY (campaign_id) REFERENCES dbo.Campaigns(campaign_id);
END
GO
