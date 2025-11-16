# 📅 Day 7 – PL/pgSQL Functions & Triggers  
Today your PostgreSQL skills level up into the **backend developer tier**: you’ll learn how to embed business logic **inside the database** using:

- PL/pgSQL functions  
- BEFORE & AFTER triggers  
- Audit tables  
- Automatic workflow behavior  
- Custom validation logic  

This is one of the biggest differentiators between “I write queries” and **“I design and enforce rules at the data layer.”**

---

# 🎯 Learning Goals for Day 7

By the end of today, you will be able to:

✔ Write stored procedures in PL/pgSQL  
✔ Create triggers that execute before or after inserts/updates  
✔ Enforce business rules at the database level  
✔ Automatically audit all changes to tasks or invoices  
✔ Build reusable summary functions  
✔ Understand real production use cases for triggers & functions  

---

# 🧩 What You Will Build

## 1️⃣ Audit Tables  
You create two audit tables:

- `task_audit`
- `invoice_audit`

These store old/new status values, who changed them, and when.

**Real-world purpose:**  
Track workflow changes for compliance, analytics, debugging, and accountability.

---

## 2️⃣ Business Rule Enforcement with Triggers

### 🔒 Example: Limit hours spent per time-entry  
A BEFORE INSERT trigger enforces that no time entry can exceed 12 hours:

```sql
IF NEW.hours_spent > 12 THEN
    RAISE EXCEPTION 'Time entry exceeds allowed daily max';
END IF;
```

**Why this matters:**  
Stops bad data before it hits your reporting systems.

---

## 3️⃣ Automatic Project Completion  
When all tasks in a project are marked `done`, a trigger automatically sets:

```sql
project.status = 'completed'
```

**This simulates real project management automation.**

---

## 4️⃣ Full Audit Logging for Status Changes

Every time a task or invoice status changes:

- old status  
- new status  
- who changed it  
- timestamp  

gets stored automatically.

This is typical for:

- Finance systems  
- HR systems  
- Supply chain  
- Time-tracking & billing  

---

## 5️⃣ Reporting Function: `get_project_summary(project_id)`

This stored function returns:

- total hours  
- task count  
- total invoice amount  
- paid amount  
- last activity date  

You can use it like:

```sql
SELECT * FROM get_project_summary(42);
```

This is how many companies build **internal APIs directly from the DB layer.**

---

# 🧪 Exercises (TODOs)

To deepen your skills you will:

### ✔ Add updated_at triggers  
Automatically maintain timestamp fields.

### ✔ Build invoice auto-due-date logic  
Set due_date to 30 days after issue_date if omitted.

### ✔ Validate admin users  
Ensure they use a corporate email domain.

### ✔ Create a function returning account financial summaries  
(Revenue, unpaid invoices, etc.)

---

# 🧠 What You’ll Be Able to Say as a Developer

After Day 7, you can confidently include on your CV:

> “Designed PL/pgSQL stored functions and database triggers to enforce business rules, implement audit logging, maintain data quality, and build reusable analytical functions within PostgreSQL.”

This is *very* attractive for roles in:

- Backend development  
- Data engineering  
- DevOps/SRE  
- Analytics engineering  
- Database administration  

---

# 📁 Repo Structure After Day 7

```
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   ├── 03_day3_joins.sql
│   ├── 04_day4_aggregations.sql
│   ├── 05_day5_constraints_indexes.sql
│   ├── 06_day6_views_ctes_windows.sql
│   └── 07_day7_functions_triggers.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    ├── README_Day3.md
    ├── README_Day4.md
    ├── README_Day5.md
    ├── README_Day6.md
    └── README_Day7.md
```

---

# 🚀 Next Steps — Day 8  
We move into **transactions, locking, concurrency control, and ACID-testing**—very important for production reliability.

