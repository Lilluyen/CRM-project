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
SET IDENTITY_INSERT [dbo].[Activities] ON 
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (1, N'CUSTOMER', 1, N'CALL', N'Call Customer', N'Called customer to confirm delivery status', 2, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (2, N'LEAD', 1, N'EMAIL', N'Send email to Lead', N'Sent follow-up email regarding proposal', 1, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (3, N'INTERNAL', NULL, N'MEETING', N'Internal Meetng', N'Internal meeting about Q2 sales strategy', 3, CAST(N'2026-03-03T19:14:42.120' AS DateTime), CAST(N'2026-03-03T19:14:42.120' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (4, NULL, NULL, N'task_overdue', N'Task overdue: Call Potential Customer', N'Due date was 2026-03-06T15:00', NULL, CAST(N'2026-03-28T16:20:34.190' AS DateTime), CAST(N'2026-03-28T16:20:34.193' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (5, NULL, NULL, N'task_overdue', N'Task overdue: Design CRM Database', N'Due date was 2026-03-10T17:00', NULL, CAST(N'2026-03-28T16:20:34.197' AS DateTime), CAST(N'2026-03-28T16:20:34.197' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (6, NULL, NULL, N'task_overdue', N'Task overdue: Prepare Product Demo', N'Due date was 2026-03-11T16:00', NULL, CAST(N'2026-03-28T16:20:34.200' AS DateTime), CAST(N'2026-03-28T16:20:34.197' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (7, NULL, NULL, N'task_overdue', N'Task overdue: Create Contacts Module', N'Due date was 2026-03-12T17:00', NULL, CAST(N'2026-03-28T16:20:34.200' AS DateTime), CAST(N'2026-03-28T16:20:34.200' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Activities] ([activity_id], [related_type], [related_id], [activity_type], [subject], [description], [created_by], [activity_date], [created_at], [source_type], [source_id], [performed_by], [metadata], [updated_at]) VALUES (8, NULL, NULL, N'task_overdue', N'Task overdue: Send Proposal Email', N'Due date was 2026-03-13T10:00', NULL, CAST(N'2026-03-28T16:20:34.203' AS DateTime), CAST(N'2026-03-28T16:20:34.200' AS DateTime), NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Activities] OFF
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 1, N'Contacted', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-10T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 2, N'Contacted', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-12T10:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (1, 6, N'Qualified', CAST(N'2026-01-05T08:00:00.000' AS DateTime), CAST(N'2026-01-20T11:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 3, N'Qualified', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-10T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 4, N'Converted', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (2, 15, N'New', CAST(N'2026-02-03T08:00:00.000' AS DateTime), CAST(N'2026-02-03T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 5, N'New', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-01-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 8, N'Lost', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-02-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (3, 13, N'Converted', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-02-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 7, N'Qualified', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 9, N'Qualified', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (4, 14, N'Contacted', CAST(N'2026-03-01T08:00:00.000' AS DateTime), CAST(N'2026-03-03T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (5, 10, N'Contacted', CAST(N'2026-02-12T08:00:00.000' AS DateTime), CAST(N'2026-02-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (5, 12, N'Qualified', CAST(N'2026-02-12T08:00:00.000' AS DateTime), CAST(N'2026-02-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (6, 11, N'New', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-01-15T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (6, 17, N'Contacted', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-01-20T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (7, 16, N'Qualified', CAST(N'2026-02-20T08:00:00.000' AS DateTime), CAST(N'2026-02-25T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (7, 20, N'Converted', CAST(N'2026-02-20T08:00:00.000' AS DateTime), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (8, 18, N'Lost', CAST(N'2026-03-02T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Leads] ([campaign_id], [lead_id], [lead_status], [assigned_at], [updated_at]) VALUES (9, 19, N'New', CAST(N'2026-03-05T08:00:00.000' AS DateTime), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaign_Reports] ON 
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (1, 1, 3, 1, 0, CAST(1666.67 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-02-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (2, 2, 3, 1, 1, CAST(2333.33 AS Decimal(10, 2)), CAST(28.50 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (3, 3, 3, 1, 1, CAST(666.67 AS Decimal(10, 2)), CAST(42.30 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (4, 4, 3, 2, 0, CAST(4000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-06T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (5, 5, 2, 1, 0, CAST(1750.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (6, 6, 2, 0, 0, CAST(1500.00 AS Decimal(10, 2)), CAST(15.00 AS Decimal(5, 2)), CAST(N'2026-02-02T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (7, 7, 2, 1, 1, CAST(1500.00 AS Decimal(10, 2)), CAST(55.20 AS Decimal(5, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (8, 8, 1, 0, 0, CAST(9000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (9, 9, 1, 0, 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(5, 2)), CAST(N'2026-03-06T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Campaign_Reports] ([report_id], [campaign_id], [total_lead], [qualified_lead], [converted_lead], [cost_per_lead], [roi], [created_at]) VALUES (10, 10, 0, 0, 0, CAST(0.00 AS Decimal(10, 2)), CAST(38.70 AS Decimal(5, 2)), CAST(N'2026-01-02T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaign_Reports] OFF
GO
SET IDENTITY_INSERT [dbo].[Campaigns] ON 
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (1, N'Facebook Lead Gen Q1', N'Chạy quảng cáo thu lead cho sản phẩm CRM', CAST(5000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-03-31' AS Date), N'Facebook', N'ACTIVE', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (2, N'Google Search Ads - Cloud', N'Quảng cáo từ khóa dịch vụ Cloud Migration', CAST(7000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-04-30' AS Date), N'Google', N'ACTIVE', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (3, N'Email Marketing Automation', N'Gửi email nurturing khách hàng tiềm năng', CAST(2000.00 AS Decimal(15, 2)), CAST(N'2026-01-15' AS Date), CAST(N'2026-02-28' AS Date), N'Email', N'COMPLETED', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (4, N'Business Seminar 2026', N'Tổ chức hội thảo chuyển đổi số cho doanh nghiệp', CAST(12000.00 AS Decimal(15, 2)), CAST(N'2026-03-10' AS Date), CAST(N'2026-03-10' AS Date), N'Event', N'PLANNING', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (5, N'LinkedIn B2B Outreach', N'Chiến dịch tiếp cận khách hàng doanh nghiệp', CAST(3500.00 AS Decimal(15, 2)), CAST(N'2026-02-10' AS Date), CAST(N'2026-05-10' AS Date), N'LinkedIn', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (6, N'SEO Branding Campaign', N'Tăng nhận diện thương hiệu qua SEO', CAST(4000.00 AS Decimal(15, 2)), CAST(N'2025-11-01' AS Date), CAST(N'2026-02-01' AS Date), N'SEO', N'COMPLETED', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (7, N'Referral Partner Program', N'Khuyến khích đối tác giới thiệu khách hàng', CAST(3000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), N'Referral', N'ACTIVE', 5, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (8, N'Product Launch Ads', N'Quảng bá ra mắt hệ thống CRM phiên bản mới', CAST(9000.00 AS Decimal(15, 2)), CAST(N'2026-03-01' AS Date), CAST(N'2026-04-15' AS Date), N'Facebook', N'ACTIVE', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (9, N'Retargeting Campaign', N'Retarget khách hàng đã truy cập website', CAST(2500.00 AS Decimal(15, 2)), CAST(N'2026-02-20' AS Date), CAST(N'2026-03-30' AS Date), N'Google Display', N'ACTIVE', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (10, N'Year End Promotion 2025', N'Chiến dịch ưu đãi cuối năm', CAST(6000.00 AS Decimal(15, 2)), CAST(N'2025-10-01' AS Date), CAST(N'2025-12-31' AS Date), N'Multi-channel', N'COMPLETED', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Campaigns] OFF
GO
SET IDENTITY_INSERT [dbo].[Categories] ON 
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (1, N'Áo sơ mi', N'Các loại áo sơ mi nam và nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (2, N'Quần jeans', N'Quần jeans thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (3, N'Váy đầm', N'Váy đầm công sở và dạo phố', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (4, N'Áo khoác', N'Áo khoác mùa đông', N'INACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (5, N'Phụ kiện', N'Phụ kiện thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (6, N'Áo thun', N'Áo thun nam nữ nhiều mẫu mã', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (7, N'Áo polo', N'Áo polo lịch sự và trẻ trung', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (8, N'Quần short', N'Quần short thể thao và dạo phố', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (9, N'Quần tây', N'Quần tây công sở nam nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (10, N'Áo hoodie', N'Áo hoodie phong cách streetwear', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (11, N'Áo len', N'Áo len giữ ấm mùa đông', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (12, N'Áo vest', N'Áo vest công sở cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (13, N'Đồ thể thao', N'Trang phục thể thao năng động', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (14, N'Đồ ngủ', N'Đồ ngủ thoải mái tại nhà', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (15, N'Đồ lót', N'Đồ lót nam nữ cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (16, N'Balo', N'Balo thời trang và du lịch', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (17, N'Túi xách', N'Túi xách nữ thời trang', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (18, N'Giày sneaker', N'Giày sneaker năng động', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (19, N'Giày cao gót', N'Giày cao gót nữ sang trọng', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (20, N'Dép sandal', N'Dép sandal mùa hè', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (21, N'Mũ nón', N'Mũ thời trang các loại', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (22, N'Khăn choàng', N'Khăn choàng cổ mùa đông', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (23, N'Thắt lưng', N'Thắt lưng da cao cấp', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (24, N'Đồng hồ', N'Đồng hồ thời trang nam nữ', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Categories] ([category_id], [category_name], [description], [status], [created_at]) VALUES (25, N'Kính mát', N'Kính mát chống tia UV', N'ACTIVE', CAST(N'2026-01-05T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Categories] OFF
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 1)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 5)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 7)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (1, 10)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (2, 2)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (2, 8)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (3, 3)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (5, 6)
GO
INSERT [dbo].[Category_Products] ([category_id], [product_id]) VALUES (5, 9)
GO
SET IDENTITY_INSERT [dbo].[Leads] ON 
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (1, N'Nguyen Van An', N'an.nguyen@gmail.com', N'0901000001', N'Ao thun', N'Website', N'Qualified', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (2, N'Tran Thi Binh', N'binh.tran@gmail.com', N'0901000002', N'', N'Facebook', N'QUALIFIED', 2, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:25.277' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (3, N'Le Hoang Nam', N'nam.le@gmail.com', N'0901000003', N'Ao khoac', N'Referral', N'Nurturing', 3, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 60, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (4, N'Pham Gia Huy', N'huy.pham@gmail.com', N'', N'', N'Website', N'NURTURING', 4, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:31.657' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (5, N'Do Minh Quan', N'quan@gmail.com', N'0901000005', NULL, N'LinkedIn', N'New', 5, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (6, N'Vo Thu Trang', N'trang@gmail.com', NULL, NULL, N'Facebook', N'New', 6, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 20, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (7, N'Nguyen Tuan Kiet', N'kiet@gmail.com', N'abc123', NULL, N'Seminar', N'Lost', 7, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (8, N'Bui Thanh Dat', N'dat@gmail.com', NULL, NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 18, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (9, N'Hoang Lan Chi', N'chi.hoang@gmail.com', N'0901000009', N'Chan vay', N'Referral', N'Qualified', 9, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (10, N'Pham Duc Long', N'long.pham@gmail.com', N'0901000010', N'', N'Facebook', N'QUALIFIED', 10, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:38.807' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (11, N'Nguyen Hai Yen', N'yen.nguyen@gmail.com', NULL, NULL, N'Website', N'New', 1, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (12, N'Tran Quoc Bao', N'bao.tran@gmail.com', N'0901000012', N'Ao blazer', N'LinkedIn', N'Qualified', 2, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (13, N'Le Thi Hoa', N'hoa.le@gmail.com', N'0901000013', N'', N'Referral', N'QUALIFIED', 3, NULL, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-23T15:43:48.693' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (14, N'Vo Minh Tam', N'tam.vo@gmail.com', N'0901000014', NULL, N'Seminar', N'Nurturing', 4, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (15, N'Dang Quang Vinh', N'vinh.dang@gmail.com', NULL, NULL, N'Website', N'New', 5, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 40, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (16, N'Phan Thu Ha', N'ha.phan@gmail.com', N'0901000016', N'Dam du tiec', N'Facebook', N'Qualified', 6, 5, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (17, N'Nguyen Duc Manh', N'manh.nguyen@gmail.com', N'0901000017', NULL, N'LinkedIn', N'Nurturing', 7, 1, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (18, N'Trinh Bao Chau', N'chau@gmail.com', N'abc999', NULL, N'Website', N'Lost', 8, 4, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 15, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (19, N'Le Anh Tuan', N'tuan.le@gmail.com', N'0901000019', N'Quan kaki', N'Referral', N'Qualified', 9, 2, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 80, 0, NULL)
GO
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score], [is_converted], [converted_customer_id]) VALUES (20, N'Pham Ngoc Mai', N'mai.pham@gmail.com', N'0901000020', NULL, N'Facebook', N'Nurturing', 10, 3, CAST(N'2026-03-03T19:49:02.007' AS DateTime), CAST(N'2026-03-03T19:49:02.007' AS DateTime), 70, 0, NULL)
GO
SET IDENTITY_INSERT [dbo].[Leads] OFF
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (1, 1, 1, CAST(N'2026-03-02T14:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (1, 3, 1, CAST(N'2026-03-02T14:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (2, 1, 1, CAST(N'2026-03-03T08:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (2, 2, 1, CAST(N'2026-03-03T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (3, 1, 1, CAST(N'2026-02-25T17:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (3, 4, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 1, 1, CAST(N'2026-03-07T08:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 2, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (4, 3, 1, CAST(N'2026-03-07T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (5, 1, 1, CAST(N'2026-03-03T09:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (5, 5, 1, CAST(N'2026-03-03T10:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (6, 1, 1, CAST(N'2026-03-01T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (6, 3, 1, CAST(N'2026-03-01T09:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (7, 1, 1, CAST(N'2026-03-02T15:30:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (7, 5, 1, CAST(N'2026-03-02T16:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (8, 1, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (8, 5, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (9, 1, 1, CAST(N'2026-03-07T22:10:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (9, 4, 0, NULL)
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (10, 1, 1, CAST(N'2026-03-01T09:00:00.000' AS DateTime))
GO
INSERT [dbo].[Notification_Recipients] ([notification_id], [user_id], [is_read], [read_at]) VALUES (10, 5, 1, CAST(N'2026-03-01T10:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Notification_Rule_Engine] ON 
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (1, N'Notify khi Task được tạo', N'event_trigger', N'Khi 1 task mới được tạo và assign, gửi thông báo cho người nhận', N'task_created', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[Task mới] {{task_title}}', N'Bạn được giao task: {{task_title}}. Deadline: {{due_date}}.', N'alert', N'normal', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.857' AS DateTime), NULL)
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (2, N'Notify khi Task hoàn thành', N'event_trigger', N'Khi task được đánh dấu completed, notify người tạo task', N'task_completed', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[Hoàn thành] {{task_title}}', N'Task "{{task_title}}" đã được hoàn thành bởi {{assignee_name}}.', N'alert', N'normal', N'owner', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.867' AS DateTime), NULL)
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (3, N'Cảnh báo Task quá hạn', N'event_trigger', N'Khi task bị overdue, cảnh báo assignee và escalate cho manager', N'task_overdue', NULL, NULL, NULL, NULL, N'day', NULL, NULL, NULL, N'[OVERDUE] {{task_title}} đã quá hạn', N'Task "{{task_title}}" đã quá deadline {{due_date}}. Vui lòng xử lý ngay.', N'escalation', N'high', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.877' AS DateTime), NULL)
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (4, N'Customer không được contact 7 ngày', N'condition', N'Nếu customer chưa có activity nào trong 7 ngày, nhắc owner follow up', NULL, N'customer', N'last_activity_date', N'no_activity_for', 7, N'day', NULL, NULL, NULL, N'[Follow up] {{customer_name}} chưa được liên hệ', N'Customer {{customer_name}} chưa có tương tác trong 7 ngày. Hãy liên hệ ngay.', N'reminder', N'normal', N'owner', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.887' AS DateTime), NULL)
GO
INSERT [dbo].[Notification_Rule_Engine] ([rule_id], [rule_name], [rule_type], [description], [trigger_event], [entity_type], [condition_field], [condition_operator], [condition_value], [condition_unit], [cron_expression], [next_run_at], [last_run_at], [notification_title_template], [notification_content_template], [notification_type], [notification_priority], [recipient_type], [recipient_user_id], [escalate_after_minutes], [escalate_to_user_id], [is_active], [created_by], [created_at], [updated_at]) VALUES (5, N'Daily Task Digest', N'schedule', N'Mỗi sáng 8h gửi tóm tắt task trong ngày cho từng user', NULL, NULL, NULL, NULL, NULL, N'day', N'0 8 * * *', CAST(N'2026-03-29T00:00:00.000' AS DateTime), NULL, N'[Daily Digest] Task hôm nay của bạn', N'Bạn có {{task_count}} task cần xử lý hôm nay. Deadline gần nhất: {{nearest_due}}.', N'digest', N'low', N'assignee', NULL, NULL, NULL, 1, NULL, CAST(N'2026-03-28T16:15:34.893' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[Notification_Rule_Engine] OFF
GO
SET IDENTITY_INSERT [dbo].[Notifications] ON 
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (1, N'Deal Mới Cần Xử Lý', N'Deal "CRM Implementation" (deal_id=35) vừa được tạo và chờ xử lý.', N'deal', N'deal', 35, CAST(N'2026-03-02T13:37:03.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (2, N'Lead Chuyển Đổi Thành Công', N'Lead id=4 đã được chuyển đổi thành khách hàng.', N'lead', N'lead', 4, CAST(N'2026-03-03T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (3, N'Ticket Khẩn Cần Phân Công', N'Ticket #5 mức HIGH chưa được phân công xử lý.', N'ticket', N'ticket', 5, CAST(N'2026-02-25T17:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (4, N'Task Sắp Đến Hạn', N'Task "Design CRM Database" sẽ đến hạn vào 2026-03-10.', N'task', N'task', 1, CAST(N'2026-03-07T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (5, N'Khách Hàng VIP Mới', N'Customer_id=28 vừa đạt hạng PLATINUM.', N'customer', N'customer', 28, CAST(N'2026-03-03T09:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (6, N'Campaign Kết Thúc', N'Campaign id=3 đã kết thúc. Tỷ lệ chuyển đổi đạt 33%.', N'campaign', N'campaign', 3, CAST(N'2026-03-01T08:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (7, N'Deal Thắng - Chúc Mừng!', N'Deal id=22 đã chốt thành công 14,800,000 VND.', N'deal', N'deal', 22, CAST(N'2026-03-02T15:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (8, N'Nhắc Nhở Follow-up Khách Hàng', N'10 khách hàng chưa được liên hệ trong 30 ngày qua.', N'system', NULL, NULL, CAST(N'2026-03-05T07:00:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (9, N'OTP Thất Bại Nhiều Lần', N'Customer_id=5 đã nhập OTP sai 3 lần liên tiếp.', N'security', N'customer', 5, CAST(N'2026-03-07T22:05:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([notification_id], [title], [content], [type], [related_type], [related_id], [created_at], [priority], [status], [scheduled_at], [created_by], [expires_at]) VALUES (10, N'Báo Cáo Dịch Vụ Tháng 2/2026', N'Tổng 30 tickets, giải quyết 22, thời gian phản hồi TB: 1.9h.', N'report', NULL, NULL, CAST(N'2026-03-01T08:30:00.000' AS DateTime), N'normal', N'pending', NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (1, N'Váy Dạ Hội Luxury Rouge', N'VDH-001', CAST(4500000.00 AS Decimal(15, 2)), N'Váy dạ hội thiết kế cao cấp, chất liệu lụa nhập khẩu, màu đỏ rượu', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:50.653' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (2, N'Đầm Công Sở Sapphire', N'DCS-002', CAST(1850000.00 AS Decimal(15, 2)), N'Đầm công sở thanh lịch, vải tweed, màu xanh sapphire', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:44.700' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (3, N'Váy Cưới Ivory Princess', N'VC-003', CAST(12000000.00 AS Decimal(15, 2)), N'Váy cưới công chúa, ren Pháp, đuôi dài 1.5m, màu trắng ngà', N'ACTIVE', CAST(N'2026-01-10T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:47.500' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (4, N'Đầm Thiết Kế Bohemian Sunset', N'DTK-004', CAST(2200000.00 AS Decimal(15, 2)), N'Đầm thiết kế phong cách boho, in hoạ tiết hoa, chất voan mềm', N'ACTIVE', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:38.833' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (5, N'Váy Dự Tiệc Midnight Sequin', N'VDT-005', CAST(3100000.00 AS Decimal(15, 2)), N'Váy dự tiệc đính sequin ánh bạc, dáng ôm, phù hợp sự kiện', N'ACTIVE', CAST(N'2026-01-15T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:41.960' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (6, N'Đầm Trẻ Trung Summer Blossom', N'DTT-006', CAST(980000.00 AS Decimal(15, 2)), N'Đầm hoa nhí tươi tắn, chất cotton mềm, phù hợp đi chơi ngày hè', N'ACTIVE', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:33.263' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (7, N'Váy Cao Cấp Velvet Noir', N'VCC-007', CAST(5800000.00 AS Decimal(15, 2)), N'Váy nhung đen cao cấp, cổ V sâu, phù hợp tiệc tối sang trọng', N'ACTIVE', CAST(N'2026-01-20T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:36.327' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (8, N'Đầm Công Sở Minimalist Grey', N'DCS-008', CAST(1650000.00 AS Decimal(15, 2)), N'Đầm công sở tối giản, màu xám đậm, chất liệu polyester cao cấp', N'ACTIVE', CAST(N'2026-02-01T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:27.533' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (9, N'Váy Vintage Floral Midi', N'VVT-009', CAST(1350000.00 AS Decimal(15, 2)), N'Váy midi vintage họa tiết hoa retro, chất linen thoáng mát', N'ACTIVE', CAST(N'2026-02-01T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:30.483' AS DateTime))
GO
INSERT [dbo].[Products] ([product_id], [name], [sku], [price], [description], [status], [created_at], [updated_at]) VALUES (10, N'Đầm Dạ Hội Pearl Gown', N'DDH-010', CAST(7500000.00 AS Decimal(15, 2)), N'Đầm gown dạ hội đính ngọc trai thủ công, dáng xoè, chất satin', N'ACTIVE', CAST(N'2026-02-05T08:00:00.000' AS DateTime), CAST(N'2026-03-28T16:23:24.020' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (1, N'ADMIN', N'Qu?n tr? h? th?ng', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (2, N'SALE', N'Nhân viên kinh doanh', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (3, N'MARKETING', N'Nhân viên marketing', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (4, N'CS', N'Customer Support', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (5, N'MANAGER', N'Qu?n l?', CAST(N'2026-03-03T19:14:42.067' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Service_Reports] ON 
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (1, CAST(N'2025-10-31' AS Date), 18, 16, CAST(2.40 AS Decimal(10, 2)), CAST(18.50 AS Decimal(10, 2)), CAST(N'2025-11-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (2, CAST(N'2025-11-30' AS Date), 22, 20, CAST(1.80 AS Decimal(10, 2)), CAST(15.20 AS Decimal(10, 2)), CAST(N'2025-12-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (3, CAST(N'2025-12-31' AS Date), 31, 28, CAST(2.10 AS Decimal(10, 2)), CAST(14.80 AS Decimal(10, 2)), CAST(N'2026-01-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (4, CAST(N'2026-01-31' AS Date), 25, 24, CAST(1.50 AS Decimal(10, 2)), CAST(12.30 AS Decimal(10, 2)), CAST(N'2026-02-01T08:00:00.000' AS DateTime))
GO
INSERT [dbo].[Service_Reports] ([report_id], [report_date], [total_ticket], [resolved_ticket], [avg_response_time], [avg_resolution_time], [created_at]) VALUES (5, CAST(N'2026-02-28' AS Date), 30, 22, CAST(1.90 AS Decimal(10, 2)), CAST(16.70 AS Decimal(10, 2)), CAST(N'2026-03-01T08:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Service_Reports] OFF
GO
SET IDENTITY_INSERT [dbo].[Style_Tags] ON 
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (1, N'#Vintage', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (2, N'#Minimalism', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (3, N'#Streetwear', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (4, N'#Office', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (5, N'#Pastel', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (6, N'#DarkTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (7, N'#Silk', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (8, N'#Denim', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (9, N'#Elegant', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (10, N'#Classic', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (11, N'#Sporty', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (12, N'#Bohemian', N'Style')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (13, N'#Neutral', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (14, N'#WarmTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (15, N'#CoolTone', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (16, N'#Monochrome', N'Color')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (17, N'#Cotton', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (18, N'#Linen', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (19, N'#Leather', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (20, N'#Wool', N'Material')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (21, N'#Party', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (22, N'#Casual', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (23, N'#Formal', N'Occasion')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (24, N'#Floral', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (25, N'#Checked', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (26, N'#Solid', N'Pattern')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (27, N'#Summer', N'Season')
GO
INSERT [dbo].[Style_Tags] ([tag_id], [tag_name], [category]) VALUES (28, N'#Winter', N'Season')
GO
SET IDENTITY_INSERT [dbo].[Style_Tags] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (1, N'admin', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'admin@crm.com', N'Admin', N'0900000001', 1, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:41:07.557' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (2, N'sale01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'sale01@crm.com', N'Sale', N'0900000002', 2, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:22:50.523' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (3, N'mkt01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mkt01@crm.com', N'Marketing', N'0900000003', 3, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, CAST(N'2026-03-28T16:22:28.910' AS DateTime))
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (4, N'cs01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'cs01@crm.com', N'CS', N'0900000004', 4, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (5, N'mng01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mng01@crm.com', N'Manager', N'0900000004', 5, N'ACTIVE', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (6, N'locked_user', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'lock@crm.com', N'User Bị Khóa', N'0900000005', 2, N'LOCKED', CAST(N'2026-03-03T19:14:42.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (7, N'change_pass', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'changepass@gmail.com', N'User Change Pass', N'0909999999', 1, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
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
