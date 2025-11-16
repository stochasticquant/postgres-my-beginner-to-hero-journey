# 📅 Day 9 – JSONB, Extensions & Modern PostgreSQL Features

Today you elevate beyond relational SQL and learn why PostgreSQL is considered one of the most powerful modern databases.

You will work with:

- **JSONB** (semi-structured storage)
- **GIN indexing** for fast lookups
- **Full-text search (FTS)**
- **pgcrypto** for UUID generation
- **hstore** as a key-value column type
- JSON array unnesting

These are widely used in real-life production systems.

---

## 🎯 Goals for the Day

By the end of Day 9, you will:

- Know how to add and manipulate JSONB columns
- Query JSON documents inside PostgreSQL
- Build GIN indexes to accelerate JSON queries
- Implement full-text search with ranking
- Automatically maintain search indexes via triggers
- Generate strong API keys with pgcrypto
- Use JSON unnesting to explode arrays into rows

---

## 🧩 New Concepts Today

### 🟦 1. JSONB – store flexible data

Add metadata:

```sql
ALTER TABLE tasks
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
```

Update tasks with structured JSON:

```sql
UPDATE tasks
SET metadata = jsonb_build_object(
    'complexity','high',
    'tags', jsonb_build_array('backend','api')
)
WHERE task_id = 10;
```

Query JSON:

```sql
SELECT *
FROM tasks
WHERE metadata->>'complexity' = 'high';
```

---

### 🟦 2. GIN Index on JSONB

Speeds up JSONB queries:

```sql
CREATE INDEX idx_tasks_metadata_gin
ON tasks USING GIN(metadata);
```

This makes nested JSON lookups extremely fast.

---

### 🟦 3. Full-Text Search (FTS)

PostgreSQL can index text like a search engine.

You build:

- `tsvector` column
- trigger to keep it updated
- GIN index for fast search

Then searching becomes:

```sql
SELECT * FROM tasks
WHERE search_tsv @@ plainto_tsquery('performance');
```

---

### 🟦 4. UUIDs Using pgcrypto

Enable extension:

```sql
CREATE EXTENSION pgcrypto;
```

Add UUID API keys:

```sql
ALTER TABLE users
ADD COLUMN api_key UUID DEFAULT gen_random_uuid();
```

---

### 🟦 5. JSON Array Unnesting

Get all unique tags in the database:

```sql
SELECT DISTINCT jsonb_array_elements_text(metadata->'tags') AS tag
FROM tasks
WHERE metadata ? 'tags';
```

---

### 🟦 6. Optional: hstore

A lightweight key-value type:

```sql
CREATE EXTENSION hstore;
ALTER TABLE projects ADD COLUMN extra hstore;
```

---

## 🧪 Exercises

1. **Add custom metadata** to 10 random tasks  
2. Create a GIN index on the users table for JSONB  
3. Write a query to find tasks that contain 2 specific tags  
4. Build a full-text search query that ranks results  
5. Expand all JSON tags into a frequency table  
6. Add additional hstore keys to projects and query them  

---

## 🧠 CV Skill Boost

After Day 9, you can confidently say:

> “Experienced with advanced PostgreSQL features including JSONB, GIN indexes, pgcrypto, and full-text search. Capable of designing hybrid relational/NoSQL schemas with efficient indexing and search capabilities.”

This is a **major** differentiator.

---

## 📁 Repo Structure After Day 9

```
postgresql-dev-portfolio/
│
├── schema/
│   ├── 09_day9_jsonb_extensions.sql
└── docs/
    ├── README_Day9.md
```

---

Tomorrow we finish strong with **Day 10: Performance Tuning, EXPLAIN plans, vacuuming, and optimization strategies.**
