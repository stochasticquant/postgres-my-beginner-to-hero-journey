# 📅 Day 6 – Views, CTEs & Window Functions

## 🎯 Goal

On Day 6 you’ll move into **advanced analytical SQL patterns**:

- Build **views** as reusable, stable reporting layers
- Use **CTEs (WITH)** to structure complex queries
- Use **window functions** (`RANK`, `ROW_NUMBER`, `SUM OVER`, `AVG OVER`) for rich analytics

This is the level of SQL that stands out on a developer/data engineer CV.

---

## 📁 Files for Day 6

- `schema/06_day6_views_ctes_windows.sql`  
  Contains all view definitions, CTE examples, and window function queries.

Create this file in your repo and paste in the Day 6 SQL script.

---

## 🧩 What You Build Today

### 1️⃣ Views – Your Reusable Reporting Layer

You create views that encapsulate complex joins and aggregations:

- `dev_hours_per_project`  
  → Total hours and task count per project, with account info.

- `dev_hours_per_account`  
  → Total hours, project count, and task count per account.

- `project_summary_view`  
  → Project status, budget, invoiced amount, and paid amount per project.

These views let you query:

```sql
SELECT *
FROM dev_hours_per_project
ORDER BY total_hours DESC
LIMIT 20;
```

without having to repeatedly write big JOIN + GROUP BY queries.

---

### 2️⃣ CTEs (WITH) – Structuring Complex Logic

You then use **CTEs** (`WITH`) to break down complex reports into logical steps:

- First CTE: `project_hours` – compute total hours per project.
- Second CTE: `account_summary` – aggregate those project hours by account.

Example:

```sql
WITH project_hours AS (
    SELECT
        p.project_id,
        p.name AS project_name,
        p.account_id,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.name, p.account_id
),
account_summary AS (
    SELECT
        a.account_id,
        a.name AS account_name,
        COUNT(ph.project_id)       AS project_count,
        COALESCE(SUM(ph.total_hours), 0) AS total_hours
    FROM accounts a
    LEFT JOIN project_hours ph
        ON a.account_id = ph.account_id
    GROUP BY a.account_id, a.name
)
SELECT *
FROM account_summary
ORDER BY total_hours DESC
LIMIT 20;
```

This helps you write clean, readable SQL for complex tasks.

You also use CTEs to:

- Filter accounts above a certain hour threshold
- Get **top N projects per account** using `RANK()` in a CTE

---

### 3️⃣ Window Functions – Advanced Analytics

You work with window functions to:

#### 🔹 Rank developers by total hours

```sql
SELECT
    u.user_id,
    u.full_name AS developer_name,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    RANK() OVER (ORDER BY COALESCE(SUM(te.hours_spent), 0) DESC) AS hours_rank,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(te.hours_spent), 0) DESC) AS hours_dense_rank
FROM users u
LEFT JOIN time_entries te
    ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name;
```

#### 🔹 Rank developers *within each account*

Using `PARTITION BY account_id` to restart ranking per account.

#### 🔹 Running totals

Per user over time:

```sql
SELECT
    u.user_id,
    u.full_name   AS developer_name,
    te.work_date,
    te.hours_spent,
    SUM(te.hours_spent) OVER (
        PARTITION BY u.user_id
        ORDER BY te.work_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_hours
FROM users u
JOIN time_entries te
    ON u.user_id = te.user_id;
```

#### 🔹 Comparing to overall averages

You compute per-user daily averages and compare them with the overall average across all users, using:

- `AVG(...) OVER (PARTITION BY user_id)`  
- `AVG(...) OVER ()`  

#### 🔹 Percent-of-total metrics

You calculate what **percentage of an account’s total hours** each project takes using:

```sql
SUM(ph.total_hours) OVER (PARTITION BY ph.account_id)
```

and case logic to compute percentages. This is directly useful for things like Pareto analysis.

---

### 4️⃣ Practice Exercises (TODOs)

You are encouraged to:

- Create a `developer_hours_summary` view combining tasks, projects, and hours.
- Use that view to rank developers by total hours.
- Write CTEs that:
  - Find projects above average hours
  - Compute invoice percentages per account
  - Build Pareto-like cumulative distributions per account

These exercises push you from just copying queries to **designing your own analytical patterns**.

---

## 🧠 What You’ll Be Able to Say After Day 6

After completing Day 6, you can honestly say:

> “I can design reusable reporting layers in PostgreSQL using views, structure complex logic with CTEs, and write analytical queries with window functions (RANK, SUM OVER, AVG OVER, running totals, percentages of total). I can analyze developer workload, project contributions, and account-level summaries in a scalable way.”

This is very strong for backend, analytics, and data engineering roles.

---

## 📁 Suggested Repository Structure After Day 6

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   ├── 03_day3_joins.sql
│   ├── 04_day4_aggregations.sql
│   ├── 05_day5_constraints_indexes.sql
│   └── 06_day6_views_ctes_windows.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    ├── README_Day3.md
    ├── README_Day4.md
    ├── README_Day5.md
    └── README_Day6.md
```

---

Next up, **Day 7** – we’ll write **PL/pgSQL functions and triggers** to push some business logic into the database itself (e.g., enforcing daily hour limits, calculating project summaries on demand).
