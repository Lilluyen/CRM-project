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
INSERT INTO Tasks (title, description, related_type, related_id, assigned_to, priority, status, due_date)
VALUES
(N'Gọi lại khách hàng Lan Anh', N'Tư vấn bộ sưu tập mới', 'Customer', 1, 2, 'HIGH', 'OPEN', DATEADD(day, 2, GETDATE())),

(N'Chăm sóc khách Minh Tú', N'Follow up sau mua hàng', 'Customer', 2, 2, 'MEDIUM', 'IN_PROGRESS', DATEADD(day, 1, GETDATE())),

(N'Tư vấn deal Sơn Tùng', N'Đàm phán giá hợp đồng', 'Deal', 1, 2, 'HIGH', 'OPEN', DATEADD(day, 5, GETDATE())),

(N'Xử lý ticket khách Hoa', N'Khách phàn nàn sản phẩm lỗi', 'Ticket', 1, 4, 'HIGH', 'OPEN', DATEADD(day, 1, GETDATE())),

(N'Gửi email campaign', N'Gửi email marketing tháng 3', 'Campaign', 1, 3, 'MEDIUM', 'OPEN', DATEADD(day, 3, GETDATE())),

(N'Follow up lead mới', N'Liên hệ lead từ Facebook', 'Lead', 1, 2, 'HIGH', 'IN_PROGRESS', DATEADD(day, 2, GETDATE())),

(N'Kiểm tra tồn kho sản phẩm', N'Phối hợp bộ phận kho', 'Product', 1, 5, 'LOW', 'OPEN', DATEADD(day, 4, GETDATE())),

(N'Chăm sóc khách VIP', N'Khách GOLD cần tư vấn riêng', 'Customer', 12, 2, 'HIGH', 'OPEN', DATEADD(day, 1, GETDATE())),

(N'Gọi lại khách blacklist', N'Xác minh lý do blacklist', 'Customer', 3, 4, 'MEDIUM', 'OPEN', DATEADD(day, 3, GETDATE())),

(N'Cập nhật thông tin deal', N'Cập nhật giá trị thực tế', 'Deal', 2, 2, 'LOW', 'DONE', DATEADD(day, -1, GETDATE())),

(N'Chuẩn bị báo cáo sale', N'Báo cáo tuần', 'Customer', 4, 5, 'MEDIUM', 'IN_PROGRESS', DATEADD(day, 2, GETDATE())),

(N'Kiểm tra feedback', N'Xem phản hồi khách hàng', 'Ticket', 2, 4, 'MEDIUM', 'OPEN', DATEADD(day, 1, GETDATE())),

(N'Tư vấn sản phẩm mới', N'Giới thiệu BST mới', 'Customer', 7, 2, 'HIGH', 'OPEN', DATEADD(day, 2, GETDATE())),

(N'Follow up deal lớn', N'Hợp đồng giá trị cao', 'Deal', 3, 5, 'HIGH', 'OPEN', DATEADD(day, 6, GETDATE())),

(N'Chăm sóc khách hàng cũ', N'Khách quay lại mua', 'Customer', 10, 2, 'LOW', 'DONE', DATEADD(day, -2, GETDATE())),

(N'Xử lý khiếu nại', N'Khách yêu cầu đổi trả', 'Ticket', 3, 4, 'HIGH', 'IN_PROGRESS', DATEADD(day, 1, GETDATE())),

(N'Tư vấn lead tiềm năng', N'Lead có score cao', 'Lead', 2, 2, 'HIGH', 'OPEN', DATEADD(day, 2, GETDATE())),

(N'Cập nhật CRM', N'Kiểm tra dữ liệu khách hàng', 'Customer', 13, 5, 'LOW', 'OPEN', DATEADD(day, 5, GETDATE())),

(N'Gửi báo giá', N'Báo giá cho khách hàng mới', 'Deal', 4, 2, 'MEDIUM', 'OPEN', DATEADD(day, 3, GETDATE())),

(N'Nhắc nhở thanh toán', N'Khách chưa thanh toán đủ', 'Deal', 5, 2, 'HIGH', 'OPEN', DATEADD(day, 1, GETDATE()));



-----------------------------------------------------------------------------------------------



INSERT INTO Activities (related_type, related_id, activity_type, subject, description, created_by, activity_date)
VALUES
('Customer', 1, 'CALL', N'Gọi tư vấn sản phẩm', N'Khách quan tâm váy dự tiệc', 2, GETDATE()),

('Customer', 2, 'EMAIL', N'Gửi catalogue', N'Đã gửi catalogue mới nhất', 2, GETDATE()),

('Lead', 1, 'CALL', N'Gọi lead Facebook', N'Lead hỏi về giá sản phẩm', 2, GETDATE()),

('Deal', 1, 'MEETING', N'Họp ký hợp đồng', N'Trao đổi điều khoản hợp đồng', 2, GETDATE()),

('Ticket', 1, 'SUPPORT', N'Hỗ trợ khiếu nại', N'Khách yêu cầu đổi size', 4, GETDATE()),

('Customer', 12, 'CALL', N'Chăm sóc khách VIP', N'Khách hài lòng với dịch vụ', 2, GETDATE()),

('Lead', 2, 'EMAIL', N'Gửi báo giá', N'Lead đang xem xét', 2, GETDATE()),

('Customer', 3, 'CALL', N'Xác minh blacklist', N'Khách có lịch sử hoàn trả cao', 4, GETDATE()),

('Deal', 2, 'UPDATE', N'Cập nhật stage deal', N'Deal chuyển sang Negotiation', 2, GETDATE()),

('Customer', 7, 'MEETING', N'Tư vấn trực tiếp', N'Khách thử đồ tại showroom', 2, GETDATE()),

('Ticket', 2, 'SUPPORT', N'Phản hồi ticket', N'Đã giải quyết xong', 4, GETDATE()),

('Customer', 10, 'CALL', N'Nhắc lịch thanh toán', N'Khách hẹn thanh toán tuần sau', 2, GETDATE()),

('Deal', 3, 'CALL', N'Trao đổi giá trị deal', N'Khách yêu cầu giảm giá', 2, GETDATE()),

('Lead', 3, 'CALL', N'Follow up lead', N'Lead chưa phản hồi email', 2, GETDATE()),

('Customer', 4, 'EMAIL', N'Gửi chương trình khuyến mãi', N'Khách quan tâm ưu đãi tháng 3', 3, GETDATE()),

('Ticket', 3, 'SUPPORT', N'Xử lý yêu cầu hoàn tiền', N'Đang chờ xác nhận kế toán', 4, GETDATE()),

('Customer', 13, 'CALL', N'Chăm sóc sau mua', N'Khách hài lòng sản phẩm', 2, GETDATE()),

('Deal', 4, 'MEETING', N'Họp với khách hàng', N'Bàn về điều khoản hợp đồng', 5, GETDATE()),

('Customer', 19, 'CALL', N'Giới thiệu sản phẩm mới', N'Khách quan tâm BST hè', 2, GETDATE()),

('Lead', 4, 'EMAIL', N'Gửi thông tin chi tiết', N'Lead yêu cầu thêm thông tin', 3, GETDATE());


------------------------------------------------------------------------------------------------

INSERT INTO [CRM_System].[dbo].[Categories] ([category_name], [description], [status], [created_at])
VALUES 
-- NHÓM ĐỒ NAM (1-10) -> INACTIVE
(N'Áo Thun Nam', N'Các loại áo phông cotton, cổ tròn, cổ tim cho nam', 'INACTIVE', GETDATE()),
(N'Áo Sơ Mi Nam', N'Sơ mi công sở, sơ mi flannel, sơ mi đi biển', 'INACTIVE', GETDATE()),
(N'Quần Jean Nam', N'Quần bò dáng slim-fit, baggy, straight cho nam', 'INACTIVE', GETDATE()),
(N'Quần Tây Nam', N'Quần vải thanh lịch cho môi trường công sở', 'INACTIVE', GETDATE()),
(N'Áo Khoác Nam', N'Áo gió, áo phao, áo bomber nam', 'INACTIVE', GETDATE()),
(N'Quần Short Nam', N'Quần lửng mặc nhà hoặc đi chơi', 'INACTIVE', GETDATE()),
(N'Vest Nam', N'Bộ suit và áo blazer nam cao cấp', 'INACTIVE', GETDATE()),
(N'Đồ Lót Nam', N'Boxer và quần lót nam chất liệu thông thoáng', 'INACTIVE', GETDATE()),
(N'Đồ Thể Thao Nam', N'Bộ đồ tập gym, chạy bộ cho nam', 'INACTIVE', GETDATE()),
(N'Áo Len Nam', N'Áo dệt kim, áo len cổ lọ cho mùa đông', 'INACTIVE', GETDATE()),

-- NHÓM ĐỒ NỮ (11-20) -> INACTIVE
(N'Váy Hoa Nhí', N'Váy voan nhẹ nhàng cho mùa hè', 'INACTIVE', GETDATE()),
(N'Chân Váy', N'Chân váy chữ A, váy bút chì, váy xếp ly', 'INACTIVE', GETDATE()),
(N'Áo Croptop', N'Áo dáng ngắn thời trang cho nữ', 'INACTIVE', GETDATE()),
(N'Đầm Dạ Hội', N'Trang phục sang trọng cho các buổi tiệc', 'INACTIVE', GETDATE()),
(N'Áo Sơ Mi Nữ', N'Sơ mi kiểu, áo blouse nữ tính', 'INACTIVE', GETDATE()),
(N'Quần Jean Nữ', N'Skinny jean, mom jean, jean ống rộng', 'INACTIVE', GETDATE()),
(N'Áo Khoác Cardigan', N'Áo khoác len nhẹ cho nữ', 'INACTIVE', GETDATE()),
(N'Bộ Đồ Ngủ Nữ', N'Pijama lụa và đồ mặc nhà', 'INACTIVE', GETDATE()),
(N'Áo Hai Dây', N'Áo camisole, áo dây gợi cảm', 'INACTIVE', GETDATE()),
(N'Quần Legging', N'Quần ôm co giãn đa năng', 'INACTIVE', GETDATE()),

-- NHÓM TRẺ EM (21-25) -> INACTIVE
(N'Đồ Sơ Sinh', N'Quần áo mềm mại cho bé dưới 1 tuổi', 'INACTIVE', GETDATE()),
(N'Váy Bé Gái', N'Các mẫu váy công chúa và váy mặc hằng ngày', 'INACTIVE', GETDATE()),
(N'Bộ Đồ Bé Trai', N'Quần áo năng động cho bé trai', 'INACTIVE', GETDATE()),
(N'Áo Khoác Trẻ Em', N'Giữ ấm cho bé vào mùa đông', 'INACTIVE', GETDATE()),
(N'Đồ Bơi Trẻ Em', N'Đồ bơi một mảnh và hai mảnh cho bé', 'INACTIVE', GETDATE()),

-- NHÓM TRẺ EM (26-30) -> ACTIVE
(N'Giày Trẻ Em', N'Giày tập đi và giày thể thao cho bé', 'ACTIVE', GETDATE()),
(N'Mũ Em Bé', N'Mũ che thóp và mũ lưỡi trai nhỏ', 'ACTIVE', GETDATE()),
(N'Yếm Ăn Dặm', N'Yếm vải và yếm silicon cho bé', 'ACTIVE', GETDATE()),
(N'Tất Trẻ Em', N'Tất chống trượt cho bé yêu', 'ACTIVE', GETDATE()),
(N'Đồ Chơi Vải', N'Phụ kiện đồ chơi an toàn đi kèm', 'ACTIVE', GETDATE()),

-- PHỤ KIỆN (31-40) -> ACTIVE
(N'Thắt Lưng Da', N'Thắt lưng da bò, da cá sấu thật', 'ACTIVE', GETDATE()),
(N'Ví & Túi Xách', N'Túi cầm tay và ví nam/nữ', 'ACTIVE', GETDATE()),
(N'Cà Vạt & Nơ', N'Phụ kiện trang trọng cho quý ông', 'ACTIVE', GETDATE()),
(N'Mũ & Nón', N'Mũ lưỡi trai, mũ len, mũ bucket', 'ACTIVE', GETDATE()),
(N'Tất & Vớ', N'Tất cotton khử mùi', 'ACTIVE', GETDATE()),
(N'Kính Thời Trang', N'Kính râm và gọng kính', 'ACTIVE', GETDATE()),
(N'Trang Sức Cài Áo', N'Brooch cài vest sang trọng', 'ACTIVE', GETDATE()),
(N'Khăn Quàng Cổ', N'Khăn len, khăn lụa thời trang', 'ACTIVE', GETDATE()),
(N'Găng Tay', N'Găng tay da và găng tay len', 'ACTIVE', GETDATE()),
(N'Đồng Hồ', N'Đồng hồ đeo tay thời trang', 'ACTIVE', GETDATE()),

-- ĐỒ THEO DỊP & KHÁC (41-50) -> ACTIVE
(N'Đồ Tập Yoga', N'Quần áo chuyên dụng cho tập luyện', 'ACTIVE', GETDATE()),
(N'Đồ Bơi & Bikini', N'Trang phục đi biển cho nữ', 'ACTIVE', GETDATE()),
(N'Đồ Cưới', N'Váy cưới và vest chú rể', 'ACTIVE', GETDATE()),
(N'Áo Dài Truyền Thống', N'Áo dài cách tân và truyền thống', 'ACTIVE', GETDATE()),
(N'Trang Phục Hóa Trang', N'Đồ Halloween và lễ hội', 'ACTIVE', GETDATE()),
(N'Áo Polo Đồng Phục', N'Áo thun có cổ lịch sự', 'ACTIVE', GETDATE()),
(N'Quần Jogger', N'Phong cách streetwear thoải mái', 'ACTIVE', GETDATE()),
(N'Áo Hoodie', N'Áo nỉ có mũ trẻ trung', 'ACTIVE', GETDATE()),
(N'Quần Kaki', N'Quần vải thô bền bỉ', 'ACTIVE', GETDATE()),
(N'Hàng Giảm Giá', N'Các sản phẩm đang trong chương trình sale', 'ACTIVE', GETDATE());

