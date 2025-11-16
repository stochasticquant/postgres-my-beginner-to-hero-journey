# 📅 Day 3 – Joins & Relationships

## 🎯 Goal

On Day 3 you will learn how to **combine data across multiple tables** using SQL joins:

- Understand how tables in `dev_portfolio` relate to each other
- Master `INNER JOIN` and `LEFT JOIN`
- Write multi-table queries involving accounts, users, projects, tasks, time entries, and invoices
- Start building queries that look like real backend/API or reporting queries

This is where the database starts to feel like a real application.

---

## 📁 Files for Day 3

- `schema/03_day3_joins.sql`  
  Contains all example JOIN queries, organized by topic.

You can create this file in your repo and paste the full Day 3 SQL script into it.

---

## 🧩 What You Work With

You will actively join these tables:

- `accounts` ↔ `users` (account has many users)
- `accounts` ↔ `projects` (account has many projects)
- `projects` ↔ `tasks` (project has many tasks)
- `tasks` ↔ `time_entries` (task has many time logs)
- `users` ↔ `tasks` (user is assignee of tasks)
- `accounts` ↔ `invoices` ↔ `projects` (billing per project & account)

Understanding these relationships makes you think like a **backend/database engineer**, not just someone who “knows some SQL”.

---

## 🧪 Step-by-Step Activities

### 1️⃣ Basic One-to-Many Joins

You start by joining simple pairs:

- Accounts → Users  
- Accounts → Projects  
- Projects → Tasks  

Example:

```sql
SELECT
    a.account_id,
    a.name          AS account_name,
    p.project_id,
    p.name          AS project_name,
    p.status,
    p.budget_usd
FROM accounts a
JOIN projects p
    ON a.account_id = p.account_id
ORDER BY a.account_id, p.project_id
LIMIT 50;
```

You’ll get comfortable reading and writing `JOIN ... ON ...` patterns.

---

### 2️⃣ Three-Table Joins

Then we step up:

- Tasks + Projects + Accounts  
- Tasks + Assignee Users + Accounts  

Example:

```sql
SELECT
    t.task_id,
    t.title           AS task_title,
    t.status          AS task_status,
    t.priority,
    u.full_name       AS assignee_name,
    a.name            AS account_name
FROM tasks t
JOIN users u
    ON t.assignee_id = u.user_id
JOIN accounts a
    ON u.account_id = a.account_id
ORDER BY a.account_id, u.user_id, t.task_id
LIMIT 100;
```

This is exactly the sort of query used in real-world dashboards and APIs.

---

### 3️⃣ Time Entries with Full Context

You learn to join:

- `time_entries` → `tasks` → `projects` → `accounts` → `users`

to answer questions like:

- *“What work did each developer do for each client?”*  
- *“How many hours were logged per project?”* (aggregation comes in Day 4)

Example:

```sql
SELECT
    te.time_entry_id,
    te.work_date,
    te.hours_spent,
    u.full_name        AS developer_name,
    p.name             AS project_name,
    a.name             AS account_name
FROM time_entries te
JOIN users u
    ON te.user_id = u.user_id
JOIN tasks t
    ON te.task_id = t.task_id
JOIN projects p
    ON t.project_id = p.project_id
JOIN accounts a
    ON p.account_id = a.account_id
ORDER BY te.work_date DESC, u.user_id
LIMIT 100;
```

This is powerful: you’re combining data across **five tables** in one query.

---

### 4️⃣ Invoices with Projects & Accounts

You link revenue (invoices) back to:

- Clients (accounts)
- Work (projects)

Example:

```sql
SELECT
    i.invoice_id,
    i.issue_date,
    i.due_date,
    i.amount_usd,
    i.status         AS invoice_status,
    a.name           AS account_name,
    p.name           AS project_name
FROM invoices i
JOIN accounts a
    ON i.account_id = a.account_id
LEFT JOIN projects p
    ON i.project_id = p.project_id
ORDER BY i.invoice_id
LIMIT 100;
```

Notice the `LEFT JOIN` to handle invoices that might not be tied to a specific project.

---

### 5️⃣ LEFT JOINs & “Missing Data”

You then practice `LEFT JOIN` to answer questions like:

- Which accounts have no projects?  
- Which projects have no tasks?  
- Which users have no tasks assigned?

Example:

```sql
SELECT
    p.project_id,
    p.name           AS project_name,
    t.task_id,
    t.title          AS task_title
FROM projects p
LEFT JOIN tasks t
    ON p.project_id = t.project_id
ORDER BY p.project_id, t.task_id NULLS LAST
LIMIT 100;
```

And you’ll learn the important pattern:

> “Find rows with no child records” → `LEFT JOIN ... WHERE child.id IS NULL`

---

### 6️⃣ Preview: Simple Counts with GROUP BY

You get a **teaser** of what’s coming on Day 4:

- Count users per account  
- Count projects per account  
- Count tasks per project  

Example:

```sql
SELECT
    a.account_id,
    a.name           AS account_name,
    COUNT(p.project_id) AS project_count
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
GROUP BY a.account_id, a.name
ORDER BY project_count DESC
LIMIT 20;
```

We won’t go too deep into aggregations yet, but you start seeing how joins + GROUP BY combine.

---

### 7️⃣ Practice Exercises (TODO Section)

At the bottom of the script, you have **TODO challenges**:

- Tasks + account name + project name + assignee name for tasks in progress.
- Time entries only for FinTech accounts.
- Users with counts of assigned tasks (including those with 0).
- Invoices with a flag based on project status.
- Projects with NO tasks at all.

You should implement these in the same file or a separate `03_day3_joins_exercises.sql`.

---

## 🧠 What You’ll Be Able to Say After Day 3

After mastering Day 3, you can honestly say:

> “I can confidently write joins across multiple tables in PostgreSQL, including INNER and LEFT joins. I can combine accounts, users, projects, tasks, time entries, and invoices to answer real business questions, and I understand how to detect missing relationships using LEFT JOIN ... IS NULL patterns.”

This is **core professional SQL**.

---

## 📁 Suggested Repository Structure After Day 3

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   └── 03_day3_joins.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    └── README_Day3.md
```

---

Next up, **Day 4** – we’ll turn these joins into **reporting & analytics queries** using `GROUP BY`, `HAVING`, and aggregations like `SUM`, `COUNT`, and `AVG`.
