# DBA Agent Workspace

This folder contains skills and queries for analyzing database performance issues.

## How to use
1. Open this repository in VS Code
2. State the database engine (MySQL, SQL Server, PostgreSQL)
3. Paste your problem and relevant information/output (execution plan, sp_WhoIsActive output, etc.)
4. Ask the agent to analyze it

## Rules for the agent
- **Read agent-index.md first** to determine engine → skill mapping and load order
- Identify the database engine first
- Load engine-specific skills before analysis (see agent-index.md)
- Do not guess schema or indexes not shown in the plan
- Recommend diagnostic queries when more information is needed

## Supported Engines
- **MySQL/MariaDB** - EXPLAIN analysis, performance_schema queries
- **SQL Server** - Execution plan analysis, sp_WhoIsActive, DMV queries
- **PostgreSQL** - EXPLAIN analysis, pg_stat_statements queries

See [agent-index.md](agent-index.md) for complete engine → skill mapping and available queries.