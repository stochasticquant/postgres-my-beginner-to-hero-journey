# 📅 Day 4 – Aggregations & Reporting (GROUP BY, HAVING)

## 🎯 Goal

On Day 4 you will learn to turn raw rows into **professional reports and summaries** using:

- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `GROUP BY` on one and multiple columns
- `HAVING` to filter aggregated results
- Simple subqueries for more advanced reporting

By the end of Day 4, you’ll be able to answer real business questions from the `dev_portfolio` database using analytical SQL.

---

## 📁 Files for Day 4

- `schema/04_day4_aggregations.sql`  
  Contains all example aggregation/reporting queries.

You can create this file in your repo and paste in the Day 4 SQL script.

---

## 🧩 What You Work With

You leverage all the data populated in Days 1–3:

- Thousands of tasks with priorities, statuses, due dates  
- Thousands of time entries with hours logged by users  
- Hundreds of invoices by accounts and projects  
- Accounts, users, projects all connected via joins  

This allows you to compute:

- How busy each developer is  
- How large each client’s workload is  
- How much revenue comes from each account  
- Which projects consume the most effort  

---

## 🧪 Step-by-Step Activities

### 1️⃣ Basic Aggregations

You start with global summaries:

- Total number of rows per table  
- Minimum, maximum, average, and total budgets  
- Invoice amount statistics  

Example:

```sql
SELECT
    COUNT(*)       AS total_projects,
    MIN(budget_usd) AS min_budget,
    MAX(budget_usd) AS max_budget,
    AVG(budget_usd) AS avg_budget,
    SUM(budget_usd) AS sum_budget
FROM projects;
```

This teaches you how aggregate functions work on entire tables.

---

### 2️⃣ GROUP BY – Simple Categorized Reports

You then group by:

- Industry → number of accounts  
- User role → number of users  
- Project status → number of projects, average budget  

Example:

```sql
SELECT
    status,
    COUNT(*)        AS project_count,
    AVG(budget_usd) AS avg_budget,
    SUM(budget_usd) AS total_budget
FROM projects
GROUP BY status
ORDER BY total_budget DESC;
```

This mirrors typical management reports: “How many active projects do we have? What’s the total budget per status?”

---

### 3️⃣ GROUP BY with Joins

You start combining multiple tables with `JOIN + GROUP BY`:

- Users per account  
- Projects & total budget per account  
- Tasks per project  
- Total hours per project  
- Total hours per user  

Example:

```sql
SELECT
    p.project_id,
    p.name              AS project_name,
    SUM(te.hours_spent) AS total_hours
FROM projects p
JOIN tasks t
    ON p.project_id = t.project_id
JOIN time_entries te
    ON t.task_id = te.task_id
GROUP BY p.project_id, p.name
ORDER BY total_hours DESC
LIMIT 30;
```

Now you’re doing serious analytics.

---

### 4️⃣ HAVING – Filtering Aggregated Results

You learn the difference between:

- `WHERE` → filters rows *before* aggregation  
- `HAVING` → filters groups *after* aggregation  

Examples:

- Accounts with more than 10 users  
- Projects with more than 50 tasks  
- Users with more than 100 logged hours  
- Accounts with total invoice value > 100,000  

```sql
SELECT
    u.user_id,
    u.full_name         AS developer_name,
    SUM(te.hours_spent) AS total_hours
FROM users u
JOIN time_entries te
    ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name
HAVING SUM(te.hours_spent) > 100
ORDER BY total_hours DESC;
```

This is essential in interviews and real-world analytics.

---

### 5️⃣ Multi-table Analytical Reports

You then build higher-value reports, such as:

#### 🔹 Account-level summary

For each account:

- Number of projects  
- Number of tasks  
- Total logged hours  

```sql
SELECT
    a.account_id,
    a.name                    AS account_name,
    COUNT(DISTINCT p.project_id) AS project_count,
    COUNT(DISTINCT t.task_id)    AS task_count,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
LEFT JOIN tasks t
    ON p.project_id = t.project_id
LEFT JOIN time_entries te
    ON t.task_id = te.task_id
GROUP BY a.account_id, a.name
ORDER BY total_hours DESC;
```

#### 🔹 Project-level summary

- Tasks per project  
- Total hours logged  
- Average hours per task  

#### 🔹 Developer-level summary

- Tasks worked on  
- Projects worked on  
- Total hours logged  

#### 🔹 Invoice & revenue summary per account

- Number of invoices  
- Total invoiced amount  
- Total paid  
- Total overdue  

These kinds of queries are exactly what appear in real dashboards & BI tools.

---

### 6️⃣ Simple Subqueries

You then step into **subqueries**:

- Projects whose total hours are above the *average* project’s total hours  
- Users whose total hours are above the *average* user’s total hours  

This introduces patterns like:

```sql
SELECT
    project_id,
    project_name,
    total_hours
FROM (
    SELECT
        p.project_id,
        p.name AS project_name,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.name
) project_hours
WHERE total_hours >
    (SELECT AVG(total_hours) FROM (...subquery...));
```

Subqueries are critical for slightly more advanced analytics and later help you understand CTEs and window functions.

---

### 7️⃣ Practice Exercises

The script ends with **TODOs** for you to design your own reports, such as:

- Industry-level summaries (accounts, projects, invoice totals)  
- Status-based project analytics (average hours per status)  
- Top accounts by total logged hours with project count filters  
- Developer-level revenue impact  
- Projects with no time entries at all  

Implement these in the same `04_day4_aggregations.sql` or in a separate `04_day4_exercises.sql`.

---

## 🧠 What You’ll Be Able to Say After Day 4

After mastering Day 4, you can honestly say:

> “I can design and write analytical SQL queries using GROUP BY, HAVING, and aggregate functions to produce meaningful business reports. I can summarize activity across accounts, projects, tasks, developers, and invoices, and I understand when to use JOINs and subqueries for advanced reporting.”

This is **exactly** what hiring managers expect from a developer/data engineer comfortable with SQL.

---

## 📁 Suggested Repository Structure After Day 4

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   ├── 03_day3_joins.sql
│   └── 04_day4_aggregations.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    ├── README_Day3.md
    └── README_Day4.md
```

---

Next up, **Day 5** – we’ll focus on **constraints, indexes, and data integrity**, making your schema more robust and performant like a real production system.
