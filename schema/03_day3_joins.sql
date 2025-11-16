------------------------------------------------------------
-- DAY 3 – JOINS & RELATIONSHIPS
-- Database: dev_portfolio
-- Focus:
--   - Understanding relationships between tables
--   - INNER JOIN and LEFT JOIN
--   - Multi-table joins across the full schema
--   - Practical queries combining accounts, users, projects, tasks, time entries, invoices
--
-- HOW TO USE:
--   1. Connect to the dev_portfolio database in pgAdmin.
--   2. Open Query Tool.
--   3. Run queries section by section.
--   4. Modify filters and columns to explore on your own.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – CURRENT DB & QUICK COUNTS
------------------------------------------------------------
SELECT current_database() AS current_db;

SELECT 'accounts' AS table, count(*) FROM accounts
UNION ALL SELECT 'users', count(*) FROM users
UNION ALL SELECT 'projects', count(*) FROM projects
UNION ALL SELECT 'tasks', count(*) FROM tasks
UNION ALL SELECT 'time_entries', count(*) FROM time_entries
UNION ALL SELECT 'invoices', count(*) FROM invoices;

------------------------------------------------------------
-- 1. BASIC ONE-TO-MANY JOINS
------------------------------------------------------------

-- 1.1 Accounts and their users (one account -> many users)
SELECT
    a.account_id,
    a.name          AS account_name,
    a.industry,
    u.user_id,
    u.full_name,
    u.role
FROM accounts a
JOIN users u
    ON a.account_id = u.account_id
ORDER BY a.account_id, u.user_id
LIMIT 50;

-- 1.2 Accounts and their projects
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

-- 1.3 Projects and their tasks
SELECT
    p.project_id,
    p.name          AS project_name,
    t.task_id,
    t.title         AS task_title,
    t.status        AS task_status,
    t.priority
FROM projects p
JOIN tasks t
    ON p.project_id = t.project_id
ORDER BY p.project_id, t.task_id
LIMIT 50;

------------------------------------------------------------
-- 2. JOINING THREE TABLES
------------------------------------------------------------

-- 2.1 Tasks with project and account information
SELECT
    t.task_id,
    t.title           AS task_title,
    t.status          AS task_status,
    t.priority,
    p.project_id,
    p.name            AS project_name,
    p.status          AS project_status,
    a.account_id,
    a.name            AS account_name,
    a.industry
FROM tasks t
JOIN projects p
    ON t.project_id = p.project_id
JOIN accounts a
    ON p.account_id = a.account_id
ORDER BY a.account_id, p.project_id, t.task_id
LIMIT 100;

-- 2.2 Tasks with assignee (user) and account
SELECT
    t.task_id,
    t.title           AS task_title,
    t.status          AS task_status,
    t.priority,
    u.user_id,
    u.full_name       AS assignee_name,
    u.role            AS assignee_role,
    a.account_id,
    a.name            AS account_name
FROM tasks t
JOIN users u
    ON t.assignee_id = u.user_id
JOIN accounts a
    ON u.account_id = a.account_id
ORDER BY a.account_id, u.user_id, t.task_id
LIMIT 100;

------------------------------------------------------------
-- 3. TIME ENTRIES ACROSS TASKS, PROJECTS, USERS, ACCOUNTS
------------------------------------------------------------

-- 3.1 Time entries with task & user info
SELECT
    te.time_entry_id,
    te.work_date,
    te.hours_spent,
    te.notes,
    t.task_id,
    t.title         AS task_title,
    u.user_id,
    u.full_name     AS developer_name
FROM time_entries te
JOIN tasks t
    ON te.task_id = t.task_id
JOIN users u
    ON te.user_id = u.user_id
ORDER BY te.work_date DESC, te.time_entry_id
LIMIT 100;

-- 3.2 Time entries with project & account info (4-way join)
SELECT
    te.time_entry_id,
    te.work_date,
    te.hours_spent,
    t.task_id,
    t.title         AS task_title,
    p.project_id,
    p.name          AS project_name,
    a.account_id,
    a.name          AS account_name
FROM time_entries te
JOIN tasks t
    ON te.task_id = t.task_id
JOIN projects p
    ON t.project_id = p.project_id
JOIN accounts a
    ON p.account_id = a.account_id
ORDER BY te.work_date DESC, te.time_entry_id
LIMIT 100;

-- 3.3 Time entries with project, account, and developer information
SELECT
    te.time_entry_id,
    te.work_date,
    te.hours_spent,
    u.user_id,
    u.full_name        AS developer_name,
    p.project_id,
    p.name             AS project_name,
    a.account_id,
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

------------------------------------------------------------
-- 4. INVOICES WITH PROJECTS & ACCOUNTS
------------------------------------------------------------

-- 4.1 Invoices with account & project info
SELECT
    i.invoice_id,
    i.issue_date,
    i.due_date,
    i.amount_usd,
    i.status         AS invoice_status,
    a.account_id,
    a.name           AS account_name,
    p.project_id,
    p.name           AS project_name,
    p.status         AS project_status
FROM invoices i
JOIN accounts a
    ON i.account_id = a.account_id
LEFT JOIN projects p
    ON i.project_id = p.project_id
ORDER BY i.invoice_id
LIMIT 100;

-- 4.2 Overdue invoices with their client and (optional) project
SELECT
    i.invoice_id,
    i.amount_usd,
    i.due_date,
    a.name          AS account_name,
    p.name          AS project_name
FROM invoices i
JOIN accounts a
    ON i.account_id = a.account_id
LEFT JOIN projects p
    ON i.project_id = p.project_id
WHERE i.status = 'overdue'
ORDER BY i.due_date;

------------------------------------------------------------
-- 5. LEFT JOINS – INCLUDING 'ORPHAN' ROWS
------------------------------------------------------------

-- 5.1 All accounts, including those without any projects (LEFT JOIN)
SELECT
    a.account_id,
    a.name          AS account_name,
    a.industry,
    p.project_id,
    p.name          AS project_name,
    p.status        AS project_status
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
ORDER BY a.account_id, p.project_id NULLS LAST
LIMIT 100;

-- 5.2 All projects, including those without any tasks
SELECT
    p.project_id,
    p.name          AS project_name,
    p.status        AS project_status,
    t.task_id,
    t.title         AS task_title,
    t.status        AS task_status
FROM projects p
LEFT JOIN tasks t
    ON p.project_id = t.project_id
ORDER BY p.project_id, t.task_id NULLS LAST
LIMIT 100;

-- 5.3 All users, including those not assigned to any tasks
SELECT
    u.user_id,
    u.full_name     AS user_name,
    u.role,
    t.task_id,
    t.title         AS task_title,
    t.status        AS task_status
FROM users u
LEFT JOIN tasks t
    ON u.user_id = t.assignee_id
ORDER BY u.user_id, t.task_id NULLS LAST
LIMIT 100;

------------------------------------------------------------
-- 6. PREVIEW: SIMPLE COUNTS WITH GROUP BY (TEASER FOR DAY 4)
------------------------------------------------------------

-- 6.1 How many users per account?
SELECT
    a.account_id,
    a.name          AS account_name,
    COUNT(u.user_id) AS user_count
FROM accounts a
LEFT JOIN users u
    ON a.account_id = u.account_id
GROUP BY a.account_id, a.name
ORDER BY user_count DESC, a.account_id
LIMIT 20;

-- 6.2 How many projects per account?
SELECT
    a.account_id,
    a.name           AS account_name,
    COUNT(p.project_id) AS project_count
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
GROUP BY a.account_id, a.name
ORDER BY project_count DESC, a.account_id
LIMIT 20;

-- 6.3 How many tasks per project?
SELECT
    p.project_id,
    p.name           AS project_name,
    COUNT(t.task_id) AS task_count
FROM projects p
LEFT JOIN tasks t
    ON p.project_id = t.project_id
GROUP BY p.project_id, p.name
ORDER BY task_count DESC, p.project_id
LIMIT 20;

------------------------------------------------------------
-- 7. PRACTICE EXERCISES (TODO – WRITE YOUR OWN JOINS)
------------------------------------------------------------

-- 7.1 TODO:
-- List all tasks with their account name, project name, and assignee name.
-- Only include tasks with status 'in_progress'.

-- 7.2 TODO:
-- Show all time entries for 'FinTech' accounts only, including:
--   - account name
--   - project name
--   - task title
--   - developer name
--   - work_date and hours_spent

-- 7.3 TODO:
-- List all users and how many tasks they are assigned to (including users with 0 tasks).
-- Hint: LEFT JOIN users to tasks, then GROUP BY user.

-- 7.4 TODO:
-- Show all invoices with:
--   - account name
--   - project name (if any)
--   - a flag indicating whether the project is 'active' or not.

-- 7.5 TODO:
-- List all projects that currently have NO tasks associated with them.
-- Hint: LEFT JOIN projects to tasks and filter where t.task_id IS NULL.
