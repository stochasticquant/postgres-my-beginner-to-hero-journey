------------------------------------------------------------
-- DAY 8 – TRANSACTIONS, LOCKS & CONCURRENCY
-- Database: dev_portfolio
-- Focus:
--   - Explicit transactions (BEGIN / COMMIT / ROLLBACK)
--   - Understanding ACID properties
--   - Locking behavior (row-level locks, FOR UPDATE)
--   - Simulating concurrent updates (for two sessions)
--   - Basic deadlock awareness & retry pattern
--
-- HOW TO USE:
--   1. Open TWO pgAdmin Query Tools (Session A and Session B),
--      both connected to dev_portfolio.
--   2. Run the commented scenarios step by step.
--   3. Observe how locks and transactions behave.
------------------------------------------------------------

------------------------------------------------------------
-- 0. SANITY CHECK – CURRENT DB
------------------------------------------------------------
SELECT current_database() AS current_db;

------------------------------------------------------------
-- 1. BASIC TRANSACTIONS
------------------------------------------------------------
-- By default, pgAdmin runs each statement in its own transaction (autocommit).
-- Here we practice explicit control.

-- 1.1 Simple transaction: update + rollback

-- BEGIN;
-- UPDATE projects
-- SET status = 'on_hold'
-- WHERE project_id = 1;
--
-- -- Check the change inside the same transaction:
-- SELECT project_id, name, status FROM projects WHERE project_id = 1;
--
-- -- Revert the change:
-- ROLLBACK;
--
-- -- Now check again (status should be back to original):
-- SELECT project_id, name, status FROM projects WHERE project_id = 1;


-- 1.2 Simple transaction: update + commit

-- BEGIN;
-- UPDATE projects
-- SET status = 'active'
-- WHERE project_id = 1;
--
-- -- Check inside transaction:
-- SELECT project_id, name, status FROM projects WHERE project_id = 1;
--
-- -- Make it permanent:
-- COMMIT;
--
-- -- Check outside transaction:
-- SELECT project_id, name, status FROM projects WHERE project_id = 1;


------------------------------------------------------------
-- 2. BANKING-STYLE EXAMPLE WITH ROLLBACK
------------------------------------------------------------
-- We'll simulate moving hours between two tasks,
-- then ROLLBACK to avoid corrupting realistic data.

-- 2.1 Inspect two time entries (for demonstration)
SELECT * FROM time_entries
ORDER BY time_entry_id
LIMIT 5;

-- Note one or two IDs from above, then:

-- BEGIN;
-- UPDATE time_entries
-- SET hours_spent = hours_spent + 1
-- WHERE time_entry_id = 1;
--
-- UPDATE time_entries
-- SET hours_spent = hours_spent - 1
-- WHERE time_entry_id = 2;
--
-- -- Check inside transaction:
-- SELECT time_entry_id, hours_spent
-- FROM time_entries
-- WHERE time_entry_id IN (1, 2);
--
-- -- Decide to rollback:
-- ROLLBACK;
--
-- -- Check values again (should be unchanged):
-- SELECT time_entry_id, hours_spent
-- FROM time_entries
-- WHERE time_entry_id IN (1, 2);


------------------------------------------------------------
-- 3. ROW-LEVEL LOCKS WITH SELECT ... FOR UPDATE
------------------------------------------------------------

-- 3.1 Basic lock demo – use two sessions

-- SESSION A:
-- BEGIN;
-- SELECT project_id, name, status
-- FROM projects
-- WHERE project_id = 10
-- FOR UPDATE;

-- SESSION B:
-- Try to update the same row while Session A holds the lock:
-- UPDATE projects
-- SET status = 'on_hold'
-- WHERE project_id = 10;

-- Observation:
--  - Session B will BLOCK until Session A COMMITs or ROLLBACKs.

-- SESSION A:
-- COMMIT;  -- or ROLLBACK;

-- SESSION B:
-- The UPDATE now completes once the lock is released.


------------------------------------------------------------
-- 4. DEMO: LOST UPDATE PROBLEM & HOW FOR UPDATE HELPS
------------------------------------------------------------
-- Scenario: Two sessions read same row, compute new value,
-- then both update without proper locking → last write wins.

-- Pick a user with noticeable total hours:
SELECT
    u.user_id,
    u.full_name,
    SUM(te.hours_spent) AS total_hours
FROM users u
JOIN time_entries te ON u.user_id = te.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC
LIMIT 5;

-- Suppose we manually adjust a single time_entry as a naive "correction".

-- SESSION A (bad pattern – no locking):
-- BEGIN;
-- SELECT hours_spent
-- FROM time_entries
-- WHERE time_entry_id = 3;
-- -- Assume it returns e.g. 5.0
--
-- UPDATE time_entries
-- SET hours_spent = 6.0
-- WHERE time_entry_id = 3;
-- COMMIT;

-- SESSION B (runs concurrently with SESSION A):
-- BEGIN;
-- SELECT hours_spent
-- FROM time_entries
-- WHERE time_entry_id = 3;
-- -- Might also see 5.0 (depending on timing and isolation level)
--
-- UPDATE time_entries
-- SET hours_spent = 7.0
-- WHERE time_entry_id = 3;
-- COMMIT;

-- Final value will be 7.0 → Session A's change is LOST.

-- Better pattern with FOR UPDATE:

-- SESSION A:
-- BEGIN;
-- SELECT hours_spent
-- FROM time_entries
-- WHERE time_entry_id = 3
-- FOR UPDATE;
--
-- UPDATE time_entries
-- SET hours_spent = 6.0
-- WHERE time_entry_id = 3;
-- COMMIT;

-- SESSION B:
-- BEGIN;
-- SELECT hours_spent
-- FROM time_entries
-- WHERE time_entry_id = 3
-- FOR UPDATE;  -- will BLOCK until Session A commits
--
-- -- Now Session B sees the new value and can adjust safely
-- UPDATE time_entries
-- SET hours_spent = hours_spent + 1
-- WHERE time_entry_id = 3;
-- COMMIT;


------------------------------------------------------------
-- 5. TRANSACTION ISOLATION LEVELS (OVERVIEW)
------------------------------------------------------------
-- PostgreSQL default isolation level is READ COMMITTED.
-- You can change it per session:

-- SHOW default_transaction_isolation;

-- SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- For this 10-day program we mostly stay at the default (READ COMMITTED),
-- but it's good to know how to check/change it.


------------------------------------------------------------
-- 6. SIMULATING A DEADLOCK (EDUCATIONAL – CAREFUL!)
------------------------------------------------------------
-- Only try this if you are comfortable with manually ROLLBACK/COMMIT.
-- Use two sessions and SMALL test rows, not production-critical data.

-- Pick two projects:
SELECT project_id, name FROM projects ORDER BY project_id LIMIT 2;

-- Suppose they are IDs 11 and 12.

-- SESSION A:
-- BEGIN;
-- UPDATE projects
-- SET status = 'on_hold'
-- WHERE project_id = 11;

-- SESSION B:
-- BEGIN;
-- UPDATE projects
-- SET status = 'active'
-- WHERE project_id = 12;

-- Now create circular waiting:

-- SESSION A (still open transaction):
-- UPDATE projects
-- SET status = 'completed'
-- WHERE project_id = 12;

-- SESSION B:
-- UPDATE projects
-- SET status = 'planned'
-- WHERE project_id = 11;

-- At this point, PostgreSQL detects a deadlock and will abort
-- one of the transactions with an error like:
--   "ERROR: deadlock detected"

-- After that, make sure to:
--   COMMIT or ROLLBACK the surviving transaction to clean up.


------------------------------------------------------------
-- 7. SIMPLE RETRY PATTERN (FOR SERIALIZATION / DEADLOCK ERRORS)
------------------------------------------------------------
-- In application code, you typically catch deadlock/serialization errors
-- and retry. In pure SQL, we can outline the logic as a stored procedure
-- pattern (this is conceptual – not a full implementation with loops).

-- Example: update project status inside a transaction-safe function:

DROP FUNCTION IF EXISTS safe_update_project_status(INT, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION safe_update_project_status(
    p_project_id INT,
    p_new_status VARCHAR
)
RETURNS VOID AS $$
BEGIN
    -- In a real app, transaction boundaries and retry logic
    -- would be handled in the application layer.
    UPDATE projects
    SET status = p_new_status
    WHERE project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;

-- Usage:
-- SELECT safe_update_project_status(10, 'active');


------------------------------------------------------------
-- 8. PRACTICE EXERCISES (TODO)
------------------------------------------------------------

-- 8.1 TODO:
-- In two separate pgAdmin sessions, experiment with:
--   - BEGIN;
--   - UPDATE the same row in tasks;
--   - Observe blocking and lock behavior;
--   - COMMIT/ROLLBACK in different orders.

-- 8.2 TODO:
-- Change your session isolation level to REPEATABLE READ and:
--   - Run a long SELECT in Session A
--   - Insert or update data in Session B
--   - See how Session A does or does not see changes.

-- 8.3 TODO:
-- Wrap multiple related operations (e.g., creating a project,
-- creating initial tasks, creating an initial invoice) in a single
-- transaction and ROLLBACK to see everything revert.

-- 8.4 TODO:
-- Try to create a deadlock using different tables (e.g., tasks and invoices),
-- and observe the error. Practice resolving it by proper lock ordering.

-- 8.5 TODO:
-- Think about which operations in your future apps must be transactional:
--   - e.g., money transfers, booking systems, inventory updates –
--   and how you would model them in PostgreSQL using BEGIN/COMMIT/ROLLBACK.

------------------------------------------------------------
-- END OF DAY 8
------------------------------------------------------------
