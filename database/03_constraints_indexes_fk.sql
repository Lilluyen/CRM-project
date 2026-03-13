-- ============================================================
-- PHẦN 3: INDEX, RÀNG BUỘC (DEFAULT, UNIQUE, FOREIGN KEY)
-- ============================================================

USE [CRM_System]
GO

CREATE NONCLUSTERED INDEX [IX_Customer_Measurements_customer_measured] ON [dbo].[Customer_Measurements]
(
	[customer_id] ASC,
	[measured_at] DESC
)
INCLUDE([preferred_size],[height],[weight],[body_shape]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Measurements_Latest]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Measurements_Latest] ON [dbo].[Customer_Measurements]
(
	[customer_id] ASC,
	[measured_at] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_Style_Map_customer]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_Style_Map_customer] ON [dbo].[Customer_Style_Map]
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_StyleMap]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_StyleMap] ON [dbo].[Customer_Style_Map]
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Customer__B43B145F6990E478]    Script Date: 3/3/2026 8:01:49 PM ******/
ALTER TABLE [dbo].[Customers] ADD UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_customer_phone]    Script Date: 3/3/2026 8:01:49 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [UQ_customer_phone] UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customers_Filter]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_Filter] ON [dbo].[Customers]
(
	[loyalty_tier] ASC,
	[status] ASC,
	[return_rate] ASC
)
INCLUDE([name],[phone],[rfm_score],[last_purchase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customers_rfm_customer]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_rfm_customer] ON [dbo].[Customers]
(
	[rfm_score] DESC,
	[customer_id] DESC
)
INCLUDE([name],[phone],[email],[gender],[loyalty_tier],[return_rate],[last_purchase],[status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Deals_customer_id]    Script Date: 3/3/2026 8:01:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_Deals_customer_id] ON [dbo].[Deals]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uq_users_username]    Script Date: 3/3/2026 8:01:49 PM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [uq_users_username] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Activities] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Campaign_Leads] ADD  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[Campaign_Reports] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Campaigns] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Categories] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Customer_Measurements] ADD  DEFAULT (getdate()) FOR [measured_at]
GO
ALTER TABLE [dbo].[Customer_Segment_Map] ADD  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[CustomerOTP] ADD  DEFAULT ((0)) FOR [failed_attempt]
GO
ALTER TABLE [dbo].[CustomerOTP] ADD  DEFAULT ((0)) FOR [send_count]
GO
ALTER TABLE [dbo].[CustomerOTP] ADD  DEFAULT (sysdatetime()) FOR [last_send]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ('INDIVIDUAL') FOR [customer_type]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ('BRONZE') FOR [loyalty_tier]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [rfm_score]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [return_rate]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Deals] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Feedbacks] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leads] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leads] ADD  DEFAULT ((0)) FOR [is_converted]
GO
ALTER TABLE [dbo].[Notification_Recipients] ADD  CONSTRAINT [DF_NotificationRecipients_IsRead]  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[Notifications] ADD  CONSTRAINT [DF_Notifications_CreatedAt]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Service_Reports] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Task_Assignees] ADD  CONSTRAINT [DF_TaskAssignees_AssignedAt]  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[Task_History] ADD  CONSTRAINT [DF_TaskHistory_ChangedAt]  DEFAULT (getdate()) FOR [changed_at]
GO
ALTER TABLE [dbo].[Task_History]  WITH CHECK ADD  CONSTRAINT [fk_th_user] FOREIGN KEY([changed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_Status]  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_Priority]  DEFAULT ('Medium') FOR [priority]
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_Progress]  DEFAULT ((0)) FOR [progress]
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_CreatedAt]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Tickets] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Virtual_Wardrobe] ADD  DEFAULT (getdate()) FOR [bought_at]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [fk_activities_user] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [fk_activities_user]
GO
ALTER TABLE [dbo].[Campaign_Leads]  WITH CHECK ADD  CONSTRAINT [fk_cl_campaign] FOREIGN KEY([campaign_id])
REFERENCES [dbo].[Campaigns] ([campaign_id])
GO
ALTER TABLE [dbo].[Campaign_Leads] CHECK CONSTRAINT [fk_cl_campaign]
GO
ALTER TABLE [dbo].[Campaign_Leads]  WITH CHECK ADD  CONSTRAINT [fk_cl_lead] FOREIGN KEY([lead_id])
REFERENCES [dbo].[Leads] ([lead_id])
GO
ALTER TABLE [dbo].[Campaign_Leads] CHECK CONSTRAINT [fk_cl_lead]
GO
ALTER TABLE [dbo].[Campaign_Reports]  WITH CHECK ADD  CONSTRAINT [fk_campaign_reports_campaign] FOREIGN KEY([campaign_id])
REFERENCES [dbo].[Campaigns] ([campaign_id])
GO
ALTER TABLE [dbo].[Campaign_Reports] CHECK CONSTRAINT [fk_campaign_reports_campaign]
GO
ALTER TABLE [dbo].[Campaigns]  WITH CHECK ADD  CONSTRAINT [fk_campaigns_user] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Campaigns] CHECK CONSTRAINT [fk_campaigns_user]
GO
ALTER TABLE [dbo].[Category_Products]  WITH CHECK ADD  CONSTRAINT [fk_cp_category] FOREIGN KEY([category_id])
REFERENCES [dbo].[Categories] ([category_id])
GO
ALTER TABLE [dbo].[Category_Products] CHECK CONSTRAINT [fk_cp_category]
GO
ALTER TABLE [dbo].[Category_Products]  WITH CHECK ADD  CONSTRAINT [fk_cp_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([product_id])
GO
ALTER TABLE [dbo].[Category_Products] CHECK CONSTRAINT [fk_cp_product]
GO
ALTER TABLE [dbo].[Customer_Measurements]  WITH CHECK ADD  CONSTRAINT [fk_measure_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Customer_Measurements] CHECK CONSTRAINT [fk_measure_customer]
GO
ALTER TABLE [dbo].[Customer_Segment_Map]  WITH CHECK ADD  CONSTRAINT [fk_csm_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Customer_Segment_Map] CHECK CONSTRAINT [fk_csm_customer]
GO
ALTER TABLE [dbo].[Customer_Segment_Map]  WITH CHECK ADD  CONSTRAINT [fk_csm_segment] FOREIGN KEY([segment_id])
REFERENCES [dbo].[Customer_Segments] ([segment_id])
GO
ALTER TABLE [dbo].[Customer_Segment_Map] CHECK CONSTRAINT [fk_csm_segment]
GO
ALTER TABLE [dbo].[Customer_Style_Map]  WITH CHECK ADD  CONSTRAINT [fk_style_cust] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Customer_Style_Map] CHECK CONSTRAINT [fk_style_cust]
GO
ALTER TABLE [dbo].[Customer_Style_Map]  WITH CHECK ADD  CONSTRAINT [fk_style_tag] FOREIGN KEY([tag_id])
REFERENCES [dbo].[Style_Tags] ([tag_id])
GO
ALTER TABLE [dbo].[Customer_Style_Map] CHECK CONSTRAINT [fk_style_tag]
GO
ALTER TABLE [dbo].[CustomerOTP]  WITH CHECK ADD  CONSTRAINT [fk_customerotp_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[CustomerOTP] CHECK CONSTRAINT [fk_customerotp_customer]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [fk_customers_owner] FOREIGN KEY([owner_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [fk_customers_owner]
GO
ALTER TABLE [dbo].[Deal_Products]  WITH CHECK ADD  CONSTRAINT [fk_dp_deal] FOREIGN KEY([deal_id])
REFERENCES [dbo].[Deals] ([deal_id])
GO
ALTER TABLE [dbo].[Deal_Products] CHECK CONSTRAINT [fk_dp_deal]
GO
ALTER TABLE [dbo].[Deal_Products]  WITH CHECK ADD  CONSTRAINT [fk_dp_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([product_id])
GO
ALTER TABLE [dbo].[Deal_Products] CHECK CONSTRAINT [fk_dp_product]
GO
ALTER TABLE [dbo].[Deals]  WITH CHECK ADD  CONSTRAINT [fk_deals_customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Deals] CHECK CONSTRAINT [fk_deals_customers]
GO
ALTER TABLE [dbo].[Deals]  WITH CHECK ADD  CONSTRAINT [fk_deals_lead] FOREIGN KEY([lead_id])
REFERENCES [dbo].[Leads] ([lead_id])
GO
ALTER TABLE [dbo].[Deals] CHECK CONSTRAINT [fk_deals_lead]
GO
ALTER TABLE [dbo].[Deals]  WITH CHECK ADD  CONSTRAINT [fk_deals_owner] FOREIGN KEY([owner_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Deals] CHECK CONSTRAINT [fk_deals_owner]
GO
ALTER TABLE [dbo].[Feedbacks]  WITH CHECK ADD  CONSTRAINT [fk_feedbacks_ticket] FOREIGN KEY([ticket_id])
REFERENCES [dbo].[Tickets] ([ticket_id])
GO
ALTER TABLE [dbo].[Feedbacks] CHECK CONSTRAINT [fk_feedbacks_ticket]
GO
ALTER TABLE [dbo].[Leads]  WITH CHECK ADD  CONSTRAINT [fk_leads_campaign] FOREIGN KEY([campaign_id])
REFERENCES [dbo].[Campaigns] ([campaign_id])
GO
ALTER TABLE [dbo].[Leads] CHECK CONSTRAINT [fk_leads_campaign]
GO
ALTER TABLE [dbo].[Leads]  WITH CHECK ADD  CONSTRAINT [fk_leads_customers] FOREIGN KEY([converted_customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Leads] CHECK CONSTRAINT [fk_leads_customers]
GO
ALTER TABLE [dbo].[Leads]  WITH CHECK ADD  CONSTRAINT [fk_leads_user] FOREIGN KEY([assigned_to])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Leads] CHECK CONSTRAINT [fk_leads_user]
GO
ALTER TABLE [dbo].[Notification_Recipients]  WITH CHECK ADD  CONSTRAINT [fk_nr_notification] FOREIGN KEY([notification_id])
REFERENCES [dbo].[Notifications] ([notification_id])
GO
ALTER TABLE [dbo].[Notification_Recipients] CHECK CONSTRAINT [fk_nr_notification]
GO
ALTER TABLE [dbo].[Notification_Recipients]  WITH CHECK ADD  CONSTRAINT [fk_nr_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notification_Recipients] CHECK CONSTRAINT [fk_nr_user]
GO
ALTER TABLE [dbo].[Task_Assignees]  WITH CHECK ADD  CONSTRAINT [fk_ta_task] FOREIGN KEY([task_id])
REFERENCES [dbo].[Tasks] ([task_id])
GO
ALTER TABLE [dbo].[Task_Assignees] CHECK CONSTRAINT [fk_ta_task]
GO
ALTER TABLE [dbo].[Task_Assignees]  WITH CHECK ADD  CONSTRAINT [fk_ta_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Task_Assignees] CHECK CONSTRAINT [fk_ta_user]
GO
ALTER TABLE [dbo].[Task_History]  WITH CHECK ADD  CONSTRAINT [fk_th_task] FOREIGN KEY([task_id])
REFERENCES [dbo].[Tasks] ([task_id])
GO
ALTER TABLE [dbo].[Task_History] CHECK CONSTRAINT [fk_th_task]
GO
ALTER TABLE [dbo].[Task_History_Detail]  WITH CHECK ADD  CONSTRAINT [fk_thd_history] FOREIGN KEY([history_id])
REFERENCES [dbo].[Task_History] ([history_id])
GO
ALTER TABLE [dbo].[Task_History_Detail] CHECK CONSTRAINT [fk_thd_history]
GO
ALTER TABLE [dbo].[Notification_Rules] 
ADD DEFAULT ((1)) FOR [is_active]
GO

ALTER TABLE [dbo].[Notification_Rules] 
ADD DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notification_Rules]  WITH CHECK 
ADD CONSTRAINT [FK_Notification_Rules_Notifications] 
FOREIGN KEY([notification_id])
REFERENCES [dbo].[Notifications] ([notification_id])
GO
ALTER TABLE [dbo].[Tickets]  WITH CHECK ADD  CONSTRAINT [fk_tickets_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [fk_tickets_customer]
GO
ALTER TABLE [dbo].[Tickets]  WITH CHECK ADD  CONSTRAINT [fk_tickets_user] FOREIGN KEY([assigned_to])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Tickets] CHECK CONSTRAINT [fk_tickets_user]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [fk_users_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[Roles] ([role_id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [fk_users_role]
GO
ALTER TABLE [dbo].[Virtual_Wardrobe]  WITH CHECK ADD  CONSTRAINT [fk_wardrobe_cust] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Virtual_Wardrobe] CHECK CONSTRAINT [fk_wardrobe_cust]
GO
GO
