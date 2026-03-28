USE [CRM_System]
GO

/*SET IDENTITY_INSERT [dbo].[Activities] ON
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (1, N'CUSTOMER', 1, N'CALL', N'Call Customer', N'Called customer to confirm delivery status', 2, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Activities] OFF
GO
*/
/*
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 1, N'Contacted', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-10T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 2, N'Contacted', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-12T10:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 6, N'Qualified', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-20T11:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 3, N'Qualified', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-10T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 4, N'Converted', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 15, N'New', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-03T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 5, N'New', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-01-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 8, N'Lost', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-02-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 13, N'Converted', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-02-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 7, N'Qualified', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 9, N'Qualified', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 14, N'Contacted', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-03T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (5, 10, N'Contacted', CAST(N'2026-02-12T08:00:00.000' AS DateTime), CAST(N'2026-02-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (5, 12, N'Qualified', CAST(N'2026-02-12T08:00:00.000' AS DateTime), CAST(N'2026-02-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (6, 11, N'New', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-01-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (6, 17, N'Contacted', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-01-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (7, 16, N'Qualified', CAST(N'2026-02-20T08:00:00.000' AS DateTime), CAST(N'2026-02-25T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (7, 20, N'Converted', CAST(N'2026-02-20T08:00:00.000' AS DateTime), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (8, 18, N'Lost', CAST(N'2026-03-02T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (9, 19, N'New', CAST(N'2026-03-05T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
*/
/*
SET IDENTITY_INSERT [dbo].[Campaign_Reports] ON
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (1, 1, 3, 1, 0, CAST(1666.67 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-02-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (2, 2, 3, 1, 1, CAST(2333.33 AS Decimal(10, 2)), CAST(28.50 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (3, 3, 3, 1, 1, CAST(666.67 AS Decimal(10, 2)), CAST(42.30 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (4, 4, 3, 2, 0, CAST(4000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-06T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (5, 5, 2, 1, 0, CAST(1750.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (6, 6, 2, 0, 0, CAST(1500.00 AS Decimal(10, 2)), CAST(15.00 AS Decimal(5, 2)), CAST(N'2026-02-02T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (7, 7, 2, 1, 1, CAST(1500.00 AS Decimal(10, 2)), CAST(55.20 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (8, 8, 1, 0, 0, CAST(9000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (9, 9, 1, 0, 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-06T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (10, 10, 0, 0, 0, CAST(0.00 AS Decimal(10, 2)), CAST(38.70 AS Decimal(5, 2)), CAST(N'2026-01-02T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaign_Reports] OFF
GO
*/
SET IDENTITY_INSERT [dbo].[Campaigns] ON
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (1, N'Facebook Lead Gen Q1', N'Run ads to generate leads for CRM products', CAST(5000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-03-31' AS Date), N'Facebook', N'ACTIVE', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (2, N'Google Search Ads - Cloud', N'Keyword advertising for Cloud Migration services', CAST(7000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-04-30' AS Date), N'Google', N'ACTIVE', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (3, N'Email Marketing Automation', N'Send nurturing emails to potential customers.', CAST(2000.00 AS Decimal(15, 2)), CAST(N'2026-01-15' AS Date), CAST(N'2026-02-28' AS Date), N'Email', N'COMPLETED', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (4, N'Business Seminar 2026', N'Organize a digital transformation workshop for businesses.', CAST(12000.00 AS Decimal(15, 2)), CAST(N'2026-03-10' AS Date), CAST(N'2026-03-10' AS Date), N'Event', N'PLANNING', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (5, N'LinkedIn B2B Outreach', N'Business customer outreach campaign', CAST(3500.00 AS Decimal(15, 2)), CAST(N'2026-02-10' AS Date), CAST(N'2026-05-10' AS Date), N'LinkedIn', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (6, N'SEO Branding Campaign', N'Increase brand awareness through SEO.', CAST(4000.00 AS Decimal(15, 2)), CAST(N'2025-11-01' AS Date), CAST(N'2026-02-01' AS Date), N'SEO', N'COMPLETED', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (7, N'Referral Partner Program', N'Encourage partners to refer customers.', CAST(3000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), N'Referral', N'ACTIVE', 5, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (8, N'Product Launch Ads', N'Promoting the launch of the new version of the CRM system.', CAST(9000.00 AS Decimal(15, 2)), CAST(N'2026-03-01' AS Date), CAST(N'2026-04-15' AS Date), N'Facebook', N'ACTIVE', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (9, N'Retargeting Campaign', N'Retarget customers who have visited the website.', CAST(2500.00 AS Decimal(15, 2)), CAST(N'2026-02-20' AS Date), CAST(N'2026-03-30' AS Date), N'Google Display', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (10, N'Year End Promotion 2025', N'Year-end promotional campaign', CAST(6000.00 AS Decimal(15, 2)), CAST(N'2025-10-01' AS Date), CAST(N'2025-12-31' AS Date), N'Multi-channel', N'COMPLETED', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaigns] OFF
GO
SET IDENTITY_INSERT [dbo].[Categories] ON
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (1, N'Shirts', N'Men and women shirts', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (2, N'Jeans', N'Fashion jeans', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (3, N'Dresses', N'Office and casual dresses', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (4, N'Jackets', N'Winter jackets', N'INACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (5, N'Accessories', N'Fashion accessories', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (6, N'T-Shirts', N'Men and women T-shirts with many styles', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (7, N'Polo Shirts', N'Elegant and youthful polo shirts', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (8, N'Shorts', N'Sports and casual shorts', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (9, N'Trousers', N'Office trousers for men and women', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (10, N'Hoodies', N'Streetwear hoodies', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (11, N'Sweaters', N'Warm winter sweaters', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (12, N'Blazers', N'High-end office blazers', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (13, N'Sportswear', N'Dynamic sports clothing', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (14, N'Sleepwear', N'Comfortable home sleepwear', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (15, N'Underwear', N'High-quality men and women underwear', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (16, N'Backpacks', N'Fashion and travel backpacks', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (17, N'Handbags', N'Fashion handbags for women', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (18, N'Sneakers', N'Dynamic sneakers', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (19, N'High Heels', N'Elegant high heels for women', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (20, N'Sandals', N'Summer sandals', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (21, N'Hats', N'Fashion hats of various types', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (22, N'Scarves', N'Winter scarves', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (23, N'Belts', N'High-quality leather belts', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (24, N'Watches', N'Fashion watches for men and women', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (25, N'Sunglasses', N'UV protection sunglasses', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Categories] OFF
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 1)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 5)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 7)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 10)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (2, 2)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (2, 8)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (3, 3)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (5, 6)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (5, 9)
GO
/*
SET IDENTITY_INSERT [dbo].[Leads] ON
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (1, N'Nguyen Van An', N'an.nguyen@gmail.com', N'0901000001', N'Ao thun', N'Website', N'Qualified', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (2, N'Tran Thi Binh', N'binh.tran@gmail.com', N'0901000002', N'', N'Facebook', N'QUALIFIED', 2, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:25.277' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (3, N'Le Hoang Nam', N'nam.le@gmail.com', N'0901000003', N'Ao khoac', N'Referral', N'Nurturing', 3, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 60, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (4, N'Pham Gia Huy', N'huy.pham@gmail.com', N'', N'', N'Website', N'NURTURING', 4, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:31.657' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (5, N'Do Minh Quan', N'quan@gmail.com', N'0901000005', NULL, N'LinkedIn', N'New', 5, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (6, N'Vo Thu Trang', N'trang@gmail.com', NULL, NULL, N'Facebook', N'New', 6, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 20, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (7, N'Nguyen Tuan Kiet', N'kiet@gmail.com', N'abc123', NULL, N'Seminar', N'Lost', 7, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (8, N'Bui Thanh Dat', N'dat@gmail.com', NULL, NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 18, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (9, N'Hoang Lan Chi', N'chi.hoang@gmail.com', N'0901000009', N'Chan vay', N'Referral', N'Qualified', 9, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (10, N'Pham Duc Long', N'long.pham@gmail.com', N'0901000010', N'', N'Facebook', N'QUALIFIED', 10, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:38.807' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (11, N'Nguyen Hai Yen', N'yen.nguyen@gmail.com', NULL, NULL, N'Website', N'New', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (12, N'Tran Quoc Bao', N'bao.tran@gmail.com', N'0901000012', N'Ao blazer', N'LinkedIn', N'Qualified', 2, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (13, N'Le Thi Hoa', N'hoa.le@gmail.com', N'0901000013', N'', N'Referral', N'QUALIFIED', 3, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:48.693' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (14, N'Vo Minh Tam', N'tam.vo@gmail.com', N'0901000014', NULL, N'Seminar', N'Nurturing', 4, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (15, N'Dang Quang Vinh', N'vinh.dang@gmail.com', NULL, NULL, N'Website', N'New', 5, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (16, N'Phan Thu Ha', N'ha.phan@gmail.com', N'0901000016', N'Dam du tiec', N'Facebook', N'Qualified', 6, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (17, N'Nguyen Duc Manh', N'manh.nguyen@gmail.com', N'0901000017', NULL, N'LinkedIn', N'Nurturing', 7, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (18, N'Trinh Bao Chau', N'chau@gmail.com', N'abc999', NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (19, N'Le Anh Tuan', N'tuan.le@gmail.com', N'0901000019', N'Quan kaki', N'Referral', N'Qualified', 9, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (20, N'Pham Ngoc Mai', N'mai.pham@gmail.com', N'0901000020', NULL, N'Facebook', N'Nurturing', 10, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
SET IDENTITY_INSERT [dbo].[Leads] OFF
GO
*/
/*
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (1, 1, 1, CAST(N'2026-03-02T14:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (1, 3, 1, CAST(N'2026-03-02T14:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (2, 1, 1, CAST(N'2026-03-03T08:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (2, 2, 1, CAST(N'2026-03-03T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (3, 1, 1, CAST(N'2026-02-25T17:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (3, 4, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 1, 1, CAST(N'2026-03-07T08:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 2, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 3, 1, CAST(N'2026-03-07T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (5, 1, 1, CAST(N'2026-03-03T09:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (5, 5, 1, CAST(N'2026-03-03T10:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (6, 1, 1, CAST(N'2026-03-01T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (6, 3, 1, CAST(N'2026-03-01T09:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (7, 1, 1, CAST(N'2026-03-02T15:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (7, 5, 1, CAST(N'2026-03-02T16:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (8, 1, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (8, 5, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (9, 1, 1, CAST(N'2026-03-07T22:10:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (9, 4, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (10, 1, 1, CAST(N'2026-03-01T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (10, 5, 1, CAST(N'2026-03-01T10:00:00.000' AS DateTime))
GO
*/
SET IDENTITY_INSERT [dbo].[Notification_Rule_Engine] ON
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) 
VALUES 
(1, N'Notify when a Task is created', N'event_trigger', N'When a new task is created and assigned, send a notification to the assignee', N'task_created', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[New Task] {{task_title}}', N'You have been assigned a new task: {{task_title}}. Deadline: {{due_date}}.', N'alert', N'normal', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.857' AS DateTime), NULL)
GO

INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) 
VALUES 
(2, N'Notify when a Task is completed', N'event_trigger', N'When a task is marked as completed, notify the task owner', N'task_completed', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[Completed] {{task_title}}', N'Task "{{task_title}}" has been completed by {{assignee_name}}.', N'alert', N'normal', N'owner', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.867' AS DateTime), NULL)
GO

INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) 
VALUES 
(3, N'Task overdue alert', N'event_trigger', N'When a task becomes overdue, send a warning to the assignee and escalate to the manager', N'task_overdue', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[OVERDUE] {{task_title}} is overdue', N'Task "{{task_title}}" has passed the deadline {{due_date}}. Please take action immediately.', N'escalation', N'high', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.877' AS DateTime), NULL)
GO
--INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (4, N'Customer không được contact 7 ngày', N'condition', N'Nếu customer chưa có activity nào trong 7 ngày, nhắc owner follow up', NULL, N'customer', N'last_activity_date', N'no_activity_for', 7, N'day', NULL, NULL, NULL, N'[Follow up] {{customer_name}} chưa được liên hệ', N'Customer {{customer_name}} chưa có tương tác trong 7 ngày. Hãy liên hệ ngay.', N'reminder', N'normal', N'owner', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.887' AS DateTime), NULL)
--GO
--INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (5, N'Daily Task Digest', N'schedule', N'Mỗi sáng 8h gửi tóm tắt task trong ngày cho từng user', NULL, NULL, NULL, NULL, NULL, N'day', N'0 8 * * *', CAST(N'2026-03-29T00:00:00.000' AS DateTime), NULL, N'[Daily Digest] Task hôm nay của bạn', N'Bạn có {{task_count}} task cần xử lý hôm nay. Deadline gần nhất: {{nearest_due}}.', N'digest', N'low', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.893' AS DateTime), NULL)
--GO
SET IDENTITY_INSERT [dbo].[Notification_Rule_Engine] OFF
GO
--SET IDENTITY_INSERT [dbo].[Notifications] ON
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (1, N'Deal Mới Cần Xử Lý', N'Deal "CRM Implementation" (deal_id=35) vừa được tạo và chờ xử lý.', N'deal', N'deal', 35, CAST(N'2026-03-02T13:37:03.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (2, N'Lead Chuyển Đổi Thành Công', N'Lead id=4 đã được chuyển đổi thành khách hàng.', N'lead', N'lead', 4, CAST(N'2026-03-03T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (3, N'Ticket Khẩn Cần Phân Công', N'Ticket #5 mức HIGH chưa được phân công xử lý.', N'ticket', N'ticket', 5, CAST(N'2026-02-25T17:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (4, N'Task Sắp Đến Hạn', N'Task "Design CRM Database" sẽ đến hạn vào 2026-03-10.', N'task', N'task', 1, CAST(N'2026-03-07T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (5, N'Khách Hàng VIP Mới', N'Customer_id=28 vừa đạt hạng PLATINUM.', N'customer', N'customer', 28, CAST(N'2026-03-03T09:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (6, N'Campaign Kết Thúc', N'Campaign id=3 đã kết thúc. Tỷ lệ chuyển đổi đạt 33%.', N'campaign', N'campaign', 3, CAST(N'2026-03-01T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (7, N'Deal Thắng - Chúc Mừng!', N'Deal id=22 đã chốt thành công 14,800,000 VND.', N'deal', N'deal', 22, CAST(N'2026-03-02T15:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (8, N'Nhắc Nhở Follow-up Khách Hàng', N'10 khách hàng chưa được liên hệ trong 30 ngày qua.', N'system', NULL, NULL, CAST(N'2026-03-05T07:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (9, N'OTP Thất Bại Nhiều Lần', N'Customer_id=5 đã nhập OTP sai 3 lần liên tiếp.', N'security', N'customer', 5, CAST(N'2026-03-07T22:05:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (10, N'Báo Cáo Dịch Vụ Tháng 2/2026', N'Tổng 30 tickets, giải quyết 22, thời gian phản hồi TB: 1.9h.', N'report', NULL, NULL, CAST(N'2026-03-01T08:30:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
--GO
--SET IDENTITY_INSERT [dbo].[Notifications] OFF
--GO
SET IDENTITY_INSERT [dbo].[Products] ON
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(1, N'Luxury Rouge Evening Dress', N'RED-001', CAST(4500000.00 AS Decimal(15, 2)), N'High-end designer evening dress, imported silk fabric, wine red color', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:50.653' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(2, N'Sapphire Office Dress', N'OD-002', CAST(1850000.00 AS Decimal(15, 2)), N'Elegant office dress, tweed fabric, sapphire blue color', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:44.700' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(3, N'Ivory Princess Wedding Dress', N'PWD-003', CAST(12000000.00 AS Decimal(15, 2)), N'Princess-style wedding dress, French lace, 1.5m long train, ivory color', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:47.500' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(4, N'Bohemian Sunset Designer Dress', N'SDD-004', CAST(2200000.00 AS Decimal(15, 2)), N'Boho-style designer dress, floral printed pattern, soft chiffon fabric', N'ACTIVE', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:38.833' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(5, N'Midnight Sequin Party Dress', N'SPD-005', CAST(3100000.00 AS Decimal(15, 2)), N'Party dress with silver sequin details, body-fit design, suitable for events', N'ACTIVE', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:41.960' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(6, N'Summer Blossom Casual Dress', N'BCD-006', CAST(980000.00 AS Decimal(15, 2)), N'Fresh floral dress, soft cotton fabric, suitable for summer outings', N'ACTIVE', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:33.263' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(7, N'Velvet Noir Premium Dress', N'NPD-007', CAST(5800000.00 AS Decimal(15, 2)), N'Premium black velvet dress, deep V-neck, suitable for luxury evening parties', N'ACTIVE', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:36.327' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(8, N'Minimalist Grey Office Dress', N'GOD-008', CAST(1650000.00 AS Decimal(15, 2)), N'Minimalist office dress, dark grey color, high-quality polyester fabric', N'ACTIVE', CAST(N'2026-02-01T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:27.533' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(9, N'Vintage Floral Midi Dress', N'FMD-009', CAST(1350000.00 AS Decimal(15, 2)), N'Vintage midi dress with retro floral pattern, breathable linen fabric', N'ACTIVE', CAST(N'2026-02-01T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:30.483' AS DateTime))
GO

INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES
(10, N'Pearl Evening Gown', N'EG-010', CAST(7500000.00 AS Decimal(15, 2)), N'Evening gown with handcrafted pearl details, flared design, satin fabric', N'ACTIVE', CAST(N'2026-02-05T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:24.020' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (1, N'ADMIN', N'System Admin', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (2, N'SALE', N'Sale Staff', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (3, N'MARKETING', N'Marketing Staff', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (4, N'CS', N'Customer Support Staff', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (5, N'MANAGER', N'Manager', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Service_Reports] ON
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (1, CAST(N'2025-10-31' AS Date), 18, 16, CAST(2.40 AS Decimal(10, 2)), CAST(18.50 AS Decimal(10, 2)), CAST(N'2025-11-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (2, CAST(N'2025-11-30' AS Date), 22, 20, CAST(1.80 AS Decimal(10, 2)), CAST(15.20 AS Decimal(10, 2)), CAST(N'2025-12-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (3, CAST(N'2025-12-31' AS Date), 31, 28, CAST(2.10 AS Decimal(10, 2)), CAST(14.80 AS Decimal(10, 2)), CAST(N'2026-01-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (4, CAST(N'2026-01-31' AS Date), 25, 24, CAST(1.50 AS Decimal(10, 2)), CAST(12.30 AS Decimal(10, 2)), CAST(N'2026-02-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (5, CAST(N'2026-02-28' AS Date), 30, 22, CAST(1.90 AS Decimal(10, 2)), CAST(16.70 AS Decimal(10, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Service_Reports] OFF
GO
SET IDENTITY_INSERT [dbo].[Style_Tags] ON
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (1, N'#Vintage', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (2, N'#Minimalism', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (3, N'#Streetwear', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (4, N'#Office', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (5, N'#Pastel', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (6, N'#DarkTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (7, N'#Silk', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (8, N'#Denim', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (9, N'#Elegant', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (10, N'#Classic', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (11, N'#Sporty', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (12, N'#Bohemian', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (13, N'#Neutral', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (14, N'#WarmTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (15, N'#CoolTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (16, N'#Monochrome', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (17, N'#Cotton', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (18, N'#Linen', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (19, N'#Leather', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (20, N'#Wool', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (21, N'#Party', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (22, N'#Casual', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (23, N'#Formal', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (24, N'#Floral', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (25, N'#Checked', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (26, N'#Solid', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (27, N'#Summer', N'Season')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (28, N'#Winter', N'Season')
GO
SET IDENTITY_INSERT [dbo].[Style_Tags] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (1, N'admin', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'admin@crm.com', N'Admin', N'0900000001', 1, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:41:07.557' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (2, N'sale01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'sale01@crm.com', N'Sale', N'0900000002', 2, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:22:50.523' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (3, N'mkt01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mkt01@crm.com', N'Marketing', N'0900000003', 3, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:22:28.910' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (4, N'cs01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'cs01@crm.com', N'CS', N'0900000004', 4, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (5, N'mng01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mng01@crm.com', N'Manager', N'0900000004', 5, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (6, N'locked_user', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'lock@crm.com', N'User Bị Khóa', N'0900000005', 2, N'LOCKED', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (7, N'change_pass', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'changepass@gmail.com', N'User Change Pass', N'0909999999', 1, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
