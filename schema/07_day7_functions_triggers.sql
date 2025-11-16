------------------------------------------------------------
-- DAY 7 – PL/pgSQL FUNCTIONS & TRIGGERS
-- Database: dev_portfolio
-- Focus:
--   - Writing stored functions in PL/pgSQL
--   - Creating BEFORE/AFTER triggers
--   - Enforcing business logic at the database layer
--   - Auditing changes automatically
--
-- HOW TO USE:
--   1. Connect to dev_portfolio in pgAdmin.
--   2. Run this file top to bottom.
------------------------------------------------------------

------------------------------------------------------------
-- 1. ENABLE PL/pgSQL (usually enabled by default)
------------------------------------------------------------
--CREATE EXTENSION IF NOT EXISTS plpgsql;

------------------------------------------------------------
-- 2. UTILITY: AUDIT TABLES
------------------------------------------------------------
DROP TABLE IF EXISTS task_audit CASCADE;
DROP TABLE IF EXISTS invoice_audit CASCADE;

CREATE TABLE task_audit (
    audit_id       BIGSERIAL PRIMARY KEY,
    task_id        INT,
    old_status     VARCHAR(50),
    new_status     VARCHAR(50),
    changed_by     VARCHAR(200),
    changed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoice_audit (
    audit_id       BIGSERIAL PRIMARY KEY,
    invoice_id     INT,
    old_status     VARCHAR(50),
    new_status     VARCHAR(50),
    changed_by     VARCHAR(200),
    changed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

------------------------------------------------------------
-- 3. FUNCTION: VALIDATE HOURS BEFORE INSERT
------------------------------------------------------------
-- Prevent inserting more than 12 hours in a single time entry
DROP FUNCTION IF EXISTS validate_time_entry() CASCADE;

CREATE OR REPLACE FUNCTION validate_time_entry()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.hours_spent > 12 THEN
        RAISE EXCEPTION 'Time entry exceeds allowed daily max of 12 hours: attempted = %', NEW.hours_spent;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_time_entry
BEFORE INSERT ON time_entries
FOR EACH ROW
EXECUTE FUNCTION validate_time_entry();


------------------------------------------------------------
-- 4. FUNCTION: AUTO-SET PROJECT STATUS
------------------------------------------------------------
DROP FUNCTION IF EXISTS auto_close_project() CASCADE;

CREATE OR REPLACE FUNCTION auto_close_project()
RETURNS TRIGGER AS $$
DECLARE
    open_tasks INT;
BEGIN
    -- Count incomplete tasks
    SELECT COUNT(*) INTO open_tasks
    FROM tasks
    WHERE project_id = NEW.project_id
      AND status <> 'done';

    IF open_tasks = 0 THEN
        -- Automatically mark project as completed
        UPDATE projects
        SET status = 'completed'
        WHERE project_id = NEW.project_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- When a task is marked as done, check project status
CREATE TRIGGER trg_auto_close_project
AFTER UPDATE OF status ON tasks
FOR EACH ROW
WHEN (NEW.status = 'done')
EXECUTE FUNCTION auto_close_project();


------------------------------------------------------------
-- 5. FUNCTION: AUDIT TASK STATUS CHANGES
------------------------------------------------------------
DROP FUNCTION IF EXISTS audit_task_status() CASCADE;

CREATE OR REPLACE FUNCTION audit_task_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO task_audit(task_id, old_status, new_status, changed_by)
        VALUES(OLD.task_id, OLD.status, NEW.status, current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_task_status
AFTER UPDATE OF status ON tasks
FOR EACH ROW
EXECUTE FUNCTION audit_task_status();


------------------------------------------------------------
-- 6. FUNCTION: AUDIT INVOICE STATUS CHANGES
------------------------------------------------------------
DROP FUNCTION IF EXISTS audit_invoice_status() CASCADE;

CREATE OR REPLACE FUNCTION audit_invoice_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO invoice_audit(invoice_id, old_status, new_status, changed_by)
        VALUES(OLD.invoice_id, OLD.status, NEW.status, current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_invoice_status
AFTER UPDATE OF status ON invoices
FOR EACH ROW
EXECUTE FUNCTION audit_invoice_status();


------------------------------------------------------------
-- 7. UTILITY FUNCTION: GET PROJECT SUMMARY
------------------------------------------------------------
DROP FUNCTION IF EXISTS get_project_summary(INT) CASCADE;

CREATE OR REPLACE FUNCTION get_project_summary(pid INT)
RETURNS TABLE(
    project_id INT,
    project_name TEXT,
    total_hours NUMERIC,
    task_count INT,
    invoice_total NUMERIC,
    invoice_paid NUMERIC,
    last_work_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.project_id,
        p.name,
        COALESCE(SUM(te.hours_spent), 0) AS total_hours,
        COUNT(DISTINCT t.task_id)        AS task_count,
        COALESCE(SUM(i.amount_usd), 0)   AS invoice_total,
        COALESCE(SUM(i.amount_usd) FILTER (WHERE i.status='paid'), 0) AS invoice_paid,
        MAX(te.work_date)                AS last_work_date
    FROM projects p
    LEFT JOIN tasks t ON p.project_id = t.project_id
    LEFT JOIN time_entries te ON t.task_id = te.task_id
    LEFT JOIN invoices i ON p.project_id = i.project_id
    WHERE p.project_id = pid
    GROUP BY p.project_id, p.name;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- 8. TRY CALLING THE SUMMARY FUNCTION
------------------------------------------------------------
SELECT * FROM get_project_summary(1);


------------------------------------------------------------
-- 9. TEST TRIGGERS
------------------------------------------------------------
-- 9.1 Test audit for tasks
-- UPDATE tasks SET status='done' WHERE task_id=1;

-- SELECT * FROM task_audit ORDER BY changed_at DESC LIMIT 10;

-- 9.2 Test invoice audit
-- UPDATE invoices SET status='paid' WHERE invoice_id=1;

-- SELECT * FROM invoice_audit ORDER BY changed_at DESC LIMIT 10;

-- 9.3 Test hours validation (should raise exception)
-- INSERT INTO time_entries(task_id, user_id, work_date, hours_spent)
-- VALUES(1, 1, CURRENT_DATE, 20);

------------------------------------------------------------
-- 10. TODO PRACTICE
------------------------------------------------------------

-- 10.1 TODO:
-- Write a trigger that automatically sets `updated_at = now()` whenever a task is updated.

-- 10.2 TODO:
-- Write a function that returns the top 5 developers by total hours.

-- 10.3 TODO:
-- Write a BEFORE INSERT trigger on invoices:
--   If due_date is NULL → automatically set due_date = issue_date + INTERVAL '30 days'.

-- 10.4 TODO:
-- Write a trigger on users:
--   If role='admin' → ensure email domain ends with '@company.com'.

-- 10.5 TODO:
-- Write a function that returns:
--   - total account hours
--   - total invoice amount
--   - unpaid invoice amount
--   - percentage paid
-- For a given account_id.

------------------------------------------------------------
-- END OF DAY 7
------------------------------------------------------------
