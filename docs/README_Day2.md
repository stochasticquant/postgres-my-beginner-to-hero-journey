# 📅 Day 2 – Query Fundamentals & Data Exploration

## 🎯 Goal

On Day 2 you will become **fluent with basic SELECT queries** in PostgreSQL using pgAdmin:

- Explore all tables created on Day 1
- Filter rows with `WHERE`
- Sort results with `ORDER BY`
- Page through data with `LIMIT` and `OFFSET`
- Use simple expressions & functions to derive new columns

This day is about getting fully comfortable querying the `dev_portfolio` database.

---

## 📁 Files for Day 2

- `schema/02_day2_queries.sql`  
  Contains all Day 2 example queries, organized by topic.

You can create this file in your project and paste in the contents of the Day 2 script.

---

## 🧩 What You Work With

You’ll query the following tables filled with thousands of realistic rows:

- `accounts` – 100+ companies
- `users` – 500+ developers, managers, admins
- `projects` – 300+ projects over different industries
- `tasks` – ~3000 tasks with statuses, priorities, due dates
- `time_entries` – ~8000–10000 time logs
- `invoices` – a few hundred invoices with amounts & statuses

This gives you a **real-world feeling dataset** to practice on.

---

## 🧪 Step-by-Step Activities

### 1️⃣ Basic Exploration

Use simple `SELECT * FROM table LIMIT n` queries to get a feel for each table:

- Inspect all entities (accounts, users, projects, tasks, time_entries, invoices).
- Start noticing patterns: statuses, priorities, budgets, dates.

This builds intuition about the data model.

---

### 2️⃣ Selecting Columns & Aliases

You’ll learn to:

- Select specific columns instead of `*`
- Rename columns with `AS` (aliases)
- Add computed columns (e.g. project age in days)

Example:

```sql
SELECT
    project_id,
    name AS project_name,
    status,
    start_date,
    (CURRENT_DATE - start_date) AS project_age_days,
    budget_usd
FROM projects
LIMIT 20;
```

This is how you start shaping result sets for API responses or reports.

---

### 3️⃣ Filtering with WHERE

You’ll practice:

- Filtering by equality (e.g., `status = 'active'`)
- Comparing numeric values (`budget_usd > 150000`)
- Working with dates (`due_date < CURRENT_DATE`, ranges with `BETWEEN`)
- Filtering by boolean (`active = TRUE`)

Examples:

- Active users
- Overdue tasks
- High-budget projects
- Time entries with more than 6 hours logged

---

### 4️⃣ Advanced Filtering Patterns

You will apply:

- `IN` for multiple values
- `LIKE` for pattern matching
- `IS NULL` / `IS NOT NULL` for missing values

Example:

```sql
SELECT
    task_id,
    title,
    status,
    due_date
FROM tasks
WHERE due_date < CURRENT_DATE
  AND status <> 'done'
ORDER BY due_date;
```

These patterns appear all the time in backend and analytics work.

---

### 5️⃣ ORDER BY & Pagination (LIMIT/OFFSET)

You’ll learn to:

- Sort results by one or more columns
- Derive a priority ranking with `CASE`
- Page through results using `LIMIT` and `OFFSET`

Examples:

- Top 20 highest-budget projects  
- Next 20 highest-budget projects (page 2)  
- Sorting tasks by priority and due date  

This is very close to what’s done in real APIs (e.g., “fetch page 3 of tasks sorted by priority”).

---

### 6️⃣ Basic Expressions & Functions

You’ll start using simple expressions to enrich your results:

- String concatenation
- `COALESCE` to handle NULLs
- Date arithmetic (duration in days)
- `CASE` expressions to build human-readable labels

Example:

```sql
SELECT
    invoice_id,
    amount_usd,
    status,
    CASE status
        WHEN 'draft'   THEN 'Not sent to client yet'
        WHEN 'sent'    THEN 'Waiting for client payment'
        WHEN 'paid'    THEN 'Payment received'
        WHEN 'overdue' THEN 'Payment late – follow up needed'
        ELSE 'Unknown'
    END AS status_label
FROM invoices
ORDER BY invoice_id
LIMIT 40;
```

This skill is heavily used when building views, reports, and API responses.

---

### 7️⃣ Practice TODOs (Self-Guided)

At the end of the script, you’ll find commented **TODO queries** for you to design yourself, such as:

- List all active projects for FinTech accounts.
- Show the 50 most recently created tasks.
- Find all manager users at a specific email domain.
- List invoices due in the next 30 days.

You can write these queries in the same `02_day2_queries.sql` file or in a separate `02_day2_exercises.sql`.

---

## 🧠 What You’ll Be Able to Say After Day 2

On your CV or in an interview, after fully understanding Day 2 concepts, you can honestly say:

> “I am comfortable querying PostgreSQL databases using SELECT, WHERE, ORDER BY, and LIMIT/OFFSET. I can filter on dates, booleans, text patterns, and NULLs, as well as create derived columns using expressions and CASE logic. I’ve practiced these skills on a realistic, multi-table dataset.”

---

## 📁 Suggested Repository Structure After Day 2

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   └── 02_day2_queries.sql
└── docs/
    ├── README_Day1.md
    └── README_Day2.md
```

---

You’re now ready for **Day 3**, where we dive deep into **JOINs** and start combining tables to answer more complex, real-world questions.
