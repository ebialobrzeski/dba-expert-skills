# Analysis Queries

This folder contains production-safe diagnostic queries for identifying performance issues across SQL Server, PostgreSQL, and MySQL.

## Overview

Each subfolder contains queries specific to that database engine:
- **sqlserver/** - SQL Server 2019+ queries
- **postgres/** - PostgreSQL queries
- **mysql/** - MySQL (InnoDB) queries

All queries are read-only and safe to run in production environments during troubleshooting.

---

## SQL Server Queries

### active-queries.sql
Identifies currently executing queries with execution plans and resource consumption.

**Use when:**
- Investigating slow query performance
- Identifying high CPU or I/O consumers
- Need to see what's running right now

**Output includes:** session info, query text, CPU time, reads, writes, wait type, execution plan

### blocking-chains.sql
Shows blocking hierarchies and identifies head blockers.

**Use when:**
- Users report query timeouts
- Investigating deadlocks or blocking
- Need to see who is blocking whom

**Output includes:** blocking chain visualization, wait times, wait resources

### expensive-queries.sql
Top queries by total CPU time from the plan cache.

**Use when:**
- Identifying queries to optimize
- Understanding cumulative resource usage
- Finding queries that run frequently but inefficiently

**Output includes:** execution count, CPU time, logical reads, elapsed time, query text, plans

### index-missing.sql
Missing index recommendations from SQL Server optimizer.

**Use when:**
- Query performance is poor despite proper statistics
- Looking for quick optimization opportunities
- Planning index maintenance

**Output includes:** impact estimate, suggested index definition, CREATE statement

**Warning:** Review carefully before implementing. Consider write overhead and index overlap.

### wait-stats.sql
Aggregated wait statistics showing what SQL Server is waiting on.

**Use when:**
- Understanding system-level bottlenecks
- Baseline performance analysis
- Comparing before/after changes

**Output includes:** wait types, wait times, signal waits, percentage of total

---

## PostgreSQL Queries

### active-queries.sql
Currently executing queries with wait events and runtime.

**Use when:**
- Identifying long-running queries
- Checking current database activity
- Understanding wait events

**Output includes:** PID, username, application, state, wait events, query text

### blocking-queries.sql
Lock waits and blocking relationships.

**Use when:**
- Investigating query hangs
- Finding lock contention
- Identifying blocking sessions

**Output includes:** blocked/blocking PIDs, users, query text, wait duration

### table-stats.sql
Table sizes, index usage, and maintenance statistics.

**Use when:**
- Planning VACUUM or ANALYZE operations
- Understanding table bloat
- Evaluating index effectiveness

**Output includes:** table/index sizes, scan counts, dead tuples, last maintenance times

### index-unused.sql
Indexes that have never been scanned.

**Use when:**
- Reducing storage overhead
- Improving write performance
- Planning index cleanup

**Output includes:** index name, size, table size

**Warning:** Excludes primary keys. Some indexes may be for constraints or future use.

### expensive-queries.sql
Top queries by execution time from pg_stat_statements.

**Use when:**
- Identifying optimization targets
- Understanding query patterns
- Comparing query performance over time

**Requires:** pg_stat_statements extension

**Output includes:** queryid, execution time stats, rows, cache hit ratio, I/O stats

---

## MySQL Queries

### active-queries.sql
Currently running queries from processlist.

**Use when:**
- Checking current database activity
- Finding long-running queries
- Investigating performance issues

**Output includes:** connection ID, user, database, duration, state, query text

### blocking-locks.sql
InnoDB lock waits and blocking transactions.

**Use when:**
- Investigating query timeouts
- Finding lock contention
- Understanding transaction isolation issues

**Output includes:** waiting/blocking transaction IDs, threads, queries, duration

### table-stats.sql
Table and index sizes from information_schema.

**Use when:**
- Understanding storage usage
- Planning capacity
- Identifying large tables

**Output includes:** table sizes (data + indexes), row counts, engine, timestamps

### index-unused.sql
Indexes with no recorded usage from performance_schema.

**Use when:**
- Reducing index overhead
- Improving INSERT/UPDATE performance
- Planning index cleanup

**Requires:** performance_schema enabled

**Output includes:** schema, table, index name, size

**Warning:** Excludes PRIMARY keys. Statistics reset on server restart.

### expensive-queries.sql
Top queries by total execution time from statement digests.

**Use when:**
- Finding optimization candidates
- Understanding workload patterns
- Baseline performance analysis

**Requires:** performance_schema and statement digests enabled

**Output includes:** execution time stats, rows examined/sent, temp tables, sorts

---

## General Usage Notes

### Safety
- All queries are read-only and production-safe
- Queries may consume resources on busy systems
- Consider running during maintenance windows for baseline analysis

### Performance Impact
- DMV/system view queries have minimal overhead
- Some queries scan metadata or aggregate statistics
- Large result sets may impact network/client resources

### Prerequisites
Some queries require:
- **SQL Server:** VIEW SERVER STATE permission
- **PostgreSQL:** pg_stat_statements extension for expensive-queries.sql
- **MySQL:** performance_schema enabled for some queries

### Customization
Queries can be modified to:
- Adjust TOP/LIMIT values
- Filter by database/schema
- Change sort order
- Add/remove columns

### Automation
These queries can be:
- Logged to tables for trending
- Scheduled for baseline capture
- Integrated into monitoring solutions
- Used in alerting workflows

---

## Related Skills

These queries support the following analysis skills:
- **SQL Server:** analyze-execution-plan.md, analyze-sp-whoisactive-output.md
- **PostgreSQL:** analyze-execution-plan.md
- **MySQL:** analyze-execution-plan.md

Use these queries to gather context before requesting execution plan analysis or when investigating runtime performance issues.
