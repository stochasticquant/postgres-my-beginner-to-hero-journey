# 📅 Day 1 – PostgreSQL Dev Portfolio Setup

## 🎯 Goal

Set up the **dev_portfolio** database with:

- A realistic, professional schema
- Thousands of rows of synthetic but meaningful data
- A clean base to use for all later days (joins, analytics, functions, performance, etc.)

You will:

1. Create the `dev_portfolio` database.
2. Create all core tables for the Developer Project & Time Tracking platform.
3. Bulk-generate realistic data using PostgreSQL's `generate_series()` and `random()` functions.
4. Verify that data has been created correctly using quick sanity checks.

---

## ✅ Prerequisites

- PostgreSQL server installed and running.
- pgAdmin installed and connected to your PostgreSQL server.
- A superuser or a user with permission to create databases (e.g. `postgres` or your admin user).
- Optional: an application user like `yourself` who will own the `dev_portfolio` database.

---

## 🧩 Step 1 – Create the Database

In pgAdmin:

1. Open **Query Tool** on the `postgres` database (or any admin DB).
2. Run:

```sql
CREATE DATABASE dev_portfolio OWNER charles;
```

> If you don't have a `charles` role, either create it or remove `OWNER charles` and let PostgreSQL choose the default owner.

3. In pgAdmin, **refresh** the server and connect to the new `dev_portfolio` database.

---

## 🧩 Step 2 – Create the Schema (Tables)

With `dev_portfolio` selected, open the Query Tool and run the **Day 1 SQL script**:

- Drops existing tables (if any).
- Creates 6 core tables:

  - `accounts` – clients/companies
  - `users` – developers, managers, admins
  - `projects` – projects per account
  - `tasks` – work units assigned to users
  - `time_entries` – logged hours
  - `invoices` – billing records

The tables include:

- Proper primary keys
- Foreign key relationships
- Basic constraints (`NOT NULL`, `CHECK` constraints)
- Reasonable data types (`VARCHAR`, `NUMERIC`, `TIMESTAMP`, `DATE`, `BOOLEAN`)

---

## 🧩 Step 3 – Insert Realistic Bulk Data

The script then uses `generate_series()` and `random()` to create thousands of rows:

### Approximate volumes:

- **100** accounts
- **500** users
- **300** projects
- **~3000** tasks
- **~8000–10000** time_entries
- **~500** invoices

This ensures:

- You have **enough data** to practice real analytics queries.
- Joins and aggregations feel like real-world workloads.
- Performance tuning later (Day 8) is meaningful.

Key techniques used:

- `generate_series()` for bulk creation.
- `CROSS JOIN LATERAL` to repeat patterns per parent row.
- Randomized industries, roles, budgets, dates, statuses.
- Synthetic but realistic timestamps and amounts.

---

## 🧩 Step 4 – Run Quick Checks

At the end of the script you’ll find sanity checks:

```sql
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
```

This returns row counts per table. You should see:

- 100+ accounts  
- 500+ users  
- 300+ projects  
- 3000+ tasks  
- 8000+ time_entries  
- A few hundred invoices  

You can also inspect sample rows:

```sql
SELECT * FROM accounts LIMIT 10;
SELECT * FROM users LIMIT 10;
SELECT * FROM projects LIMIT 10;
SELECT * FROM tasks LIMIT 10;
SELECT * FROM time_entries LIMIT 10;
SELECT * FROM invoices LIMIT 10;
```

---

## 🧠 What You Learn on Day 1

- How to structure a **domain-driven schema** for a realistic business use case.
- How to use PostgreSQL’s **bulk data generation** features (`generate_series`, `random`, `CROSS JOIN LATERAL`).
- How to quickly create **large, realistic datasets** for testing, learning, and performance work.
- How to use pgAdmin’s Query Tool to execute large scripts and validate results.

---

## 📁 Suggested File Naming

In your GitHub repo:

- Save this SQL as: `schema/01_day1_setup.sql`
- Save this README as: `docs/README_Day1.md` (or just `README_Day1.md` in root)

Example structure:

```bash
postgresql-dev-portfolio/
│
├── schema/
│   └── 01_day1_setup.sql
└── docs/
    └── README_Day1.md
```

---

You’re now ready for **Day 2**, where you’ll start writing **SELECT queries**, filtering, sorting, and exploring this dataset in depth.
