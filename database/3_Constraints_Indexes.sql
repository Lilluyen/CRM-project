USE [CRM_System]
GO

SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Activities_Related_Date]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Activities_Related_Date] ON [dbo].[Activities]
(
	[related_type] ASC,
	[related_id] ASC,
	[activity_date] DESC
)
INCLUDE([activity_id],[activity_type],[subject],[created_by]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Activities_Source]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Activities_Source] ON [dbo].[Activities]
(
	[source_type] ASC,
	[source_id] ASC
)
INCLUDE([activity_id],[activity_type],[activity_date])
WHERE ([source_type] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_segment_map_segment]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_segment_map_segment] ON [dbo].[Customer_Segment_Map]
(
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uq_segment_name]    Script Date: 3/28/2026 4:55:23 PM ******/
ALTER TABLE [dbo].[Customer_Segments] ADD  CONSTRAINT [uq_segment_name] UNIQUE NONCLUSTERED
(
	[segment_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_StyleMap]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_StyleMap] ON [dbo].[Customer_Style_Map]
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_customer_loyalty]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_customer_loyalty] ON [dbo].[Customers]
(
	[loyalty_tier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_customer_owner]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_customer_owner] ON [dbo].[Customers]
(
	[owner_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_customer_source]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_customer_source] ON [dbo].[Customers]
(
	[source] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Deals_customer_id]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Deals_customer_id] ON [dbo].[Deals]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Leads_Email]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Leads_Email] ON [dbo].[Leads]
(
	[email] ASC
)
WHERE ([email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Leads_Phone]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Leads_Phone] ON [dbo].[Leads]
(
	[phone] ASC
)
WHERE ([phone] IS NOT NULL AND [phone]<>'')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_NQueue_Poll]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_NQueue_Poll] ON [dbo].[Notification_Queue]
(
	[status] ASC,
	[scheduled_at] ASC,
	[priority] DESC
)
WHERE ([status]='pending')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_NQueue_Recipient]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_NQueue_Recipient] ON [dbo].[Notification_Queue]
(
	[recipient_user_id] ASC,
	[created_at] DESC
)
INCLUDE([status],[title],[type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_NQueue_Retry]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_NQueue_Retry] ON [dbo].[Notification_Queue]
(
	[status] ASC,
	[retry_count] ASC
)
WHERE ([status]='failed')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_NRE_Scheduler]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_NRE_Scheduler] ON [dbo].[Notification_Rule_Engine]
(
	[is_active] ASC,
	[next_run_at] ASC
)
WHERE (([rule_type] IN ('schedule', 'condition')) AND [is_active]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_NRE_TriggerEvent]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_NRE_TriggerEvent] ON [dbo].[Notification_Rule_Engine]
(
	[trigger_event] ASC,
	[is_active] ASC
)
WHERE ([rule_type]='event_trigger' AND [is_active]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Notifications_Scheduler]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Notifications_Scheduler] ON [dbo].[Notifications]
(
	[status] ASC,
	[scheduled_at] ASC
)
WHERE ([status] IN ('pending', 'failed'))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Anchors_Session_Page]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Anchors_Session_Page] ON [dbo].[Pagination_Anchors]
(
	[session_id] ASC,
	[page_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_filter_segment]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_filter_segment] ON [dbo].[Segment_Filters]
(
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_history_segment]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [idx_history_segment] ON [dbo].[Segment_Update_History]
(
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaskAssignees_ActiveUser]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaskAssignees_ActiveUser] ON [dbo].[Task_Assignees]
(
	[user_id] ASC,
	[is_primary] ASC,
	[removed_at] ASC
)
INCLUDE([task_id],[assigned_at],[assigned_by]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaskComments_Progress]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaskComments_Progress] ON [dbo].[Task_Comments]
(
	[task_id] ASC,
	[is_deleted] ASC,
	[is_completed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaskComments_Task]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaskComments_Task] ON [dbo].[Task_Comments]
(
	[task_id] ASC,
	[created_at] ASC
)
WHERE ([is_deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaskHistory_Task_Time]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaskHistory_Task_Time] ON [dbo].[Task_History]
(
	[task_id] ASC,
	[changed_at] DESC
)
INCLUDE([action],[changed_by]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaskReminders_Poll]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaskReminders_Poll] ON [dbo].[Task_Reminders]
(
	[is_sent] ASC,
	[remind_at] ASC
)
WHERE ([is_sent]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Tasks_DueDate_Status]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Tasks_DueDate_Status] ON [dbo].[Tasks]
(
	[due_date] ASC,
	[status] ASC
)
INCLUDE([task_id],[title],[related_type],[related_id])
WHERE ([status]<>'completed' AND [status]<>'cancelled')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Tasks_Related]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_Tasks_Related] ON [dbo].[Tasks]
(
	[related_type] ASC,
	[related_id] ASC
)
INCLUDE([task_id],[title],[status],[priority],[due_date],[created_by],[created_at]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uq_users_username]    Script Date: 3/28/2026 4:55:23 PM ******/
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
ALTER TABLE [dbo].[customer_contact] ADD  DEFAULT ((0)) FOR [is_primary]
GO
ALTER TABLE [dbo].[customer_contact] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[customer_merge_request] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[customer_merge_request] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[customer_note] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Customer_Segment_Map] ADD  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[Customer_Segments] ADD  DEFAULT ('STATIC') FOR [segment_type]
GO
ALTER TABLE [dbo].[Customer_Segments] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[Customer_Segments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Customer_Segments] ADD  DEFAULT ('ROUND_ROBIN') FOR [assignment_type]
GO
ALTER TABLE [dbo].[Customer_Segments] ADD  DEFAULT ((0)) FOR [customer_count]
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
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [return_rate]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [total_spent]
GO
ALTER TABLE [dbo].[Deals] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Feedbacks] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leads] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leads] ADD  DEFAULT ((0)) FOR [is_converted]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT ('normal') FOR [priority]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT (getdate()) FOR [scheduled_at]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT ((0)) FOR [retry_count]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT ((3)) FOR [max_retries]
GO
ALTER TABLE [dbo].[Notification_Queue] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notification_Recipients] ADD  CONSTRAINT [DF_NotificationRecipients_IsRead]  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] ADD  DEFAULT ('day') FOR [condition_unit]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] ADD  DEFAULT ('normal') FOR [notification_priority]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notifications] ADD  CONSTRAINT [DF_Notifications_CreatedAt]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ('normal') FOR [priority]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[Pagination_Anchors] ADD  DEFAULT (getutcdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Segment_Filters] ADD  DEFAULT ('AND') FOR [logic_operator]
GO
ALTER TABLE [dbo].[Segment_Filters] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Segment_Update_History] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Service_Reports] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Task_Assignees] ADD  CONSTRAINT [DF_TaskAssignees_AssignedAt]  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[Task_Assignees] ADD  CONSTRAINT [DF_TaskAssignees_IsPrimary]  DEFAULT ((0)) FOR [is_primary]
GO
ALTER TABLE [dbo].[Task_Comments] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Task_Comments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Task_Comments] ADD  DEFAULT ((0)) FOR [is_completed]
GO
ALTER TABLE [dbo].[Task_History] ADD  CONSTRAINT [DF_TaskHistory_ChangedAt]  DEFAULT (getdate()) FOR [changed_at]
GO
ALTER TABLE [dbo].[Task_History] ADD  CONSTRAINT [DF_TaskHistory_Action]  DEFAULT ('update') FOR [action]
GO
ALTER TABLE [dbo].[Task_Reminders] ADD  DEFAULT ('day') FOR [remind_before_unit]
GO
ALTER TABLE [dbo].[Task_Reminders] ADD  DEFAULT ((0)) FOR [is_sent]
GO
ALTER TABLE [dbo].[Task_Reminders] ADD  DEFAULT (getdate()) FOR [created_at]
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
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [fk_activities_performed_by] FOREIGN KEY([performed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [fk_activities_performed_by]
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
ALTER TABLE [dbo].[customer_contact]  WITH CHECK ADD  CONSTRAINT [FK_customer_contact_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[customer_contact] CHECK CONSTRAINT [FK_customer_contact_customer]
GO
ALTER TABLE [dbo].[customer_merge_request]  WITH CHECK ADD  CONSTRAINT [FK_cmr_source] FOREIGN KEY([source_id])
REFERENCES [dbo].[Customers] ([customer_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[customer_merge_request] CHECK CONSTRAINT [FK_cmr_source]
GO
ALTER TABLE [dbo].[customer_merge_request]  WITH CHECK ADD  CONSTRAINT [FK_cmr_target] FOREIGN KEY([target_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[customer_merge_request] CHECK CONSTRAINT [FK_cmr_target]
GO
ALTER TABLE [dbo].[customer_note]  WITH CHECK ADD  CONSTRAINT [FK_customer_note_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[customer_note] CHECK CONSTRAINT [FK_customer_note_customer]
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
ALTER TABLE [dbo].[Customer_Segment_Map]  WITH CHECK ADD  CONSTRAINT [fk_map_user] FOREIGN KEY([assigned_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customer_Segment_Map] CHECK CONSTRAINT [fk_map_user]
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [fk_segment_created_by] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [fk_segment_created_by]
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [fk_segment_last_user] FOREIGN KEY([last_assigned_user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [fk_segment_last_user]
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [fk_segment_updated_by] FOREIGN KEY([updated_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [fk_segment_updated_by]
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
ALTER TABLE [dbo].[Notification_Queue]  WITH CHECK ADD  CONSTRAINT [FK_NotificationQueue_Notifications] FOREIGN KEY([notification_id])
REFERENCES [dbo].[Notifications] ([notification_id])
GO
ALTER TABLE [dbo].[Notification_Queue] CHECK CONSTRAINT [FK_NotificationQueue_Notifications]
GO
ALTER TABLE [dbo].[Notification_Queue]  WITH CHECK ADD  CONSTRAINT [FK_NotificationQueue_User] FOREIGN KEY([recipient_user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notification_Queue] CHECK CONSTRAINT [FK_NotificationQueue_User]
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
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [fk_nre_created_by] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [fk_nre_created_by]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [fk_nre_escalate_to] FOREIGN KEY([escalate_to_user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [fk_nre_escalate_to]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [fk_nre_recipient_user] FOREIGN KEY([recipient_user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [fk_nre_recipient_user]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [fk_notifications_created_by] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [fk_notifications_created_by]
GO
ALTER TABLE [dbo].[Segment_Filters]  WITH CHECK ADD  CONSTRAINT [fk_filter_segment] FOREIGN KEY([segment_id])
REFERENCES [dbo].[Customer_Segments] ([segment_id])
GO
ALTER TABLE [dbo].[Segment_Filters] CHECK CONSTRAINT [fk_filter_segment]
GO
ALTER TABLE [dbo].[Segment_Update_History]  WITH CHECK ADD  CONSTRAINT [fk_history_segment] FOREIGN KEY([segment_id])
REFERENCES [dbo].[Customer_Segments] ([segment_id])
GO
ALTER TABLE [dbo].[Segment_Update_History] CHECK CONSTRAINT [fk_history_segment]
GO
ALTER TABLE [dbo].[Segment_Update_History]  WITH CHECK ADD  CONSTRAINT [fk_history_user] FOREIGN KEY([updated_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Segment_Update_History] CHECK CONSTRAINT [fk_history_user]
GO
ALTER TABLE [dbo].[Task_Assignees]  WITH CHECK ADD  CONSTRAINT [fk_ta_assigned_by] FOREIGN KEY([assigned_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Task_Assignees] CHECK CONSTRAINT [fk_ta_assigned_by]
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
ALTER TABLE [dbo].[Task_Comments]  WITH CHECK ADD  CONSTRAINT [fk_tc_parent] FOREIGN KEY([parent_comment_id])
REFERENCES [dbo].[Task_Comments] ([comment_id])
GO
ALTER TABLE [dbo].[Task_Comments] CHECK CONSTRAINT [fk_tc_parent]
GO
ALTER TABLE [dbo].[Task_Comments]  WITH CHECK ADD  CONSTRAINT [fk_tc_task] FOREIGN KEY([task_id])
REFERENCES [dbo].[Tasks] ([task_id])
GO
ALTER TABLE [dbo].[Task_Comments] CHECK CONSTRAINT [fk_tc_task]
GO
ALTER TABLE [dbo].[Task_Comments]  WITH CHECK ADD  CONSTRAINT [fk_tc_user] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Task_Comments] CHECK CONSTRAINT [fk_tc_user]
GO
ALTER TABLE [dbo].[Task_History]  WITH CHECK ADD  CONSTRAINT [fk_th_task] FOREIGN KEY([task_id])
REFERENCES [dbo].[Tasks] ([task_id])
GO
ALTER TABLE [dbo].[Task_History] CHECK CONSTRAINT [fk_th_task]
GO
ALTER TABLE [dbo].[Task_History]  WITH CHECK ADD  CONSTRAINT [fk_th_user] FOREIGN KEY([changed_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Task_History] CHECK CONSTRAINT [fk_th_user]
GO
ALTER TABLE [dbo].[Task_History_Detail]  WITH CHECK ADD  CONSTRAINT [fk_thd_history] FOREIGN KEY([history_id])
REFERENCES [dbo].[Task_History] ([history_id])
GO
ALTER TABLE [dbo].[Task_History_Detail] CHECK CONSTRAINT [fk_thd_history]
GO
ALTER TABLE [dbo].[Task_Reminders]  WITH CHECK ADD  CONSTRAINT [fk_tr_created_by] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Task_Reminders] CHECK CONSTRAINT [fk_tr_created_by]
GO
ALTER TABLE [dbo].[Task_Reminders]  WITH CHECK ADD  CONSTRAINT [fk_tr_task] FOREIGN KEY([task_id])
REFERENCES [dbo].[Tasks] ([task_id])
GO
ALTER TABLE [dbo].[Task_Reminders] CHECK CONSTRAINT [fk_tr_task]
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
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [CK_Activities_SourceType] CHECK  (([source_type]='manual' OR [source_type]='system' OR [source_type]='customer' OR [source_type]='lead' OR [source_type]='deal' OR [source_type]='task' OR [source_type] IS NULL))
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [CK_Activities_SourceType]
GO
ALTER TABLE [dbo].[customer_contact]  WITH CHECK ADD CHECK  (([type]='PHONE' OR [type]='EMAIL'))
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [chk_assignment_type] CHECK  (([assignment_type]='LEAST_CUSTOMERS' OR [assignment_type]='ROUND_ROBIN'))
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [chk_assignment_type]
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [chk_segment_status] CHECK  (([status]='INACTIVE' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [chk_segment_status]
GO
ALTER TABLE [dbo].[Customer_Segments]  WITH CHECK ADD  CONSTRAINT [chk_segment_type] CHECK  (([segment_type]='DYNAMIC' OR [segment_type]='STATIC'))
GO
ALTER TABLE [dbo].[Customer_Segments] CHECK CONSTRAINT [chk_segment_type]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [chk_loyalty_tier] CHECK  (([loyalty_tier]='BLACKLIST' OR [loyalty_tier]='DIAMOND' OR [loyalty_tier]='PLATINUM' OR [loyalty_tier]='BRONZE' OR [loyalty_tier]='SILVER' OR [loyalty_tier]='GOLD'))
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [chk_loyalty_tier]
GO
ALTER TABLE [dbo].[Notification_Queue]  WITH CHECK ADD  CONSTRAINT [CK_NQueue_Priority] CHECK  (([priority]='urgent' OR [priority]='high' OR [priority]='normal' OR [priority]='low'))
GO
ALTER TABLE [dbo].[Notification_Queue] CHECK CONSTRAINT [CK_NQueue_Priority]
GO
ALTER TABLE [dbo].[Notification_Queue]  WITH CHECK ADD  CONSTRAINT [CK_NQueue_Status] CHECK  (([status]='cancelled' OR [status]='failed' OR [status]='sent' OR [status]='pending'))
GO
ALTER TABLE [dbo].[Notification_Queue] CHECK CONSTRAINT [CK_NQueue_Status]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [CK_NRE_Priority] CHECK  (([notification_priority]='urgent' OR [notification_priority]='high' OR [notification_priority]='normal' OR [notification_priority]='low'))
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [CK_NRE_Priority]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [CK_NRE_RecipientType] CHECK  (([recipient_type]='specific_user' OR [recipient_type]='manager' OR [recipient_type]='owner' OR [recipient_type]='assignee' OR [recipient_type] IS NULL))
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [CK_NRE_RecipientType]
GO
ALTER TABLE [dbo].[Notification_Rule_Engine]  WITH CHECK ADD  CONSTRAINT [CK_NRE_RuleType] CHECK  (([rule_type]='condition' OR [rule_type]='schedule' OR [rule_type]='event_trigger'))
GO
ALTER TABLE [dbo].[Notification_Rule_Engine] CHECK CONSTRAINT [CK_NRE_RuleType]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [CK_Notifications_Priority] CHECK  (([priority]='urgent' OR [priority]='high' OR [priority]='normal' OR [priority]='low'))
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [CK_Notifications_Priority]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [CK_Notifications_Status] CHECK  (([status]='cancelled' OR [status]='failed' OR [status]='sent' OR [status]='pending' OR [status]='draft'))
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [CK_Notifications_Status]
GO
ALTER TABLE [dbo].[Segment_Filters]  WITH CHECK ADD  CONSTRAINT [chk_filter_logic] CHECK  (([logic_operator]='OR' OR [logic_operator]='AND'))
GO
ALTER TABLE [dbo].[Segment_Filters] CHECK CONSTRAINT [chk_filter_logic]
GO
ALTER TABLE [dbo].[Segment_Filters]  WITH CHECK ADD  CONSTRAINT [chk_filter_operator] CHECK  (([operator]='IN' OR [operator]='LIKE' OR [operator]='<=' OR [operator]='>=' OR [operator]='<' OR [operator]='>' OR [operator]='='))
GO
ALTER TABLE [dbo].[Segment_Filters] CHECK CONSTRAINT [chk_filter_operator]
GO
ALTER TABLE [dbo].[Task_History]  WITH CHECK ADD  CONSTRAINT [CK_TaskHistory_Action] CHECK  (([action]='update' OR [action]='reopened' OR [action]='priority_changed' OR [action]='due_date_changed' OR [action]='cancelled' OR [action]='completed' OR [action]='progress_updated' OR [action]='unassigned' OR [action]='assigned' OR [action]='status_changed' OR [action]='created' OR [action] IS NULL))
GO
ALTER TABLE [dbo].[Task_History] CHECK CONSTRAINT [CK_TaskHistory_Action]
GO
ALTER TABLE [dbo].[Task_Reminders]  WITH CHECK ADD  CONSTRAINT [CK_TR_Unit] CHECK  (([remind_before_unit]='day' OR [remind_before_unit]='hour' OR [remind_before_unit]='minute'))
GO
ALTER TABLE [dbo].[Task_Reminders] CHECK CONSTRAINT [CK_TR_Unit]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [CK_Tasks_RelatedType] CHECK  (([related_type]='deal' OR [related_type]='lead' OR [related_type]='customer' OR [related_type] IS NULL))
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [CK_Tasks_RelatedType]
GO

GO
USE [master]
GO
ALTER DATABASE [CRM_System] SET  READ_WRITE
GO
