-- ============================================================
-- PHẦN 2: CHÈN DỮ LIỆU
-- ============================================================

USE [CRM_System]
GO

SET IDENTITY_INSERT [dbo].[Activities] ON 

INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at]) VALUES (1, N'CUSTOMER', 1, N'CALL', N'Call Customer', N'Called customer to confirm delivery status', 2, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime))
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at]) VALUES (2, N'LEAD', 1, N'EMAIL', N'Send email to Lead', N'Sent follow-up email regarding proposal', 1, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime))
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at]) VALUES (3, N'INTERNAL', NULL, N'MEETING', N'Internal Meetng', N'Internal meeting about Q2 sales strategy', 3, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime))
SET IDENTITY_INSERT [dbo].[Activities] OFF
GO
SET IDENTITY_INSERT [dbo].[Campaigns] ON 

INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (1, N'Facebook Lead Gen Q1', N'Chạy quảng cáo thu lead cho sản phẩm CRM', CAST(5000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-03-31' AS Date), N'Facebook', N'ACTIVE', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (2, N'Google Search Ads - Cloud', N'Quảng cáo từ khóa dịch vụ Cloud Migration', CAST(7000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-04-30' AS Date), N'Google', N'ACTIVE', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (3, N'Email Marketing Automation', N'Gửi email nurturing khách hàng tiềm năng', CAST(2000.00 AS Decimal(15, 2)), CAST(N'2026-01-15' AS Date), CAST(N'2026-02-28' AS Date), N'Email', N'COMPLETED', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (4, N'Business Seminar 2026', N'Tổ chức hội thảo chuyển đổi số cho doanh nghiệp', CAST(12000.00 AS Decimal(15, 2)), CAST(N'2026-03-10' AS Date), CAST(N'2026-03-10' AS Date), N'Event', N'PLANNING', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (5, N'LinkedIn B2B Outreach', N'Chiến dịch tiếp cận khách hàng doanh nghiệp', CAST(3500.00 AS Decimal(15, 2)), CAST(N'2026-02-10' AS Date), CAST(N'2026-05-10' AS Date), N'LinkedIn', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (6, N'SEO Branding Campaign', N'Tăng nhận diện thương hiệu qua SEO', CAST(4000.00 AS Decimal(15, 2)), CAST(N'2025-11-01' AS Date), CAST(N'2026-02-01' AS Date), N'SEO', N'COMPLETED', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (7, N'Referral Partner Program', N'Khuyến khích đối tác giới thiệu khách hàng', CAST(3000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), N'Referral', N'ACTIVE', 5, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (8, N'Product Launch Ads', N'Quảng bá ra mắt hệ thống CRM phiên bản mới', CAST(9000.00 AS Decimal(15, 2)), CAST(N'2026-03-01' AS Date), CAST(N'2026-04-15' AS Date), N'Facebook', N'ACTIVE', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (9, N'Retargeting Campaign', N'Retarget khách hàng đã truy cập website', CAST(2500.00 AS Decimal(15, 2)), CAST(N'2026-02-20' AS Date), CAST(N'2026-03-30' AS Date), N'Google Display', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (10, N'Year End Promotion 2025', N'Chiến dịch ưu đãi cuối năm', CAST(6000.00 AS Decimal(15, 2)), CAST(N'2025-10-01' AS Date), CAST(N'2025-12-31' AS Date), N'Multi-channel', N'COMPLETED', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
SET IDENTITY_INSERT [dbo].[Campaigns] OFF
GO
SET IDENTITY_INSERT [dbo].[Customer_Measurements] ON 

INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (26, 1, CAST(158.00 AS Decimal(5, 2)), CAST(48.00 AS Decimal(5, 2)), CAST(82.00 AS Decimal(5, 2)), CAST(64.00 AS Decimal(5, 2)), CAST(88.00 AS Decimal(5, 2)), CAST(36.00 AS Decimal(5, 2)), N'S', N'Petite', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (27, 2, CAST(165.00 AS Decimal(5, 2)), CAST(55.00 AS Decimal(5, 2)), CAST(86.00 AS Decimal(5, 2)), CAST(68.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (28, 3, CAST(170.00 AS Decimal(5, 2)), CAST(62.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(72.00 AS Decimal(5, 2)), CAST(96.00 AS Decimal(5, 2)), CAST(40.00 AS Decimal(5, 2)), N'L', N'Athletic', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (29, 4, CAST(160.00 AS Decimal(5, 2)), CAST(50.00 AS Decimal(5, 2)), CAST(84.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(37.00 AS Decimal(5, 2)), N'S', N'Petite', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (30, 5, CAST(168.00 AS Decimal(5, 2)), CAST(58.00 AS Decimal(5, 2)), CAST(88.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(94.00 AS Decimal(5, 2)), CAST(39.00 AS Decimal(5, 2)), N'M', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (31, 6, CAST(172.00 AS Decimal(5, 2)), CAST(65.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(74.00 AS Decimal(5, 2)), CAST(98.00 AS Decimal(5, 2)), CAST(41.00 AS Decimal(5, 2)), N'L', N'Athletic', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (32, 7, CAST(155.00 AS Decimal(5, 2)), CAST(46.00 AS Decimal(5, 2)), CAST(80.00 AS Decimal(5, 2)), CAST(62.00 AS Decimal(5, 2)), CAST(86.00 AS Decimal(5, 2)), CAST(35.00 AS Decimal(5, 2)), N'S', N'Slim', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (33, 8, CAST(163.00 AS Decimal(5, 2)), CAST(52.00 AS Decimal(5, 2)), CAST(85.00 AS Decimal(5, 2)), CAST(67.00 AS Decimal(5, 2)), CAST(91.00 AS Decimal(5, 2)), CAST(37.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (34, 9, CAST(167.00 AS Decimal(5, 2)), CAST(57.00 AS Decimal(5, 2)), CAST(87.00 AS Decimal(5, 2)), CAST(69.00 AS Decimal(5, 2)), CAST(93.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (35, 10, CAST(173.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(93.00 AS Decimal(5, 2)), CAST(75.00 AS Decimal(5, 2)), CAST(99.00 AS Decimal(5, 2)), CAST(41.00 AS Decimal(5, 2)), N'L', N'Rectangle', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (36, 11, CAST(159.00 AS Decimal(5, 2)), CAST(49.00 AS Decimal(5, 2)), CAST(83.00 AS Decimal(5, 2)), CAST(65.00 AS Decimal(5, 2)), CAST(89.00 AS Decimal(5, 2)), CAST(36.00 AS Decimal(5, 2)), N'S', N'Petite', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (37, 12, CAST(166.00 AS Decimal(5, 2)), CAST(56.00 AS Decimal(5, 2)), CAST(86.00 AS Decimal(5, 2)), CAST(69.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (38, 13, CAST(171.00 AS Decimal(5, 2)), CAST(63.00 AS Decimal(5, 2)), CAST(91.00 AS Decimal(5, 2)), CAST(73.00 AS Decimal(5, 2)), CAST(97.00 AS Decimal(5, 2)), CAST(40.00 AS Decimal(5, 2)), N'L', N'Athletic', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (39, 14, CAST(162.00 AS Decimal(5, 2)), CAST(51.00 AS Decimal(5, 2)), CAST(84.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(37.00 AS Decimal(5, 2)), N'S', N'Slim', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (40, 15, CAST(169.00 AS Decimal(5, 2)), CAST(59.00 AS Decimal(5, 2)), CAST(89.00 AS Decimal(5, 2)), CAST(71.00 AS Decimal(5, 2)), CAST(95.00 AS Decimal(5, 2)), CAST(39.00 AS Decimal(5, 2)), N'M', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (41, 16, CAST(174.00 AS Decimal(5, 2)), CAST(67.00 AS Decimal(5, 2)), CAST(94.00 AS Decimal(5, 2)), CAST(76.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(5, 2)), CAST(42.00 AS Decimal(5, 2)), N'L', N'Rectangle', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (42, 17, CAST(156.00 AS Decimal(5, 2)), CAST(47.00 AS Decimal(5, 2)), CAST(81.00 AS Decimal(5, 2)), CAST(63.00 AS Decimal(5, 2)), CAST(87.00 AS Decimal(5, 2)), CAST(35.00 AS Decimal(5, 2)), N'S', N'Petite', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (43, 18, CAST(164.00 AS Decimal(5, 2)), CAST(54.00 AS Decimal(5, 2)), CAST(86.00 AS Decimal(5, 2)), CAST(68.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (44, 19, CAST(168.00 AS Decimal(5, 2)), CAST(58.00 AS Decimal(5, 2)), CAST(88.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(94.00 AS Decimal(5, 2)), CAST(39.00 AS Decimal(5, 2)), N'M', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (45, 20, CAST(175.00 AS Decimal(5, 2)), CAST(68.00 AS Decimal(5, 2)), CAST(95.00 AS Decimal(5, 2)), CAST(77.00 AS Decimal(5, 2)), CAST(101.00 AS Decimal(5, 2)), CAST(42.00 AS Decimal(5, 2)), N'XL', N'Full', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (46, 21, CAST(160.00 AS Decimal(5, 2)), CAST(50.00 AS Decimal(5, 2)), CAST(84.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(37.00 AS Decimal(5, 2)), N'S', N'Slim', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (47, 22, CAST(167.00 AS Decimal(5, 2)), CAST(57.00 AS Decimal(5, 2)), CAST(87.00 AS Decimal(5, 2)), CAST(69.00 AS Decimal(5, 2)), CAST(93.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (48, 23, CAST(172.00 AS Decimal(5, 2)), CAST(64.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(74.00 AS Decimal(5, 2)), CAST(98.00 AS Decimal(5, 2)), CAST(41.00 AS Decimal(5, 2)), N'L', N'Athletic', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (49, 24, CAST(158.00 AS Decimal(5, 2)), CAST(48.00 AS Decimal(5, 2)), CAST(82.00 AS Decimal(5, 2)), CAST(64.00 AS Decimal(5, 2)), CAST(88.00 AS Decimal(5, 2)), CAST(36.00 AS Decimal(5, 2)), N'S', N'Petite', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (50, 25, CAST(165.00 AS Decimal(5, 2)), CAST(55.00 AS Decimal(5, 2)), CAST(86.00 AS Decimal(5, 2)), CAST(68.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), CAST(38.00 AS Decimal(5, 2)), N'M', N'Balanced', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (51, 26, CAST(170.00 AS Decimal(5, 2)), CAST(62.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(72.00 AS Decimal(5, 2)), CAST(96.00 AS Decimal(5, 2)), CAST(40.00 AS Decimal(5, 2)), N'L', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (52, 27, CAST(163.00 AS Decimal(5, 2)), CAST(53.00 AS Decimal(5, 2)), CAST(85.00 AS Decimal(5, 2)), CAST(67.00 AS Decimal(5, 2)), CAST(91.00 AS Decimal(5, 2)), CAST(37.00 AS Decimal(5, 2)), N'M', N'Slim', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (53, 28, CAST(169.00 AS Decimal(5, 2)), CAST(59.00 AS Decimal(5, 2)), CAST(89.00 AS Decimal(5, 2)), CAST(71.00 AS Decimal(5, 2)), CAST(95.00 AS Decimal(5, 2)), CAST(39.00 AS Decimal(5, 2)), N'M', N'Hourglass', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (54, 29, CAST(173.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(93.00 AS Decimal(5, 2)), CAST(75.00 AS Decimal(5, 2)), CAST(99.00 AS Decimal(5, 2)), CAST(41.00 AS Decimal(5, 2)), N'L', N'Rectangle', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (55, 30, CAST(176.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(96.00 AS Decimal(5, 2)), CAST(78.00 AS Decimal(5, 2)), CAST(102.00 AS Decimal(5, 2)), CAST(43.00 AS Decimal(5, 2)), N'XL', N'Full', CAST(N'2026-03-02T14:19:17.270' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (56, 30, CAST(176.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(96.00 AS Decimal(5, 2)), CAST(78.00 AS Decimal(5, 2)), CAST(102.00 AS Decimal(5, 2)), CAST(43.00 AS Decimal(5, 2)), N'XL', N'HOURGLASS', CAST(N'2026-03-03T19:59:55.297' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (57, 30, CAST(176.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(96.00 AS Decimal(5, 2)), CAST(78.00 AS Decimal(5, 2)), CAST(102.00 AS Decimal(5, 2)), CAST(43.00 AS Decimal(5, 2)), N'XL', N'HOURGLASS', CAST(N'2026-03-03T20:00:01.243' AS DateTime))
SET IDENTITY_INSERT [dbo].[Customer_Measurements] OFF
GO
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (1, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (1, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (1, 9)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (2, 2)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (2, 6)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (2, 10)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (3, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (3, 8)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (3, 11)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (4, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (4, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (4, 12)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (5, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (5, 7)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (5, 15)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (6, 2)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (6, 6)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (6, 13)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (7, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (7, 9)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (7, 16)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (8, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (8, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (8, 17)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (9, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (9, 8)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (9, 18)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (10, 2)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (10, 6)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (10, 19)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (11, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (11, 7)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (11, 20)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (12, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (12, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (12, 21)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (13, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (13, 10)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (13, 22)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (14, 2)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (14, 11)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (14, 23)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (15, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (15, 12)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (15, 24)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (16, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (16, 9)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (16, 25)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (17, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (17, 6)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (17, 26)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (18, 2)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (18, 7)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (18, 27)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (19, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (19, 8)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (19, 28)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (20, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (20, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (20, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (20, 14)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (21, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (30, 16)
GO
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (1, N'Nguyễn Văn An', N'0909000001', N'an.nguyen@crm.vn', CAST(N'1990-05-12' AS Date), N'MALE', N'Hà Nội', N'Facebook', N'INDIVIDUAL', N'Active', N'GOLD', 555, CAST(35.00 AS Decimal(5, 2)), CAST(N'2026-02-21T19:40:32.487' AS DateTime), 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'CRM, Automation')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (2, N'Trần Thị Bình', N'0909000002', N'binh.tran@crm.vn', CAST(N'1992-08-21' AS Date), N'FEMALE', N'Hồ Chí Minh', N'Website', N'INDIVIDUAL', N'Active', N'PLATINUM', 554, CAST(42.00 AS Decimal(5, 2)), CAST(N'2026-02-26T19:40:32.487' AS DateTime), 3, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Marketing')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (3, N'Lê Hoàng Nam', N'0909000003', N'nam.le@crm.vn', CAST(N'1988-02-03' AS Date), N'MALE', N'Đà Nẵng', N'Referral', N'INDIVIDUAL', N'Active', N'GOLD', 543, CAST(25.00 AS Decimal(5, 2)), CAST(N'2026-02-11T19:40:32.487' AS DateTime), 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Cloud')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (4, N'Phạm Gia Huy', N'0909000004', N'huy.pham@crm.vn', CAST(N'1995-11-10' AS Date), N'MALE', N'Hà Nội', N'Google', N'INDIVIDUAL', N'New', N'SILVER', 534, CAST(20.00 AS Decimal(5, 2)), NULL, 4, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Website')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (5, N'Đỗ Minh Quân', N'0909000005', N'quan.do@crm.vn', CAST(N'1987-07-07' AS Date), N'MALE', N'Hải Phòng', N'Facebook', N'INDIVIDUAL', N'Active', N'GOLD', 525, CAST(30.00 AS Decimal(5, 2)), CAST(N'2026-02-16T19:40:32.487' AS DateTime), 5, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Data')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (6, N'Võ Thu Trang', N'0909000006', N'trang.vo@crm.vn', CAST(N'1993-09-19' AS Date), N'FEMALE', N'Hồ Chí Minh', N'LinkedIn', N'INDIVIDUAL', N'Active', N'PLATINUM', 515, CAST(45.00 AS Decimal(5, 2)), CAST(N'2026-02-28T19:40:32.487' AS DateTime), 3, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'AI')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (7, N'Nguyễn Tuấn Kiệt', N'0909000007', N'kiet.nguyen@crm.vn', CAST(N'1991-12-01' AS Date), N'MALE', N'Cần Thơ', N'Event', N'INDIVIDUAL', N'Active', N'GOLD', 455, CAST(28.00 AS Decimal(5, 2)), CAST(N'2026-02-19T19:40:32.487' AS DateTime), 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'ERP')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (8, N'Bùi Thành Đạt', N'0909000008', N'dat.bui@crm.vn', CAST(N'1996-04-14' AS Date), N'MALE', N'Hà Nội', N'Website', N'INDIVIDUAL', N'Churned', N'SILVER', 444, CAST(20.00 AS Decimal(5, 2)), CAST(N'2025-09-03T19:40:32.487' AS DateTime), 4, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'SEO')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (9, N'Hoàng Lan Chi', N'0909000009', N'chi.hoang@crm.vn', CAST(N'1994-06-22' AS Date), N'FEMALE', N'Đà Nẵng', N'Referral', N'INDIVIDUAL', N'Active', N'GOLD', 435, CAST(22.00 AS Decimal(5, 2)), CAST(N'2026-02-13T19:40:32.487' AS DateTime), 5, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'HRM')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (10, N'Phạm Đức Long', N'0909000010', N'long.pham@crm.vn', CAST(N'1989-03-30' AS Date), N'MALE', N'HCM', N'Facebook', N'INDIVIDUAL', N'Active', N'GOLD', 424, CAST(36.00 AS Decimal(5, 2)), CAST(N'2026-02-22T19:40:32.487' AS DateTime), 3, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Mobile App')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (11, N'Nguyễn Hải Yến', N'0909000011', N'yen.nguyen@crm.vn', CAST(N'1997-01-05' AS Date), N'FEMALE', N'Hà Nội', N'Google', N'INDIVIDUAL', N'New', N'SILVER', 355, CAST(20.00 AS Decimal(5, 2)), NULL, 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Chatbot')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (12, N'Trần Quốc Bảo', N'0909000012', N'bao.tran@crm.vn', CAST(N'1985-10-11' AS Date), N'MALE', N'Bình Dương', N'LinkedIn', N'INDIVIDUAL', N'Active', N'PLATINUM', 344, CAST(40.00 AS Decimal(5, 2)), CAST(N'2026-02-25T19:40:32.487' AS DateTime), 1, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Cybersecurity')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (13, N'Lê Thị Hoa', N'0909000013', N'hoa.le@crm.vn', CAST(N'1993-02-17' AS Date), N'FEMALE', N'Huế', N'Referral', N'INDIVIDUAL', N'Active', N'GOLD', 333, CAST(20.00 AS Decimal(5, 2)), CAST(N'2026-02-09T19:40:32.487' AS DateTime), 4, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Hosting')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (14, N'Võ Minh Tâm', N'0909000014', N'tam.vo@crm.vn', CAST(N'1990-08-09' AS Date), N'MALE', N'Hà Nội', N'Event', N'INDIVIDUAL', N'Active', N'GOLD', 325, CAST(29.00 AS Decimal(5, 2)), CAST(N'2026-02-20T19:40:32.487' AS DateTime), 3, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'BI')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (15, N'Đặng Quang Vinh', N'0909000015', N'vinh.dang@crm.vn', CAST(N'1988-12-25' AS Date), N'MALE', N'HCM', N'Website', N'INDIVIDUAL', N'Active', N'GOLD', 314, CAST(33.00 AS Decimal(5, 2)), CAST(N'2026-02-24T19:40:32.487' AS DateTime), 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Infrastructure')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (16, N'Phan Thu Hà', N'0909000016', N'ha.phan@crm.vn', CAST(N'1996-03-03' AS Date), N'FEMALE', N'Hà Nội', N'Facebook', N'INDIVIDUAL', N'New', N'SILVER', 255, CAST(20.00 AS Decimal(5, 2)), NULL, 5, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'CRM')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (17, N'Nguyễn Đức Mạnh', N'0909000017', N'manh.nguyen@crm.vn', CAST(N'1992-07-28' AS Date), N'MALE', N'Hải Dương', N'Google', N'INDIVIDUAL', N'Active', N'GOLD', 244, CAST(18.00 AS Decimal(5, 2)), CAST(N'2026-02-06T19:40:32.487' AS DateTime), 1, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Digital Transformation')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (18, N'Trịnh Bảo Châu', N'0909000018', N'chau.trinh@crm.vn', CAST(N'1995-09-09' AS Date), N'FEMALE', N'HCM', N'Website', N'INDIVIDUAL', N'Churned', N'SILVER', 233, CAST(20.00 AS Decimal(5, 2)), CAST(N'2025-10-03T19:40:32.487' AS DateTime), 4, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Landing Page')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (19, N'Lê Anh Tuấn', N'0909000019', N'tuan.le@crm.vn', CAST(N'1987-05-15' AS Date), N'MALE', N'Quảng Ninh', N'Referral', N'INDIVIDUAL', N'Active', N'GOLD', 155, CAST(37.00 AS Decimal(5, 2)), CAST(N'2026-02-27T19:40:32.487' AS DateTime), 3, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'Testing')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (20, N'Phạm Ngọc Mai', N'0909000020', N'mai.pham@crm.vn', CAST(N'1998-11-02' AS Date), N'FEMALE', N'Hà Nội', N'Facebook', N'INDIVIDUAL', N'Active', N'PLATINUM', 111, CAST(44.00 AS Decimal(5, 2)), CAST(N'2026-03-01T19:40:32.487' AS DateTime), 2, CAST(N'2026-03-03T19:40:32.487' AS DateTime), CAST(N'2026-03-03T19:40:32.487' AS DateTime), N'E-commerce')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (21, N'Nguyễn Hải Yến', N'0909001021', N'yen.nguyen21@gmail.com', CAST(N'1995-03-12' AS Date), N'FEMALE', N'Hà Nội', N'Facebook', N'INDIVIDUAL', N'Active', N'GOLD', 555, CAST(52.00 AS Decimal(5, 2)), CAST(N'2026-02-26T19:41:15.730' AS DateTime), 2, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Váy dạ hội')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (22, N'Trần Minh Thu', N'0909001022', N'thu.tran22@gmail.com', CAST(N'1992-07-21' AS Date), N'FEMALE', N'Hải Phòng', N'Website', N'INDIVIDUAL', N'Active', N'SILVER', 534, CAST(35.00 AS Decimal(5, 2)), CAST(N'2026-02-19T19:41:15.730' AS DateTime), 3, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Đầm công sở')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (23, N'Lê Hoàng Anh', N'0909001023', N'anh.le23@gmail.com', CAST(N'1990-11-05' AS Date), N'FEMALE', N'Quảng Ninh', N'TikTok', N'INDIVIDUAL', N'Active', N'GOLD', 455, CAST(40.00 AS Decimal(5, 2)), CAST(N'2026-02-13T19:41:15.730' AS DateTime), 2, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Đầm thiết kế')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (24, N'Phạm Ngọc Mai', N'0909001024', N'mai.pham24@gmail.com', CAST(N'1996-09-18' AS Date), N'FEMALE', N'Hà Nội', N'Instagram', N'INDIVIDUAL', N'Active', N'PLATINUM', 545, CAST(58.00 AS Decimal(5, 2)), CAST(N'2026-02-28T19:41:15.730' AS DateTime), 1, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Váy cưới')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (25, N'Đỗ Thanh Huyền', N'0909001025', N'huyen.do25@gmail.com', CAST(N'1993-01-30' AS Date), N'FEMALE', N'Bắc Ninh', N'Referral', N'INDIVIDUAL', N'Active', N'GOLD', 444, CAST(30.00 AS Decimal(5, 2)), CAST(N'2026-02-06T19:41:15.730' AS DateTime), 3, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Đầm dự tiệc')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (26, N'Vũ Khánh Linh', N'0909001026', N'linh.vu26@gmail.com', CAST(N'1998-06-14' AS Date), N'FEMALE', N'Hà Nội', N'Facebook', N'INDIVIDUAL', N'Active', N'SILVER', 355, CAST(25.00 AS Decimal(5, 2)), CAST(N'2026-01-22T19:41:15.730' AS DateTime), 2, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Váy trẻ trung')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (27, N'Bùi Thu Trang', N'0909001027', N'trang.bui27@gmail.com', CAST(N'1994-04-09' AS Date), N'FEMALE', N'Hải Dương', N'Website', N'INDIVIDUAL', N'Active', N'GOLD', 454, CAST(43.00 AS Decimal(5, 2)), CAST(N'2026-02-15T19:41:15.730' AS DateTime), 1, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Đầm công sở')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (28, N'Ngô Diễm Quỳnh', N'0909001028', N'quynh.ngo28@gmail.com', CAST(N'1997-12-02' AS Date), N'FEMALE', N'Hà Nội', N'TikTok', N'INDIVIDUAL', N'Active', N'PLATINUM', 544, CAST(60.00 AS Decimal(5, 2)), CAST(N'2026-03-01T19:41:15.730' AS DateTime), 2, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Váy cao cấp')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (29, N'Hoàng Mỹ Dung', N'0909001029', N'dung.hoang29@gmail.com', CAST(N'1991-08-27' AS Date), N'FEMALE', N'Quảng Ninh', N'Referral', N'INDIVIDUAL', N'Active', N'BLACKLIST', 435, CAST(37.00 AS Decimal(5, 2)), CAST(N'2026-02-09T19:41:15.730' AS DateTime), 3, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T19:41:15.730' AS DateTime), N'Đầm dạ hội')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (30, N'Đặng Phương Thảo', N'0909001030', N'thao.dang30@gmail.com', CAST(N'1995-05-11' AS Date), N'FEMALE', N'Hà Nội', N'Instagram', N'INDIVIDUAL', N'Active', N'BRONZE', 344, CAST(22.00 AS Decimal(5, 2)), CAST(N'2026-01-27T19:41:15.730' AS DateTime), 1, CAST(N'2026-03-03T19:41:15.730' AS DateTime), CAST(N'2026-03-03T20:00:01.240' AS DateTime), N'Váy đi chơi')
SET IDENTITY_INSERT [dbo].[Customers] OFF
GO
SET IDENTITY_INSERT [dbo].[Deals] ON 

INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (18, 3, 3, N'Website Maintenance 2025', CAST(3000.00 AS Decimal(15, 2)), CAST(3000.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-01-15' AS Date), 2, CAST(N'2026-01-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (19, 5, 5, N'Cloud Setup Phase 1', CAST(9500.00 AS Decimal(15, 2)), CAST(9200.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-01-28' AS Date), 3, CAST(N'2026-01-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (20, 8, 8, N'UI/UX Redesign', CAST(4200.00 AS Decimal(15, 2)), CAST(4200.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-02-02' AS Date), 4, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (21, 10, 10, N'Analytics Integration', CAST(7600.00 AS Decimal(15, 2)), CAST(7500.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-02-10' AS Date), 2, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (22, 12, 12, N'Infrastructure Modernization', CAST(15000.00 AS Decimal(15, 2)), CAST(14800.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-02-18' AS Date), 1, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (23, 15, 15, N'Email Automation Upgrade', CAST(2800.00 AS Decimal(15, 2)), CAST(2800.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-02-25' AS Date), 5, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (24, 18, 18, N'Customer Support Portal', CAST(6700.00 AS Decimal(15, 2)), CAST(6600.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2026-02-26' AS Date), 3, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (25, 2, 2, N'CRM Basic Package', CAST(5000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), N'Closed Lost', 0, CAST(N'2026-01-20' AS Date), 4, CAST(N'2026-01-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (26, 6, 6, N'Server Upgrade', CAST(8800.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), N'Closed Lost', 0, CAST(N'2026-01-30' AS Date), 5, CAST(N'2026-01-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (27, 7, 7, N'HR Digitalization', CAST(7200.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), N'Closed Lost', 0, CAST(N'2026-02-05' AS Date), 2, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (28, 9, 9, N'Mobile App Phase 1', CAST(11000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), N'Closed Lost', 0, CAST(N'2026-02-11' AS Date), 3, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (29, 11, 11, N'Security Hardening', CAST(3900.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), N'Closed Lost', 0, CAST(N'2026-02-14' AS Date), 1, CAST(N'2026-02-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (30, 3, NULL, N'Website Maintenance 2024', CAST(2500.00 AS Decimal(15, 2)), CAST(2500.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2025-11-10' AS Date), 2, CAST(N'2025-11-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (31, 3, NULL, N'Hosting Renewal', CAST(1200.00 AS Decimal(15, 2)), CAST(1200.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2025-08-05' AS Date), 2, CAST(N'2025-08-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (32, 5, NULL, N'Cloud Subscription Renewal', CAST(4000.00 AS Decimal(15, 2)), CAST(4000.00 AS Decimal(15, 2)), N'Closed Won', 100, CAST(N'2025-09-12' AS Date), 3, CAST(N'2025-09-02T13:31:56.590' AS DateTime), CAST(N'2026-03-02T13:31:56.590' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (35, 2, 2, N'CRM Implementation', CAST(8000.00 AS Decimal(15, 2)), NULL, N'Qualified', 40, CAST(N'2026-04-15' AS Date), 3, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (36, 3, 3, N'Marketing Automation Setup', CAST(5200.00 AS Decimal(15, 2)), NULL, N'Proposal', 60, CAST(N'2026-04-01' AS Date), 2, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (37, 4, 4, N'SEO Optimization', CAST(2300.00 AS Decimal(15, 2)), NULL, N'Negotiation', 75, CAST(N'2026-03-20' AS Date), 4, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (38, 5, 5, N'Cloud Migration', CAST(12000.00 AS Decimal(15, 2)), NULL, N'Qualified', 50, CAST(N'2026-05-10' AS Date), 3, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (39, 6, 6, N'IT Support Annual Contract', CAST(6400.00 AS Decimal(15, 2)), NULL, N'Prospecting', 25, CAST(N'2026-04-25' AS Date), 5, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (40, 7, 7, N'HR Management System', CAST(9100.00 AS Decimal(15, 2)), NULL, N'Proposal', 65, CAST(N'2026-04-18' AS Date), 2, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (41, 8, 8, N'E-commerce Development', CAST(15000.00 AS Decimal(15, 2)), NULL, N'Negotiation', 80, CAST(N'2026-03-28' AS Date), 4, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (42, 9, 9, N'Mobile App Development', CAST(20000.00 AS Decimal(15, 2)), NULL, N'Qualified', 55, CAST(N'2026-05-30' AS Date), 3, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (43, 10, 10, N'Data Analytics Dashboard', CAST(7000.00 AS Decimal(15, 2)), NULL, N'Proposal', 60, CAST(N'2026-04-12' AS Date), 2, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (44, 11, 11, N'Cybersecurity Audit', CAST(4800.00 AS Decimal(15, 2)), NULL, N'Prospecting', 30, CAST(N'2026-04-05' AS Date), 5, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (45, 12, 12, N'Network Infrastructure Upgrade', CAST(11000.00 AS Decimal(15, 2)), NULL, N'Qualified', 50, CAST(N'2026-05-01' AS Date), 4, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (46, 13, 13, N'AI Chatbot Integration', CAST(7600.00 AS Decimal(15, 2)), NULL, N'Proposal', 70, CAST(N'2026-04-22' AS Date), 3, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (47, 14, 14, N'Business Intelligence Setup', CAST(9800.00 AS Decimal(15, 2)), NULL, N'Negotiation', 75, CAST(N'2026-03-27' AS Date), 2, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (48, 15, 15, N'Email Marketing System', CAST(3100.00 AS Decimal(15, 2)), NULL, N'Qualified', 45, CAST(N'2026-04-09' AS Date), 5, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (49, 16, 16, N'ERP Customization', CAST(13400.00 AS Decimal(15, 2)), NULL, N'Proposal', 65, CAST(N'2026-05-14' AS Date), 4, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (50, 17, 17, N'Landing Page Optimization', CAST(2100.00 AS Decimal(15, 2)), NULL, N'Prospecting', 20, CAST(N'2026-03-25' AS Date), 3, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (51, 18, 18, N'Customer Portal Development', CAST(8700.00 AS Decimal(15, 2)), NULL, N'Qualified', 55, CAST(N'2026-04-30' AS Date), 2, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (52, 19, 19, N'Performance Monitoring System', CAST(6900.00 AS Decimal(15, 2)), NULL, N'Negotiation', 78, CAST(N'2026-04-03' AS Date), 5, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
INSERT [dbo].[Deals] ([deal_id], [customer_id], [lead_id], [deal_name], [expected_value], [actual_value], [stage], [probability], [expected_close_date], [owner_id], [created_at], [updated_at]) VALUES (53, 20, 20, N'Digital Transformation Consulting', CAST(25000.00 AS Decimal(15, 2)), NULL, N'Proposal', 68, CAST(N'2026-06-01' AS Date), 1, CAST(N'2026-03-02T13:37:03.097' AS DateTime), CAST(N'2026-03-02T13:37:03.097' AS DateTime))
SET IDENTITY_INSERT [dbo].[Deals] OFF
GO
SET IDENTITY_INSERT [dbo].[Leads] ON 
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (1, N'Nguyen Van An', N'an.nguyen@gmail.com', N'0901000001', N'Ao thun', N'Website', N'Qualified', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (2, N'Tran Thi Binh', N'binh.tran@gmail.com', N'0901000002', N'', N'Facebook', N'QUALIFIED', 2, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:25.277' AS DateTime), 70, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (3, N'Le Hoang Nam', N'nam.le@gmail.com', N'0901000003', N'Ao khoac', N'Referral', N'Nurturing', 3, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 60, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (4, N'Pham Gia Huy', N'huy.pham@gmail.com', N'', N'', N'Website', N'NURTURING', 4, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:31.657' AS DateTime), 40, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (5, N'Do Minh Quan', NULL, N'0901000005', NULL, N'LinkedIn', N'New', 5, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (6, N'Vo Thu Trang', NULL, NULL, NULL, N'Facebook', N'New', 6, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 20, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (7, N'Nguyen Tuan Kiet', NULL, N'abc123', NULL, N'Seminar', N'Lost', 7, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (8, N'Bui Thanh Dat', NULL, NULL, NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 18, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (9, N'Hoang Lan Chi', N'chi.hoang@gmail.com', N'0901000009', N'Chan vay', N'Referral', N'Qualified', 9, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (10, N'Pham Duc Long', N'long.pham@gmail.com', N'0901000010', N'', N'Facebook', N'QUALIFIED', 10, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:38.807' AS DateTime), 70, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (11, N'Nguyen Hai Yen', N'yen.nguyen@gmail.com', NULL, NULL, N'Website', N'New', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (12, N'Tran Quoc Bao', N'bao.tran@gmail.com', N'0901000012', N'Ao blazer', N'LinkedIn', N'Qualified', 2, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (13, N'Le Thi Hoa', N'hoa.le@gmail.com', N'0901000013', N'', N'Referral', N'QUALIFIED', 3, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:48.693' AS DateTime), 70, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (14, N'Vo Minh Tam', N'tam.vo@gmail.com', N'0901000014', NULL, N'Seminar', N'Nurturing', 4, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (15, N'Dang Quang Vinh', N'vinh.dang@gmail.com', NULL, NULL, N'Website', N'New', 5, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (16, N'Phan Thu Ha', N'ha.phan@gmail.com', N'0901000016', N'Dam du tiec', N'Facebook', N'Qualified', 6, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (17, N'Nguyen Duc Manh', N'manh.nguyen@gmail.com', N'0901000017', NULL, N'LinkedIn', N'Nurturing', 7, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (18, N'Trinh Bao Chau', NULL, N'abc999', NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (19, N'Le Anh Tuan', N'tuan.le@gmail.com', N'0901000019', N'Quan kaki', N'Referral', N'Qualified', 9, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (20, N'Pham Ngoc Mai', N'mai.pham@gmail.com', N'0901000020', NULL, N'Facebook', N'Nurturing', 10, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)SET IDENTITY_INSERT [dbo].[Leads] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (1, N'ADMIN', N'Qu?n tr? h? th?ng', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (2, N'SALE', N'Nhân viên kinh doanh', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (3, N'MARKETING', N'Nhân viên marketing', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (4, N'CS', N'Customer Support', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (5, N'MANAGER', N'Qu?n l?', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Style_Tags] ON 

INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (1, N'#Vintage', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (2, N'#Minimalism', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (3, N'#Streetwear', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (4, N'#Office', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (5, N'#Pastel', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (6, N'#DarkTone', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (7, N'#Silk', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (8, N'#Denim', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (9, N'#Elegant', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (10, N'#Classic', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (11, N'#Sporty', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (12, N'#Bohemian', N'Style')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (13, N'#Neutral', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (14, N'#WarmTone', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (15, N'#CoolTone', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (16, N'#Monochrome', N'Color')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (17, N'#Cotton', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (18, N'#Linen', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (19, N'#Leather', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (20, N'#Wool', N'Material')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (21, N'#Party', N'Occasion')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (22, N'#Casual', N'Occasion')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (23, N'#Formal', N'Occasion')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (24, N'#Floral', N'Pattern')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (25, N'#Checked', N'Pattern')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (26, N'#Solid', N'Pattern')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (27, N'#Summer', N'Season')
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (28, N'#Winter', N'Season')
SET IDENTITY_INSERT [dbo].[Style_Tags] OFF
GO
INSERT [dbo].[Task_Assignees] ([task_id], [user_id], [assigned_at]) VALUES (1, 2, CAST(N'2026-03-03T19:14:42.110' AS DateTime))
INSERT [dbo].[Task_Assignees] ([task_id], [user_id], [assigned_at]) VALUES (1, 3, CAST(N'2026-03-03T19:14:42.110' AS DateTime))
INSERT [dbo].[Task_Assignees] ([task_id], [user_id], [assigned_at]) VALUES (2, 1, CAST(N'2026-03-03T19:14:42.110' AS DateTime))
INSERT [dbo].[Task_Assignees] ([task_id], [user_id], [assigned_at]) VALUES (3, 2, CAST(N'2026-03-03T19:14:42.110' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Tasks] ON

INSERT [dbo].[Tasks]
([task_id], [title], [description], [status], [priority], [due_date], [progress], [created_by], [created_at], [start_date], [completed_at], [updated_at])
VALUES
(1, N'Design CRM Database', 
N'Design full schema for CRM system including ERD',
N'In Progress',
N'High',
CAST('2026-03-10 17:00:00' AS DATETIME),
40,
1,
CAST('2026-03-03 09:00:00' AS DATETIME),
NULL,
NULL,
NULL),

(2, N'Create Contacts Module',
N'Implement contacts table and API',
N'Pending',
N'Medium',
CAST('2026-03-12 17:00:00' AS DATETIME),
0,
2,
CAST('2026-03-05 10:00:00' AS DATETIME),
CAST('2026-03-06 09:00:00' AS DATETIME),
NULL,
NULL),

(3, N'Call Potential Customer',
N'Follow up with lead from marketing campaign',
N'Completed',
N'High',
CAST('2026-03-06 15:00:00' AS DATETIME),
100,
3,
CAST('2026-03-04 11:00:00' AS DATETIME),
CAST('2026-03-05 09:00:00' AS DATETIME),
CAST('2026-03-05 14:30:00' AS DATETIME),
CAST('2026-03-05 14:30:00' AS DATETIME)),

(4, N'Prepare Product Demo',
N'Prepare demo environment for CRM presentation',
N'In Progress',
N'High',
CAST('2026-03-11 16:00:00' AS DATETIME),
60,
2,
CAST('2026-03-06 09:30:00' AS DATETIME),
CAST('2026-03-07 08:30:00' AS DATETIME),
NULL,
CAST('2026-03-07 15:00:00' AS DATETIME)),

(5, N'Send Proposal Email',
N'Send quotation and proposal to client',
N'Pending',
N'Low',
CAST('2026-03-13 10:00:00' AS DATETIME),
0,
1,
CAST('2026-03-07 13:00:00' AS DATETIME),
CAST('2026-03-08 09:00:00' AS DATETIME),
NULL,
NULL)

SET IDENTITY_INSERT [dbo].[Tasks] OFF
GO
SET IDENTITY_INSERT [dbo].[Tickets] ON 

INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (1, 1, N'Lỗi gửi OTP nhiều lần', N'Hệ thống gửi OTP quá nhiều lần.', N'MEDIUM', N'OPEN', NULL, CAST(N'2026-02-28T14:51:03.783' AS DateTime), CAST(N'2026-02-28T14:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (2, 1, N'Không nhận được email xác nhận', N'Tôi không nhận được email kích hoạt tài khoản.', N'HIGH', N'OPEN', 1, CAST(N'2026-02-28T11:51:03.783' AS DateTime), CAST(N'2026-02-28T12:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (3, 1, N'Tài khoản bị khóa', N'Tôi đăng nhập sai nhiều lần và bị khóa.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-27T16:51:03.783' AS DateTime), CAST(N'2026-02-28T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (4, 1, N'Không cập nhật được thông tin cá nhân', N'Tôi không thể sửa số điện thoại.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-26T16:51:03.783' AS DateTime), CAST(N'2026-02-26T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (5, 1, N'Yêu cầu hoàn tiền', N'Tôi muốn hoàn tiền cho đơn hàng #1234.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-25T16:51:03.783' AS DateTime), CAST(N'2026-02-28T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (6, 1, N'Giao hàng chậm', N'Đơn hàng của tôi bị giao trễ 5 ngày.', N'MEDIUM', N'RESOLVED', 1, CAST(N'2026-02-22T16:51:03.783' AS DateTime), CAST(N'2026-02-23T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (7, 1, N'Sản phẩm bị lỗi', N'Sản phẩm nhận được bị hỏng.', N'HIGH', N'RESOLVED', 1, CAST(N'2026-02-21T16:51:03.783' AS DateTime), CAST(N'2026-02-22T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (8, 1, N'Yêu cầu xuất hóa đơn', N'Tôi cần xuất hóa đơn VAT.', N'LOW', N'CLOSED', 1, CAST(N'2026-02-18T16:51:03.783' AS DateTime), CAST(N'2026-02-19T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (9, 2, N'Đổi mật khẩu không thành công', N'Tôi không đổi được mật khẩu.', N'MEDIUM', N'OPEN', NULL, CAST(N'2026-02-27T16:51:03.783' AS DateTime), CAST(N'2026-02-27T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (10, 3, N'App bị crash', N'Ứng dụng bị crash khi mở.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-28T06:51:03.783' AS DateTime), CAST(N'2026-02-28T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (11, 1, N'Tư vấn sản phẩm', N'Tôi cần tư vấn sản phẩm mới.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-24T16:51:03.783' AS DateTime), CAST(N'2026-02-24T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (12, 1, N'Không thêm được địa chỉ giao hàng', N'Hệ thống báo lỗi khi thêm địa chỉ.', N'MEDIUM', N'IN_PROGRESS', 1, CAST(N'2026-02-26T16:51:03.783' AS DateTime), CAST(N'2026-02-28T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (13, 1, N'Yêu cầu hủy đơn hàng', N'Tôi muốn hủy đơn trước khi giao.', N'HIGH', N'RESOLVED', 1, CAST(N'2026-02-20T16:51:03.783' AS DateTime), CAST(N'2026-02-21T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (14, 1, N'Lỗi hiển thị trên mobile', N'Giao diện mobile bị vỡ layout.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-28T13:51:03.783' AS DateTime), CAST(N'2026-02-28T13:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (15, 1, N'Không áp dụng được mã giảm giá', N'Tôi nhập mã nhưng hệ thống báo sai.', N'MEDIUM', N'CLOSED', 1, CAST(N'2026-02-16T16:51:03.783' AS DateTime), CAST(N'2026-02-17T16:51:03.783' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (16, 1, N'Lỗi gửi OTP nhiều lần', N'Hệ thống gửi OTP quá nhiều lần.', N'MEDIUM', N'OPEN', NULL, CAST(N'2026-02-28T14:57:07.203' AS DateTime), CAST(N'2026-02-28T14:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (17, 1, N'Không nhận được email xác nhận', N'Tôi không nhận được email kích hoạt tài khoản.', N'HIGH', N'OPEN', 1, CAST(N'2026-02-28T11:57:07.203' AS DateTime), CAST(N'2026-02-28T12:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (18, 1, N'Tài khoản bị khóa', N'Tôi đăng nhập sai nhiều lần và bị khóa.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-27T16:57:07.203' AS DateTime), CAST(N'2026-02-28T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (19, 1, N'Không cập nhật được thông tin cá nhân', N'Tôi không thể sửa số điện thoại.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-26T16:57:07.203' AS DateTime), CAST(N'2026-02-26T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (20, 1, N'Yêu cầu hoàn tiền', N'Tôi muốn hoàn tiền cho đơn hàng #1234.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-25T16:57:07.203' AS DateTime), CAST(N'2026-02-28T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (21, 1, N'Giao hàng chậm', N'Đơn hàng của tôi bị giao trễ 5 ngày.', N'MEDIUM', N'RESOLVED', 1, CAST(N'2026-02-22T16:57:07.203' AS DateTime), CAST(N'2026-02-23T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (22, 1, N'Sản phẩm bị lỗi', N'Sản phẩm nhận được bị hỏng.', N'HIGH', N'RESOLVED', 1, CAST(N'2026-02-21T16:57:07.203' AS DateTime), CAST(N'2026-02-22T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (23, 1, N'Yêu cầu xuất hóa đơn', N'Tôi cần xuất hóa đơn VAT.', N'LOW', N'CLOSED', 1, CAST(N'2026-02-18T16:57:07.203' AS DateTime), CAST(N'2026-02-19T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (24, 2, N'Đổi mật khẩu không thành công', N'Tôi không đổi được mật khẩu.', N'MEDIUM', N'OPEN', NULL, CAST(N'2026-02-27T16:57:07.203' AS DateTime), CAST(N'2026-02-27T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (25, 3, N'App bị crash', N'Ứng dụng bị crash khi mở.', N'HIGH', N'IN_PROGRESS', 1, CAST(N'2026-02-28T06:57:07.203' AS DateTime), CAST(N'2026-02-28T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (26, 1, N'Tư vấn sản phẩm', N'Tôi cần tư vấn sản phẩm mới.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-24T16:57:07.203' AS DateTime), CAST(N'2026-02-24T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (27, 1, N'Không thêm được địa chỉ giao hàng', N'Hệ thống báo lỗi khi thêm địa chỉ.', N'MEDIUM', N'IN_PROGRESS', 1, CAST(N'2026-02-26T16:57:07.203' AS DateTime), CAST(N'2026-02-28T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (28, 1, N'Yêu cầu hủy đơn hàng', N'Tôi muốn hủy đơn trước khi giao.', N'HIGH', N'RESOLVED', 1, CAST(N'2026-02-20T16:57:07.203' AS DateTime), CAST(N'2026-02-21T16:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (29, 1, N'Lỗi hiển thị trên mobile', N'Giao diện mobile bị vỡ layout.', N'LOW', N'OPEN', NULL, CAST(N'2026-02-28T13:57:07.203' AS DateTime), CAST(N'2026-02-28T13:57:07.203' AS DateTime))
INSERT [dbo].[Tickets] ([ticket_id], [customer_id], [subject], [description], [priority], [status], [assigned_to], [created_at], [updated_at]) VALUES (30, 1, N'Không áp dụng được mã giảm giá', N'Tôi nhập mã nhưng hệ thống báo sai.', N'MEDIUM', N'CLOSED', 1, CAST(N'2026-02-16T16:57:07.203' AS DateTime), CAST(N'2026-02-17T16:57:07.203' AS DateTime))
SET IDENTITY_INSERT [dbo].[Tickets] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (1, N'admin', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'admin@crm.com', N'Admin', N'0900000001', 1, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-03T19:14:54.677' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (2, N'sale01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'sale01@crm.com', N'Sale', N'0900000002', 2, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (3, N'mkt01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mkt01@crm.com', N'Marketing', N'0900000003', 3, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-03T19:15:03.503' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (4, N'cs01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'cs01@crm.com', N'CS', N'0900000004', 4, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (5, N'mng01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mng01@crm.com', N'Manager', N'0900000004', 5, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (6, N'locked_user', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'lock@crm.com', N'User Bị Khóa', N'0900000005', 2, N'LOCKED', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (7, N'change_pass', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'changepass@gmail.com', N'User Change Pass', N'0909999999', 1, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
-- ============================================================
-- SEED DATA - Dữ liệu giả lập cho 17 bảng chưa có data
-- Copy toàn bộ nội dung này và PASTE VÀO CUỐI full_script.sql
-- ============================================================
-- Thứ tự INSERT đảm bảo FK hợp lệ:
--   Products → Categories → Category_Products
--   Customer_Segments → Customer_Segment_Map
--   CustomerOTP
--   Campaign_Leads → Campaign_Reports
--   Deal_Products
--   Virtual_Wardrobe
--   Feedbacks
--   Service_Reports
--   Notifications → Notification_Recipients → Notification_Rules
--   Task_History → Task_History_Detail
-- ============================================================


-- ============================================================
-- 1. Products
-- ============================================================
SET IDENTITY_INSERT [dbo].[Products] ON
GO
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (1, N'Váy Dạ Hội Luxury Rouge', N'VDH-001', CAST(4500000.00 AS Decimal(15,2)), N'Váy dạ hội thiết kế cao cấp, chất liệu lụa nhập khẩu, màu đỏ rượu', N'active', CAST(N'2026-01-10T08:00:00' AS DateTime), CAST(N'2026-02-01T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (2, N'Đầm Công Sở Sapphire', N'DCS-002', CAST(1850000.00 AS Decimal(15,2)), N'Đầm công sở thanh lịch, vải tweed, màu xanh sapphire', N'active', CAST(N'2026-01-10T08:00:00' AS DateTime), CAST(N'2026-02-01T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (3, N'Váy Cưới Ivory Princess', N'VC-003', CAST(12000000.00 AS Decimal(15,2)), N'Váy cưới công chúa, ren Pháp, đuôi dài 1.5m, màu trắng ngà', N'active', CAST(N'2026-01-10T08:00:00' AS DateTime), CAST(N'2026-02-01T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (4, N'Đầm Thiết Kế Bohemian Sunset', N'DTK-004', CAST(2200000.00 AS Decimal(15,2)), N'Đầm thiết kế phong cách boho, in hoạ tiết hoa, chất voan mềm', N'active', CAST(N'2026-01-15T08:00:00' AS DateTime), CAST(N'2026-02-10T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (5, N'Váy Dự Tiệc Midnight Sequin', N'VDT-005', CAST(3100000.00 AS Decimal(15,2)), N'Váy dự tiệc đính sequin ánh bạc, dáng ôm, phù hợp sự kiện', N'active', CAST(N'2026-01-15T08:00:00' AS DateTime), CAST(N'2026-02-10T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (6, N'Đầm Trẻ Trung Summer Blossom', N'DTT-006', CAST(980000.00 AS Decimal(15,2)), N'Đầm hoa nhí tươi tắn, chất cotton mềm, phù hợp đi chơi ngày hè', N'active', CAST(N'2026-01-20T08:00:00' AS DateTime), CAST(N'2026-02-15T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (7, N'Váy Cao Cấp Velvet Noir', N'VCC-007', CAST(5800000.00 AS Decimal(15,2)), N'Váy nhung đen cao cấp, cổ V sâu, phù hợp tiệc tối sang trọng', N'active', CAST(N'2026-01-20T08:00:00' AS DateTime), CAST(N'2026-02-15T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (8, N'Đầm Công Sở Minimalist Grey', N'DCS-008', CAST(1650000.00 AS Decimal(15,2)), N'Đầm công sở tối giản, màu xám đậm, chất liệu polyester cao cấp', N'active', CAST(N'2026-02-01T08:00:00' AS DateTime), CAST(N'2026-02-20T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (9, N'Váy Vintage Floral Midi', N'VVT-009', CAST(1350000.00 AS Decimal(15,2)), N'Váy midi vintage họa tiết hoa retro, chất linen thoáng mát', N'active', CAST(N'2026-02-01T08:00:00' AS DateTime), CAST(N'2026-02-20T08:00:00' AS DateTime))
INSERT [dbo].[Products] ([product_id],[name],[sku],[price],[description],[status],[created_at],[updated_at]) VALUES (10, N'Đầm Dạ Hội Pearl Gown', N'DDH-010', CAST(7500000.00 AS Decimal(15,2)), N'Đầm gown dạ hội đính ngọc trai thủ công, dáng xoè, chất satin', N'active', CAST(N'2026-02-05T08:00:00' AS DateTime), CAST(N'2026-03-01T08:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Products] OFF
GO

-- ============================================================
-- 2. Categories
-- ============================================================
SET IDENTITY_INSERT [dbo].[Categories] ON
GO

INSERT [dbo].[Categories] ([category_id],[category_name],[description],[status],[created_at]) VALUES 
(1, N'Áo sơ mi', N'Các loại áo sơ mi nam và nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(2, N'Quần jeans', N'Quần jeans thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(3, N'Váy đầm', N'Váy đầm công sở và dạo phố', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(4, N'Áo khoác', N'Áo khoác mùa đông', N'INACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(5, N'Phụ kiện', N'Phụ kiện thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),

(6, N'Áo thun', N'Áo thun nam nữ nhiều mẫu mã', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(7, N'Áo polo', N'Áo polo lịch sự và trẻ trung', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(8, N'Quần short', N'Quần short thể thao và dạo phố', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(9, N'Quần tây', N'Quần tây công sở nam nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(10, N'Áo hoodie', N'Áo hoodie phong cách streetwear', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),

(11, N'Áo len', N'Áo len giữ ấm mùa đông', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(12, N'Áo vest', N'Áo vest công sở cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(13, N'Đồ thể thao', N'Trang phục thể thao năng động', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(14, N'Đồ ngủ', N'Đồ ngủ thoải mái tại nhà', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(15, N'Đồ lót', N'Đồ lót nam nữ cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),

(16, N'Balo', N'Balo thời trang và du lịch', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(17, N'Túi xách', N'Túi xách nữ thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(18, N'Giày sneaker', N'Giày sneaker năng động', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(19, N'Giày cao gót', N'Giày cao gót nữ sang trọng', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(20, N'Dép sandal', N'Dép sandal mùa hè', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),

(21, N'Mũ nón', N'Mũ thời trang các loại', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(22, N'Khăn choàng', N'Khăn choàng cổ mùa đông', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(23, N'Thắt lưng', N'Thắt lưng da cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(24, N'Đồng hồ', N'Đồng hồ thời trang nam nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime)),
(25, N'Kính mát', N'Kính mát chống tia UV', N'ACTIVE', CAST(N'2026-01-05T08:00:00' AS DateTime))

SET IDENTITY_INSERT [dbo].[Categories] OFF
GO

-- ============================================================
-- 3. Category_Products
-- ============================================================
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (1, 1)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (1, 5)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (1, 7)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (1, 10)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (2, 2)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (2, 8)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (3, 3)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (4, 4)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (4, 9)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (5, 6)
INSERT [dbo].[Category_Products] ([category_id],[product_id]) VALUES (5, 9)
GO

-- ============================================================
-- 4. Customer_Segments
-- ============================================================
SET IDENTITY_INSERT [dbo].[Customer_Segments] ON
GO
INSERT [dbo].[Customer_Segments] ([segment_id],[segment_name],[criteria_logic]) VALUES (1, N'VIP Platinum', N'loyalty_tier = ''PLATINUM'' AND rfm_score >= 500')
INSERT [dbo].[Customer_Segments] ([segment_id],[segment_name],[criteria_logic]) VALUES (2, N'Khách Hàng Vàng', N'loyalty_tier = ''GOLD'' AND rfm_score BETWEEN 300 AND 499')
INSERT [dbo].[Customer_Segments] ([segment_id],[segment_name],[criteria_logic]) VALUES (3, N'Khách Hàng Mới', N'status = ''New'' AND created_at >= DATEADD(MONTH,-3,GETDATE())')
INSERT [dbo].[Customer_Segments] ([segment_id],[segment_name],[criteria_logic]) VALUES (4, N'Khách Hàng Rời Bỏ', N'status = ''Churned'' OR last_purchase < DATEADD(MONTH,-6,GETDATE())')
INSERT [dbo].[Customer_Segments] ([segment_id],[segment_name],[criteria_logic]) VALUES (5, N'Khách Hàng Tiềm Năng', N'return_rate >= 40.0 AND loyalty_tier != ''BLACKLIST''')
SET IDENTITY_INSERT [dbo].[Customer_Segments] OFF
GO

-- ============================================================
-- 5. Customer_Segment_Map  (customer_id 1-30 đều hợp lệ)
-- ============================================================
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (2,  1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (6,  1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (12, 1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (20, 1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (24, 1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (28, 1, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (1,  2, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (3,  2, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (5,  2, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (7,  2, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (23, 2, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (4,  3, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (11, 3, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (16, 3, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (8,  4, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (18, 4, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (2,  5, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (6,  5, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (21, 5, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (24, 5, CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Customer_Segment_Map] ([customer_id],[segment_id],[assigned_at]) VALUES (28, 5, CAST(N'2026-03-01T08:00:00' AS DateTime))
GO

-- ============================================================
-- 6. CustomerOTP  (customer_id FK → Customers, PK = customer_id, không có IDENTITY)
-- ============================================================
INSERT [dbo].[CustomerOTP] ([customer_id],[otp_hash],[otp_expired_at],[failed_attempt],[send_count],[last_send]) VALUES (1,  N'$2a$12$hashCustomer01saltABCDEFGHIJKLM', CAST(N'2026-03-09T10:00:00' AS DateTime2), 0, 1, CAST(N'2026-03-08T09:55:00' AS DateTime2))
INSERT [dbo].[CustomerOTP] ([customer_id],[otp_hash],[otp_expired_at],[failed_attempt],[send_count],[last_send]) VALUES (2,  N'$2a$12$hashCustomer02saltABCDEFGHIJKLM', CAST(N'2026-03-09T11:00:00' AS DateTime2), 0, 1, CAST(N'2026-03-08T10:55:00' AS DateTime2))
INSERT [dbo].[CustomerOTP] ([customer_id],[otp_hash],[otp_expired_at],[failed_attempt],[send_count],[last_send]) VALUES (5,  N'$2a$12$hashCustomer05saltABCDEFGHIJKLM', CAST(N'2026-03-08T08:00:00' AS DateTime2), 3, 2, CAST(N'2026-03-07T22:00:00' AS DateTime2))
INSERT [dbo].[CustomerOTP] ([customer_id],[otp_hash],[otp_expired_at],[failed_attempt],[send_count],[last_send]) VALUES (21, N'$2a$12$hashCustomer21saltABCDEFGHIJKLM', CAST(N'2026-03-09T14:00:00' AS DateTime2), 0, 1, CAST(N'2026-03-08T13:58:00' AS DateTime2))
INSERT [dbo].[CustomerOTP] ([customer_id],[otp_hash],[otp_expired_at],[failed_attempt],[send_count],[last_send]) VALUES (24, N'$2a$12$hashCustomer24saltABCDEFGHIJKLM', CAST(N'2026-03-09T15:30:00' AS DateTime2), 1, 2, CAST(N'2026-03-08T15:25:00' AS DateTime2))
GO

-- ============================================================
-- 7. Campaign_Leads  (campaign_id 1-10, lead_id 1-20 đều hợp lệ)
-- ============================================================
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (1, 1,  N'Contacted', CAST(N'2026-01-05T08:00:00' AS DateTime), CAST(N'2026-01-10T09:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (1, 2,  N'Contacted', CAST(N'2026-01-05T08:00:00' AS DateTime), CAST(N'2026-01-12T10:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (1, 6,  N'Qualified', CAST(N'2026-01-05T08:00:00' AS DateTime), CAST(N'2026-01-20T11:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (2, 3,  N'Qualified', CAST(N'2026-02-03T08:00:00' AS DateTime), CAST(N'2026-02-10T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (2, 4,  N'Converted', CAST(N'2026-02-03T08:00:00' AS DateTime), CAST(N'2026-02-20T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (2, 15, N'New',       CAST(N'2026-02-03T08:00:00' AS DateTime), CAST(N'2026-02-03T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (3, 5,  N'New',       CAST(N'2026-01-20T08:00:00' AS DateTime), CAST(N'2026-01-20T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (3, 8,  N'Lost',      CAST(N'2026-01-20T08:00:00' AS DateTime), CAST(N'2026-02-05T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (3, 13, N'Converted', CAST(N'2026-01-20T08:00:00' AS DateTime), CAST(N'2026-02-15T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (4, 7,  N'Qualified', CAST(N'2026-03-01T08:00:00' AS DateTime), CAST(N'2026-03-05T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (4, 9,  N'Qualified', CAST(N'2026-03-01T08:00:00' AS DateTime), CAST(N'2026-03-05T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (4, 14, N'Contacted', CAST(N'2026-03-01T08:00:00' AS DateTime), CAST(N'2026-03-03T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (5, 10, N'Contacted', CAST(N'2026-02-12T08:00:00' AS DateTime), CAST(N'2026-02-15T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (5, 12, N'Qualified', CAST(N'2026-02-12T08:00:00' AS DateTime), CAST(N'2026-02-20T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (6, 11, N'New',       CAST(N'2026-01-15T08:00:00' AS DateTime), CAST(N'2026-01-15T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (6, 17, N'Contacted', CAST(N'2026-01-15T08:00:00' AS DateTime), CAST(N'2026-01-20T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (7, 16, N'Qualified', CAST(N'2026-02-20T08:00:00' AS DateTime), CAST(N'2026-02-25T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (7, 20, N'Converted', CAST(N'2026-02-20T08:00:00' AS DateTime), CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (8, 18, N'Lost',      CAST(N'2026-03-02T08:00:00' AS DateTime), CAST(N'2026-03-05T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Leads] ([campaign_id],[lead_id],[lead_status],[assigned_at],[updated_at]) VALUES (9, 19, N'New',       CAST(N'2026-03-05T08:00:00' AS DateTime), CAST(N'2026-03-05T08:00:00' AS DateTime))
GO

-- ============================================================
-- 8. Campaign_Reports  (campaign_id 1-10 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Campaign_Reports] ON
GO
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (1, 1,  3, 1, 0, CAST(1666.67 AS Decimal(10,2)), CAST(0.00  AS Decimal(5,2)), CAST(N'2026-02-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (2, 2,  3, 1, 1, CAST(2333.33 AS Decimal(10,2)), CAST(28.50 AS Decimal(5,2)), CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (3, 3,  3, 1, 1, CAST(666.67  AS Decimal(10,2)), CAST(42.30 AS Decimal(5,2)), CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (4, 4,  3, 2, 0, CAST(4000.00 AS Decimal(10,2)), CAST(0.00  AS Decimal(5,2)), CAST(N'2026-03-06T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (5, 5,  2, 1, 0, CAST(1750.00 AS Decimal(10,2)), CAST(0.00  AS Decimal(5,2)), CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (6, 6,  2, 0, 0, CAST(1500.00 AS Decimal(10,2)), CAST(15.00 AS Decimal(5,2)), CAST(N'2026-02-02T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (7, 7,  2, 1, 1, CAST(1500.00 AS Decimal(10,2)), CAST(55.20 AS Decimal(5,2)), CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (8, 8,  1, 0, 0, CAST(9000.00 AS Decimal(10,2)), CAST(0.00  AS Decimal(5,2)), CAST(N'2026-03-05T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (9, 9,  1, 0, 0, CAST(0.00    AS Decimal(10,2)), CAST(0.00  AS Decimal(5,2)), CAST(N'2026-03-06T08:00:00' AS DateTime))
INSERT [dbo].[Campaign_Reports] ([report_id],[campaign_id],[total_lead],[qualified_lead],[converted_lead],[cost_per_lead],[roi],[created_at]) VALUES (10,10, 0, 0, 0, CAST(0.00    AS Decimal(10,2)), CAST(38.70 AS Decimal(5,2)), CAST(N'2026-01-02T08:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Campaign_Reports] OFF
GO

-- ============================================================
-- 9. Deal_Products  (deal_id hợp lệ: 18-53, product_id 1-10)
-- ============================================================
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (18, 2,  2, CAST(1850000.00  AS Decimal(15,2)), CAST(5.00  AS Decimal(5,2)), CAST(3515000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (19, 7,  1, CAST(5800000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(5800000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (19, 10, 1, CAST(7500000.00  AS Decimal(15,2)), CAST(5.00  AS Decimal(5,2)), CAST(7125000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (20, 4,  1, CAST(2200000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(2200000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (20, 6,  2, CAST(980000.00   AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(1960000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (21, 10, 1, CAST(7500000.00  AS Decimal(15,2)), CAST(5.00  AS Decimal(5,2)), CAST(7125000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (22, 3,  1, CAST(12000000.00 AS Decimal(15,2)), CAST(10.00 AS Decimal(5,2)), CAST(10800000.00 AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (22, 1,  1, CAST(4500000.00  AS Decimal(15,2)), CAST(5.00  AS Decimal(5,2)), CAST(4275000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (23, 2,  1, CAST(1850000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(1850000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (23, 8,  1, CAST(1650000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(1650000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (24, 5,  1, CAST(3100000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(3100000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (24, 9,  3, CAST(1350000.00  AS Decimal(15,2)), CAST(5.00  AS Decimal(5,2)), CAST(3847500.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (30, 9,  2, CAST(1350000.00  AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(2700000.00  AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (31, 6,  1, CAST(980000.00   AS Decimal(15,2)), CAST(0.00  AS Decimal(5,2)), CAST(980000.00   AS Decimal(15,2)))
INSERT [dbo].[Deal_Products] ([deal_id],[product_id],[quantity],[unit_price],[discount],[total_price]) VALUES (32, 7,  1, CAST(5800000.00  AS Decimal(15,2)), CAST(10.00 AS Decimal(5,2)), CAST(5220000.00  AS Decimal(15,2)))
GO

-- ============================================================
-- 10. Virtual_Wardrobe  (customer_id 1-30, product_id 1-10 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Virtual_Wardrobe] ON
GO
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (1,  21, 1,  CAST(N'2026-02-26T10:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust21_prod1.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (2,  21, 5,  CAST(N'2026-01-15T10:00:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (3,  22, 2,  CAST(N'2026-02-19T11:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust22_prod2.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (4,  23, 4,  CAST(N'2026-02-13T14:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust23_prod4.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (5,  24, 3,  CAST(N'2026-02-28T09:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust24_prod3.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (6,  24, 7,  CAST(N'2026-02-28T09:30:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (7,  25, 4,  CAST(N'2026-02-06T13:00:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (8,  26, 6,  CAST(N'2026-01-22T10:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust26_prod6.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (9,  27, 2,  CAST(N'2026-02-15T15:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust27_prod2.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (10, 27, 8,  CAST(N'2026-01-20T10:00:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (11, 28, 7,  CAST(N'2026-03-01T10:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust28_prod7.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (12, 28, 10, CAST(N'2026-02-14T09:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust28_prod10.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (13, 29, 1,  CAST(N'2026-02-09T11:00:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (14, 30, 9,  CAST(N'2026-01-27T14:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust30_prod9.jpg')
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (15, 1,  5,  CAST(N'2026-02-21T10:00:00' AS DateTime), NULL)
INSERT [dbo].[Virtual_Wardrobe] ([wardrobe_id],[customer_id],[product_id],[bought_at],[photo_feedback]) VALUES (16, 2,  10, CAST(N'2026-02-26T10:00:00' AS DateTime), N'https://cdn.crm.vn/feedback/cust2_prod10.jpg')
SET IDENTITY_INSERT [dbo].[Virtual_Wardrobe] OFF
GO

-- ============================================================
-- 11. Feedbacks  (ticket_id 1-30 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Feedbacks] ON
GO
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (1,  6,  5, N'Xử lý rất nhanh, nhân viên nhiệt tình.',            CAST(N'2026-02-24T08:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (2,  7,  4, N'Đã đổi sản phẩm mới, hài lòng.',                   CAST(N'2026-02-23T10:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (3,  8,  5, N'Xuất hóa đơn nhanh, đúng thông tin.',               CAST(N'2026-02-20T09:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (4,  13, 4, N'Hủy đơn thành công, hoàn tiền đúng hẹn.',           CAST(N'2026-02-22T11:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (5,  15, 3, N'Hỗ trợ ổn nhưng hơi chậm phản hồi.',               CAST(N'2026-02-18T14:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (6,  21, 5, N'Nhân viên rất thân thiện, giải quyết nhanh chóng.', CAST(N'2026-02-24T09:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (7,  22, 4, N'Sản phẩm thay thế tốt hơn bản gốc.',                CAST(N'2026-02-23T11:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (8,  23, 5, N'Hóa đơn VAT đúng và gửi email kịp thời.',           CAST(N'2026-02-20T10:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (9,  28, 4, N'Hủy đơn nhanh, không phát sinh phí.',               CAST(N'2026-02-22T12:00:00' AS DateTime))
INSERT [dbo].[Feedbacks] ([feedback_id],[ticket_id],[rating],[comment],[created_at]) VALUES (10, 30, 3, N'Giải quyết được nhưng cần nhiều bước xác nhận.',    CAST(N'2026-02-18T15:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Feedbacks] OFF
GO

-- ============================================================
-- 12. Service_Reports  (độc lập, không có FK)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Service_Reports] ON
GO
INSERT [dbo].[Service_Reports] ([report_id],[report_date],[total_ticket],[resolved_ticket],[avg_response_time],[avg_resolution_time],[created_at]) VALUES (1, CAST(N'2025-10-31' AS Date), 18, 16, CAST(2.40 AS Decimal(10,2)), CAST(18.50 AS Decimal(10,2)), CAST(N'2025-11-01T08:00:00' AS DateTime))
INSERT [dbo].[Service_Reports] ([report_id],[report_date],[total_ticket],[resolved_ticket],[avg_response_time],[avg_resolution_time],[created_at]) VALUES (2, CAST(N'2025-11-30' AS Date), 22, 20, CAST(1.80 AS Decimal(10,2)), CAST(15.20 AS Decimal(10,2)), CAST(N'2025-12-01T08:00:00' AS DateTime))
INSERT [dbo].[Service_Reports] ([report_id],[report_date],[total_ticket],[resolved_ticket],[avg_response_time],[avg_resolution_time],[created_at]) VALUES (3, CAST(N'2025-12-31' AS Date), 31, 28, CAST(2.10 AS Decimal(10,2)), CAST(14.80 AS Decimal(10,2)), CAST(N'2026-01-01T08:00:00' AS DateTime))
INSERT [dbo].[Service_Reports] ([report_id],[report_date],[total_ticket],[resolved_ticket],[avg_response_time],[avg_resolution_time],[created_at]) VALUES (4, CAST(N'2026-01-31' AS Date), 25, 24, CAST(1.50 AS Decimal(10,2)), CAST(12.30 AS Decimal(10,2)), CAST(N'2026-02-01T08:00:00' AS DateTime))
INSERT [dbo].[Service_Reports] ([report_id],[report_date],[total_ticket],[resolved_ticket],[avg_response_time],[avg_resolution_time],[created_at]) VALUES (5, CAST(N'2026-02-28' AS Date), 30, 22, CAST(1.90 AS Decimal(10,2)), CAST(16.70 AS Decimal(10,2)), CAST(N'2026-03-01T08:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Service_Reports] OFF
GO

-- ============================================================
-- 13. Notifications  (độc lập, user_id 1-7 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Notifications] ON
GO
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (1,  N'Deal Mới Cần Xử Lý',              N'Deal "CRM Implementation" (deal_id=35) vừa được tạo và chờ xử lý.',          N'deal',     N'deal',     35,   CAST(N'2026-03-02T13:37:03' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (2,  N'Lead Chuyển Đổi Thành Công',      N'Lead id=4 đã được chuyển đổi thành khách hàng.',                              N'lead',     N'lead',     4,    CAST(N'2026-03-03T08:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (3,  N'Ticket Khẩn Cần Phân Công',       N'Ticket #5 mức HIGH chưa được phân công xử lý.',                               N'ticket',   N'ticket',   5,    CAST(N'2026-02-25T17:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (4,  N'Task Sắp Đến Hạn',                N'Task "Design CRM Database" sẽ đến hạn vào 2026-03-10.',                       N'task',     N'task',     1,    CAST(N'2026-03-07T08:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (5,  N'Khách Hàng VIP Mới',              N'Customer_id=28 vừa đạt hạng PLATINUM.',                                       N'customer', N'customer', 28,   CAST(N'2026-03-03T09:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (6,  N'Campaign Kết Thúc',               N'Campaign id=3 đã kết thúc. Tỷ lệ chuyển đổi đạt 33%.',                       N'campaign', N'campaign', 3,    CAST(N'2026-03-01T08:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (7,  N'Deal Thắng - Chúc Mừng!',         N'Deal id=22 đã chốt thành công 14,800,000 VND.',                               N'deal',     N'deal',     22,   CAST(N'2026-03-02T15:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (8,  N'Nhắc Nhở Follow-up Khách Hàng',  N'10 khách hàng chưa được liên hệ trong 30 ngày qua.',                          N'system',   NULL,        NULL, CAST(N'2026-03-05T07:00:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (9,  N'OTP Thất Bại Nhiều Lần',          N'Customer_id=5 đã nhập OTP sai 3 lần liên tiếp.',                              N'security', N'customer', 5,    CAST(N'2026-03-07T22:05:00' AS DateTime))
INSERT [dbo].[Notifications] ([notification_id],[title],[content],[type],[related_type],[related_id],[created_at]) VALUES (10, N'Báo Cáo Dịch Vụ Tháng 2/2026',   N'Tổng 30 tickets, giải quyết 22, thời gian phản hồi TB: 1.9h.',                N'report',   NULL,        NULL, CAST(N'2026-03-01T08:30:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO

-- ============================================================
-- 14. Notification_Recipients  (notification_id 1-10, user_id 1-7 hợp lệ)
-- ============================================================
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (1,  1, 1, CAST(N'2026-03-02T14:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (1,  3, 1, CAST(N'2026-03-02T14:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (2,  1, 1, CAST(N'2026-03-03T08:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (2,  2, 1, CAST(N'2026-03-03T09:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (3,  1, 1, CAST(N'2026-02-25T17:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (3,  4, 0, NULL)
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (4,  1, 1, CAST(N'2026-03-07T08:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (4,  2, 0, NULL)
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (4,  3, 1, CAST(N'2026-03-07T09:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (5,  1, 1, CAST(N'2026-03-03T09:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (5,  5, 1, CAST(N'2026-03-03T10:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (6,  1, 1, CAST(N'2026-03-01T09:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (6,  3, 1, CAST(N'2026-03-01T09:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (7,  1, 1, CAST(N'2026-03-02T15:30:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (7,  5, 1, CAST(N'2026-03-02T16:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (8,  1, 0, NULL)
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (8,  5, 0, NULL)
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (9,  1, 1, CAST(N'2026-03-07T22:10:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (9,  4, 0, NULL)
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (10, 1, 1, CAST(N'2026-03-01T09:00:00' AS DateTime))
INSERT [dbo].[Notification_Recipients] ([notification_id],[user_id],[is_read],[read_at]) VALUES (10, 5, 1, CAST(N'2026-03-01T10:00:00' AS DateTime))
GO

-- ============================================================
-- 15. Notification_Rules  (notification_id 1-10 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Notification_Rules] ON
GO
INSERT [dbo].[Notification_Rules] ([rule_id],[notification_id],[rule_type],[interval_value],[interval_unit],[next_run],[last_run],[is_active],[created_at]) VALUES (1, 8,  N'RECURRING', 7,    N'DAY',   CAST(N'2026-03-12T07:00:00' AS DateTime), CAST(N'2026-03-05T07:00:00' AS DateTime), 1, CAST(N'2026-01-01T00:00:00' AS DateTime))
INSERT [dbo].[Notification_Rules] ([rule_id],[notification_id],[rule_type],[interval_value],[interval_unit],[next_run],[last_run],[is_active],[created_at]) VALUES (2, 10, N'RECURRING', 1,    N'MONTH', CAST(N'2026-04-01T08:30:00' AS DateTime), CAST(N'2026-03-01T08:30:00' AS DateTime), 1, CAST(N'2026-01-01T00:00:00' AS DateTime))
INSERT [dbo].[Notification_Rules] ([rule_id],[notification_id],[rule_type],[interval_value],[interval_unit],[next_run],[last_run],[is_active],[created_at]) VALUES (3, 4,  N'ONE_TIME',  NULL, NULL,     CAST(N'2026-03-10T08:00:00' AS DateTime), NULL,                                     1, CAST(N'2026-03-07T08:00:00' AS DateTime))
INSERT [dbo].[Notification_Rules] ([rule_id],[notification_id],[rule_type],[interval_value],[interval_unit],[next_run],[last_run],[is_active],[created_at]) VALUES (4, 3,  N'ONE_TIME',  NULL, NULL,     CAST(N'2026-02-26T09:00:00' AS DateTime), CAST(N'2026-02-25T17:00:00' AS DateTime), 0, CAST(N'2026-02-25T17:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Notification_Rules] OFF
GO

-- ============================================================
-- 16. Task_History  (task_id 1-5, user_id 1-7 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Task_History] ON
GO
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (1,  1, 1, CAST(N'2026-03-03T19:14:42' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (2,  1, 2, CAST(N'2026-03-05T10:00:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (3,  1, 1, CAST(N'2026-03-07T14:00:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (4,  2, 2, CAST(N'2026-03-05T10:30:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (5,  2, 1, CAST(N'2026-03-06T09:00:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (6,  3, 3, CAST(N'2026-03-04T11:00:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (7,  3, 3, CAST(N'2026-03-05T14:30:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (8,  4, 2, CAST(N'2026-03-06T09:30:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (9,  4, 2, CAST(N'2026-03-07T15:00:00' AS DateTime))
INSERT [dbo].[Task_History] ([history_id],[task_id],[changed_by],[changed_at]) VALUES (10, 5, 1, CAST(N'2026-03-07T13:00:00' AS DateTime))
SET IDENTITY_INSERT [dbo].[Task_History] OFF
GO

-- ============================================================
-- 17. Task_History_Detail  (history_id 1-10 hợp lệ)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Task_History_Detail] ON
GO
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (1,  1,  N'status',      NULL,           N'In Progress')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (2,  1,  N'progress',    NULL,           N'0')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (3,  2,  N'progress',    N'0',           N'20')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (4,  3,  N'progress',    N'20',          N'40')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (5,  4,  N'status',      NULL,           N'Pending')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (6,  4,  N'start_date',  NULL,           N'2026-03-06 09:00:00')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (7,  5,  N'description', N'Implement contacts table and API', N'Implement contacts table and API endpoints')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (8,  6,  N'status',      NULL,           N'Completed')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (9,  6,  N'start_date',  NULL,           N'2026-03-05 09:00:00')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (10, 7,  N'progress',    N'80',          N'100')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (11, 7,  N'completed_at',NULL,           N'2026-03-05 14:30:00')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (12, 8,  N'status',      NULL,           N'In Progress')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (13, 8,  N'start_date',  NULL,           N'2026-03-07 08:30:00')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (14, 9,  N'progress',    N'30',          N'60')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (15, 10, N'status',      NULL,           N'Pending')
INSERT [dbo].[Task_History_Detail] ([detail_id],[history_id],[field_name],[old_value],[new_value]) VALUES (16, 10, N'start_date',  NULL,           N'2026-03-08 09:00:00')
SET IDENTITY_INSERT [dbo].[Task_History_Detail] OFF
GO
GO
