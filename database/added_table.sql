DROP TABLE IF EXISTS [dbo].[Notification_Rules];
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification_Rules](
	[rule_id] [int] IDENTITY(1,1) NOT NULL,
	[notification_id] [int] NOT NULL,
	[rule_type] [varchar](30) NOT NULL,
	[interval_value] [int] NULL,
	[interval_unit] [varchar](20) NULL,
	[next_run] [datetime] NOT NULL,
	[last_run] [datetime] NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime] NOT NULL,
 CONSTRAINT [PK_Notification_Rules] PRIMARY KEY CLUSTERED 
(
	[rule_id] ASC
)WITH (
	PAD_INDEX = OFF,
	STATISTICS_NORECOMPUTE = OFF,
	IGNORE_DUP_KEY = OFF,
	ALLOW_ROW_LOCKS = ON,
	ALLOW_PAGE_LOCKS = ON,
	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [PRIMARY]
) ON [PRIMARY]
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