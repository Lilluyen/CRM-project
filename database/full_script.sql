﻿USE [master]
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CRM_System')
BEGIN
    ALTER DATABASE CRM_System SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CRM_System;
END
GO
/****** Object:  Database [CRM_System]    Script Date: 3/2/2026 2:28:51 PM ******/
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
/****** Object:  UserDefinedTableType [dbo].[IntList]    Script Date: 3/2/2026 2:28:52 PM ******/
CREATE TYPE [dbo].[IntList] AS TABLE(
	[value] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StringList]    Script Date: 3/2/2026 2:28:52 PM ******/
CREATE TYPE [dbo].[StringList] AS TABLE(
	[value] [nvarchar](100) NULL
)
GO
/****** Object:  Table [dbo].[Activities]    Script Date: 3/2/2026 2:28:52 PM ******/
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
PRIMARY KEY CLUSTERED 
(
	[activity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Campaign_Leads]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Campaign_Reports]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Campaigns]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Categories]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Category_Products]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Customer_Measurements]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Measurements](
	[measure_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[height] [decimal](5, 2) NULL,
	[weight] [decimal](5, 2) NULL,
	[bust] [decimal](5, 2) NULL,
	[waist] [decimal](5, 2) NULL,
	[hips] [decimal](5, 2) NULL,
	[shoulder] [decimal](5, 2) NULL,
	[preferred_size] [nvarchar](10) NULL,
	[body_shape] [nvarchar](50) NULL,
	[measured_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[measure_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Segment_Map]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Segment_Map](
	[customer_id] [int] NOT NULL,
	[segment_id] [int] NOT NULL,
	[assigned_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC,
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Segments]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_Segments](
	[segment_id] [int] IDENTITY(1,1) NOT NULL,
	[segment_name] [nvarchar](50) NULL,
	[criteria_logic] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[segment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_Style_Map]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[CustomerOTP]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Customers]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[phone] [varchar](20) NOT NULL,
	[email] [varchar](100) NULL,
	[birthday] [date] NULL,
	[gender] [nvarchar](10) NOT NULL,
	[address] [nvarchar](255) NULL,
	[source] [nvarchar](50) NULL,
	[status] [nvarchar](20) NULL,
	[loyalty_tier] [nvarchar](20) NULL,
	[rfm_score] [int] NULL,
	[return_rate] [decimal](5, 2) NULL,
	[last_purchase] [datetime] NULL,
	[owner_id] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[interest] [nvarchar](255) NULL,
 CONSTRAINT [PK__Customer__CD65CB852677CF47] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Deal_Products]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Deals]    Script Date: 3/2/2026 2:28:52 PM ******/
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
 CONSTRAINT [PK__Deals__C012A76CEBB1369C] PRIMARY KEY CLUSTERED 
(
	[deal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Feedbacks]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Leads]    Script Date: 3/2/2026 2:28:52 PM ******/
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
PRIMARY KEY CLUSTERED 
(
	[lead_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[notification_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[title] [nvarchar](100) NULL,
	[content] [nvarchar](max) NULL,
	[type] [varchar](20) NULL,
	[is_read] [bit] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[notification_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Service_Reports]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Style_Tags]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Tasks]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tasks](
	[task_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[description] [nvarchar](max) NULL,
	[related_type] [varchar](50) NULL,
	[related_id] [int] NULL,
	[assigned_to] [int] NULL,
	[priority] [varchar](20) NULL,
	[status] [varchar](20) NULL,
	[due_date] [date] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[task_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tickets]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[UserOTP]    Script Date: 3/2/2026 2:28:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserOTP](
	[user_id] [int] NOT NULL,
	[otp_hash] [nvarchar](255) NOT NULL,
	[otp_expired_at] [datetime2](7) NOT NULL,
	[failed_attempt] [int] NULL,
	[send_count] [int] NULL,
	[last_send] [datetime2](7) NULL,
	[created_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 3/2/2026 2:28:52 PM ******/
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
/****** Object:  Table [dbo].[Virtual_Wardrobe]    Script Date: 3/2/2026 2:28:52 PM ******/
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
SET IDENTITY_INSERT [dbo].[Campaigns] ON 

INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (1, N'Facebook Lead Gen Q1', N'Chạy quảng cáo thu lead cho sản phẩm CRM', CAST(5000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-03-31' AS Date), N'Facebook', N'Running', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (2, N'Google Search Ads - Cloud', N'Quảng cáo từ khóa dịch vụ Cloud Migration', CAST(7000.00 AS Decimal(15, 2)), CAST(N'2026-02-01' AS Date), CAST(N'2026-04-30' AS Date), N'Google', N'Running', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (3, N'Email Marketing Automation', N'Gửi email nurturing khách hàng tiềm năng', CAST(2000.00 AS Decimal(15, 2)), CAST(N'2026-01-15' AS Date), CAST(N'2026-02-28' AS Date), N'Email', N'Completed', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (4, N'Business Seminar 2026', N'Tổ chức hội thảo chuyển đổi số cho doanh nghiệp', CAST(12000.00 AS Decimal(15, 2)), CAST(N'2026-03-10' AS Date), CAST(N'2026-03-10' AS Date), N'Event', N'Planned', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (5, N'LinkedIn B2B Outreach', N'Chiến dịch tiếp cận khách hàng doanh nghiệp', CAST(3500.00 AS Decimal(15, 2)), CAST(N'2026-02-10' AS Date), CAST(N'2026-05-10' AS Date), N'LinkedIn', N'Running', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (6, N'SEO Branding Campaign', N'Tăng nhận diện thương hiệu qua SEO', CAST(4000.00 AS Decimal(15, 2)), CAST(N'2025-11-01' AS Date), CAST(N'2026-02-01' AS Date), N'SEO', N'Completed', 2, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (7, N'Referral Partner Program', N'Khuyến khích đối tác giới thiệu khách hàng', CAST(3000.00 AS Decimal(15, 2)), CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), N'Referral', N'Running', 5, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (8, N'Product Launch Ads', N'Quảng bá ra mắt hệ thống CRM phiên bản mới', CAST(9000.00 AS Decimal(15, 2)), CAST(N'2026-03-01' AS Date), CAST(N'2026-04-15' AS Date), N'Facebook', N'Running', 3, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (9, N'Retargeting Campaign', N'Retarget khách hàng đã truy cập website', CAST(2500.00 AS Decimal(15, 2)), CAST(N'2026-02-20' AS Date), CAST(N'2026-03-30' AS Date), N'Google Display', N'Running', 4, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
INSERT [dbo].[Campaigns] ([campaign_id], [name], [description], [budget], [start_date], [end_date], [channel], [status], [created_by], [created_at], [updated_at]) VALUES (10, N'Year End Promotion 2025', N'Chiến dịch ưu đãi cuối năm', CAST(6000.00 AS Decimal(15, 2)), CAST(N'2025-10-01' AS Date), CAST(N'2025-12-31' AS Date), N'Multi-channel', N'Completed', 1, CAST(N'2026-03-02T13:17:33.460' AS DateTime), CAST(N'2026-03-02T13:17:33.460' AS DateTime))
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
GO
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (1, N'Nguyễn Văn An', N'0909000001', N'an.nguyen@crm.vn', CAST(N'1990-05-12' AS Date), N'Nam', N'Hà Nội', N'Facebook', N'Active', N'GOLD', 0, CAST(0.65 AS Decimal(5, 2)), CAST(N'2026-02-20T13:30:57.477' AS DateTime), 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'CRM, Automation')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (2, N'Trần Thị Bình', N'0909000002', N'binh.tran@crm.vn', CAST(N'1992-08-21' AS Date), N'Nữ', N'Hồ Chí Minh', N'Website', N'Active', N'PLATINUM', 0, CAST(0.72 AS Decimal(5, 2)), CAST(N'2026-02-25T13:30:57.477' AS DateTime), 3, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Marketing')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (3, N'Lê Hoàng Nam', N'0909000003', N'nam.le@crm.vn', CAST(N'1988-02-03' AS Date), N'Nam', N'Đà Nẵng', N'Referral', N'Active', N'GOLD', 0, CAST(0.55 AS Decimal(5, 2)), CAST(N'2026-02-10T13:30:57.477' AS DateTime), 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Cloud')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (4, N'Phạm Gia Huy', N'0909000004', N'huy.pham@crm.vn', CAST(N'1995-11-10' AS Date), N'Nam', N'Hà Nội', N'Google', N'New', N'SILVER', 0, CAST(0.20 AS Decimal(5, 2)), NULL, 4, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Website')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (5, N'Đỗ Minh Quân', N'0909000005', N'quan.do@crm.vn', CAST(N'1987-07-07' AS Date), N'Nam', N'Hải Phòng', N'Facebook', N'Active', N'GOLD', 111, CAST(0.60 AS Decimal(5, 2)), CAST(N'2026-02-15T13:30:57.477' AS DateTime), 5, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Data')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (6, N'Võ Thu Trang', N'0909000006', N'trang.vo@crm.vn', CAST(N'1993-09-19' AS Date), N'Nữ', N'Hồ Chí Minh', N'LinkedIn', N'Active', N'PLATINUM', 111, CAST(0.75 AS Decimal(5, 2)), CAST(N'2026-02-27T13:30:57.477' AS DateTime), 3, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'AI')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (7, N'Nguyễn Tuấn Kiệt', N'0909000007', N'kiet.nguyen@crm.vn', CAST(N'1991-12-01' AS Date), N'Nam', N'Cần Thơ', N'Event', N'Active', N'GOLD', 111, CAST(0.58 AS Decimal(5, 2)), CAST(N'2026-02-18T13:30:57.477' AS DateTime), 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'ERP')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (8, N'Bùi Thành Đạt', N'0909000008', N'dat.bui@crm.vn', CAST(N'1996-04-14' AS Date), N'Nam', N'Hà Nội', N'Website', N'Churned', N'SILVER', 111, CAST(0.10 AS Decimal(5, 2)), CAST(N'2025-09-02T13:30:57.477' AS DateTime), 4, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'SEO')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (9, N'Hoàng Lan Chi', N'0909000009', N'chi.hoang@crm.vn', CAST(N'1994-06-22' AS Date), N'Nữ', N'Đà Nẵng', N'Referral', N'Active', N'GOLD', 222, CAST(0.52 AS Decimal(5, 2)), CAST(N'2026-02-12T13:30:57.477' AS DateTime), 5, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'HRM')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (10, N'Phạm Đức Long', N'0909000010', N'long.pham@crm.vn', CAST(N'1989-03-30' AS Date), N'Nam', N'HCM', N'Facebook', N'Active', N'GOLD', 222, CAST(0.66 AS Decimal(5, 2)), CAST(N'2026-02-21T13:30:57.477' AS DateTime), 3, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Mobile App')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (11, N'Nguyễn Hải Yến', N'0909000011', N'yen.nguyen@crm.vn', CAST(N'1997-01-05' AS Date), N'Nữ', N'Hà Nội', N'Google', N'New', N'SILVER', 222, CAST(0.18 AS Decimal(5, 2)), NULL, 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Chatbot')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (12, N'Trần Quốc Bảo', N'0909000012', N'bao.tran@crm.vn', CAST(N'1985-10-11' AS Date), N'Nam', N'Bình Dương', N'LinkedIn', N'Active', N'PLATINUM', 333, CAST(0.70 AS Decimal(5, 2)), CAST(N'2026-02-24T13:30:57.477' AS DateTime), 1, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Cybersecurity')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (13, N'Lê Thị Hoa', N'0909000013', N'hoa.le@crm.vn', CAST(N'1993-02-17' AS Date), N'Nữ', N'Huế', N'Referral', N'Active', N'GOLD', 333, CAST(0.50 AS Decimal(5, 2)), CAST(N'2026-02-08T13:30:57.477' AS DateTime), 4, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Hosting')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (14, N'Võ Minh Tâm', N'0909000014', N'tam.vo@crm.vn', CAST(N'1990-08-09' AS Date), N'Nam', N'Hà Nội', N'Event', N'Active', N'GOLD', 333, CAST(0.59 AS Decimal(5, 2)), CAST(N'2026-02-19T13:30:57.477' AS DateTime), 3, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'BI')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (15, N'Đặng Quang Vinh', N'0909000015', N'vinh.dang@crm.vn', CAST(N'1988-12-25' AS Date), N'Nam', N'HCM', N'Website', N'Active', N'GOLD', 444, CAST(0.63 AS Decimal(5, 2)), CAST(N'2026-02-23T13:30:57.477' AS DateTime), 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Infrastructure')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (16, N'Phan Thu Hà', N'0909000016', N'ha.phan@crm.vn', CAST(N'1996-03-03' AS Date), N'Nữ', N'Hà Nội', N'Facebook', N'New', N'SILVER', 444, CAST(0.22 AS Decimal(5, 2)), NULL, 5, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'CRM')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (17, N'Nguyễn Đức Mạnh', N'0909000017', N'manh.nguyen@crm.vn', CAST(N'1992-07-28' AS Date), N'Nam', N'Hải Dương', N'Google', N'Active', N'GOLD', 444, CAST(0.48 AS Decimal(5, 2)), CAST(N'2026-02-05T13:30:57.477' AS DateTime), 1, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Digital Transformation')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (18, N'Trịnh Bảo Châu', N'0909000018', N'chau.trinh@crm.vn', CAST(N'1995-09-09' AS Date), N'Nữ', N'HCM', N'Website', N'Churned', N'SILVER', 555, CAST(0.12 AS Decimal(5, 2)), CAST(N'2025-10-02T13:30:57.477' AS DateTime), 4, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Landing Page')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (19, N'Lê Anh Tuấn', N'0909000019', N'tuan.le@crm.vn', CAST(N'1987-05-15' AS Date), N'Nam', N'Quảng Ninh', N'Referral', N'Active', N'GOLD', 555, CAST(0.67 AS Decimal(5, 2)), CAST(N'2026-02-26T13:30:57.477' AS DateTime), 3, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'Testing')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (20, N'Phạm Ngọc Mai', N'0909000020', N'mai.pham@crm.vn', CAST(N'1998-11-02' AS Date), N'Nữ', N'Hà Nội', N'Facebook', N'Active', N'PLATINUM', 555, CAST(0.74 AS Decimal(5, 2)), CAST(N'2026-02-28T13:30:57.477' AS DateTime), 2, CAST(N'2026-03-02T13:30:57.477' AS DateTime), CAST(N'2026-03-02T13:30:57.477' AS DateTime), N'E-commerce')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (21, N'Nguyễn Hải Yến', N'0909001021', N'yen.nguyen21@gmail.com', CAST(N'1995-03-12' AS Date), N'Female', N'Hà Nội', N'Facebook', N'Active', N'GOLD', 555, CAST(0.82 AS Decimal(5, 2)), CAST(N'2026-02-25T14:19:04.910' AS DateTime), 2, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Váy dạ hội')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (22, N'Trần Minh Thu', N'0909001022', N'thu.tran22@gmail.com', CAST(N'1992-07-21' AS Date), N'Female', N'Hải Phòng', N'Website', N'Active', N'SILVER', 534, CAST(0.65 AS Decimal(5, 2)), CAST(N'2026-02-18T14:19:04.910' AS DateTime), 3, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Đầm công sở')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (23, N'Lê Hoàng Anh', N'0909001023', N'anh.le23@gmail.com', CAST(N'1990-11-05' AS Date), N'Female', N'Quảng Ninh', N'TikTok', N'Active', N'GOLD', 455, CAST(0.70 AS Decimal(5, 2)), CAST(N'2026-02-12T14:19:04.910' AS DateTime), 2, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Đầm thiết kế')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (24, N'Phạm Ngọc Mai', N'0909001024', N'mai.pham24@gmail.com', CAST(N'1996-09-18' AS Date), N'Female', N'Hà Nội', N'Instagram', N'Active', N'PLATINUM', 545, CAST(0.88 AS Decimal(5, 2)), CAST(N'2026-02-27T14:19:04.910' AS DateTime), 1, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Váy cưới')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (25, N'Đỗ Thanh Huyền', N'0909001025', N'huyen.do25@gmail.com', CAST(N'1993-01-30' AS Date), N'Female', N'Bắc Ninh', N'Referral', N'Active', N'GOLD', 444, CAST(0.60 AS Decimal(5, 2)), CAST(N'2026-02-05T14:19:04.910' AS DateTime), 3, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Đầm dự tiệc')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (26, N'Vũ Khánh Linh', N'0909001026', N'linh.vu26@gmail.com', CAST(N'1998-06-14' AS Date), N'Female', N'Hà Nội', N'Facebook', N'Active', N'SILVER', 355, CAST(0.55 AS Decimal(5, 2)), CAST(N'2026-01-21T14:19:04.910' AS DateTime), 2, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Váy trẻ trung')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (27, N'Bùi Thu Trang', N'0909001027', N'trang.bui27@gmail.com', CAST(N'1994-04-09' AS Date), N'Female', N'Hải Dương', N'Website', N'Active', N'GOLD', 454, CAST(0.73 AS Decimal(5, 2)), CAST(N'2026-02-14T14:19:04.910' AS DateTime), 1, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Đầm công sở')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (28, N'Ngô Diễm Quỳnh', N'0909001028', N'quynh.ngo28@gmail.com', CAST(N'1997-12-02' AS Date), N'Female', N'Hà Nội', N'TikTok', N'Active', N'PLATINUM', 544, CAST(0.90 AS Decimal(5, 2)), CAST(N'2026-02-28T14:19:04.910' AS DateTime), 2, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Váy cao cấp')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (29, N'Hoàng Mỹ Dung', N'0909001029', N'dung.hoang29@gmail.com', CAST(N'1991-08-27' AS Date), N'Female', N'Quảng Ninh', N'Referral', N'Active', N'BLACKLIST', 435, CAST(0.67 AS Decimal(5, 2)), CAST(N'2026-02-08T14:19:04.910' AS DateTime), 3, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Đầm dạ hội')
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [source], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at], [interest]) VALUES (30, N'Đặng Phương Thảo', N'0909001030', N'thao.dang30@gmail.com', CAST(N'1995-05-11' AS Date), N'Female', N'Hà Nội', N'Instagram', N'Active', N'BRONZE', 344, CAST(0.52 AS Decimal(5, 2)), CAST(N'2026-01-26T14:19:04.910' AS DateTime), 1, CAST(N'2026-03-02T14:19:04.910' AS DateTime), CAST(N'2026-03-02T14:19:04.910' AS DateTime), N'Váy đi chơi')
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

INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (2, N'Nguyen Van An', N'an.nguyen@gmail.com', N'0901000001', N'CRM Solution', N'Website', N'New', 1, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 45)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (3, N'Tran Thi Binh', N'binh.tran@gmail.com', N'0901000002', N'Email Marketing', N'Facebook', N'Contacted', 1, 3, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 55)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (4, N'Le Hoang Nam', N'nam.le@gmail.com', N'0901000003', N'Cloud Migration', N'Referral', N'Qualified', 2, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 72)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (5, N'Pham Gia Huy', N'huy.pham@gmail.com', N'0901000004', N'Website Development', N'Website', N'Converted', 2, 4, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 80)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (6, N'Do Minh Quan', N'quan.do@gmail.com', N'0901000005', N'Data Analytics', N'LinkedIn', N'New', 3, 5, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 50)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (7, N'Vo Thu Trang', N'trang.vo@gmail.com', N'0901000006', N'Marketing Automation', N'Facebook', N'Contacted', 1, 3, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 60)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (8, N'Nguyen Tuan Kiet', N'kiet.nguyen@gmail.com', N'0901000007', N'ERP System', N'Seminar', N'Qualified', 4, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 75)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (9, N'Bui Thanh Dat', N'dat.bui@gmail.com', N'0901000008', N'SEO Services', N'Website', N'Lost', 3, 4, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 30)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (10, N'Hoang Lan Chi', N'chi.hoang@gmail.com', N'0901000009', N'HR Management Software', N'Referral', N'Qualified', 4, 5, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 68)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (11, N'Pham Duc Long', N'long.pham@gmail.com', N'0901000010', N'Mobile App Development', N'Facebook', N'Contacted', 2, 3, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 58)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (12, N'Nguyen Hai Yen', N'yen.nguyen@gmail.com', N'0901000011', N'AI Chatbot', N'Website', N'New', 5, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 47)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (13, N'Tran Quoc Bao', N'bao.tran@gmail.com', N'0901000012', N'Cybersecurity', N'LinkedIn', N'Qualified', 5, 1, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 82)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (14, N'Le Thi Hoa', N'hoa.le@gmail.com', N'0901000013', N'Cloud Hosting', N'Referral', N'Converted', 3, 4, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 77)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (15, N'Vo Minh Tam', N'tam.vo@gmail.com', N'0901000014', N'Business Intelligence', N'Seminar', N'Contacted', 4, 3, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 63)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (16, N'Dang Quang Vinh', N'vinh.dang@gmail.com', N'0901000015', N'Infrastructure Upgrade', N'Website', N'New', 2, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 52)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (17, N'Phan Thu Ha', N'ha.phan@gmail.com', N'0901000016', N'CRM Customization', N'Facebook', N'Qualified', 1, 5, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 70)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (18, N'Nguyen Duc Manh', N'manh.nguyen@gmail.com', N'0901000017', N'Digital Transformation', N'LinkedIn', N'Contacted', 5, 1, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 66)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (19, N'Trinh Bao Chau', N'chau.trinh@gmail.com', N'0901000018', N'Landing Page Optimization', N'Website', N'Lost', 2, 4, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 35)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (20, N'Le Anh Tuan', N'tuan.le@gmail.com', N'0901000019', N'Automation Testing', N'Referral', N'Qualified', 3, 2, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 74)
INSERT [dbo].[Leads] ([lead_id], [full_name], [email], [phone], [interest], [source], [status], [campaign_id], [assigned_to], [created_at], [updated_at], [score]) VALUES (21, N'Pham Ngoc Mai', N'mai.pham@gmail.com', N'0901000020', N'E-commerce Platform', N'Facebook', N'Converted', 4, 3, CAST(N'2026-03-02T13:17:37.557' AS DateTime), CAST(N'2026-03-02T13:17:37.557' AS DateTime), 85)
SET IDENTITY_INSERT [dbo].[Leads] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (1, N'ADMIN', N'Quản trị hệ thống', CAST(N'2026-02-25T10:48:57.280' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (2, N'SALE', N'Nhân viên kinh doanh', CAST(N'2026-02-25T10:48:57.280' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (3, N'MARKETING', N'Nhân viên marketing', CAST(N'2026-02-25T10:48:57.280' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (4, N'CS', N'Customer Support', CAST(N'2026-02-25T10:48:57.280' AS DateTime))
INSERT [dbo].[Roles] ([role_id], [role_name], [description], [created_at]) VALUES (5, N'MANAGER', N'Quản lý', CAST(N'2026-02-25T10:48:57.280' AS DateTime))
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

INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (1, N'admin', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'admin@crm.com', N'Admin', N'0900000001', 1, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, CAST(N'2026-03-02T14:06:58.203' AS DateTime))
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (2, N'sale01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'sale01@crm.com', N'Sale', N'0900000002', 2, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (3, N'mkt01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'mkt01@crm.com', N'Marketing', N'0900000003', 3, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (4, N'cs01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'cs01@crm.com', N'CS', N'0900000004', 4, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (5, N'manager01', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'manager@crm.com', N'Manager', N'0900000005', 5, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (6, N'blocked_user', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'blockeduser@gmail.com', N'Blocked Staff', N'0909999999', 3, N'LOCKED', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
INSERT [dbo].[Users] ([user_id], [username], [password_hash], [email], [full_name], [phone], [role_id], [status], [created_at], [updated_at], [last_login_at]) VALUES (7, N'change_pass', N'$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG', N'changepass@gmail.com', N'User Change Pass', N'0909999999', 1, N'ACTIVE', CAST(N'2026-02-28T16:51:03.757' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
/****** Object:  Index [IX_Customer_Measurements_customer_measured]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_Measurements_customer_measured] ON [dbo].[Customer_Measurements]
(
	[customer_id] ASC,
	[measured_at] DESC
)
INCLUDE([preferred_size],[height],[weight],[body_shape]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Measurements_Latest]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Measurements_Latest] ON [dbo].[Customer_Measurements]
(
	[customer_id] ASC,
	[measured_at] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_Style_Map_customer]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_Style_Map_customer] ON [dbo].[Customer_Style_Map]
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_StyleMap]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_StyleMap] ON [dbo].[Customer_Style_Map]
(
	[customer_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Customer__B43B145F86D346E3]    Script Date: 3/2/2026 2:28:53 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [UQ__Customer__B43B145F86D346E3] UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Customer__B43B145FB1339CC5]    Script Date: 3/2/2026 2:28:53 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [UQ__Customer__B43B145FB1339CC5] UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_customer_phone]    Script Date: 3/2/2026 2:28:53 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [UQ_customer_phone] UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customers_Filter]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_Filter] ON [dbo].[Customers]
(
	[loyalty_tier] ASC,
	[status] ASC,
	[return_rate] ASC
)
INCLUDE([name],[phone],[rfm_score],[last_purchase]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customers_rfm_customer]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_rfm_customer] ON [dbo].[Customers]
(
	[rfm_score] DESC,
	[customer_id] DESC
)
INCLUDE([name],[phone],[email],[gender],[loyalty_tier],[return_rate],[last_purchase],[status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Deals_customer_id]    Script Date: 3/2/2026 2:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_Deals_customer_id] ON [dbo].[Deals]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uq_users_username]    Script Date: 3/2/2026 2:28:53 PM ******/
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
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF__Customers__statu__7C4F7684]  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF__Customers__loyal__7D439ABD]  DEFAULT ('BRONZE') FOR [loyalty_tier]
GO
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF__Customers__rfm_s__7E37BEF6]  DEFAULT ((0)) FOR [rfm_score]
GO
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF__Customers__retur__7F2BE32F]  DEFAULT ((0)) FOR [return_rate]
GO
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF__Customers__creat__00200768]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Deals] ADD  CONSTRAINT [DF__Deals__created_a__01142BA1]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Feedbacks] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Leads] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Service_Reports] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Tasks] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Tickets] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[UserOTP] ADD  DEFAULT ((0)) FOR [failed_attempt]
GO
ALTER TABLE [dbo].[UserOTP] ADD  DEFAULT ((0)) FOR [send_count]
GO
ALTER TABLE [dbo].[UserOTP] ADD  DEFAULT (sysdatetime()) FOR [last_send]
GO
ALTER TABLE [dbo].[UserOTP] ADD  DEFAULT (sysdatetime()) FOR [created_at]
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
ALTER TABLE [dbo].[Deals]  WITH CHECK ADD  CONSTRAINT [FK_Deals_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Deals] CHECK CONSTRAINT [FK_Deals_Customers]
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
ALTER TABLE [dbo].[Leads]  WITH CHECK ADD  CONSTRAINT [fk_leads_user] FOREIGN KEY([assigned_to])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Leads] CHECK CONSTRAINT [fk_leads_user]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [fk_notifications_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [fk_notifications_user]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [fk_tasks_user] FOREIGN KEY([assigned_to])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [fk_tasks_user]
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
ALTER TABLE [dbo].[UserOTP]  WITH CHECK ADD  CONSTRAINT [fk_userotp_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserOTP] CHECK CONSTRAINT [fk_userotp_user]
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
/****** Object:  StoredProcedure [dbo].[sp_Calculate_RFM]    Script Date: 3/2/2026 2:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_Calculate_RFM]

AS
BEGIN
    SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
    ;WITH RFM_BASE AS (
    SELECT 
        c.customer_id,

        -- Recency
        ISNULL(
            DATEDIFF(DAY, MAX(d.updated_at), GETDATE()),
            9999   -- nếu chưa mua bao giờ → rất lâu
        ) AS recency_days,

        -- Frequency
        COUNT(d.deal_id) AS frequency,

        -- Monetary
        ISNULL(SUM(d.actual_value), 0) AS monetary

    FROM Customers c
    LEFT JOIN Deals d 
        ON c.customer_id = d.customer_id
        AND d.stage = 'Won'

    GROUP BY c.customer_id
),

    RFM_SCORE AS (
        SELECT *,
            -- R: mua càng gần đây → điểm càng cao
            NTILE(6) OVER (ORDER BY recency_days DESC) - 1 AS R_score,

            -- F: mua càng nhiều → điểm càng cao
            NTILE(6) OVER (ORDER BY frequency ASC) - 1 AS F_score,

            -- M: chi càng nhiều → điểm càng cao
            NTILE(6) OVER (ORDER BY monetary ASC) - 1 AS M_score
        FROM RFM_BASE
    )

    UPDATE c
    SET c.rfm_score = (s.R_score*100 + s.F_score*10 + s.M_score)
    FROM Customers c
    JOIN RFM_SCORE s 
        ON c.customer_id = s.customer_id;

END;
GO
/****** Object:  StoredProcedure [dbo].[sp_FilterCustomersAdvanced]    Script Date: 3/2/2026 2:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FilterCustomersAdvanced]
(
    @PageNumber INT,
    @PageSize   INT,

    @Keyword NVARCHAR(100) = NULL,

    @LoyaltyTiers dbo.StringList READONLY,
    @BodyShapes   dbo.StringList READONLY,
    @Sizes        dbo.StringList READONLY,
    @TagIds       dbo.IntList    READONLY,

    @ReturnRateMode NVARCHAR(10) = NULL
)
AS
BEGIN
SET NOCOUNT ON;

-- =====================================================
-- 1. LỌC CUSTOMER TRƯỚC → ĐƯA VÀO TEMP TABLE
-- =====================================================
CREATE TABLE #FilteredCustomers (
    customer_id INT PRIMARY KEY
);

INSERT INTO #FilteredCustomers(customer_id)
SELECT c.customer_id
FROM Customers c
WHERE 1=1

AND (
    @Keyword IS NULL
    OR c.name LIKE '%' + @Keyword + '%'
    OR c.phone LIKE '%' + @Keyword + '%'
)

AND (
    NOT EXISTS (SELECT 1 FROM @LoyaltyTiers)
    OR c.loyalty_tier IN (SELECT value FROM @LoyaltyTiers)
)

AND (
    @ReturnRateMode IS NULL
    OR (@ReturnRateMode = 'HIGH'   AND c.return_rate > 40.0)
    OR (@ReturnRateMode = 'NORMAL' AND c.return_rate <= 40.0)
)

AND (
    NOT EXISTS (SELECT 1 FROM @TagIds)
    OR EXISTS (
        SELECT 1
        FROM Customer_Style_Map sm
        WHERE sm.customer_id = c.customer_id
        AND sm.tag_id IN (SELECT value FROM @TagIds)
    )
);

-- =====================================================
-- 2. COUNT TOTAL → dùng cho pagination
-- =====================================================
SELECT COUNT(*) AS TotalRecords FROM #FilteredCustomers;

-- =====================================================
-- 3. JOIN dữ liệu để render UI
-- =====================================================
WITH LatestMeasurement AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY measured_at DESC) AS rn
    FROM Customer_Measurements
),
TagAgg AS (
    SELECT
        csm.customer_id,
        STRING_AGG(t.tag_name, ', ') AS style_tags
    FROM Customer_Style_Map csm
    JOIN Style_Tags t ON csm.tag_id = t.tag_id
    GROUP BY csm.customer_id
)

SELECT
    c.customer_id,
    c.name,
    c.phone,
    c.email,
    c.gender,
    c.loyalty_tier,
    c.rfm_score,

    CASE
        WHEN m.preferred_size IS NULL THEN NULL
        ELSE CONCAT(
            m.preferred_size,
            ' (',
            CAST(m.height AS INT),
            'cm - ',
            CAST(m.weight AS INT),
            'kg)'
        )
    END AS fit_profile,

    m.body_shape,
    m.height,
    m.weight,

    ta.style_tags,

    c.return_rate,
    c.last_purchase AS last_purchase_date,
    c.status

FROM #FilteredCustomers fc
JOIN Customers c ON c.customer_id = fc.customer_id

LEFT JOIN LatestMeasurement m
       ON m.customer_id = c.customer_id AND m.rn = 1

LEFT JOIN TagAgg ta
       ON ta.customer_id = c.customer_id

WHERE 1=1

AND (
    NOT EXISTS (SELECT 1 FROM @BodyShapes)
    OR m.body_shape IN (SELECT value FROM @BodyShapes)
)

AND (
    NOT EXISTS (SELECT 1 FROM @Sizes)
    OR m.preferred_size IN (SELECT value FROM @Sizes)
)

ORDER BY c.rfm_score DESC, c.customer_id DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCustomersPaged]    Script Date: 3/2/2026 2:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_GetCustomersPaged]
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tổng record (để tính total page)
    SELECT COUNT(*) AS TotalRecords
    FROM Customers;

    WITH TagAgg AS (
        SELECT
            csm.customer_id,
            STRING_AGG(t.tag_name, ', ') AS style_tags
        FROM Customer_Style_Map csm
        JOIN Style_Tags t ON csm.tag_id = t.tag_id
        GROUP BY csm.customer_id
    ),
    LatestMeasurement AS (
        SELECT *
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY customer_id
                       ORDER BY measured_at DESC
                   ) rn
            FROM Customer_Measurements
        ) x
        WHERE rn = 1
    )

    SELECT
        c.customer_id,
        c.name,
        c.phone,
        c.email,
        c.gender,
        c.loyalty_tier,
        c.rfm_score,

        CASE
            WHEN m.preferred_size IS NULL THEN NULL
            ELSE CONCAT(
                m.preferred_size,
                ' (',
                CAST(m.height AS INT),
                'cm - ',
                CAST(m.weight AS INT),
                'kg)'
            )
        END AS fit_profile,

        m.body_shape,
        m.height,
        m.weight,

        ta.style_tags,

        c.return_rate,
        c.last_purchase AS last_purchase_date,
        c.status

    FROM Customers c
    LEFT JOIN LatestMeasurement m ON m.customer_id = c.customer_id
    LEFT JOIN TagAgg ta ON ta.customer_id = c.customer_id

    ORDER BY c.rfm_score DESC, c.customer_id DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
USE [master]
GO
ALTER DATABASE [CRM_System] SET  READ_WRITE 
GO
