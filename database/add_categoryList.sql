USE CRM_System;
GO

/* =========================
INSERT SAMPLE CATEGORIES
========================= */

INSERT INTO Categories (category_name, description, status)
VALUES 
(N'Áo sơ mi', N'Các loại áo sơ mi nam và nữ', 'ACTIVE'),

(N'Quần jeans', N'Quần jeans thời trang', 'ACTIVE'),

(N'Váy đầm', N'Váy đầm công sở và dạo phố', 'ACTIVE'),

(N'Áo khoác', N'Áo khoác mùa đông', 'INACTIVE'),

(N'Phụ kiện', N'Phụ kiện thời trang', 'ACTIVE');
INSERT INTO Categories (category_name, description, status)
VALUES 

(N'Áo thun', N'Áo thun nam nữ nhiều mẫu mã', 'ACTIVE'),
(N'Áo polo', N'Áo polo lịch sự và trẻ trung', 'ACTIVE'),
(N'Quần short', N'Quần short thể thao và dạo phố', 'ACTIVE'),
(N'Quần tây', N'Quần tây công sở nam nữ', 'ACTIVE'),
(N'Áo hoodie', N'Áo hoodie phong cách streetwear', 'ACTIVE'),

(N'Áo len', N'Áo len giữ ấm mùa đông', 'ACTIVE'),
(N'Áo vest', N'Áo vest công sở cao cấp', 'ACTIVE'),
(N'Đồ thể thao', N'Trang phục thể thao năng động', 'ACTIVE'),
(N'Đồ ngủ', N'Đồ ngủ thoải mái tại nhà', 'ACTIVE'),
(N'Đồ lót', N'Đồ lót nam nữ cao cấp', 'ACTIVE'),

(N'Balo', N'Balo thời trang và du lịch', 'ACTIVE'),
(N'Túi xách', N'Túi xách nữ thời trang', 'ACTIVE'),
(N'Giày sneaker', N'Giày sneaker năng động', 'ACTIVE'),
(N'Giày cao gót', N'Giày cao gót nữ sang trọng', 'ACTIVE'),
(N'Dép sandal', N'Dép sandal mùa hè', 'ACTIVE'),

(N'Mũ nón', N'Mũ thời trang các loại', 'ACTIVE'),
(N'Khăn choàng', N'Khăn choàng cổ mùa đông', 'ACTIVE'),
(N'Thắt lưng', N'Thắt lưng da cao cấp', 'ACTIVE'),
(N'Đồng hồ', N'Đồng hồ thời trang nam nữ', 'ACTIVE'),
(N'Kính mát', N'Kính mát chống tia UV', 'ACTIVE');
GO

/* =========================
TEST SELECT
========================= */

USE CRM_System;
GO

INSERT INTO Categories (category_name, description, status)
VALUES 

(N'Áo thun', N'Áo thun nam nữ nhiều mẫu mã', 'ACTIVE'),
(N'Áo polo', N'Áo polo lịch sự và trẻ trung', 'ACTIVE'),
(N'Quần short', N'Quần short thể thao và dạo phố', 'ACTIVE'),
(N'Quần tây', N'Quần tây công sở nam nữ', 'ACTIVE'),
(N'Áo hoodie', N'Áo hoodie phong cách streetwear', 'ACTIVE'),

(N'Áo len', N'Áo len giữ ấm mùa đông', 'ACTIVE'),
(N'Áo vest', N'Áo vest công sở cao cấp', 'ACTIVE'),
(N'Đồ thể thao', N'Trang phục thể thao năng động', 'ACTIVE'),
(N'Đồ ngủ', N'Đồ ngủ thoải mái tại nhà', 'ACTIVE'),
(N'Đồ lót', N'Đồ lót nam nữ cao cấp', 'ACTIVE'),

(N'Balo', N'Balo thời trang và du lịch', 'ACTIVE'),
(N'Túi xách', N'Túi xách nữ thời trang', 'ACTIVE'),
(N'Giày sneaker', N'Giày sneaker năng động', 'ACTIVE'),
(N'Giày cao gót', N'Giày cao gót nữ sang trọng', 'ACTIVE'),
(N'Dép sandal', N'Dép sandal mùa hè', 'ACTIVE'),

(N'Mũ nón', N'Mũ thời trang các loại', 'ACTIVE'),
(N'Khăn choàng', N'Khăn choàng cổ mùa đông', 'ACTIVE'),
(N'Thắt lưng', N'Thắt lưng da cao cấp', 'ACTIVE'),
(N'Đồng hồ', N'Đồng hồ thời trang nam nữ', 'ACTIVE'),
(N'Kính mát', N'Kính mát chống tia UV', 'ACTIVE');

GO
SELECT COUNT(*) FROM Categories;