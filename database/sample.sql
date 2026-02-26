INSERT INTO Roles (role_name, description)
VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALE', 'Nhân viên kinh doanh'),
('MARKETING', 'Nhân viên marketing'),
('CS', 'Customer Support'),
('MANAGER', 'Quản lý');

INSERT INTO Roles (role_name, description)
VALUES
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


 --chen du lieu campaign
 INSERT INTO [CRM_System].[dbo].[Campaigns]
(
    [name],
    [description],
    [budget],
    [start_date],
    [end_date],
    [channel],
    [status],
    [created_by],
    [created_at],
    [updated_at]
)
VALUES
(N'Facebook Ads - Tháng 1 2026',
 N'Chạy quảng cáo Facebook cho sản phẩm vay tiêu dùng',
 45000000,
 '2026-01-01',
 '2026-01-31',
 'Facebook',
 'COMPLETED',
 1,
 GETDATE(),
 GETDATE()),

(N'Google Search - Thẻ tín dụng Q1',
 N'Quảng cáo Google Search thu lead mở thẻ tín dụng',
 80000000,
 '2026-01-15',
 '2026-03-31',
 'Google',
 'ACTIVE',
 1,
 GETDATE(),
 GETDATE()),

(N'Email Marketing - Upsell khách hàng cũ',
 N'Gửi email marketing upsell thẻ tín dụng',
 15000000,
 '2026-02-01',
 '2026-02-28',
 'Email',
 'COMPLETED',
 2,
 GETDATE(),
 GETDATE()),

(N'TikTok Lead Gen - Sinh viên 2026',
 N'Chạy quảng cáo TikTok target sinh viên 18-22 tuổi',
 35000000,
 '2026-04-01',
 '2026-04-30',
 'TikTok',
 'PLANNED',
 1,
 GETDATE(),
 GETDATE()),

(N'Zalo OA - Mở thẻ nhanh',
 N'Broadcast Zalo thu lead mở thẻ online',
 20000000,
 '2026-03-10',
 '2026-04-10',
 'Zalo',
 'ACTIVE',
 3,
 GETDATE(),
 GETDATE()),

(N'Facebook Remarketing - Tháng 2',
 N'Retarget khách đã truy cập website',
 30000000,
 '2026-02-01',
 '2026-02-28',
 'Facebook',
 'COMPLETED',
 2,
 GETDATE(),
 GETDATE()),

(N'Google Display - Branding',
 N'Chiến dịch branding trên Google Display Network',
 60000000,
 '2026-03-01',
 '2026-05-31',
 'Google',
 'ACTIVE',
 1,
 GETDATE(),
 GETDATE()),

(N'Affiliate Marketing - Q2',
 N'Hợp tác affiliate để thu lead vay tiêu dùng',
 50000000,
 '2026-04-01',
 '2026-06-30',
 'Affiliate',
 'PLANNED',
 2,
 GETDATE(),
 GETDATE()),

(N'SMS Marketing - Flash Sale',
 N'Gửi SMS khuyến mãi mở thẻ nhanh',
 10000000,
 '2026-03-20',
 '2026-03-25',
 'SMS',
 'ACTIVE',
 3,
 GETDATE(),
 GETDATE()),

(N'Influencer Campaign - TikTok',
 N'Hợp tác KOL TikTok quảng bá sản phẩm vay',
 70000000,
 '2026-05-01',
 '2026-05-31',
 'TikTok',
 'PLANNED',
 1,
 GETDATE(),
 GETDATE());