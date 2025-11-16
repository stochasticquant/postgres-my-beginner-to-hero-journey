# 📅 Day 8 – Transactions, Locks & Concurrency

Today you move from “I can query data” to **“I understand how to keep data correct under concurrency.”**  
This is essential for **production systems**, especially with many users or services hitting the database at once.

---

## 🎯 Learning Objectives

By the end of Day 8 you will:

- Understand and use **explicit transactions**: `BEGIN`, `COMMIT`, `ROLLBACK`
- Know what **ACID** means in practice
- See how **row-level locks** work (`SELECT ... FOR UPDATE`)
- Simulate **concurrent updates** using two pgAdmin sessions
- Observe how PostgreSQL handles **deadlocks**
- Understand where **retry logic** belongs (usually in application code)

This knowledge is crucial for backend, data engineering, and DevOps roles.

---

## 📁 Files for Day 8

- `schema/08_day8_transactions_concurrency.sql`  
  Contains transaction/locking demos and exercise prompts.

Create this file in your repo and paste in the Day 8 SQL script.

---

## 🧩 Key Concepts

### 1️⃣ Transactions & ACID

A transaction is a unit of work that must be **all-or-nothing**.

ACID stands for:

- **Atomicity** – all changes succeed or none do  
- **Consistency** – constraints stay valid  
- **Isolation** – concurrent transactions don’t corrupt each other  
- **Durability** – committed data survives crashes

You practice:

- Updating data and then **ROLLBACK** to undo
- Updating data and **COMMIT** to persist

---

### 2️⃣ Explicit Transactions in Practice

You learn patterns like:

```sql
BEGIN;

UPDATE projects
SET status = 'on_hold'
WHERE project_id = 1;

-- Inspect data inside the transaction
SELECT project_id, name, status
FROM projects
WHERE project_id = 1;

-- Either:
COMMIT;   -- make changes permanent
-- or:
ROLLBACK; -- undo all changes in this transaction
```

You also simulate a “money transfer” style operation between time entries and see how **ROLLBACK** restores the original state.

---

### 3️⃣ Row-Level Locks & `SELECT ... FOR UPDATE`

You open two pgAdmin Query Tools:

- **Session A**
- **Session B**

You then:

- Lock a specific project row in Session A:

```sql
BEGIN;
SELECT project_id, name, status
FROM projects
WHERE project_id = 10
FOR UPDATE;
```

- Try to update the same row in Session B.  
You observe that Session B **blocks** until Session A commits or rolls back.

This teaches you:

- How PostgreSQL protects rows being modified
- Why long-running transactions can block others
- Why careful lock usage matters

---

### 4️⃣ Lost Update Problem & Fix

You simulate a **lost update**:

- Session A reads a value and writes a new one  
- Session B does the same without locking  
- Final update overwrites Session A’s changes

Then you fix it with:

```sql
SELECT ... FOR UPDATE;
```

before changing the row, ensuring that concurrent sessions **wait in line** instead of trampling each other.

---

### 5️⃣ Isolation Levels (Overview)

You briefly inspect and optionally change isolation levels:

```sql
SHOW default_transaction_isolation;

SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

For this course you mostly keep the default (`READ COMMITTED`), but now you know where to look and how to switch.

---

### 6️⃣ Deadlocks

You intentionally create a deadlock using two sessions and two rows updated in opposite orders.

Result:

- PostgreSQL detects a deadlock
- It kills one transaction with an error: `deadlock detected`
- You must COMMIT or ROLLBACK the surviving transaction

You learn:

- Why **consistent lock ordering** matters
- Why you should **minimize long-held locks**
- That you need **retry logic** in applications

---

### 7️⃣ Safe Update Function (Conceptual)

You define a simple function:

```sql
CREATE OR REPLACE FUNCTION safe_update_project_status(
    p_project_id INT,
    p_new_status VARCHAR
)
RETURNS VOID AS $$
BEGIN
    UPDATE projects
    SET status = p_new_status
    WHERE project_id = p_project_id;
END;
$$ LANGUAGE plpgsql;
```

In the real world, retries + transaction boundaries usually live in your **application**, but this function illustrates structured updates inside the DB.

---

## 🧪 Hands-On Exercises

You are encouraged to:

1. Use two pgAdmin sessions to:
   - Lock rows with `SELECT ... FOR UPDATE`
   - Observe blocking behavior
   - Commit/rollback and see when locks are released  

2. Change session isolation level to `REPEATABLE READ` and:
   - Run a long SELECT in Session A  
   - Mutate data in Session B  
   - Re-run in Session A and see visibility rules  

3. Group multiple operations (insert project + tasks + invoice) into a single transaction and then ROLLBACK to see everything undone.

4. Experiment with deadlocks and practice resolving them conceptually:
   - Lock order  
   - Short transactions  
   - Proper retry patterns  

---

## 🧠 How to Describe This on Your CV

After Day 8, you can honestly say:

> “I understand transaction handling, isolation levels, and row-level locking in PostgreSQL. I’ve used explicit transactions (BEGIN/COMMIT/ROLLBACK), SELECT FOR UPDATE, and simulated concurrency and deadlocks using multiple sessions. I know how to reason about data consistency and safe updates in concurrent environments.”

This is advanced knowledge and highly valuable for senior/lead roles.

---

## 📁 Suggested Repo Structure After Day 8

```text
postgresql-dev-portfolio/
│
├── schema/
│   ├── 01_day1_setup.sql
│   ├── 02_day2_queries.sql
│   ├── 03_day3_joins.sql
│   ├── 04_day4_aggregations.sql
│   ├── 05_day5_constraints_indexes.sql
│   ├── 06_day6_views_ctes_windows.sql
│   ├── 07_day7_functions_triggers.sql
│   └── 08_day8_transactions_concurrency.sql
└── docs/
    ├── README_Day1.md
    ├── README_Day2.md
    ├── README_Day3.md
    ├── README_Day4.md
    ├── README_Day5.md
    ├── README_Day6.md
    ├── README_Day7.md
    └── README_Day8.md
```

---

Next, **Day 9** will dive into **JSONB, extensions, and advanced PostgreSQL features**, giving your schema modern capabilities (semi-structured data, flexible metadata, etc.).
