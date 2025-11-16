------------------------------------------------------------
-- DAY 9 – JSONB, EXTENSIONS & ADVANCED POSTGRES FEATURES
-- Database: dev_portfolio
-- Focus:
--   - JSONB storage and querying
--   - Full-text search
--   - GIN indexes
--   - Unnesting JSON arrays
--   - Using pgcrypto for UUID and hashing
--   - Using hstore (optional)
------------------------------------------------------------

------------------------------------------------------------
-- 1. JSONB Columns
------------------------------------------------------------
ALTER TABLE tasks
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;

-- Update sample rows with metadata
UPDATE tasks
SET metadata = jsonb_build_object(
    'complexity', (ARRAY['low','medium','high'])[floor(random()*3)+1],
    'tags', jsonb_build_array('backend','api','db')[floor(random()*3)]
)
WHERE random() < 0.05; -- Update ~5% of tasks

-- Check sample
SELECT task_id, title, metadata
FROM tasks
WHERE metadata <> '{}'::jsonb
LIMIT 10;


------------------------------------------------------------
-- 2. JSONB Operators
------------------------------------------------------------
-- Get tasks tagged with 'backend'
SELECT task_id, title, metadata
FROM tasks
WHERE metadata->'tags' ? 'backend'
LIMIT 20;

-- Get tasks with complexity = 'high'
SELECT task_id, title, metadata
FROM tasks
WHERE metadata->>'complexity' = 'high';


------------------------------------------------------------
-- 3. GIN Index on JSONB
------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_tasks_metadata_gin
ON tasks USING GIN (metadata);


------------------------------------------------------------
-- 4. Full-Text Search (FTS)
------------------------------------------------------------
-- Add a search column to tasks
ALTER TABLE tasks
ADD COLUMN search_tsv tsvector;

-- Populate search field
UPDATE tasks
SET search_tsv =
    setweight(to_tsvector('english', coalesce(title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(description,'')), 'B');

-- Create GIN index
CREATE INDEX IF NOT EXISTS idx_tasks_search_tsv
ON tasks USING GIN (search_tsv);

-- Search example
SELECT task_id, title
FROM tasks
WHERE search_tsv @@ plainto_tsquery('performance');


------------------------------------------------------------
-- 5. Trigger to Keep FTS Updated
------------------------------------------------------------
CREATE OR REPLACE FUNCTION tasks_search_update() RETURNS trigger AS $$
BEGIN
    NEW.search_tsv :=
        setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description,'')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_tasks_search_update ON tasks;

CREATE TRIGGER trg_tasks_search_update
BEFORE INSERT OR UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION tasks_search_update();


------------------------------------------------------------
-- 6. pgcrypto UUID Usage
------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE users
ADD COLUMN api_key UUID DEFAULT gen_random_uuid();

SELECT user_id, full_name, api_key
FROM users
LIMIT 10;


------------------------------------------------------------
-- 7. JSON Unnest Example
------------------------------------------------------------
-- Find all distinct tags used in metadata
SELECT DISTINCT jsonb_array_elements_text(metadata->'tags') AS tag
FROM tasks
WHERE metadata ? 'tags';


------------------------------------------------------------
-- 8. hstore Example (Optional)
------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS hstore;

ALTER TABLE projects
ADD COLUMN extra hstore DEFAULT ''::hstore;

UPDATE projects
SET extra = hstore('priority', (ARRAY['low','medium','high'])[floor(random()*3)+1])
WHERE random() < 0.05;

SELECT project_id, extra
FROM projects
WHERE extra <> ''::hstore
LIMIT 10;


------------------------------------------------------------
-- END OF DAY 9
------------------------------------------------------------
