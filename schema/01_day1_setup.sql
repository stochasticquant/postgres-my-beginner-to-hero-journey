------------------------------------------------------------
-- DAY 1 – FULL SETUP SCRIPT
-- Database: dev_portfolio
-- Content:
--   1. Create database (run in postgres DB)
--   2. Create schema (tables)
--   3. Insert realistic bulk test data (1000s of rows)
------------------------------------------------------------

------------------------------------------------------------
-- 1. CREATE DATABASE (run this in 'postgres' or another DB)
------------------------------------------------------------
-- If it already exists, you can skip this section.

-- CREATE DATABASE dev_portfolio OWNER charles;

-- After creating, connect to dev_portfolio in pgAdmin,
-- then run everything below.


------------------------------------------------------------
-- 2. CREATE TABLES (run in dev_portfolio)
------------------------------------------------------------

DROP TABLE IF EXISTS time_entries CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;

-- 1. Accounts (clients / companies)
CREATE TABLE accounts (
    account_id      SERIAL PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    industry        VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users (developers, managers, admins)
CREATE TABLE users (
    user_id         SERIAL PRIMARY KEY,
    account_id      INT NOT NULL REFERENCES accounts(account_id),
    full_name       VARCHAR(200) NOT NULL,
    email           VARCHAR(200) UNIQUE NOT NULL,
    role            VARCHAR(50) NOT NULL CHECK (role IN ('developer', 'manager', 'admin')),
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Projects
CREATE TABLE projects (
    project_id      SERIAL PRIMARY KEY,
    account_id      INT NOT NULL REFERENCES accounts(account_id),
    name            VARCHAR(200) NOT NULL,
    status          VARCHAR(50) NOT NULL CHECK (status IN ('planned', 'active', 'on_hold', 'completed')),
    start_date      DATE NOT NULL,
    end_date        DATE,
    budget_usd      NUMERIC(12,2),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tasks
CREATE TABLE tasks (
    task_id         SERIAL PRIMARY KEY,
    project_id      INT NOT NULL REFERENCES projects(project_id),
    assignee_id     INT REFERENCES users(user_id),
    title           VARCHAR(300) NOT NULL,
    description     TEXT,
    status          VARCHAR(50) NOT NULL CHECK (status IN ('todo', 'in_progress', 'blocked', 'done')),
    priority        VARCHAR(20) NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    estimated_hours NUMERIC(6,2),
    due_date        DATE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Time entries
CREATE TABLE time_entries (
    time_entry_id   SERIAL PRIMARY KEY,
    task_id         INT NOT NULL REFERENCES tasks(task_id),
    user_id         INT NOT NULL REFERENCES users(user_id),
    work_date       DATE NOT NULL,
    hours_spent     NUMERIC(5,2) NOT NULL CHECK (hours_spent > 0),
    notes           TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Invoices
CREATE TABLE invoices (
    invoice_id      SERIAL PRIMARY KEY,
    account_id      INT NOT NULL REFERENCES accounts(account_id),
    project_id      INT REFERENCES projects(project_id),
    issue_date      DATE NOT NULL,
    due_date        DATE NOT NULL,
    amount_usd      NUMERIC(12,2) NOT NULL CHECK (amount_usd >= 0),
    status          VARCHAR(50) NOT NULL CHECK (status IN ('draft', 'sent', 'paid', 'overdue')),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


------------------------------------------------------------
-- 3. INSERT REALISTIC BULK DATA
-- We will use generate_series() to create thousands of rows.
-- Approx:
--   100 accounts
--   500 users
--   300 projects
--   3000 tasks
--   8000+ time_entries
--   500 invoices
------------------------------------------------------------

---------------------------
-- 3.1 Accounts (100 rows)
---------------------------
INSERT INTO accounts (name, industry, created_at)
SELECT
    'Company ' || gs AS name,
    (ARRAY['E-commerce','FinTech','Healthcare','Education','Retail','Energy','Media','Logistics'])[
        (floor(random()*8)::int + 1)
    ] AS industry,
    now() - (gs * interval '1 day') AS created_at
FROM generate_series(1, 100) AS gs;


---------------------------
-- 3.2 Users (approx 500 rows)
-- For each account, create 5 users
---------------------------
INSERT INTO users (account_id, full_name, email, role, active, created_at)
SELECT
    a.account_id,
    'User ' || a.account_id || '-' || u.gs AS full_name,
    lower('user' || a.account_id || '_' || u.gs || '@example.com') AS email,
    (ARRAY['developer','developer','developer','manager','admin'])[
        (floor(random()*5)::int + 1)
    ] AS role,
    (random() > 0.05) AS active, -- ~95% active
    now() - (floor(random()*365)::int * interval '1 day') AS created_at
FROM accounts a
CROSS JOIN LATERAL generate_series(1, 5) AS u(gs);


---------------------------
-- 3.3 Projects (approx 300 rows)
-- Each account gets between 1 and 5 projects
---------------------------
INSERT INTO projects (account_id, name, status, start_date, end_date, budget_usd, created_at)
SELECT
    a.account_id,
    'Project ' || a.account_id || '-' || p.gs AS name,
    (ARRAY['planned','active','on_hold','completed'])[
        (floor(random()*4)::int + 1)
    ] AS status,
    (CURRENT_DATE - (floor(random()*365)::int) * interval '1 day')::date AS start_date,
    CASE
        WHEN random() < 0.4 THEN  -- 40% have end_date
            (CURRENT_DATE + (floor(random()*120)::int) * interval '1 day')::date
        ELSE
            NULL
    END AS end_date,
    ROUND((random() * 200000 + 20000)::numeric, 2) AS budget_usd,
    now() - (floor(random()*365)::int * interval '1 day') AS created_at
FROM accounts a
CROSS JOIN LATERAL generate_series(1, 3) AS p(gs);  -- ~ 3 projects per account => ~300


---------------------------
-- 3.4 Tasks (approx 3000 rows)
-- Each project gets between 5 and 15 tasks
---------------------------
INSERT INTO tasks (project_id, assignee_id, title, description, status, priority, estimated_hours, due_date, created_at)
SELECT
    p.project_id,
    u.user_id AS assignee_id,
    'Task ' || p.project_id || '-' || t.gs AS title,
    'Auto-generated task for project ' || p.project_id AS description,
    (ARRAY['todo','in_progress','blocked','done'])[
        (floor(random()*4)::int + 1)
    ] AS status,
    (ARRAY['low','medium','high','critical'])[
        (floor(random()*4)::int + 1)
    ] AS priority,
    ROUND((random() * 40 + 1)::numeric, 2) AS estimated_hours,
    (CURRENT_DATE + (floor(random()*60)::int) * interval '1 day')::date AS due_date,
    now() - (floor(random()*365)::int * interval '1 day') AS created_at
FROM projects p
JOIN accounts a ON p.account_id = a.account_id
JOIN LATERAL (
    SELECT user_id
    FROM users u
    WHERE u.account_id = a.account_id
    ORDER BY random()
    LIMIT 1
) AS u ON true
CROSS JOIN LATERAL generate_series(1, 10) AS t(gs);  -- ~10 tasks per project => ~3000


---------------------------
-- 3.5 Time Entries (approx 8000–10000 rows)
-- Each task gets between 1 and 5 time entries
---------------------------
INSERT INTO time_entries (task_id, user_id, work_date, hours_spent, notes, created_at)
SELECT
    t.task_id,
    t.assignee_id,
    (CURRENT_DATE - (floor(random()*60)::int) * interval '1 day')::date AS work_date,
    ROUND((random() * 7 + 1)::numeric, 2) AS hours_spent,
    'Work log for task ' || t.task_id AS notes,
    now() - (floor(random()*60)::int * interval '1 day') AS created_at
FROM tasks t
CROSS JOIN LATERAL generate_series(1, 3) AS g(gs)  -- ~3 entries per task
WHERE t.assignee_id IS NOT NULL;


---------------------------
-- 3.6 Invoices (approx 500 rows)
---------------------------
INSERT INTO invoices (account_id, project_id, issue_date, due_date, amount_usd, status, created_at)
SELECT
    p.account_id,
    p.project_id,
    (CURRENT_DATE - (floor(random()*120)::int) * interval '1 day')::date AS issue_date,
    (CURRENT_DATE + (floor(random()*60)::int) * interval '1 day')::date AS due_date,
    ROUND((random() * 50000 + 5000)::numeric, 2) AS amount_usd,
    (ARRAY['draft','sent','paid','overdue'])[
        (floor(random()*4)::int + 1)
    ] AS status,
    now() - (floor(random()*120)::int * interval '1 day') AS created_at
FROM projects p
WHERE random() < 0.6;  -- ~60% of projects have invoices


------------------------------------------------------------
-- 4. QUICK CHECKS
------------------------------------------------------------

-- Row counts (you should see large, realistic numbers)
SELECT 'accounts' AS table, count(*) FROM accounts
UNION ALL
SELECT 'users', count(*) FROM users
UNION ALL
SELECT 'projects', count(*) FROM projects
UNION ALL
SELECT 'tasks', count(*) FROM tasks
UNION ALL
SELECT 'time_entries', count(*) FROM time_entries
UNION ALL
SELECT 'invoices', count(*) FROM invoices;

-- Sample data
SELECT * FROM accounts LIMIT 10;
SELECT * FROM users LIMIT 10;
SELECT * FROM projects LIMIT 10;
SELECT * FROM tasks LIMIT 10;
SELECT * FROM time_entries LIMIT 10;
SELECT * FROM invoices LIMIT 10;
