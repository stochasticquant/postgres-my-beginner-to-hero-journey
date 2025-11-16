# postgres-my-beginner-to-hero-journey

# 📘 PostgreSQL Professional Learning Program (10-Day Portfolio Project)
### A complete hands-on SQL learning journey using pgAdmin + a real business use case

This repository contains a **10-day structured PostgreSQL learning program** designed to take you from **beginner to professional**, using a **realistic enterprise use case**:
🏢 **Developer Project & Time Tracking Platform**

This project demonstrates production-level SQL skills across:

- Database design  
- Advanced SQL querying  
- Joins, aggregations, analytics  
- Constraints, indexes & performance tuning  
- Views, CTEs, window functions  
- PL/pgSQL functions & triggers  
- JSONB & PostgreSQL extensions  
- Backup/restore & security  
- pgAdmin workflow (ERDs, Query Tool, GUI tools)

By completing this program, you will have:

✔ A full enterprise-grade database  
✔ A complete GitHub portfolio project  
✔ Real SQL experience suitable for developer/data-engineer roles  
✔ Professional scripts for your CV  

---

# 🗂 Project Structure

```
postgresql-dev-portfolio/
│
├── README.md
├── schema/
│   ├── 01_create_tables.sql
│   ├── 02_insert_sample_data.sql
│   ├── 03_constraints_indexes.sql
│   ├── 04_views_ctes.sql
│   ├── 05_functions_triggers.sql
│   ├── 06_json_extensions.sql
│
├── demos/
│   ├── joins_examples.sql
│   ├── analytics_examples.sql
│   ├── performance_examples.sql
│
└── backup/
    └── dev_portfolio.backup
```

---

# 🧱 Use Case Summary: Developer Project & Time Tracking Platform

You will build a complete backend database for:

- Clients (accounts)
- Developers/project managers (users)
- Projects
- Tasks
- Time entries
- Invoices

This schema mirrors real SaaS systems used in consulting/engineering companies.

---

# 🧩 Database Schema Overview

### **Tables Included**
- `accounts`
- `users`
- `projects`
- `tasks`
- `time_entries`
- `invoices`

### **Relationships**
- One account → many users  
- One account → many projects  
- One project → many tasks  
- One task → many time entries  

---

# 🗓️ 10-Day PostgreSQL Learning Program (FULL VERSION)

---

# **DAY 1 — PostgreSQL & pgAdmin Basics**

### 🎯 Goal  
Get comfortable navigating pgAdmin and running SQL.

### 📚 Topics  
- Connecting via pgAdmin  
- Query Tool basics  
- Viewing table details  
- CRUD basics  

### 🧪 Tasks  
1. Create `dev_portfolio` database  
2. Create tables using provided schema  
3. Insert initial rows into `accounts` and `users`  
4. Navigate using View/Edit Data  

---

# **DAY 2 — SELECT Mastery**

### 🎯 Goal  
Learn to write solid SELECT queries.

### 📚 Topics  
- Filtering (`WHERE`)  
- Sorting (`ORDER BY`)  
- Pagination (`LIMIT`, `OFFSET`)  
- Basic functions  

### 🧪 Tasks  
- Query top-budget projects  
- Active users only  
- Filter overdue tasks  

---

# **DAY 3 — Joins & Schema Relationships**

### 🎯 Goal  
Understand multi-table relationships and JOIN operations.

### 📚 Topics  
- INNER JOIN  
- LEFT JOIN  
- ERD generation in pgAdmin  

### 🧪 Tasks  
- Generate ERD via pgAdmin  
- Query tasks with project + assignee name  

---

# **DAY 4 — Aggregations & Reporting**

### 🎯 Goal  
Learn professional analytics SQL.

### 📚 Topics  
- `SUM`, `COUNT`, `AVG`  
- `GROUP BY`  
- `HAVING`  
- Subqueries  

### 🧪 Tasks  
- Total hours per project  
- Total hours per developer  
- Projects with > 5 hours logged  

---

# **DAY 5 — Constraints & Indexes**

### 🎯 Goal  
Make schema robust and performant.

### 📚 Topics  
- PK, FK  
- UNIQUE, CHECK, NOT NULL  
- Index creation  
- Index inspection in pgAdmin  

### 🧪 Tasks  
- Add unique constraint (account_id, project_name)  
- Add indexes to speed up joins & filters  

---

# **DAY 6 — Views, CTEs & Window Functions**

### 🎯 Goal  
Master reusable and analytical SQL.

### 📚 Topics  
- CTEs (`WITH`)  
- Views  
- Window functions (`ROW_NUMBER`, `RANK`, `OVER`)  

### 🧪 Tasks  
- Create `project_hours` view  
- Rank developers by contribution per project  

---

# **DAY 7 — Functions & Triggers (PL/pgSQL)**

### 🎯 Goal  
Learn PostgreSQL programming.

### 📚 Topics  
- PL/pgSQL syntax  
- Functions with parameters  
- BEFORE/AFTER triggers  

### 🧪 Tasks  
- Function to compute total project hours  
- Trigger to prevent > 24 hours per day per user  

---

# **DAY 8 — Query Optimization & EXPLAIN ANALYZE**

### 🎯 Goal  
Be able to diagnose slow queries.

### 📚 Topics  
- Execution plans  
- Sequential vs index scans  
- Effect of indexes  

### 🧪 Tasks  
- Compare query plans before/after indexing  
- Visualize EXPLAIN output in pgAdmin  

---

# **DAY 9 — JSONB & PostgreSQL Extensions**

### 🎯 Goal  
Leverage PostgreSQL advanced modern features.

### 📚 Topics  
- JSONB columns  
- JSON operators  
- GIN indexing  
- `uuid-ossp` and `pgcrypto` extensions  

### 🧪 Tasks  
- Add metadata JSONB to `tasks`  
- Query JSONB arrays  
- Add GIN index  

---

# **DAY 10 — Security, Roles & Backup/Restore**

### 🎯 Goal  
Learn professional database administration basics.

### 📚 Topics  
- User/role creation  
- Object privilege GRANTs  
- pgAdmin backup  
- pg_dump / pg_restore  

### 🧪 Tasks  
- Create read-only reporting role  
- Backup database  
- Restore into new database  

---

# 🎓 Skills Gained (CV-Ready)

- SQL (beginner → advanced)  
- Data modeling & schema design  
- Complex joins & analytical queries  
- Database constraints, normalization  
- Indexing strategies & performance tuning  
- Window functions & CTEs  
- PL/pgSQL function & trigger development  
- JSONB storage and indexing  
- Backup/restore operations  
- Role-based database security  
- pgAdmin tooling & workflow  

---
