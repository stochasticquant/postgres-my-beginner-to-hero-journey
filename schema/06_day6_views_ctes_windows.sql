------------------------------------------------------------
-- DAY 6 – VIEWS, CTEs & WINDOW FUNCTIONS
-- Database: dev_portfolio
-- Focus:
--   - Creating reusable VIEWS for reporting
--   - Using CTEs (WITH) to structure complex queries
--   - Using WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK, SUM OVER, AVG OVER)
--
-- HOW TO USE:
--   1. Connect to the dev_portfolio database in pgAdmin.
--   2. Open Query Tool.
--   3. Run this script section by section.
--   4. Inspect created views under: Schemas -> public -> Views.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – CURRENT DB
------------------------------------------------------------
SELECT current_database() AS current_db;

------------------------------------------------------------
-- 1. CREATE REUSABLE VIEWS
------------------------------------------------------------
-- We will create:
--   - dev_hours_per_project
--   - dev_hours_per_account
--   - project_summary_view
------------------------------------------------------------

-- 1.1 View: total hours per project
DROP VIEW IF EXISTS dev_hours_per_project;
CREATE VIEW dev_hours_per_project AS
SELECT
    p.project_id,
    p.name                    AS project_name,
    a.account_id,
    a.name                    AS account_name,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    COUNT(DISTINCT t.task_id) AS task_count
FROM projects p
JOIN accounts a
    ON p.account_id = a.account_id
LEFT JOIN tasks t
    ON p.project_id = t.project_id
LEFT JOIN time_entries te
    ON t.task_id = te.task_id
GROUP BY p.project_id, p.name, a.account_id, a.name;

-- Quick preview
SELECT * FROM dev_hours_per_project
ORDER BY total_hours DESC
LIMIT 20;


-- 1.2 View: total hours per account
DROP VIEW IF EXISTS dev_hours_per_account;
CREATE VIEW dev_hours_per_account AS
SELECT
    a.account_id,
    a.name                    AS account_name,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    COUNT(DISTINCT p.project_id)     AS project_count,
    COUNT(DISTINCT t.task_id)        AS task_count
FROM accounts a
LEFT JOIN projects p
    ON a.account_id = p.account_id
LEFT JOIN tasks t
    ON p.project_id = t.project_id
LEFT JOIN time_entries te
    ON t.task_id = te.task_id
GROUP BY a.account_id, a.name;

-- Quick preview
SELECT * FROM dev_hours_per_account
ORDER BY total_hours DESC
LIMIT 20;


-- 1.3 View: project summary with invoices
DROP VIEW IF EXISTS project_summary_view;
CREATE VIEW project_summary_view AS
SELECT
    p.project_id,
    p.name                    AS project_name,
    a.account_id,
    a.name                    AS account_name,
    p.status                  AS project_status,
    p.budget_usd,
    COALESCE(SUM(DISTINCT i.amount_usd) FILTER (WHERE i.status IN ('sent','paid','overdue')), 0) AS invoiced_amount,
    COALESCE(SUM(DISTINCT i.amount_usd) FILTER (WHERE i.status = 'paid'), 0) AS paid_amount
FROM projects p
JOIN accounts a
    ON p.account_id = a.account_id
LEFT JOIN invoices i
    ON p.project_id = i.project_id
GROUP BY p.project_id, p.name, a.account_id, a.name, p.status, p.budget_usd;

-- Quick preview
SELECT * FROM project_summary_view
ORDER BY invoiced_amount DESC
LIMIT 20;

------------------------------------------------------------
-- 2. CTEs (COMMON TABLE EXPRESSIONS)
------------------------------------------------------------
-- CTEs (WITH ...) help structure complex queries.
------------------------------------------------------------

-- 2.1 CTE example: break down account, project, and hours
WITH project_hours AS (
    SELECT
        p.project_id,
        p.name            AS project_name,
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
        a.name                   AS account_name,
        COUNT(ph.project_id)     AS project_count,
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


-- 2.2 CTE with filtering: only accounts with > 200 total hours
WITH project_hours AS (
    SELECT
        p.project_id,
        p.account_id,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.account_id
),
account_summary AS (
    SELECT
        a.account_id,
        a.name                   AS account_name,
        COUNT(ph.project_id)     AS project_count,
        COALESCE(SUM(ph.total_hours), 0) AS total_hours
    FROM accounts a
    LEFT JOIN project_hours ph
        ON a.account_id = ph.account_id
    GROUP BY a.account_id, a.name
)
SELECT *
FROM account_summary
WHERE total_hours > 200
ORDER BY total_hours DESC;


-- 2.3 CTE to find the top 5 busiest projects per account by hours
WITH project_hours AS (
    SELECT
        p.project_id,
        p.name         AS project_name,
        p.account_id,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.name, p.account_id
),
ranked_projects AS (
    SELECT
        ph.*,
        RANK() OVER (PARTITION BY ph.account_id ORDER BY ph.total_hours DESC) AS project_rank
    FROM project_hours ph
)
SELECT *
FROM ranked_projects
WHERE project_rank <= 5
ORDER BY account_id, project_rank;

------------------------------------------------------------
-- 3. WINDOW FUNCTIONS – ANALYTICAL QUERIES
------------------------------------------------------------
-- We'll use:
--   - ROW_NUMBER()
--   - RANK(), DENSE_RANK()
--   - SUM() OVER (...)
--   - AVG() OVER (...)
------------------------------------------------------------

-- 3.1 Rank developers by total hours (overall)
SELECT
    u.user_id,
    u.full_name AS developer_name,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    RANK() OVER (ORDER BY COALESCE(SUM(te.hours_spent), 0) DESC) AS hours_rank,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(te.hours_spent), 0) DESC) AS hours_dense_rank
FROM users u
LEFT JOIN time_entries te
    ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC
LIMIT 50;

-- 3.2 Rank developers by hours within each account
SELECT
    a.account_id,
    a.name        AS account_name,
    u.user_id,
    u.full_name   AS developer_name,
    COALESCE(SUM(te.hours_spent), 0) AS total_hours,
    RANK() OVER (PARTITION BY a.account_id ORDER BY COALESCE(SUM(te.hours_spent), 0) DESC) AS rank_in_account
FROM accounts a
JOIN users u
    ON a.account_id = u.account_id
LEFT JOIN time_entries te
    ON u.user_id = te.user_id
GROUP BY a.account_id, a.name, u.user_id, u.full_name
ORDER BY a.account_id, rank_in_account
LIMIT 100;

-- 3.3 Running total of hours per user over time
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
    ON u.user_id = te.user_id
ORDER BY u.user_id, te.work_date
LIMIT 200;

-- 3.4 Average hours per day per user, plus comparison to overall average
WITH daily_user_hours AS (
    SELECT
        u.user_id,
        u.full_name   AS developer_name,
        te.work_date,
        SUM(te.hours_spent) AS daily_hours
    FROM users u
    JOIN time_entries te
        ON u.user_id = te.user_id
    GROUP BY u.user_id, u.full_name, te.work_date
)
SELECT
    user_id,
    developer_name,
    work_date,
    daily_hours,
    AVG(daily_hours) OVER (PARTITION BY user_id)      AS avg_daily_for_user,
    AVG(daily_hours) OVER ()                          AS avg_daily_overall
FROM daily_user_hours
ORDER BY developer_name, work_date
LIMIT 200;

-- 3.5 Project hours with percentage of account total
WITH project_hours AS (
    SELECT
        p.project_id,
        p.name        AS project_name,
        p.account_id,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours
    FROM projects p
    LEFT JOIN tasks t
        ON p.project_id = t.project_id
    LEFT JOIN time_entries te
        ON t.task_id = te.task_id
    GROUP BY p.project_id, p.name, p.account_id
)
SELECT
    ph.project_id,
    ph.project_name,
    a.name AS account_name,
    ph.total_hours,
    SUM(ph.total_hours) OVER (PARTITION BY ph.account_id) AS account_total_hours,
    CASE
        WHEN SUM(ph.total_hours) OVER (PARTITION BY ph.account_id) = 0 THEN 0
        ELSE ROUND(
            100.0 * ph.total_hours
            / SUM(ph.total_hours) OVER (PARTITION BY ph.account_id),
            2
        )
    END AS pct_of_account_hours
FROM project_hours ph
JOIN accounts a
    ON ph.account_id = a.account_id
ORDER BY a.account_id, ph.total_hours DESC
LIMIT 200;

------------------------------------------------------------
-- 4. PRACTICE EXERCISES (TODO)
------------------------------------------------------------

-- 4.1 TODO:
-- Create a view `developer_hours_summary` with:
--   - user_id, developer_name
--   - total_hours
--   - number_of_tasks_worked_on
--   - number_of_projects_worked_on

-- 4.2 TODO:
-- Using that view, write a query that ranks developers by total_hours
-- and shows only the top 10.

-- 4.3 TODO:
-- Write a CTE that:
--   - Calculates total hours per project
--   - Calculates average project hours across all projects
--   - Returns only projects where total_hours > average

-- 4.4 TODO:
-- Use a window function to:
--   - Show each invoice with its amount
--   - Show total invoice amount per account (as a window sum)
--   - Show what percentage of the account's invoice total this invoice represents.

-- 4.5 TODO:
-- Using a CTE and window functions, list for each account:
--   - its projects ordered by total_hours
--   - a rank
--   - a cumulative percentage of hours (like a Pareto chart data source).
