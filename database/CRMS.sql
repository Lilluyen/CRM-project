/* ==================================================
CRM SYSTEM – FULL DATABASE SCRIPT
SQL SERVER – UNICODE / VIETNAMESE SAFE
================================================== */

/* ================================
DATABASE
================================ */
CREATE DATABASE CRM_System;
GO
USE CRM_System;
GO

/* ================================
USERS & ROLES
================================ */
CREATE TABLE Users (
user_id        INT IDENTITY PRIMARY KEY,
username       VARCHAR(50)  NOT NULL,
password_hash  VARCHAR(255) NOT NULL,
email          VARCHAR(100),
full_name      NVARCHAR(100),
phone          VARCHAR(20),
status         VARCHAR(20),
created_at     DATETIME DEFAULT GETDATE(),
updated_at     DATETIME,
last_login_at  DATETIME
);

CREATE TABLE Roles (
role_id     INT IDENTITY PRIMARY KEY,
role_name   VARCHAR(50) NOT NULL,
description NVARCHAR(255),
created_at  DATETIME DEFAULT GETDATE()
);

CREATE TABLE User_Roles (
user_id     INT NOT NULL,
role_id     INT NOT NULL,
assigned_at DATETIME DEFAULT GETDATE(),
CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES Users(user_id),
CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

/* ================================
CUSTOMERS & CONTACTS
================================ */
CREATE TABLE Customers (
customer_id   INT IDENTITY PRIMARY KEY,
name          NVARCHAR(100),
address       NVARCHAR(255),
industry      NVARCHAR(100),
company_size  NVARCHAR(50),
phone         VARCHAR(20),
email         VARCHAR(100),
status        NVARCHAR(20),
customer_type VARCHAR(20) NOT NULL,
owner_id      INT,
created_at    DATETIME DEFAULT GETDATE(),
updated_at    DATETIME,
CONSTRAINT fk_customers_owner FOREIGN KEY (owner_id) REFERENCES Users(user_id),
CONSTRAINT chk_customer_type CHECK (customer_type IN ('INDIVIDUAL', 'COMPANY')),
CONSTRAINT chk_industry_by_type CHECK (
(customer_type = 'INDIVIDUAL' AND industry IS NULL)
OR
(customer_type = 'COMPANY' AND industry IS NOT NULL)
)
);

CREATE TABLE Contacts (
contact_id  INT IDENTITY PRIMARY KEY,
customer_id INT NOT NULL,
full_name   NVARCHAR(100),
job_title   NVARCHAR(100),
phone       VARCHAR(20),
email       VARCHAR(100),
is_primary  BIT DEFAULT 0,
status      NVARCHAR(20),
created_at  DATETIME DEFAULT GETDATE(),
updated_at  DATETIME,
CONSTRAINT fk_contacts_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

/* ================================
CUSTOMER SEGMENTS
================================ */
CREATE TABLE Customer_Segments (
segment_id   INT IDENTITY PRIMARY KEY,
segment_name NVARCHAR(50),
description  NVARCHAR(MAX)
);

CREATE TABLE Customer_Segment_Map (
customer_id INT NOT NULL,
segment_id  INT NOT NULL,
assigned_at DATETIME DEFAULT GETDATE(),
CONSTRAINT pk_customer_segment PRIMARY KEY (customer_id, segment_id),
CONSTRAINT fk_csm_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
CONSTRAINT fk_csm_segment  FOREIGN KEY (segment_id)  REFERENCES Customer_Segments(segment_id)
);

/* ================================
CAMPAIGNS & LEADS
================================ */
CREATE TABLE Campaigns (
campaign_id INT IDENTITY PRIMARY KEY,
name        NVARCHAR(100),
description NVARCHAR(MAX),
budget      DECIMAL(15,2),
start_date  DATE,
end_date    DATE,
channel     VARCHAR(50),
status      VARCHAR(20),
created_by  INT,
created_at  DATETIME DEFAULT GETDATE(),
updated_at  DATETIME,
CONSTRAINT fk_campaigns_user FOREIGN KEY (created_by) REFERENCES Users(user_id)
);

CREATE TABLE Leads (
lead_id      INT IDENTITY PRIMARY KEY,
full_name    NVARCHAR(100),
email        VARCHAR(100),
phone        VARCHAR(20),
company_name NVARCHAR(100),
interest     NVARCHAR(255),
source       VARCHAR(50),
status       VARCHAR(20),
campaign_id  INT,
assigned_to  INT,
created_at   DATETIME DEFAULT GETDATE(),
updated_at   DATETIME,
CONSTRAINT fk_leads_campaign FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id),
CONSTRAINT fk_leads_user     FOREIGN KEY (assigned_to) REFERENCES Users(user_id)
);

CREATE TABLE Campaign_Leads (
campaign_id INT NOT NULL,
lead_id     INT NOT NULL,
lead_status VARCHAR(30) NOT NULL,
assigned_at DATETIME DEFAULT GETDATE(),
updated_at  DATETIME,
CONSTRAINT pk_campaign_leads PRIMARY KEY (campaign_id, lead_id),
CONSTRAINT fk_cl_campaign FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id),
CONSTRAINT fk_cl_lead     FOREIGN KEY (lead_id)     REFERENCES Leads(lead_id)
);

/* ================================
DEALS & PRODUCTS
================================ */
CREATE TABLE Deals (
deal_id              INT IDENTITY PRIMARY KEY,
lead_id              INT,
deal_name            NVARCHAR(100),
expected_value       DECIMAL(15,2),
actual_value         DECIMAL(15,2),
stage                VARCHAR(20),
probability          INT,
expected_close_date  DATE,
owner_id             INT,
created_at           DATETIME DEFAULT GETDATE(),
updated_at           DATETIME,
CONSTRAINT fk_deals_lead  FOREIGN KEY (lead_id)  REFERENCES Leads(lead_id),
CONSTRAINT fk_deals_owner FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

CREATE TABLE Products (
product_id  INT IDENTITY PRIMARY KEY,
name        NVARCHAR(100),
sku         VARCHAR(50),
price       DECIMAL(15,2),
description NVARCHAR(MAX),
status      VARCHAR(20),
created_at  DATETIME DEFAULT GETDATE(),
updated_at  DATETIME
);

CREATE TABLE Deal_Products (
deal_id     INT NOT NULL,
product_id  INT NOT NULL,
quantity    INT,
unit_price  DECIMAL(15,2),
discount    DECIMAL(5,2),
total_price DECIMAL(15,2),
CONSTRAINT pk_deal_products PRIMARY KEY (deal_id, product_id),
CONSTRAINT fk_dp_deal    FOREIGN KEY (deal_id)    REFERENCES Deals(deal_id),
CONSTRAINT fk_dp_product FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

/* ================================
CATEGORIES
================================ */
CREATE TABLE Categories (
category_id   INT IDENTITY PRIMARY KEY,
category_name NVARCHAR(100),
description   NVARCHAR(MAX),
status        VARCHAR(20),
created_at    DATETIME DEFAULT GETDATE()
);

CREATE TABLE Category_Products (
category_id INT NOT NULL,
product_id  INT NOT NULL,
CONSTRAINT pk_category_products PRIMARY KEY (category_id, product_id),
CONSTRAINT fk_cp_category FOREIGN KEY (category_id) REFERENCES Categories(category_id),
CONSTRAINT fk_cp_product  FOREIGN KEY (product_id)  REFERENCES Products(product_id)
);

/* ================================
TASKS & ACTIVITIES
================================ */
CREATE TABLE Tasks (
task_id      INT IDENTITY PRIMARY KEY,
title        NVARCHAR(100),
description  NVARCHAR(MAX),
related_type VARCHAR(50),
related_id   INT,
assigned_to  INT,
priority     VARCHAR(20),
status       VARCHAR(20),
due_date     DATE,
created_at   DATETIME DEFAULT GETDATE(),
CONSTRAINT fk_tasks_user FOREIGN KEY (assigned_to) REFERENCES Users(user_id)
);

CREATE TABLE Activities (
activity_id   INT IDENTITY PRIMARY KEY,
related_type  VARCHAR(50),
related_id    INT,
activity_type VARCHAR(50),
subject       NVARCHAR(100),
description   NVARCHAR(MAX),
created_by    INT,
activity_date DATETIME,
created_at    DATETIME DEFAULT GETDATE(),
CONSTRAINT fk_activities_user FOREIGN KEY (created_by) REFERENCES Users(user_id)
);

/* ================================
TICKETS & FEEDBACKS
================================ */
CREATE TABLE Tickets (
ticket_id   INT IDENTITY PRIMARY KEY,
customer_id INT,
subject     NVARCHAR(100),
description NVARCHAR(MAX),
priority    VARCHAR(20),
status      VARCHAR(20),
assigned_to INT,
created_at  DATETIME DEFAULT GETDATE(),
updated_at  DATETIME,
CONSTRAINT fk_tickets_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
CONSTRAINT fk_tickets_user     FOREIGN KEY (assigned_to) REFERENCES Users(user_id)
);

CREATE TABLE Feedbacks (
feedback_id INT IDENTITY PRIMARY KEY,
ticket_id   INT,
rating      INT,
comment     NVARCHAR(MAX),
created_at  DATETIME DEFAULT GETDATE(),
CONSTRAINT fk_feedbacks_ticket FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

/* ================================
REPORTS & NOTIFICATIONS
================================ */
CREATE TABLE Service_Reports (
report_id            INT IDENTITY PRIMARY KEY,
report_date          DATE,
total_ticket         INT,
resolved_ticket      INT,
avg_response_time    DECIMAL(10,2),
avg_resolution_time  DECIMAL(10,2),
created_at           DATETIME DEFAULT GETDATE()
);

CREATE TABLE Campaign_Reports (
report_id        INT IDENTITY PRIMARY KEY,
campaign_id      INT,
total_lead       INT,
qualified_lead   INT,
converted_lead   INT,
cost_per_lead    DECIMAL(10,2),
roi              DECIMAL(5,2),
created_at       DATETIME DEFAULT GETDATE(),
CONSTRAINT fk_campaign_reports_campaign FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

CREATE TABLE Notifications (
notification_id INT IDENTITY PRIMARY KEY,
user_id         INT,
title           NVARCHAR(100),
content         NVARCHAR(MAX),
type            VARCHAR(20),
is_read         BIT DEFAULT 0,
created_at      DATETIME DEFAULT GETDATE(),
CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- END OF SCRIPT
