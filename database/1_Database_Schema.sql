USE [master]
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CRM_System')
BEGIN
    ALTER DATABASE CRM_System SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CRM_System;
END
/****** Object:  Database [CRM_System]    Script Date: 3/3/2026 8:01:48 PM ******/
CREATE DATABASE [CRM_System]
 CONTAINMENT = NONE

 GO

ALTER DATABASE [CRM_System] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CRM_System].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CRM_System] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [CRM_System] SET ANSI_NULLS OFF
GO
ALTER DATABASE [CRM_System] SET ANSI_PADDING OFF
GO
ALTER DATABASE [CRM_System] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [CRM_System] SET ARITHABORT OFF
GO
ALTER DATABASE [CRM_System] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [CRM_System] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [CRM_System] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [CRM_System] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [CRM_System] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [CRM_System] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [CRM_System] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [CRM_System] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [CRM_System] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [CRM_System] SET  ENABLE_BROKER
GO
ALTER DATABASE [CRM_System] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [CRM_System] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [CRM_System] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [CRM_System] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [CRM_System] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [CRM_System] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [CRM_System] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [CRM_System] SET RECOVERY FULL
GO
ALTER DATABASE [CRM_System] SET  MULTI_USER
GO
ALTER DATABASE [CRM_System] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [CRM_System] SET DB_CHAINING OFF
GO
ALTER DATABASE [CRM_System] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )
GO
ALTER DATABASE [CRM_System] SET TARGET_RECOVERY_TIME = 60 SECONDS
GO
ALTER DATABASE [CRM_System] SET DELAYED_DURABILITY = DISABLED
GO
ALTER DATABASE [CRM_System] SET ACCELERATED_DATABASE_RECOVERY = OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'CRM_System', N'ON'
GO
ALTER DATABASE [CRM_System] SET QUERY_STORE = ON
GO
ALTER DATABASE [CRM_System] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [CRM_System]
GO
/****** Object:  UserDefinedTableType [dbo].[IntList]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE TYPE [dbo].[IntList] AS TABLE(
	[Value] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StringList]    Script Date: 3/28/2026 4:55:23 PM ******/
CREATE TYPE [dbo].[StringList] AS TABLE(
	[Value] [nvarchar](255) NULL
)
GO
/****** Object:  Table [dbo].[Activities]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activities](
	[activity_id] [int] IDENTITY(1,1) NOT NULL,
	[related_type] [varchar](50) NULL,
	[related_id] [int] NULL,
	[activity_type] [varchar](50) NULL,
	[subject] [nvarchar](100) NULL,
	[description] [nvarchar](max) NULL,
	[created_by] [int] NULL,
	[activity_date] [datetime] NULL,
	[created_at] [datetime] NULL,
	[source_type] [varchar](50) NULL,
	[source_id] [int] NULL,
	[performed_by] [int] NULL,
	[metadata] [nvarchar](max) NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[activity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Campaign_Leads]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaign_Leads](
	[campaign_id] [int] NOT NULL,
	[lead_id] [int] NOT NULL,
	[lead_status] [varchar](30) NOT NULL,
	[assigned_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
 CONSTRAINT [pk_campaign_leads] PRIMARY KEY CLUSTERED
(
	[campaign_id] ASC,
	[lead_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Campaign_Reports]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaign_Reports](
	[report_id] [int] IDENTITY(1,1) NOT NULL,
	[campaign_id] [int] NULL,
	[total_lead] [int] NULL,
	[qualified_lead] [int] NULL,
	[converted_lead] [int] NULL,
	[cost_per_lead] [decimal](10, 2) NULL,
	[roi] [decimal](5, 2) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Campaigns]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaigns](
	[campaign_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[description] [nvarchar](max) NULL,
	[budget] [decimal](15, 2) NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[channel] [varchar](50) NULL,
	[status] [varchar](20) NULL,
	[created_by] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[campaign_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[category_id] [int] IDENTITY(1,1) NOT NULL,
	[category_name] [nvarchar](100) NULL,
	[description] [nvarchar](max) NULL,
	[status] [varchar](20) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category_Products]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category_Products](
	[category_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
 CONSTRAINT [pk_category_products] PRIMARY KEY CLUSTERED
(
	[category_id] ASC,
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[customer_contact]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_contact](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[type] [varchar](10) NOT NULL,
	[value] [varchar](255) NOT NULL,
	[is_primary] [bit] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[customer_merge_request]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_merge_request](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source_id] [int] NOT NULL,
	[target_id] [int] NOT NULL,
	[status] [varchar](20) NOT NULL,
	[field_overrides] [nvarchar](max) NULL,
	[reason] [nvarchar](max) NULL,
	[reject_reason] [nvarchar](max) NULL,
	[created_by] [int] NOT NULL,
	[reviewed_by] [int] NULL,
	[created_at] [datetime2](7) NULL,
	[reviewed_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[customer_note]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_note](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[note] [nvarchar](max) NULL,
	[created_by] [int] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Segment_Map]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Segment_Map](
	[customer_id] [int] NOT NULL,
	[segment_id] [int] NOT NULL,
	[assigned_at] [datetime] NULL,
	[assigned_by] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[customer_id] ASC,
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Segments]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Segments](
	[segment_id] [int] IDENTITY(1,1) NOT NULL,
	[segment_name] [nvarchar](50) NULL,
	[criteria_logic] [nvarchar](max) NULL,
	[segment_type] [nvarchar](10) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[created_at] [datetime] NOT NULL,
	[created_by] [int] NULL,
	[updated_at] [datetime] NULL,
	[updated_by] [int] NULL,
	[assignment_type] [nvarchar](20) NOT NULL,
	[last_assigned_user_id] [int] NULL,
	[customer_count] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Style_Map]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Style_Map](
	[customer_id] [int] NOT NULL,
	[tag_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerOTP]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerOTP](
	[customer_id] [int] NOT NULL,
	[otp_hash] [nvarchar](255) NOT NULL,
	[otp_expired_at] [datetime2](7) NOT NULL,
	[failed_attempt] [int] NULL,
	[send_count] [int] NULL,
	[last_send] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[phone] [varchar](20) NULL,
	[email] [varchar](100) NULL,
	[birthday] [date] NULL,
	[gender] [nvarchar](10) NULL,
	[address] [nvarchar](255) NULL,
	[source] [nvarchar](50) NULL,
	[customer_type] [varchar](20) NULL,
	[status] [nvarchar](20) NULL,
	[loyalty_tier] [nvarchar](20) NULL,
	[return_rate] [decimal](5, 2) NULL,
	[last_purchase] [datetime] NULL,
	[owner_id] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[interest] [nvarchar](255) NULL,
	[total_spent] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Deal_Products]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Deal_Products](
	[deal_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity] [int] NULL,
	[unit_price] [decimal](15, 2) NULL,
	[discount] [decimal](5, 2) NULL,
	[total_price] [decimal](15, 2) NULL,
 CONSTRAINT [pk_deal_products] PRIMARY KEY CLUSTERED
(
	[deal_id] ASC,
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Deals]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Deals](
	[deal_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[lead_id] [int] NULL,
	[deal_name] [nvarchar](100) NULL,
	[expected_value] [decimal](15, 2) NULL,
	[actual_value] [decimal](15, 2) NULL,
	[stage] [varchar](20) NULL,
	[probability] [int] NULL,
	[expected_close_date] [date] NULL,
	[owner_id] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[deal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Feedbacks]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feedbacks](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[ticket_id] [int] NULL,
	[rating] [int] NULL,
	[comment] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Leads]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Leads](
	[lead_id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [nvarchar](100) NULL,
	[email] [varchar](100) NULL,
	[phone] [varchar](20) NULL,
	[interest] [nvarchar](255) NULL,
	[source] [varchar](50) NULL,
	[status] [varchar](20) NULL,
	[campaign_id] [int] NULL,
	[assigned_to] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[score] [int] NULL,
	[is_converted] [bit] NOT NULL,
	[converted_customer_id] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[lead_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notification_Queue]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification_Queue](
	[queue_id] [int] IDENTITY(1,1) NOT NULL,
	[notification_id] [int] NULL,
	[title] [nvarchar](200) NOT NULL,
	[content] [nvarchar](max) NULL,
	[type] [varchar](30) NULL,
	[related_type] [varchar](50) NULL,
	[related_id] [int] NULL,
	[recipient_user_id] [int] NOT NULL,
	[status] [varchar](20) NOT NULL,
	[priority] [varchar](20) NOT NULL,
	[scheduled_at] [datetime] NOT NULL,
	[sent_at] [datetime] NULL,
	[failed_at] [datetime] NULL,
	[retry_count] [int] NOT NULL,
	[max_retries] [int] NOT NULL,
	[error_message] [nvarchar](500) NULL,
	[created_at] [datetime] NOT NULL,
 CONSTRAINT [PK_Notification_Queue] PRIMARY KEY CLUSTERED
(
	[queue_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notification_Recipients]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification_Recipients](
	[notification_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[is_read] [bit] NOT NULL,
	[read_at] [datetime] NULL,
 CONSTRAINT [PK_Notification_Recipients] PRIMARY KEY CLUSTERED
(
	[notification_id] ASC,
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notification_Rule_Engine]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification_Rule_Engine](
	[rule_id] [int] IDENTITY(1,1) NOT NULL,
	[rule_name] [nvarchar](100) NOT NULL,
	[rule_type] [varchar](30) NOT NULL,
	[description] [nvarchar](500) NULL,
	[trigger_event] [varchar](50) NULL,
	[entity_type] [varchar](50) NULL,
	[condition_field] [varchar](50) NULL,
	[condition_operator] [varchar](30) NULL,
	[condition_value] [int] NULL,
	[condition_unit] [varchar](20) NULL,
	[cron_expression] [varchar](100) NULL,
	[next_run_at] [datetime] NULL,
	[last_run_at] [datetime] NULL,
	[notification_title_template] [nvarchar](200) NULL,
	[notification_content_template] [nvarchar](max) NULL,
	[notification_type] [varchar](30) NULL,
	[notification_priority] [varchar](20) NOT NULL,
	[recipient_type] [varchar](30) NULL,
	[recipient_user_id] [int] NULL,
	[escalate_after_minutes] [int] NULL,
	[escalate_to_user_id] [int] NULL,
	[is_active] [bit] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NULL,
 CONSTRAINT [PK_Notification_Rule_Engine] PRIMARY KEY CLUSTERED
(
	[rule_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[notification_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[content] [nvarchar](max) NULL,
	[type] [varchar](30) NULL,
	[related_type] [varchar](50) NULL,
	[related_id] [int] NULL,
	[created_at] [datetime] NOT NULL,
	[priority] [varchar](20) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[scheduled_at] [datetime] NULL,
	[created_by] [int] NULL,
	[expires_at] [datetime] NULL,
 CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED
(
	[notification_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pagination_Anchors]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pagination_Anchors](
	[session_id] [uniqueidentifier] NOT NULL,
	[page_number] [int] NOT NULL,
	[anchor_rfm] [decimal](10, 4) NOT NULL,
	[anchor_id] [int] NOT NULL,
	[created_at] [datetime2](7) NULL,
 CONSTRAINT [PK_PaginationAnchors] PRIMARY KEY CLUSTERED
(
	[session_id] ASC,
	[page_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[product_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[sku] [varchar](50) NULL,
	[price] [decimal](15, 2) NULL,
	[description] [nvarchar](max) NULL,
	[status] [varchar](20) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [varchar](50) NOT NULL,
	[description] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Segment_Filters]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Segment_Filters](
	[filter_id] [int] IDENTITY(1,1) NOT NULL,
	[segment_id] [int] NOT NULL,
	[field_name] [nvarchar](50) NOT NULL,
	[operator] [nvarchar](20) NOT NULL,
	[value] [nvarchar](255) NULL,
	[logic_operator] [nvarchar](10) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[filter_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Segment_Update_History]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Segment_Update_History](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[segment_id] [int] NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime] NULL,
	[change_description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Service_Reports]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Service_Reports](
	[report_id] [int] IDENTITY(1,1) NOT NULL,
	[report_date] [date] NULL,
	[total_ticket] [int] NULL,
	[resolved_ticket] [int] NULL,
	[avg_response_time] [decimal](10, 2) NULL,
	[avg_resolution_time] [decimal](10, 2) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Style_Tags]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Style_Tags](
	[tag_id] [int] IDENTITY(1,1) NOT NULL,
	[tag_name] [nvarchar](50) NULL,
	[category] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task_Assignees]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task_Assignees](
	[task_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[assigned_at] [datetime] NOT NULL,
	[assigned_by] [int] NULL,
	[is_primary] [bit] NOT NULL,
	[removed_at] [datetime] NULL,
	[is_active] [bit] NULL,
 CONSTRAINT [PK_Task_Assignees] PRIMARY KEY CLUSTERED
(
	[task_id] ASC,
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task_Comments]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task_Comments](
	[comment_id] [int] IDENTITY(1,1) NOT NULL,
	[task_id] [int] NOT NULL,
	[created_by] [int] NOT NULL,
	[content] [nvarchar](max) NOT NULL,
	[parent_comment_id] [int] NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NULL,
	[assigned_to] [int] NULL,
	[is_completed] [bit] NOT NULL,
	[completed_at] [datetime] NULL,
 CONSTRAINT [PK_Task_Comments] PRIMARY KEY CLUSTERED
(
	[comment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task_History]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task_History](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[task_id] [int] NOT NULL,
	[changed_by] [int] NOT NULL,
	[changed_at] [datetime] NOT NULL,
	[action] [varchar](50) NOT NULL,
	[note] [nvarchar](500) NULL,
 CONSTRAINT [PK_Task_History] PRIMARY KEY CLUSTERED
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task_History_Detail]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task_History_Detail](
	[detail_id] [int] IDENTITY(1,1) NOT NULL,
	[history_id] [int] NOT NULL,
	[field_name] [varchar](50) NOT NULL,
	[old_value] [nvarchar](500) NULL,
	[new_value] [nvarchar](500) NULL,
 CONSTRAINT [PK_Task_History_Detail] PRIMARY KEY CLUSTERED
(
	[detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task_Reminders]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task_Reminders](
	[reminder_id] [int] IDENTITY(1,1) NOT NULL,
	[task_id] [int] NOT NULL,
	[remind_before_value] [int] NOT NULL,
	[remind_before_unit] [varchar](20) NOT NULL,
	[remind_at] [datetime] NOT NULL,
	[is_sent] [bit] NOT NULL,
	[sent_at] [datetime] NULL,
	[created_by] [int] NULL,
	[created_at] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_Reminders] PRIMARY KEY CLUSTERED
(
	[reminder_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tasks]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tasks](
	[task_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[description] [nvarchar](max) NULL,
	[status] [varchar](30) NOT NULL,
	[priority] [varchar](20) NOT NULL,
	[due_date] [datetime] NULL,
	[progress] [int] NOT NULL,
	[created_by] [int] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[start_date] [datetime] NULL,
	[completed_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[related_type] [varchar](50) NULL,
	[related_id] [int] NULL,
	[cancelled_at] [datetime] NULL,
 CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED
(
	[task_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tickets]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tickets](
	[ticket_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NULL,
	[subject] [nvarchar](100) NULL,
	[description] [nvarchar](max) NULL,
	[priority] [varchar](20) NULL,
	[status] [varchar](20) NULL,
	[assigned_to] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ticket_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password_hash] [varchar](255) NOT NULL,
	[email] [varchar](100) NULL,
	[full_name] [nvarchar](100) NULL,
	[phone] [varchar](20) NULL,
	[role_id] [int] NOT NULL,
	[status] [varchar](20) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[last_login_at] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Virtual_Wardrobe]    Script Date: 3/28/2026 4:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Virtual_Wardrobe](
	[wardrobe_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[bought_at] [datetime] NULL,
	[photo_feedback] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED
(
	[wardrobe_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
