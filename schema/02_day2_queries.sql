------------------------------------------------------------
-- DAY 2 – QUERY FUNDAMENTALS & DATA EXPLORATION
-- Database: dev_portfolio
-- Focus:
--   - SELECT basics
--   - WHERE filtering
--   - ORDER BY sorting
--   - LIMIT/OFFSET pagination
--   - Basic expressions & functions
--
-- HOW TO USE:
--   1. Connect to the dev_portfolio database in pgAdmin.
--   2. Open Query Tool.
--   3. Run queries section by section.
--   4. Modify filters/limits to explore the data yourself.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – ARE WE IN THE RIGHT DATABASE?
------------------------------------------------------------
SELECT current_database() AS current_db;

------------------------------------------------------------
-- 1. SIMPLE SELECTS (BASIC DATA EXPLORATION)
------------------------------------------------------------

-- 1.1 View a few accounts
SELECT *
FROM accounts
LIMIT 10;

-- 1.2 View a few users
SELECT *
FROM users
LIMIT 10;

-- 1.3 View a few projects
SELECT *
FROM projects
LIMIT 10;

-- 1.4 View a few tasks
SELECT *
FROM tasks
LIMIT 10;

-- 1.5 View a few time entries
SELECT *
FROM time_entries
LIMIT 10;

-- 1.6 View a few invoices
SELECT *
FROM invoices
LIMIT 10;

------------------------------------------------------------
-- 2. SELECT SPECIFIC COLUMNS & USE ALIASES
------------------------------------------------------------

-- 2.1 Accounts: select only name & industry
SELECT
    account_id,
    name AS account_name,
    industry
FROM accounts
LIMIT 15;

-- 2.2 Users: focus on role & activity
SELECT
    user_id,
    full_name,
    email,
    role,
    active
FROM users
LIMIT 20;

-- 2.3 Projects: computed age in days
SELECT
    project_id,
    name AS project_name,
    status,
    start_date,
    (CURRENT_DATE - start_date) AS project_age_days,
    budget_usd
FROM projects
LIMIT 20;

------------------------------------------------------------
-- 3. FILTERING WITH WHERE
------------------------------------------------------------

-- 3.1 All active users
SELECT
    user_id,
    full_name,
    role,
    active
FROM users
WHERE active = TRUE
LIMIT 20;

-- 3.2 All inactive users (if any)
SELECT
    user_id,
    full_name,
    role,
    active
FROM users
WHERE active = FALSE;

-- 3.3 Projects with high budget (> 150,000 USD)
SELECT
    project_id,
    name,
    budget_usd
FROM projects
WHERE budget_usd > 150000
ORDER BY budget_usd DESC;

-- 3.4 Projects that are currently 'active'
SELECT
    project_id,
    name,
    status
FROM projects
WHERE status = 'active'
ORDER BY project_id
LIMIT 30;

-- 3.5 Tasks with critical priority
SELECT
    task_id,
    title,
    status,
    priority,
    due_date
FROM tasks
WHERE priority = 'critical'
ORDER BY due_date;

-- 3.6 Tasks due in the next 14 days
SELECT
    task_id,
    title,
    due_date,
    priority,
    status
FROM tasks
WHERE due_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '14 days')
ORDER BY due_date, priority;

-- 3.7 Tasks that are overdue (due_date in the past and not done)
SELECT
    task_id,
    title,
    status,
    due_date
FROM tasks
WHERE due_date < CURRENT_DATE
  AND status <> 'done'
ORDER BY due_date;

-- 3.8 Time entries with more than 6 hours logged
SELECT
    time_entry_id,
    task_id,
    user_id,
    work_date,
    hours_spent
FROM time_entries
WHERE hours_spent > 6
ORDER BY work_date DESC;

-- 3.9 Invoices that are 'overdue'
SELECT
    invoice_id,
    account_id,
    project_id,
    issue_date,
    due_date,
    amount_usd,
    status
FROM invoices
WHERE status = 'overdue'
ORDER BY due_date ASC;

------------------------------------------------------------
-- 4. IN, LIKE, IS NULL, AND OTHER FILTER PATTERNS
------------------------------------------------------------

-- 4.1 Filter accounts by industry using IN
SELECT
    account_id,
    name,
    industry
FROM accounts
WHERE industry IN ('FinTech', 'E-commerce')
ORDER BY industry, name
LIMIT 30;

-- 4.2 Find users by email domain pattern using LIKE
SELECT
    user_id,
    full_name,
    email,
    role
FROM users
WHERE email LIKE '%@example.com'
ORDER BY user_id
LIMIT 50;

-- 4.3 Tasks without a due date (IS NULL)
SELECT
    task_id,
    title,
    status,
    due_date
FROM tasks
WHERE due_date IS NULL
ORDER BY task_id
LIMIT 50;

-- 4.4 Tasks with a due date (IS NOT NULL)
SELECT
    task_id,
    title,
    status,
    due_date
FROM tasks
WHERE due_date IS NOT NULL
ORDER BY due_date
LIMIT 50;

------------------------------------------------------------
-- 5. ORDER BY & PAGINATION (LIMIT/OFFSET)
------------------------------------------------------------

-- 5.1 Top 20 highest-budget projects
SELECT
    project_id,
    name,
    budget_usd,
    status
FROM projects
ORDER BY budget_usd DESC
LIMIT 20;

-- 5.2 Next 20 highest-budget projects (page 2)
SELECT
    project_id,
    name,
    budget_usd,
    status
FROM projects
ORDER BY budget_usd DESC
LIMIT 20
OFFSET 20;

-- 5.3 Sort users by created_at (newest first)
SELECT
    user_id,
    full_name,
    email,
    created_at
FROM users
ORDER BY created_at DESC
LIMIT 20;

-- 5.4 Sort tasks by priority (critical first), then by due_date
-- (We simulate priority ranking via a CASE expression)
SELECT
    task_id,
    title,
    priority,
    due_date
FROM tasks
ORDER BY
    CASE priority
        WHEN 'critical' THEN 1
        WHEN 'high'     THEN 2
        WHEN 'medium'   THEN 3
        WHEN 'low'      THEN 4
        ELSE 5
    END,
    due_date NULLS LAST
LIMIT 50;

------------------------------------------------------------
-- 6. BASIC EXPRESSIONS & FUNCTIONS
------------------------------------------------------------

-- 6.1 Build a nicer label for accounts
SELECT
    account_id,
    name,
    industry,
    name || ' (' || COALESCE(industry, 'Unknown industry') || ')' AS account_label
FROM accounts
LIMIT 20;

-- 6.2 Calculate approximate project duration in days (where end_date is known)
SELECT
    project_id,
    name,
    start_date,
    end_date,
    (end_date - start_date) AS duration_days
FROM projects
WHERE end_date IS NOT NULL
ORDER BY duration_days DESC
LIMIT 20;

-- 6.3 Show hours_spent as integer and decimal
SELECT
    time_entry_id,
    task_id,
    user_id,
    work_date,
    hours_spent,
    floor(hours_spent) AS hours_floor,
    round(hours_spent, 1) AS hours_rounded
FROM time_entries
ORDER BY work_date DESC
LIMIT 30;

-- 6.4 Create a simple "status label" for invoices using CASE
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

-- 6.5 Estimate cost of time entries assuming a flat hourly rate (e.g., 50 USD/hour)
SELECT
    time_entry_id,
    task_id,
    user_id,
    work_date,
    hours_spent,
    (hours_spent * 50) AS estimated_cost_usd
FROM time_entries
ORDER BY work_date DESC
LIMIT 40;

------------------------------------------------------------
-- 7. PRACTICE QUERIES (TRY MODIFYING THESE YOURSELF)
------------------------------------------------------------

-- 7.1 TODO:
-- List all 'active' projects for 'FinTech' accounts only.
-- Hint: you will need a JOIN between projects and accounts
-- and a WHERE filter on industry='FinTech' and status='active'.

-- 7.2 TODO:
-- Find the top 10 accounts with the highest total invoice amount.
-- (Later days will introduce GROUP BY; for now, just think about the problem.)

-- 7.3 TODO:
-- List the 50 most recently created tasks, ordered by created_at.

-- 7.4 TODO:
-- Show all 'manager' users whose email ends with '@example.com'.

-- 7.5 TODO:
-- List all invoices due in the next 30 days, sorted by due_date.
