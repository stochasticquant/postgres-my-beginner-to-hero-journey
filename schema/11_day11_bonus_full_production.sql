------------------------------------------------------------
-- DAY 11 BONUS – COMPLETE PRODUCTION-GRADE POSTGRES SKILLS
-- Database: dev_portfolio
--
-- Focus:
--   - Security & roles
--   - Row-Level Security (RLS)
--   - Materialized views
--   - Partitioning
--   - Stored procedures vs functions
--   - Error handling
--   - Temp tables
--   - psql scripting techniques
--   - Final consolidation
------------------------------------------------------------

------------------------------------------------------------
-- 1. SECURITY: ROLES & PERMISSIONS
------------------------------------------------------------
-- Create readonly, readwrite, and admin roles
CREATE ROLE readonly NOINHERIT;
CREATE ROLE readwrite NOINHERIT;
CREATE ROLE app_admin NOINHERIT SUPERUSER;

-- Grant permissions
GRANT CONNECT ON DATABASE dev_portfolio TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

GRANT CONNECT ON DATABASE dev_portfolio TO readwrite;
GRANT USAGE ON SCHEMA public TO readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;

------------------------------------------------------------
-- 2. ROW LEVEL SECURITY (RLS)
------------------------------------------------------------
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Define policy: Users can only see tasks assigned to them
CREATE POLICY user_task_policy ON tasks
FOR SELECT USING (assignee_id = current_setting('app.current_user_id')::INT);

------------------------------------------------------------
-- 3. MATERIALIZED VIEWS
------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_account_summary AS
SELECT
    a.account_id,
    a.name,
    COUNT(DISTINCT p.project_id) AS project_count,
    COUNT(DISTINCT t.task_id) AS task_count,
    SUM(te.hours_spent) AS total_hours
FROM accounts a
LEFT JOIN projects p ON a.account_id = p.account_id
LEFT JOIN tasks t ON p.project_id = t.project_id
LEFT JOIN time_entries te ON t.task_id = te.task_id
GROUP BY a.account_id, a.name;

-- Refresh MV
REFRESH MATERIALIZED VIEW mv_account_summary;

------------------------------------------------------------
-- 4. PARTITIONING (TIME-BASED)
------------------------------------------------------------
-- Partition time_entries by year
ALTER TABLE time_entries
RENAME TO time_entries_base;

CREATE TABLE time_entries (
    LIKE time_entries_base INCLUDING ALL
) PARTITION BY RANGE (work_date);

-- Year partitions
CREATE TABLE time_entries_2023 PARTITION OF time_entries
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE time_entries_2024 PARTITION OF time_entries
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Insert data back if needed (skipped for safety)

------------------------------------------------------------
-- 5. PROCEDURE WITH TRANSACTIONS & ERROR HANDLING
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE safe_transfer_hours(
    from_entry INT,
    to_entry INT,
    amount NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Start transaction block
    BEGIN
        UPDATE time_entries
        SET hours_spent = hours_spent - amount
        WHERE time_entry_id = from_entry;

        UPDATE time_entries
        SET hours_spent = hours_spent + amount
        WHERE time_entry_id = to_entry;

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred: %', SQLERRM;
        RAISE EXCEPTION 'Transfer failed';
    END;
END;
$$;

-- Call:
-- CALL safe_transfer_hours(1, 2, 1.5);

------------------------------------------------------------
-- 6. TEMP TABLE USAGE
------------------------------------------------------------
CREATE TEMP TABLE tmp_top_devs AS
SELECT
    u.user_id,
    u.full_name,
    SUM(te.hours_spent) AS total_hours
FROM users u
JOIN time_entries te ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC
LIMIT 10;

SELECT * FROM tmp_top_devs;

------------------------------------------------------------
-- 7. FINAL CLEANUP SCRIPTS
------------------------------------------------------------
ANALYZE;
VACUUM VERBOSE;

------------------------------------------------------------
-- END OF DAY 11 BONUS
------------------------------------------------------------
