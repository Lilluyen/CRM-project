/* ================================
CRM SYSTEM - FULL DATABASE SCRIPT
SQL SERVER
================================ */
-- 1. CREATE DATABASE
CREATE DATABASE CRM_System;

GO USE CRM_System;

GO
/* ================================
USERS & ROLES
================================ */
CREATE TABLE
    Users (
        user_id INT IDENTITY PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        email VARCHAR(100),
        full_name VARCHAR(100),
        phone VARCHAR(20),
        status VARCHAR(20),
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        last_login_at DATETIME
    );

CREATE TABLE
    Roles (
        role_id INT IDENTITY PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL,
        description VARCHAR(255),
        created_at DATETIME DEFAULT GETDATE ()
    );

CREATE TABLE
    User_Roles (
        user_id INT,
        role_id INT,
        assigned_at DATETIME DEFAULT GETDATE (),
        PRIMARY KEY (user_id, role_id),
        FOREIGN KEY (user_id) REFERENCES Users (user_id),
        FOREIGN KEY (role_id) REFERENCES Roles (role_id)
    );

/* ================================
CUSTOMERS & CONTACTS
================================ */
CREATE TABLE
    Customers (
        customer_id INT IDENTITY PRIMARY KEY,
        name VARCHAR(100),
        address VARCHAR(255),
        industry VARCHAR(100),
        company_size VARCHAR(50),
        phone VARCHAR(20),
        email VARCHAR(100),
        status VARCHAR(20),
        owner_id INT,
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (owner_id) REFERENCES Users (user_id)
    );

CREATE TABLE
    Contacts (
        contact_id INT IDENTITY PRIMARY KEY,
        customer_id INT,
        full_name VARCHAR(100),
        job_title VARCHAR(100),
        phone VARCHAR(20),
        email VARCHAR(100),
        is_primary BIT DEFAULT 0,
        status VARCHAR(20),
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
    );

/* ================================
CUSTOMER SEGMENTS
================================ */
CREATE TABLE
    Customer_Segments (
        segment_id INT IDENTITY PRIMARY KEY,
        segment_name VARCHAR(50),
        description TEXT
    );

CREATE TABLE
    Customer_Segment_Map (
        customer_id INT,
        segment_id INT,
        assigned_at DATETIME DEFAULT GETDATE (),
        PRIMARY KEY (customer_id, segment_id),
        FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
        FOREIGN KEY (segment_id) REFERENCES Customer_Segments (segment_id)
    );

/* ================================
CAMPAIGNS & LEADS
================================ */
CREATE TABLE
    Campaigns (
        campaign_id INT IDENTITY PRIMARY KEY,
        name VARCHAR(100),
        description TEXT,
        budget DECIMAL(15, 2),
        start_date DATE,
        end_date DATE,
        channel VARCHAR(50),
        status VARCHAR(20),
        created_by INT,
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (created_by) REFERENCES Users (user_id)
    );

CREATE TABLE
    Leads (
        lead_id INT IDENTITY PRIMARY KEY,
        full_name VARCHAR(100),
        email VARCHAR(100),
        phone VARCHAR(20),
        company_name VARCHAR(100),
        interest VARCHAR(255),
        source VARCHAR(50),
        status VARCHAR(20),
        campaign_id INT,
        assigned_to INT,
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (campaign_id) REFERENCES Campaigns (campaign_id),
        FOREIGN KEY (assigned_to) REFERENCES Users (user_id)
    );

CREATE TABLE
    Campaign_Leads (
        campaign_id INT NOT NULL,
        lead_id INT NOT NULL,
        lead_status VARCHAR(30) NOT NULL,
        -- NEW / QUALIFIED / DEAL_CREATED / WON / LOST
        assigned_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME NULL,
        PRIMARY KEY (campaign_id, lead_id),
        CONSTRAINT fk_campaign_leads_campaign FOREIGN KEY (campaign_id) REFERENCES Campaigns (campaign_id),
        CONSTRAINT fk_campaign_leads_lead FOREIGN KEY (lead_id) REFERENCES Leads (lead_id)
    );

/* ================================
DEALS & PRODUCTS
================================ */
CREATE TABLE
    Deals (
        deal_id INT IDENTITY PRIMARY KEY,
        lead_id INT,
        deal_name VARCHAR(100),
        expected_value DECIMAL(15, 2),
        actual_value DECIMAL(15, 2),
        stage VARCHAR(20),
        probability INT,
        expected_close_date DATE,
        owner_id INT,
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (lead_id) REFERENCES Leads (lead_id),
        FOREIGN KEY (owner_id) REFERENCES Users (user_id)
    );

CREATE TABLE
    Products (
        product_id INT IDENTITY PRIMARY KEY,
        name VARCHAR(100),
        sku VARCHAR(50),
        price DECIMAL(15, 2),
        description TEXT,
        status VARCHAR(20),
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME
    );

CREATE TABLE
    Deal_Products (
        deal_id INT,
        product_id INT,
        quantity INT,
        unit_price DECIMAL(15, 2),
        discount DECIMAL(5, 2),
        total_price DECIMAL(15, 2),
        PRIMARY KEY (deal_id, product_id),
        FOREIGN KEY (deal_id) REFERENCES Deals (deal_id),
        FOREIGN KEY (product_id) REFERENCES Products (product_id)
    );

/* ================================
CATEGORIES
================================ */
CREATE TABLE
    Categories (
        category_id INT IDENTITY PRIMARY KEY,
        category_name VARCHAR(100),
        description TEXT,
        status VARCHAR(20),
        created_at DATETIME DEFAULT GETDATE ()
    );

CREATE TABLE
    Category_Products (
        category_id INT,
        product_id INT,
        PRIMARY KEY (category_id, product_id),
        FOREIGN KEY (category_id) REFERENCES Categories (category_id),
        FOREIGN KEY (product_id) REFERENCES Products (product_id)
    );

/* ================================
TASKS & ACTIVITIES
================================ */
CREATE TABLE
    Tasks (
        task_id INT IDENTITY PRIMARY KEY,
        title VARCHAR(100),
        description TEXT,
        related_type VARCHAR(50),
        related_id INT,
        assigned_to INT,
        priority VARCHAR(20),
        status VARCHAR(20),
        due_date DATE,
        created_at DATETIME DEFAULT GETDATE (),
        FOREIGN KEY (assigned_to) REFERENCES Users (user_id)
    );

CREATE TABLE
    Activities (
        activity_id INT IDENTITY PRIMARY KEY,
        related_type VARCHAR(50),
        related_id INT,
        activity_type VARCHAR(50),
        subject VARCHAR(100),
        description TEXT,
        created_by INT,
        activity_date DATETIME,
        created_at DATETIME DEFAULT GETDATE (),
        FOREIGN KEY (created_by) REFERENCES Users (user_id)
    );

/* ================================
TICKETS & FEEDBACKS
================================ */
CREATE TABLE
    Tickets (
        ticket_id INT IDENTITY PRIMARY KEY,
        customer_id INT,
        subject VARCHAR(100),
        description TEXT,
        priority VARCHAR(20),
        status VARCHAR(20),
        assigned_to INT,
        created_at DATETIME DEFAULT GETDATE (),
        updated_at DATETIME,
        FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
        FOREIGN KEY (assigned_to) REFERENCES Users (user_id)
    );

CREATE TABLE
    Feedbacks (
        feedback_id INT IDENTITY PRIMARY KEY,
        ticket_id INT,
        rating INT,
        comment TEXT,
        created_at DATETIME DEFAULT GETDATE (),
        FOREIGN KEY (ticket_id) REFERENCES Tickets (ticket_id)
    );

/* ================================
REPORTS & NOTIFICATIONS
================================ */
CREATE TABLE
    Service_Reports (
        report_id INT IDENTITY PRIMARY KEY,
        report_date DATE,
        total_ticket INT,
        resolved_ticket INT,
        avg_response_time DECIMAL(10, 2),
        avg_resolution_time DECIMAL(10, 2),
        created_at DATETIME DEFAULT GETDATE ()
    );

CREATE TABLE
    Campaign_Reports (
        report_id INT IDENTITY PRIMARY KEY,
        campaign_id INT,
        total_lead INT,
        qualified_lead INT,
        converted_lead INT,
        cost_per_lead DECIMAL(10, 2),
        roi DECIMAL(5, 2),
        created_at DATETIME DEFAULT GETDATE (),
        FOREIGN KEY (campaign_id) REFERENCES Campaigns (campaign_id)
    );

CREATE TABLE
    Notifications (
        notification_id INT IDENTITY PRIMARY KEY,
        user_id INT,
        title VARCHAR(100),
        content TEXT,
        type VARCHAR(20),
        is_read BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE (),
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
    );

-- END SCRIPT