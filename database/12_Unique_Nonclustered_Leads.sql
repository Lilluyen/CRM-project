CREATE UNIQUE NONCLUSTERED INDEX UQ_Leads_Email
ON [dbo].[Leads]([email])
WHERE [email] IS NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_Leads_Phone
ON [dbo].[Leads]([phone])
WHERE [phone] IS NOT NULL AND [phone] <> '';
GO