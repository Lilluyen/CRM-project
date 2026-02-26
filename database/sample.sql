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