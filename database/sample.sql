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



 INSERT INTO [dbo].[Tasks]
([title],[description],[status],[priority],[due_date],[progress],[created_by])
VALUES
(N'Design CRM Database',
 N'Design full schema for CRM system including ERD',
 'In Progress',
 'High',
 DATEADD(DAY,7,GETDATE()),
 40,
 1),

(N'Prepare Sales Pitch Deck',
 N'Create presentation slides for potential investors',
 'Pending',
 'Medium',
 DATEADD(DAY,5,GETDATE()),
 0,
 2),

(N'Customer Follow-up Call',
 N'Call VIP customer for feedback on recent purchase',
 'Completed',
 'Low',
 DATEADD(DAY,-1,GETDATE()),
 100,
 1)
GO


INSERT INTO [dbo].[Task_Assignees]
([task_id],[user_id])
VALUES
(1,2),
(1,3),
(2,1),
(3,2)
GO


INSERT INTO [dbo].[Activities]
([activity_type],[description],[related_type],[related_id],[created_by])
VALUES
('CALL',
 N'Called customer to confirm delivery status',
 'CUSTOMER',
 1,
 2),

('EMAIL',
 N'Sent follow-up email regarding proposal',
 'LEAD',
 1,
 1),

('MEETING',
 N'Internal meeting about Q2 sales strategy',
 'INTERNAL',
 NULL,
 3)
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
