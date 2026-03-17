# CRM Project Setup Guide

## Step 1: Database Setup (SQL Server)

### Prerequisites
- SQL Server 2019 or later installed
- SQL Server Management Studio (SSMS)

### Execute Database Scripts in Order

1. **Open SQL Server Management Studio (SSMS)**

2. **Run Script 1: Create Database and Tables**
   - File: `database/01_create_database_and_tables.sql`
   - Action: Select all and execute
   - Result: Creates `CRM_System` database with all tables

3. **Run Script 2: Insert Sample Data**
   - File: `database/02_insert_data.sql`
   - Result: Populates tables with test data

4. **Run Script 3: Create Constraints and Indexes**
   - File: `database/03_constraints_indexes_fk.sql`
   - Result: Adds foreign keys, indexes, and constraints

5. **Run Script 4: Create Procedures and Triggers**
   - File: `database/04_procedures_triggers.sql`
   - Result: Creates stored procedures and database triggers

### Alternative: Quick Setup
If you have all scripts, you can run `database/full_script.sql` which combines all steps.

---

## Step 2: Configure Application Connection

The application uses **SQL Server JDBC driver** configured in `pom.xml`.

### Check Database Connection Configuration
Look for connection properties in:
- `src/main/java/util/` (likely has connection pool configuration)
- `WEB-INF/web.xml` (deployment descriptor)
- Environment variables or system properties

### Verify Connection String
Default format for SQL Server:
```
jdbc:sqlserver://localhost:1433;databaseName=CRM_System
```

---

## Step 3: Configure Email (SMTP)

Email settings are in `src/main/resources/email.properties`:
```properties
email.smtp.host=smtp.gmail.com
email.smtp.port=587
email.smtp.auth=true
email.smtp.starttls.enable=true
email.smtp.starttls.required=true
email.smtp.user=your-email@gmail.com
email.smtp.password=your-app-password
```

**If using Gmail:**
1. Enable 2-Factor Authentication
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Replace `email.smtp.password` with your App Password

---

## Step 4: Build and Run

### Build the Project
```powershell
cd "c:\Users\AD\Documents\Zalo Received Files\CRM-project (2)\CRM-project"
mvn clean install
```

### Run Tests
```powershell
mvn test
```

### Run on Application Server

**Option 1: Using Tomcat (if configured)**
```powershell
mvn tomcat:run
```

**Option 2: Deploy WAR file**
- WAR location: `target/crm.war`
- Copy to: `%CATALINA_HOME%\webapps\`
- Start Tomcat
- Access: http://localhost:8080/crm

**Option 3: Using Docker**
```powershell
docker build -t crm-app .
docker run -p 8080:8080 crm-app
```

---

## Step 5: Access the Application

Once deployed:
- **URL**: http://localhost:8080/crm
- **Login Page**: `/login.jsp`
- **Admin Dashboard**: `/admin.jsp`

---

## Troubleshooting

### Database Connection Issues
- Verify SQL Server is running: `Services → SQL Server (MSSQL...)`
- Check firewall allows port 1433
- Verify credentials in connection string

### Missing Dependencies
```powershell
mvn dependency:tree
```

### Build Fails
```powershell
mvn clean
mvn compile
```

### Tests Failed
```powershell
mvn test -DskipTests  # Skip tests and build anyway
```

---

## Project Structure Reference

```
src/main/java/
  ├── controller/          → REST API endpoints
  ├── service/             → Business logic
  ├── dao/                 → Database access
  ├── model/               → Entity classes
  ├── dto/                 → Data transfer objects
  └── util/                → Utilities (DB connection, etc.)

src/main/webapp/
  ├── login.jsp            → Login page
  ├── index.jsp            → Home page
  ├── admin.jsp            → Admin dashboard
  ├── customer.jsp         → Customer interface
  └── WEB-INF/             → Web configuration
```

---

## Default Credentials (After Running Setup Scripts)

Check the test data inserted in `02_insert_data.sql` for sample accounts.

