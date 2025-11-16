------------------------------------------------------------
-- DAY 4 – AGGREGATIONS & REPORTING (GROUP BY, HAVING)
-- Database: dev_portfolio
-- Focus:
--   - Aggregate functions: COUNT, SUM, AVG, MIN, MAX
--   - GROUP BY on one and multiple columns
--   - HAVING to filter aggregated results
--   - Simple subqueries for reporting
--
-- HOW TO USE:
--   1. Connect to the dev_portfolio database in pgAdmin.
--   2. Open Query Tool.
--   3. Run queries section by section.
--   4. Tweak filters, GROUP BY columns, and add your own metrics.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – CURRENT DB
------------------------------------------------------------
SELECT current_database() AS current_db;

------------------------------------------------------------
-- 1. BASIC AGGREGATIONS (NO GROUP BY)
------------------------------------------------------------

-- 1.1 Total number of rows per table (fast overview)
SELECT 'accounts' AS table, count(*) FROM accounts
UNION ALL SELECT 'users', count(*) FROM users
UNION ALL SELECT 'projects', count(*) FROM projects
UNION ALL SELECT 'tasks', count(*) FROM tasks
UNION ALL SELECT 'time_entries', count(*) FROM time_entries
UNION ALL SELECT 'invoices', count(*) FROM invoices;

-- 1.2 Global aggregates on numeric columns
SELECT
    COUNT(*)                     AS total_projects,
    MIN(budget_usd)              AS min_budget,
    MAX(budget_usd)              AS max_budget,
    AVG(budget_usd)              AS avg_budget,
    SUM(budget_usd)              AS sum_budget
FROM projects;

SELECT
    COUNT(*)                     AS total_invoices,
    MIN(amount_usd)              AS min_invoice_amount,
    MAX(amount_usd)              AS max_invoice_amount,
    AVG(amount_usd)              AS avg_invoice_amount,
    SUM(amount_usd)              AS total_invoice_amount
FROM invoices;

------------------------------------------------------------
-- 2. GROUP BY – SIMPLE REPORTS
------------------------------------------------------------

-- 2.1 Number of accounts per industry
SELECT
    industry,
    COUNT(*) AS account_count
FROM accounts
GROUP BY industry
ORDER BY account_count DESC;

-- 2.2 Number of users per role
SELECT
    role,
    COUNT(*) AS user_count
FROM users
GROUP BY role
ORDER BY user_count DESC;

-- 2.3 Number of projects per status
SELECT
    status,
    COUNT(*) AS project_count
FROM projects
GROUP BY status
ORDER BY project_count DESC;

-- 2.4 Average budget per project status
SELECT
    status,
    COUNT(*)        AS project_count,
    AVG(budget_usd) AS avg_budget,
    SUM(budget_usd) AS total_budget
FROM projects
GROUP BY status
ORDER BY total_budget DESC;

------------------------------------------------------------
-- 3. GROUP BY WITH JOINS
------------------------------------------------------------

-- 3.1 Number of users per account (with account names)
SELECT
    a.account_id,
    a.name              AS account_name,
    COUNT(u.user_id)    AS user_count
FROM accounts a
LEFT JOIN users u
    ON a.account_id = u.account_id
GROUP BY a.account_id, a.name
ORDER BY user_count DESC, a.account_id
LIMIT 30;

-- 3.2 Number of projects per account, and total project budget
SELECT
    a.account_id,
    a.name              AS account_name,
    COUNT(p.project_id) AS project_count,
    COALESCE(SUM(p.budget_usd), 0) AS total_budget
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
GROUP BY a.account_id, a.name
ORDER BY project_count DESC, total_budget DESC
LIMIT 30;

-- 3.3 Number of tasks per project (top 30 by task count)
SELECT
    p.project_id,
    p.name              AS project_name,
    COUNT(t.task_id)    AS task_count
FROM projects p
LEFT JOIN tasks t
    ON p.project_id = t.project_id
GROUP BY p.project_id, p.name
ORDER BY task_count DESC, p.project_id
LIMIT 30;

-- 3.4 Total hours logged per project
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

-- 3.5 Total hours logged per user (developer workload)
SELECT
    u.user_id,
    u.full_name         AS developer_name,
    SUM(te.hours_spent) AS total_hours
FROM users u
JOIN time_entries te
    ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC
LIMIT 30;

------------------------------------------------------------
-- 4. HAVING – FILTERING GROUPED RESULTS
------------------------------------------------------------

-- 4.1 Only accounts with more than 10 users
SELECT
    a.account_id,
    a.name              AS account_name,
    COUNT(u.user_id)    AS user_count
FROM accounts a
LEFT JOIN users u
    ON a.account_id = u.account_id
GROUP BY a.account_id, a.name
HAVING COUNT(u.user_id) > 10
ORDER BY user_count DESC;

-- 4.2 Only projects with more than 50 tasks
SELECT
    p.project_id,
    p.name              AS project_name,
    COUNT(t.task_id)    AS task_count
FROM projects p
LEFT JOIN tasks t
    ON p.project_id = t.project_id
GROUP BY p.project_id, p.name
HAVING COUNT(t.task_id) > 50
ORDER BY task_count DESC;

-- 4.3 Only users who have logged more than 100 hours
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

-- 4.4 Only accounts whose total invoice value exceeds 100,000
SELECT
    a.account_id,
    a.name              AS account_name,
    SUM(i.amount_usd)   AS total_invoice_amount
FROM accounts a
JOIN invoices i
    ON a.account_id = i.account_id
GROUP BY a.account_id, a.name
HAVING SUM(i.amount_usd) > 100000
ORDER BY total_invoice_amount DESC;

------------------------------------------------------------
-- 5. ANALYTICAL REPORTS COMBINING MANY TABLES
------------------------------------------------------------

-- 5.1 Account-level summary:
--      - number of projects
--      - number of tasks
--      - total logged hours
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
ORDER BY total_hours DESC, project_count DESC
LIMIT 30;

-- 5.2 Project-level summary:
--      - account name
--      - number of tasks
--      - total hours logged
--      - average hours per task
SELECT
    p.project_id,
    p.name                      AS project_name,
    a.name                      AS account_name,
    COUNT(DISTINCT t.task_id)   AS task_count,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    CASE
        WHEN COUNT(DISTINCT t.task_id) = 0 THEN 0
        ELSE COALESCE(SUM(te.hours_spent), 0) / COUNT(DISTINCT t.task_id)
    END                         AS avg_hours_per_task
FROM projects p
JOIN accounts a
    ON p.account_id = a.account_id
LEFT JOIN tasks t
    ON p.project_id = t.project_id
LEFT JOIN time_entries te
    ON t.task_id = te.task_id
GROUP BY p.project_id, p.name, a.name
ORDER BY total_hours DESC
LIMIT 30;

-- 5.3 Developer-level summary:
--      - total hours
--      - number of tasks they touched
--      - distinct projects
SELECT
    u.user_id,
    u.full_name                    AS developer_name,
    COUNT(DISTINCT t.task_id)      AS tasks_worked_on,
    COUNT(DISTINCT p.project_id)   AS projects_worked_on,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours
FROM users u
LEFT JOIN time_entries te
    ON u.user_id = te.user_id
LEFT JOIN tasks t
    ON te.task_id = t.task_id
LEFT JOIN projects p
    ON t.project_id = p.project_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC, tasks_worked_on DESC
LIMIT 30;

-- 5.4 Invoice & revenue summary per account
SELECT
    a.account_id,
    a.name                    AS account_name,
    COUNT(i.invoice_id)       AS invoice_count,
    SUM(i.amount_usd)         AS total_invoiced,
    SUM(
        CASE WHEN i.status = 'paid' THEN i.amount_usd ELSE 0 END
    )                         AS total_paid,
    SUM(
        CASE WHEN i.status = 'overdue' THEN i.amount_usd ELSE 0 END
    )                         AS total_overdue
FROM accounts a
LEFT JOIN invoices i
    ON a.account_id = i.account_id
GROUP BY a.account_id, a.name
ORDER BY total_invoiced DESC NULLS LAST
LIMIT 30;

------------------------------------------------------------
-- 6. SIMPLE SUBQUERIES
------------------------------------------------------------

-- 6.1 Projects whose total logged hours exceed the average total hours of all projects
-- Step 1 (conceptually): compute total hours per project
-- Step 2: compute the average of those totals
-- Step 3: filter to projects above that average
--
-- In one query using a subquery:
SELECT
    project_id,
    project_name,
    total_hours
FROM (
    SELECT
        p.project_id,
        p.name                      AS project_name,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.name
) project_hours
WHERE total_hours >
    (
        SELECT AVG(total_hours)
        FROM (
            SELECT
                p2.project_id,
                COALESCE(SUM(te2.hours_spent), 0) AS total_hours
            FROM projects p2
            LEFT JOIN tasks t2
                ON p2.project_id = t2.project_id
            LEFT JOIN time_entries te2
                ON t2.task_id = te2.task_id
            GROUP BY p2.project_id
        ) ph2
    )
ORDER BY total_hours DESC
LIMIT 30;

-- 6.2 Users whose total logged hours is above the average user total
SELECT
    user_id,
    developer_name,
    total_hours
FROM (
    SELECT
        u.user_id,
        u.full_name             AS developer_name,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM users u
    LEFT JOIN time_entries te
        ON u.user_id = te.user_id
    GROUP BY u.user_id, u.full_name
) user_hours
WHERE total_hours >
    (
        SELECT AVG(total_hours)
        FROM (
            SELECT
                u2.user_id,
                COALESCE(SUM(te2.hours_spent), 0) AS total_hours
            FROM users u2
            LEFT JOIN time_entries te2
                ON u2.user_id = te2.user_id
            GROUP BY u2.user_id
        ) uh2
    )
ORDER BY total_hours DESC
LIMIT 30;

------------------------------------------------------------
-- 7. PRACTICE EXERCISES (TODO)
------------------------------------------------------------

-- 7.1 TODO:
-- For each industry, compute:
--   - account_count
--   - project_count
--   - total_invoice_amount
--      (hint: join accounts to projects & invoices and GROUP BY industry)

-- 7.2 TODO:
-- For each project status ('planned','active','on_hold','completed'), compute:
--   - number of projects
--   - total hours logged
--   - average hours per project
--   Use GROUP BY status and LEFT JOIN to tasks/time_entries.

-- 7.3 TODO:
-- Find the top 10 accounts by total logged hours,
-- but only include accounts with more than 5 projects.
-- Hint: HAVING + COUNT(DISTINCT project_id).

-- 7.4 TODO:
-- For each developer, compute:
--   - total hours
--   - total invoice amount for projects they worked on
--   (hint: join users -> time_entries -> tasks -> projects -> invoices, then GROUP BY user).

-- 7.5 TODO:
-- List projects that have NO time entries at all
-- (even if they have tasks). Show account name, project name, task_count.
-- Hint: use LEFT JOIN to time_entries and HAVING SUM(hours_spent) IS NULL or = 0.
