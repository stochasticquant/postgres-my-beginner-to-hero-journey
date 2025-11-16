# 📅 Day 5 – Constraints, Indexes & Data Integrity

## 🎯 Goal

On Day 5 you turn your `dev_portfolio` database from “works fine” into **“production-ready”** by:

- Enforcing **data integrity** with constraints
- Implementing realistic **business rules** (e.g., max hours per day, valid dates)
- Creating **indexes** that support joins and common filter patterns
- Learning how to **inspect constraints and indexes** in PostgreSQL and pgAdmin

This is exactly what separates “I know SQL” from **“I can design a reliable, performant database.”**

---

## 📁 Files for Day 5

- `schema/05_day5_constraints_indexes.sql`  
  Contains all constraint and index definitions, plus validation queries.

You can create this file in your repo and paste in the Day 5 SQL script.

---

## 🧩 What You Strengthen Today

You’ll improve two major aspects:

### 1. **Data Integrity** – using constraints

You add:

- `UNIQUE (account_id, name)` on `projects`  
  → No duplicate project names under the same account.

- `UNIQUE (project_id, title)` on `tasks`  
  → No duplicate task titles within one project.

- `CHECK` on `tasks.estimated_hours`  
  → Must be `> 0` if not NULL.

- `CHECK` on `time_entries.hours_spent`  
  → Must be between `0` and `24` hours (per entry).

- `CHECK` on `invoices.due_date >= issue_date`  
  → An invoice cannot be due before it was issued.

- `CHECK` on `invoices.amount_usd >= 0`  
  → No negative invoice amounts.

These constraints encode **real business rules** directly into the database, so bad data is rejected at the source.

---

### 2. **Performance** – using indexes

You add indexes on:

- Foreign keys (for join performance):
  - `users.account_id`
  - `projects.account_id`
  - `tasks.project_id`
  - `tasks.assignee_id`
  - `time_entries.task_id`
  - `time_entries.user_id`
  - `invoices.account_id`
  - `invoices.project_id`

- Common filter patterns:
  - `projects(status)`
  - `tasks(status, priority)`
  - `time_entries(user_id, work_date)` → typical timesheet queries
  - `invoices(status, due_date)` → collections & aging reports

These indexes are chosen based on the **real queries** you wrote in Days 2–4. This is exactly how indexing works in real teams: you index what you actually query.

---

## 🧪 Step-by-Step Activities

### 1️⃣ Run the Constraint & Index Script

In pgAdmin:

1. Connect to `dev_portfolio`.
2. Open **Query Tool**.
3. Load and run `05_day5_constraints_indexes.sql`.

If everything is consistent with the Day 1–4 data, this should succeed without errors.

---

### 2️⃣ Test That Constraints Actually Work

The script includes commented-out **test INSERTs** that are expected to FAIL:

- Duplicated project names per account
- Tasks with negative estimated hours
- Time entries with more than 24 hours
- Invoices with due_date before issue_date

Uncomment **one at a time**, run them, and observe the error messages.

This gives you a feel for how PostgreSQL enforces rules.

---

### 3️⃣ Inspect Constraints & Indexes

Use the queries in the script:

- To list constraints on the main tables:

```sql
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name IN ('accounts','users','projects','tasks','time_entries','invoices')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;
```

- To list indexes:

```sql
SELECT
    t.relname      AS table_name,
    i.relname      AS index_name,
    a.attname      AS column_name,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary
FROM pg_class t
JOIN pg_index ix
    ON t.oid = ix.indrelid
JOIN pg_class i
    ON i.oid = ix.indexrelid
JOIN pg_attribute a
    ON a.attrelid = t.oid
   AND a.attnum = ANY(ix.indkey)
WHERE t.relname IN ('accounts','users','projects','tasks','time_entries','invoices')
ORDER BY t.relname, i.relname, a.attnum;
```

In **pgAdmin GUI**, you can also visually:

- Expand each table → **Constraints**
- Expand each table → **Indexes**

---

### 4️⃣ Validate Data Quality

At the end of the script, there are queries like:

- Find tasks with invalid estimated hours  
- Find time entries with invalid hours  
- Find invoices with invalid date relationships  
- Check for duplicate project names per account  
- Check for duplicate task titles per project  

These should all return **zero rows** if the data and constraints are consistent.

---

### 5️⃣ Practice Exercises (TODOs)

You are encouraged to:

- Add your own constraints to the `users` table (e.g., role validation – already present in original DDL, but redo it in a scratch DB to practice).
- Design indexes that support your most common query patterns (e.g., `status + due_date` on tasks).
- Add validation rules relating `due_date` and `created_at`.
- Create composite unique constraints (e.g., no duplicate full_name within the same account).

This trains you to think like a **database designer**.

---

## 🧠 What You’ll Be Able to Say After Day 5

After completing Day 5, you can honestly say:

> “I can design and apply database constraints (UNIQUE, CHECK, foreign keys) to enforce real business rules, and I can choose and create appropriate indexes to make queries efficient. I know how to validate and inspect these constraints and indexes using both SQL and pgAdmin.”

This is critical for any professional backend, data, or DevOps engineer role.

---

## 📁 Suggested Repository Structure After Day 5

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   ├── 03_day3_joins.sql
│   ├── 04_day4_aggregations.sql
│   └── 05_day5_constraints_indexes.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    ├── README_Day3.md
    ├── README_Day4.md
    └── README_Day5.md
```

---

Next up, **Day 6** – we’ll move into **views, CTEs, and window functions**, turning your analytical queries into reusable, powerful reporting layers.
