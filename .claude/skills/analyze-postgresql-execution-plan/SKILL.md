---
name: analyze-postgresql-execution-plan
description: Analyzes PostgreSQL EXPLAIN output to identify sequential scans, join strategy issues, bitmap index usage, planner row estimate inaccuracies, and statistics problems. Use when user provides EXPLAIN or EXPLAIN ANALYZE output for PostgreSQL.
---

# Skill: Analyze PostgreSQL Execution Plan

This skill extends the shared execution plan analysis skill with PostgreSQL-specific behavior.

## Engine assumptions
- PostgreSQL
- EXPLAIN or EXPLAIN ANALYZE output

## PostgreSQL-specific checks
- Seq Scan vs Index Scan usage
- Nested Loop vs Hash Join choice
- Rows removed by filter
- Bitmap index usage
- Planner row estimate accuracy

## Statistics considerations
- Outdated or insufficient statistics
- ANALYZE recommendations
- Correlated column issues

## Constraints
- Do not suggest planner hints
- Assume default planner settings unless stated otherwise

## Output additions
- Identify planner misestimates
- Recommend ANALYZE or query rewrites where appropriate
