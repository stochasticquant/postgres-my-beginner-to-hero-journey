------------------------------------------------------------
-- DAY 10 – PERFORMANCE TUNING, EXPLAIN, INDEXING STRATEGY
-- Database: dev_portfolio
-- Focus:
--   - EXPLAIN + EXPLAIN ANALYZE
--   - Understanding query plans
--   - Detecting sequential scans vs index scans
--   - Creating targeted indexes
--   - VACUUM, ANALYZE, AUTOVACUUM
--   - Query optimization patterns
------------------------------------------------------------

------------------------------------------------------------
-- 1. BASIC EXPLAIN
------------------------------------------------------------
EXPLAIN
SELECT * FROM tasks
WHERE status = 'done';

-- Add ANALYZE to see runtime
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE status = 'done';


------------------------------------------------------------
-- 2. DETECT SEQUENTIAL SCANS
------------------------------------------------------------
EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'user10_1@example.com';


------------------------------------------------------------
-- 3. CREATE INDEX TO IMPROVE PERFORMANCE
------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_users_email
ON users(email);

-- Re-run explain:
EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'user10_1@example.com';


------------------------------------------------------------
-- 4. MULTI-COLUMN INDEX
------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_projects_account_status
ON projects(account_id, status);

EXPLAIN ANALYZE
SELECT project_id
FROM projects
WHERE account_id = 5
AND status = 'active';


------------------------------------------------------------
-- 5. PARTIAL INDEX (only on active users)
------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_users_active_only
ON users(email)
WHERE active = TRUE;

EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'user1_3@example.com'
AND active = TRUE;


------------------------------------------------------------
-- 6. VACUUM & ANALYZE
------------------------------------------------------------
-- Reclaim storage + update planner stats
VACUUM ANALYZE tasks;
VACUUM ANALYZE users;
VACUUM ANALYZE projects;


------------------------------------------------------------
-- 7. AUTOVACUUM SETTINGS (READ-ONLY DEMO)
------------------------------------------------------------
SHOW autovacuum;

SHOW autovacuum_vacuum_scale_factor;
SHOW autovacuum_analyze_scale_factor;


------------------------------------------------------------
-- 8. QUERY OPTIMIZATION PATTERNS
------------------------------------------------------------

-- 8.1 Avoid SELECT *
EXPLAIN ANALYZE
SELECT task_id, title
FROM tasks
WHERE status = 'todo';

-- 8.2 Rewrite OR to UNION for better index usage
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE priority = 'high' OR priority = 'critical';

EXPLAIN ANALYZE
(
    SELECT * FROM tasks WHERE priority = 'high'
    UNION ALL
    SELECT * FROM tasks WHERE priority = 'critical'
);

-- 8.3 Avoid functions on indexed columns
EXPLAIN ANALYZE
SELECT *
FROM projects
WHERE lower(name) = 'project 1-1';

-- Better:
EXPLAIN ANALYZE
SELECT *
FROM projects
WHERE name = 'Project 1-1';


------------------------------------------------------------
-- 9. EXPLAIN BUFFERS (IO-level detail)
------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM accounts
WHERE industry = 'FinTech';


------------------------------------------------------------
-- 10. PRACTICE EXERCISES
------------------------------------------------------------

-- TODO:
-- 10.1 Identify slow queries using EXPLAIN ANALYZE and propose indexes.
-- 10.2 Use pg_stat_statements (requires extension) to find most expensive queries.
-- 10.3 Add indexes to speed up JOINs between tasks, projects, and users.
-- 10.4 Find unused indexes via pg_stat_user_indexes.
-- 10.5 Tune autovacuum thresholds for very large tables.

------------------------------------------------------------
-- END OF DAY 10
------------------------------------------------------------
