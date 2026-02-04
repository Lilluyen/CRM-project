INSERT INTO Roles (role_name, description)
VALUES
('ADMIN', 'Quản trị hệ thống'),
('SALE', 'Nhân viên kinh doanh'),
('MARKETING', 'Nhân viên marketing'),
('CS', 'Customer Support');

INSERT INTO Users (
    username,
    password_hash,
    email,
    full_name,
    phone,
    status
)
VALUES
('admin', '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', 'admin@crm.com', 'Admin', '0900000001', 'ACTIVE'),
('sale01', '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', 'sale01@crm.com', 'Sale', '0900000002', 'ACTIVE'),
('mkt01', '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', 'mkt01@crm.com', 'Marketing', '0900000003', 'ACTIVE'),
('cs01', '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', 'cs01@crm.com', 'CS', '0900000004', 'ACTIVE'),
('locked_user', '$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', 'lock@crm.com', 'User Bị Khóa', '0900000005', 'LOCKED');

-- ADMIN
INSERT INTO User_Roles (user_id, role_id)
VALUES (1, 1);

-- SALE
INSERT INTO User_Roles (user_id, role_id)
VALUES (2, 2);

-- MARKETING
INSERT INTO User_Roles (user_id, role_id)
VALUES (3, 3);

-- CUSTOMER SUPPORT
INSERT INTO User_Roles (user_id, role_id)
VALUES (4, 4);

-- USER có nhiều role (SALE + MARKETING)
INSERT INTO User_Roles (user_id, role_id)
VALUES
(2, 3);
