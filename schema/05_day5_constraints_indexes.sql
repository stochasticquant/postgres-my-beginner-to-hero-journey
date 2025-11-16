------------------------------------------------------------
-- DAY 5 – CONSTRAINTS, INDEXES & DATA INTEGRITY
-- Database: dev_portfolio
-- Focus:
--   - Strengthening data integrity with constraints
--   - Adding realistic business rules using CHECK & UNIQUE
--   - Creating indexes for joins and common filters
--   - Inspecting constraints and indexes
--
-- HOW TO USE:
--   1. Connect to the dev_portfolio database in pgAdmin.
--   2. Open Query Tool.
--   3. Run this script top-to-bottom once.
--   4. Use pgAdmin GUI to inspect constraints and indexes visually.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – CURRENT DB
------------------------------------------------------------
SELECT current_database() AS current_db;

------------------------------------------------------------
-- 1. ADDING / REFINING CONSTRAINTS
------------------------------------------------------------
-- We will:
--  - Enforce unique project names per account
--  - Enforce unique task titles per project
--  - Add additional CHECK constraints for data quality
------------------------------------------------------------

-- 1.1 Ensure project names are unique within an account
--     i.e., an account cannot have two projects with the same name
ALTER TABLE projects
    ADD CONSTRAINT projects_account_name_uniq
    UNIQUE (account_id, name);

-- 1.2 Ensure task titles are unique per project
--     i.e., within the same project, each task title must be unique
ALTER TABLE tasks
    ADD CONSTRAINT tasks_project_title_uniq
    UNIQUE (project_id, title);

-- 1.3 Enforce that estimated_hours on tasks must be > 0 (if not null)
ALTER TABLE tasks
    ADD CONSTRAINT tasks_estimated_hours_positive_chk
    CHECK (estimated_hours IS NULL OR estimated_hours > 0);

-- 1.4 Enforce that a time entry cannot have more than 24 hours in a single row
ALTER TABLE time_entries
    ADD CONSTRAINT time_entries_max_24_hours_chk
    CHECK (hours_spent > 0 AND hours_spent <= 24);

-- 1.5 Enforce that invoice due_date is not before issue_date
ALTER TABLE invoices
    ADD CONSTRAINT invoices_due_after_issue_chk
    CHECK (due_date >= issue_date);

-- 1.6 Enforce that invoice amount is non-negative (already in table, but redundant check is okay)
ALTER TABLE invoices
    ADD CONSTRAINT invoices_amount_non_negative_chk
    CHECK (amount_usd >= 0);

------------------------------------------------------------
-- 2. CREATING INDEXES FOR PERFORMANCE
------------------------------------------------------------
-- We will create indexes for:
--   - Foreign keys (common join columns)
--   - Commonly filtered columns (status, priority, dates)
--   - Composite indexes that match real query patterns
------------------------------------------------------------

-- 2.1 Indexes on foreign keys (helps JOIN performance)

CREATE INDEX IF NOT EXISTS idx_users_account_id
    ON users(account_id);

CREATE INDEX IF NOT EXISTS idx_projects_account_id
    ON projects(account_id);

CREATE INDEX IF NOT EXISTS idx_tasks_project_id
    ON tasks(project_id);

CREATE INDEX IF NOT EXISTS idx_tasks_assignee_id
    ON tasks(assignee_id);

CREATE INDEX IF NOT EXISTS idx_time_entries_task_id
    ON time_entries(task_id);

CREATE INDEX IF NOT EXISTS idx_time_entries_user_id
    ON time_entries(user_id);

CREATE INDEX IF NOT EXISTS idx_invoices_account_id
    ON invoices(account_id);

CREATE INDEX IF NOT EXISTS idx_invoices_project_id
    ON invoices(project_id);

-- 2.2 Indexes for common filter patterns

-- Projects filtered by status
CREATE INDEX IF NOT EXISTS idx_projects_status
    ON projects(status);

-- Tasks filtered by status and priority
CREATE INDEX IF NOT EXISTS idx_tasks_status_priority
    ON tasks(status, priority);

-- Time entries filtered by user and work_date (typical timesheet view)
CREATE INDEX IF NOT EXISTS idx_time_entries_user_date
    ON time_entries(user_id, work_date);

-- Invoices filtered by status and due_date (collections / aging view)
CREATE INDEX IF NOT EXISTS idx_invoices_status_due
    ON invoices(status, due_date);

------------------------------------------------------------
-- 3. INSPECTING CONSTRAINTS & INDEXES
------------------------------------------------------------
-- These queries help you inspect what you just created.
-- In pgAdmin, you can also:
--   - Expand a table -> Constraints
--   - Expand a table -> Indexes
------------------------------------------------------------

-- 3.1 List constraints for each main table
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name IN ('accounts','users','projects','tasks','time_entries','invoices')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 3.2 List indexes for each main table
SELECT
    t.relname                      AS table_name,
    i.relname                      AS index_name,
    a.attname                      AS column_name,
    ix.indisunique                 AS is_unique,
    ix.indisprimary                AS is_primary
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

------------------------------------------------------------
-- 4. QUICK VALIDATION QUERIES
------------------------------------------------------------

-- 4.1 Try inserting invalid data to see constraints work
-- NOTE: These are EXPECTED TO FAIL with an error.
-- Uncomment one at a time to test:

-- Example: project with duplicate name within same account
-- INSERT INTO projects (account_id, name, status, start_date, budget_usd)
-- SELECT account_id, name, 'planned', CURRENT_DATE, 10000
-- FROM projects
-- LIMIT 1;

-- Example: task with negative estimated hours
-- INSERT INTO tasks (project_id, title, estimated_hours, status, priority)
-- VALUES (1, 'Invalid Task', -5, 'todo', 'low');

-- Example: time entry with 30 hours
-- INSERT INTO time_entries (task_id, user_id, work_date, hours_spent)
-- VALUES (1, 1, CURRENT_DATE, 30);

-- Example: invoice with due_date before issue_date
-- INSERT INTO invoices (account_id, issue_date, due_date, amount_usd, status)
-- VALUES (1, CURRENT_DATE, CURRENT_DATE - INTERVAL '1 day', 1000, 'draft');

------------------------------------------------------------
-- 5. PRACTICAL BUSINESS-ORIENTED VALIDATION QUERIES
------------------------------------------------------------

-- 5.1 Find any tasks that violate the estimated_hours > 0 rule (should be none)
SELECT *
FROM tasks
WHERE estimated_hours IS NOT NULL
  AND estimated_hours <= 0;

-- 5.2 Find any time entries with hours_spent <= 0 or > 24 (should be none)
SELECT *
FROM time_entries
WHERE hours_spent <= 0
   OR hours_spent > 24;

-- 5.3 Find any invoices with due_date < issue_date (should be none)
SELECT *
FROM invoices
WHERE due_date < issue_date;

-- 5.4 Check for duplicate project names per account (should be none, thanks to UNIQUE constraint)
SELECT
    account_id,
    name,
    COUNT(*) AS cnt
FROM projects
GROUP BY account_id, name
HAVING COUNT(*) > 1;

-- 5.5 Check for duplicate task titles per project (should be none)
SELECT
    project_id,
    title,
    COUNT(*) AS cnt
FROM tasks
GROUP BY project_id, title
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- 6. PRACTICE EXERCISES (TODO)
------------------------------------------------------------

-- 6.1 TODO:
-- Add a CHECK constraint on users so that:
--   - role must be one of ('developer','manager','admin')
--   (Already present in table definition, but re-implement it yourself in a new database
--    to practice defining CHECK constraints.)

-- 6.2 TODO:
-- Add an index to speed up queries that filter tasks by due_date and status.
-- For example:
--   SELECT * FROM tasks WHERE status = 'in_progress' AND due_date < CURRENT_DATE;
-- Think about the best column order in the index.

-- 6.3 TODO:
-- Add a CHECK constraint on tasks so that due_date cannot be more than 365 days after created_at.
-- (Hint: use an expression like: due_date <= (created_at::date + INTERVAL '365 days') OR due_date IS NULL)

-- 6.4 TODO:
-- Create a composite UNIQUE constraint that prevents two users in the same account
-- from having the same full_name. (But different accounts may still have a user with that name.)

-- 6.5 TODO:
-- In a separate scratch database, experiment with:
--   - INSERTing invalid rows that break constraints
--   - OBSERVING the error messages
--   - FIXING the data and re-trying
-- This will give you intuition about how constraints protect data integrity in production systems.
