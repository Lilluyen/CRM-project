USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CRM_System')
BEGIN
    ALTER DATABASE CRM_System SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CRM_System;
END
GO

/****** Object:  Database [CRM_System]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Activities]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Campaign_Leads]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Campaign_Reports]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Campaigns]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Categories]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Category_Products]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Customer_Measurements]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Customer_Segment_Map]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Customer_Segments]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Customer_Style_Map]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Customers]    Script Date: 2/25/2026 3:19:47 PM ******/
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
	[social_link] [nvarchar](max) NULL,
	[customer_type] [varchar](20) NULL,
	[status] [nvarchar](20) NULL,
	[loyalty_tier] [nvarchar](20) NULL,
	[rfm_score] [int] NULL,
	[return_rate] [decimal](5, 2) NULL,
	[last_purchase] [datetime] NULL,
	[owner_id] [int] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Deal_Products]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Deals]    Script Date: 2/25/2026 3:19:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Deals](
	[deal_id] [int] IDENTITY(1,1) NOT NULL,
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
/****** Object:  Table [dbo].[Feedbacks]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Leads]    Script Date: 2/25/2026 3:19:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Leads](
	[lead_id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [nvarchar](100) NULL,
	[email] [varchar](100) NULL,
	[phone] [varchar](20) NULL,
	[company_name] [nvarchar](100) NULL,
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
/****** Object:  Table [dbo].[Notifications]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Products]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Service_Reports]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Style_Tags]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Tasks]    Script Date: 2/25/2026 3:19:47 PM ******/
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
/****** Object:  Table [dbo].[Tickets]    Script Date: 2/25/2026 3:19:47 PM ******/
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

/****** Object:  Table [dbo].[Users]    Script Date: 2/25/2026 3:19:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[user_id] INT IDENTITY(1,1) NOT NULL,
	[username] VARCHAR(50) NOT NULL,
	[password_hash] VARCHAR(255) NOT NULL,
	[email] VARCHAR(100) NULL,
	[full_name] NVARCHAR(100) NULL,
	[phone] VARCHAR(20) NULL,
	[role_id] INT NOT NULL,
	[status] VARCHAR(20) NULL,
	[created_at] DATETIME DEFAULT GETDATE(),
	[updated_at] DATETIME NULL,
	[last_login_at] DATETIME NULL,

PRIMARY KEY CLUSTERED ([user_id] ASC),

CONSTRAINT uq_users_username UNIQUE (username),

CONSTRAINT fk_users_role 
	FOREIGN KEY (role_id) 
	REFERENCES Roles(role_id)
);
GO
/****** Object:  Table [dbo].[Virtual_Wardrobe]    Script Date: 2/25/2026 3:19:47 PM ******/
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
SET IDENTITY_INSERT [dbo].[Customer_Measurements] ON 

INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (1, 1, CAST(162.00 AS Decimal(5, 2)), CAST(52.00 AS Decimal(5, 2)), CAST(84.00 AS Decimal(5, 2)), CAST(64.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), NULL, N'M', N'Đồng hồ cát', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (2, 2, CAST(175.00 AS Decimal(5, 2)), CAST(70.00 AS Decimal(5, 2)), CAST(95.00 AS Decimal(5, 2)), CAST(80.00 AS Decimal(5, 2)), CAST(95.00 AS Decimal(5, 2)), NULL, N'L', N'Hình chữ nhật', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (3, 4, CAST(180.00 AS Decimal(5, 2)), CAST(75.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(5, 2)), CAST(85.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(5, 2)), NULL, N'XL', N'Tam giác ngược', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (4, 7, CAST(158.00 AS Decimal(5, 2)), CAST(48.00 AS Decimal(5, 2)), CAST(80.00 AS Decimal(5, 2)), CAST(60.00 AS Decimal(5, 2)), CAST(85.00 AS Decimal(5, 2)), NULL, N'S', N'Quả lê', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (5, 10, CAST(165.00 AS Decimal(5, 2)), CAST(55.00 AS Decimal(5, 2)), CAST(88.00 AS Decimal(5, 2)), CAST(66.00 AS Decimal(5, 2)), CAST(92.00 AS Decimal(5, 2)), NULL, N'M', N'Đồng hồ cát', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (6, 12, CAST(178.00 AS Decimal(5, 2)), CAST(58.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(62.00 AS Decimal(5, 2)), CAST(94.00 AS Decimal(5, 2)), NULL, N'M', N'Thanh mảnh', CAST(N'2026-02-20T21:59:04.177' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (7, 16, NULL, NULL, NULL, NULL, NULL, NULL, N'M', N'HOURGLASS', CAST(N'2026-02-25T11:52:38.557' AS DateTime))
INSERT [dbo].[Customer_Measurements] ([measure_id], [customer_id], [height], [weight], [bust], [waist], [hips], [shoulder], [preferred_size], [body_shape], [measured_at]) VALUES (8, 19, CAST(162.00 AS Decimal(5, 2)), CAST(69.00 AS Decimal(5, 2)), CAST(60.00 AS Decimal(5, 2)), CAST(75.00 AS Decimal(5, 2)), CAST(90.00 AS Decimal(5, 2)), CAST(40.00 AS Decimal(5, 2)), N'M', N'HOURGLASS', CAST(N'2026-02-25T12:57:14.483' AS DateTime))
SET IDENTITY_INSERT [dbo].[Customer_Measurements] OFF
GO
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (1, 1)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (1, 5)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (4, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (4, 8)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (12, 4)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (12, 7)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (13, 3)
INSERT [dbo].[Customer_Style_Map] ([customer_id], [tag_id]) VALUES (13, 6)
GO
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (1, N'Nguyễn Lan Anh', N'0901234561', N'lananh@gmail.com', CAST(N'1995-05-15' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'GOLD', 545, CAST(2.50 AS Decimal(5, 2)), CAST(N'2024-05-10T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (2, N'Trần Minh Tú', N'0901234562', N'minhtu@gmail.com', CAST(N'1992-10-20' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 433, CAST(5.00 AS Decimal(5, 2)), CAST(N'2024-04-20T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (3, N'Lê Thị Hoa', N'0901234563', N'hoale@gmail.com', CAST(N'1998-02-14' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'BLACKLIST', N'BRONZE', 155, CAST(45.50 AS Decimal(5, 2)), CAST(N'2024-01-15T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (4, N'Phạm Hoàng Nam', N'0901234564', N'nampham@gmail.com', CAST(N'1990-12-01' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'GOLD', 554, CAST(0.00 AS Decimal(5, 2)), CAST(N'2024-05-18T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (5, N'Ngô Thanh Vân', N'0901234565', N'vanngo@gmail.com', CAST(N'1993-08-25' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 221, CAST(10.00 AS Decimal(5, 2)), CAST(N'2024-03-12T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (6, N'Đỗ Mạnh Hùng', N'0901234566', N'hungdo@gmail.com', CAST(N'1988-04-30' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'BRONZE', 121, CAST(15.00 AS Decimal(5, 2)), CAST(N'2023-11-20T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (7, N'Hoàng Diệp Chi', N'0901234567', N'diepchi@gmail.com', CAST(N'1997-07-07' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'GOLD', 544, CAST(1.20 AS Decimal(5, 2)), CAST(N'2024-05-15T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (8, N'Bùi Anh Tuấn', N'0901234568', N'tuanbui@gmail.com', CAST(N'1994-09-12' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 211, CAST(20.00 AS Decimal(5, 2)), CAST(N'2024-02-28T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (9, N'Vũ Phương Ly', N'0901234569', N'lyvu@gmail.com', CAST(N'2000-01-01' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'BLACKLIST', N'BRONZE', 111, CAST(60.00 AS Decimal(5, 2)), CAST(N'2024-05-01T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (10, N'Đặng Thu Thảo', N'0901234570', N'thaodang@gmail.com', CAST(N'1991-11-11' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'GOLD', 533, CAST(3.50 AS Decimal(5, 2)), CAST(N'2024-05-05T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (11, N'Trịnh Thăng Bình', N'0901234571', N'binhtrinh@gmail.com', CAST(N'1989-06-18' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 443, CAST(8.00 AS Decimal(5, 2)), CAST(N'2024-04-30T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (12, N'Mai Phương Thúy', N'0901234572', N'thuymai@gmail.com', CAST(N'1988-12-25' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'GOLD', 555, CAST(0.50 AS Decimal(5, 2)), CAST(N'2024-05-19T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (13, N'Sơn Tùng MTP', N'0901234573', N'tungmtp@gmail.com', CAST(N'1994-07-05' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 455, CAST(12.00 AS Decimal(5, 2)), CAST(N'2024-05-10T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (14, N'Hòa Minzy', N'0901234574', N'hoaminzy@gmail.com', CAST(N'1995-05-31' AS Date), N'Nữ', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'BRONZE', 311, CAST(5.00 AS Decimal(5, 2)), CAST(N'2024-04-15T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (15, N'Đen Vâu', N'0901234575', N'denvau@gmail.com', CAST(N'1989-05-13' AS Date), N'Nam', NULL, NULL, N'INDIVIDUAL', N'ACTIVE', N'SILVER', 322, CAST(2.00 AS Decimal(5, 2)), CAST(N'2024-03-20T00:00:00.000' AS DateTime), NULL, CAST(N'2026-02-20T21:58:51.823' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (16, N'Hoàng Văn Luyến', N'0956451847', N'hoangluye@gmail.com', CAST(N'2026-02-19' AS Date), N'MALE', N'', N'', N'INDIVIDUAL', N'ACTIVE', N'BRONZE', 0, CAST(0.00 AS Decimal(5, 2)), NULL, 1, CAST(N'2026-02-25T11:52:38.477' AS DateTime), NULL)
INSERT [dbo].[Customers] ([customer_id], [name], [phone], [email], [birthday], [gender], [address], [social_link], [customer_type], [status], [loyalty_tier], [rfm_score], [return_rate], [last_purchase], [owner_id], [created_at], [updated_at]) VALUES (19, N'Hoàng Văn Long', N'0956451848', N'hoangluyeert@gmail.com', CAST(N'2026-02-19' AS Date), N'MALE', N'grdgrd', N'grdgr', N'INDIVIDUAL', N'ACTIVE', N'BRONZE', 0, CAST(0.00 AS Decimal(5, 2)), NULL, 1, CAST(N'2026-02-25T12:57:14.250' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Customers] OFF
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
SET IDENTITY_INSERT [dbo].[Style_Tags] OFF
GO

SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users]
([user_id],[username],[password_hash],[email],[full_name],[phone],[role_id],[status],[created_at])
VALUES
(1,'admin','$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG','admin@crm.com','Admin','0900000001',1,'ACTIVE',GETDATE()),

(2,'sale01','$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG','sale01@crm.com','Sale','0900000002',2,'ACTIVE',GETDATE()),

(3,'mkt01','$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG','mkt01@crm.com','Marketing','0900000003',3,'ACTIVE',GETDATE()),

(4,'cs01','$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG','cs01@crm.com','CS','0900000004',4,'ACTIVE',GETDATE()),

(5,'manager01','$2a$12$K.ltnAFcUTkz1VKT8C2Hk.yPfm/jPx2PTcRWmN6G/GeIq4bMd5wPG','manager@crm.com','Manager','0900000005',5,'ACTIVE',GETDATE());

SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Customer__B43B145F1294BDA2]    Script Date: 2/25/2026 3:19:47 PM ******/
ALTER TABLE [dbo].[Customers] ADD UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_customer_phone]    Script Date: 2/25/2026 3:19:47 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [UQ_customer_phone] UNIQUE NONCLUSTERED 
(
	[phone] ASC
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
ALTER TABLE [dbo].[Virtual_Wardrobe]  WITH CHECK ADD  CONSTRAINT [fk_wardrobe_cust] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Virtual_Wardrobe] CHECK CONSTRAINT [fk_wardrobe_cust]
GO
USE [master]
GO
ALTER DATABASE [CRM_System] SET  READ_WRITE 
GO

