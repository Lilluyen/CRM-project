INSERT INTO Roles (role_name, description)
VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALE', 'Nhân viên kinh doanh'),
('MARKETING', 'Nhân viên marketing'),
('CS', 'Customer Support'),
('MANAGER', 'Quản lý');

INSERT INTO Users (
    username,
    password_hash,
    email,
    full_name,
    phone,
    role_id,
    status
)
VALUES

('admin', 
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'admin@crm.com',
 N'Admin',
 '0900000001',
 1, -- ADMIN
 'ACTIVE'),

('sale01',
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'sale01@crm.com',
 N'Sale',
 '0900000002',
 2, -- SALE
 'ACTIVE'),

('mkt01',
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'mkt01@crm.com',
 N'Marketing',
 '0900000003',
 3, -- MARKETING
 'ACTIVE'),

('cs01',
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'cs01@crm.com',
 N'CS',
 '0900000004',
 4, -- CS
 'ACTIVE'),

 ('mng01',
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'mng01@crm.com',
 N'Manager',
 '0900000004',
 5, -- CS
 'ACTIVE'),

('locked_user',
 '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG',
 'lock@crm.com',
 N'User Bị Khóa',
 '0900000005',
 2, -- SALE (ví dụ)
 'LOCKED');

INSERT INTO [dbo].[Tickets]
([customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at])
VALUES
(1, N'Lỗi sản phẩm bị rách', 
 N'Tôi nhận được sản phẩm nhưng bị rách ở tay áo.', 
 'HIGH', 'OPEN', 1, GETDATE(), NULL),

(1, N'Yêu cầu đổi size', 
 N'Sản phẩm tôi đặt bị rộng, muốn đổi sang size M.', 
 'MEDIUM', 'IN_PROGRESS', 2, GETDATE(), GETDATE()),

(1, N'Chưa nhận được hàng', 
 N'Tôi đã đặt hàng 5 ngày nhưng chưa nhận được.', 
 'HIGH', 'OPEN', 1, GETDATE(), NULL),

(1, N'Hoàn tiền đơn hàng', 
 N'Tôi muốn hoàn tiền vì sản phẩm không đúng mô tả.', 
 'HIGH', 'RESOLVED', 3, GETDATE(), GETDATE()),

(1, N'Tư vấn sản phẩm', 
 N'Tôi cần tư vấn về áo khoác mùa đông.', 
 'LOW', 'CLOSED', 2, GETDATE(), GETDATE()),

(1, N'Báo lỗi thanh toán', 
 N'Thanh toán bằng thẻ nhưng bị trừ tiền 2 lần.', 
 'URGENT', 'IN_PROGRESS', 1, GETDATE(), GETDATE()),

(1, N'Không áp dụng được mã giảm giá', 
 N'Tôi nhập mã nhưng hệ thống báo lỗi.', 
 'MEDIUM', 'OPEN', 2, GETDATE(), NULL),

(3, N'Cập nhật thông tin cá nhân', 
 N'Tôi muốn thay đổi số điện thoại.', 
 'LOW', 'CLOSED', 3, GETDATE(), GETDATE()),

(4, N'Phản ánh thái độ nhân viên', 
 N'Tôi không hài lòng về cách hỗ trợ.', 
 'HIGH', 'RESOLVED', 1, GETDATE(), GETDATE()),

(5, N'Thắc mắc về chương trình khuyến mãi', 
 N'Chương trình khuyến mãi còn áp dụng không?', 
 'LOW', 'OPEN', 2, GETDATE(), NULL);


---add campaigns detail
 USE [CRM_System]
GO
SET IDENTITY_INSERT [dbo].[Campaigns] ON 
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (1, N'Facebook Ads - Tháng 1 2026', N'Chạy quảng cáo Facebook cho sản phẩm vay tiêu dùng', CAST(45000000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-01-31' AS Date), N'SOCIAL_MEDIA', N'PLANNING', 1, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:57:42.023' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (2, N'Google Search - Thẻ tín dụng Q1', N'Quảng cáo Google Search thu lead mở thẻ tín dụng', CAST(80000000.00 AS Decimal(15, 2)), CAST(N'2026-01-15' AS Date), CAST(N'2026-03-31' AS Date), N'Google', N'ACTIVE', 1, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (3, N'Email Marketing - Upsell khách hàng cũ', N'Gửi email marketing upsell thẻ tín dụng', CAST(15000000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-02-28' AS Date), N'Email', N'COMPLETED', 2, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (4, N'TikTok Lead Gen - Sinh viên 2026', N'Chạy quảng cáo TikTok target sinh viên 18-22 tuổi', CAST(35000000.00 AS Decimal(15, 2)), CAST(N'2026-04-01' AS Date), CAST(N'2026-04-30' AS Date), N'TikTok', N'PLANNED', 1, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (5, N'Zalo OA - Mở thẻ nhanh', N'Broadcast Zalo thu lead mở thẻ online', CAST(20000000.00 AS Decimal(15, 2)), CAST(N'2026-03-10' AS Date), CAST(N'2026-04-10' AS Date), N'Zalo', N'ACTIVE', 3, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (6, N'Facebook Remarketing - Tháng 2', N'Retarget khách đã truy cập website', CAST(30000000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-02-28' AS Date), N'', N'COMPLETED', 2, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T17:06:14.910' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (7, N'Google Display - Branding', N'Chiến dịch branding trên Google Display Network', CAST(60000000.00 AS Decimal(15, 2)), CAST(N'2026-03-01' AS Date), CAST(N'2026-05-31' AS Date), N'Google', N'ACTIVE', 1, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (8, N'Affiliate Marketing - Q2', N'Hợp tác affiliate để thu lead vay tiêu dùng', CAST(50000000.00 AS Decimal(15, 2)), CAST(N'2026-04-01' AS Date), CAST(N'2026-06-30' AS Date), N'Affiliate', N'PLANNED', 2, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (9, N'SMS Marketing - Flash Sale', N'Gửi SMS khuyến mãi mở thẻ nhanh', CAST(10000000.00 AS Decimal(15, 2)), CAST(N'2026-03-20' AS Date), CAST(N'2026-03-25' AS Date), N'SMS', N'ACTIVE', 3, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (10, N'Influencer Campaign - TikTok', N'Hợp tác KOL TikTok quảng bá sản phẩm vay', CAST(70000000.00 AS Decimal(15, 2)), CAST(N'2026-05-01' AS Date), CAST(N'2026-05-31' AS Date), N'TikTok', N'PLANNED', 1, CAST(N'2026-02-26T16:35:18.460' AS DateTime), CAST(N'2026-02-26T16:35:18.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (12, N'giảm giá quần áo mùa đông', N'sale 90% ', CAST(999000.00 AS Decimal(15, 2)), CAST(N'2026-02-26' AS Date), CAST(N'2026-03-08' AS Date), N'EMAIL', N'ACTIVE', 1, CAST(N'2026-02-26T17:04:29.817' AS DateTime), CAST(N'2026-02-26T17:05:39.513' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (13, N'Du xuân đón tết', N'Sale 50% toàn bộ cửa hàng', CAST(100000000.00 AS Decimal(15, 2)), CAST(N'2026-02-27' AS Date), CAST(N'2026-03-01' AS Date), N'SOCIAL_MEDIA', N'ACTIVE', 3, CAST(N'2026-02-26T23:02:26.440' AS DateTime), CAST(N'2026-02-26T23:02:26.440' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaigns] OFF
GO
