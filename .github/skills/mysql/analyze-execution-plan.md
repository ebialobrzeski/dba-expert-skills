---
name: analyze-mysql-execution-plan
description: Analyzes MySQL EXPLAIN output to identify full table scans, index usage issues, filesorts, temporary tables, join order problems, and access type inefficiencies. Use when user provides EXPLAIN or EXPLAIN ANALYZE output for MySQL or MariaDB.
---

# Skill: Analyze MySQL Execution Plan

This skill extends the shared execution plan analysis skill with MySQL-specific behavior.

## Engine assumptions
- MySQL
- InnoDB storage engine
- EXPLAIN or EXPLAIN ANALYZE output

## MySQL-specific checks
- Full table scans
- Index usage and key selection
- Filesort and temporary tables
- Join order issues
- Access types (ALL, range, ref, eq_ref)

## Optimizer considerations
- Index selectivity
- Composite index column order
- Covering index opportunities

## Constraints
- Avoid optimizer hints unless explicitly requested
- Avoid redundant or overlapping indexes

## Output additions
- Highlight access type
- Identify missing or misordered indexes
