# 📅 Day 10 – Performance, EXPLAIN Plans & Optimization

Congratulations — you’ve reached the final day.  
Today you learn **the most important real-world PostgreSQL skill**:

> How to analyze, tune, and optimize SQL for production systems.

This is what distinguishes **senior** engineers from intermediate ones.

---

## 🎯 Goals

By the end of today you will:

- Read and understand **EXPLAIN** & **EXPLAIN ANALYZE** plans  
- Know when PostgreSQL uses:
  - Sequential scans  
  - Index scans  
  - Bitmap heap/index scans  
- Create:
  - Single-column indexes  
  - Multi-column indexes  
  - Partial indexes  
- Understand **VACUUM**, **ANALYZE**, and **autovacuum**
- Apply real-world optimization patterns

---

## 🧩 1. EXPLAIN & EXPLAIN ANALYZE

### EXPLAIN – planner estimate  
### EXPLAIN ANALYZE – actual runtime + buffers

Example:

```sql
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE status = 'done';
```

You check:

- Total runtime
- Whether it's doing:
  - Sequential scan (`Seq Scan`)
  - Index scan (`Index Scan`)
- Rows estimated vs rows actual

---

## 🧩 2. Indexing

You create:

### 🔹 Single-column index  
```sql
CREATE INDEX idx_users_email ON users(email);
```

### 🔹 Multi-column index  
```sql
CREATE INDEX idx_projects_account_status
ON projects(account_id, status);
```

### 🔹 Partial index  
```sql
CREATE INDEX idx_users_active_only
ON users(email) WHERE active = TRUE;
```

This is enterprise-level tuning.

---

## 🧩 3. VACUUM, ANALYZE & Autovacuum

- **VACUUM** frees dead tuples  
- **ANALYZE** refreshes planner statistics  
- **Autovacuum** runs this automatically

Check settings:

```sql
SHOW autovacuum;
SHOW autovacuum_vacuum_scale_factor;
```

---

## 🧩 4. Query Optimization Patterns (Real-World)

### ❌ Avoid SELECT *  
### ✔ Only select needed columns

### ❌ Avoid OR filters  
### ✔ Use UNION to enable index usage

### ❌ Avoid functions on indexed columns  
Example: `lower(column)` prevents index use.

---

## 🧩 5. EXPLAIN (ANALYZE, BUFFERS)

This gives IO detail, showing:

- Shared reads
- Cache reads
- Dirty buffers

Useful for diagnosing slow disks or poor caching.

---

## 🧪 Exercises

1. Find a slow query in your dataset  
2. Use EXPLAIN ANALYZE to identify cause  
3. Create an index to fix it  
4. Re-run EXPLAIN and confirm improvement  
5. Use `pg_stat_user_indexes` to find unused indexes  
6. Tune autovacuum settings for big tables  

---

## 🧠 CV Boost

You can now confidently claim:

> “Skilled in PostgreSQL performance tuning, EXPLAIN plan analysis, indexing strategies, and query optimization.”

This is **professional-level database engineering**.

---

## 🎉 YOU DID IT.

10 days → professional PostgreSQL portfolio.

Deliver this entire project on GitHub, and it will *seriously* stand out in your CV.

