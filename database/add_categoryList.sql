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

GO

/* =========================
TEST SELECT
========================= */

SELECT * FROM Categories;
GO