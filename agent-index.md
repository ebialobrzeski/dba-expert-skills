# DBA Agent Index

**Purpose:** Request-based skill routing and query recommendations.

---

## Request Type → Skill Mapping

**Execution Plan Analysis**
- MySQL: skills/mysql/analyze-execution-plan.md
- SQL Server: skills/sqlserver/analyze-execution-plan.md
- PostgreSQL: skills/postgres/analyze-execution-plan.md

**sp_WhoIsActive Output Analysis** (SQL Server only)
- SQL Server: skills/sqlserver/analyze-sp-whoisactive-output.md

---

## Available Diagnostic Queries by Engine

### MySQL/MariaDB
- queries/mysql/expensive-queries.sql - Identify slowest queries by total execution time
- queries/mysql/active-queries.sql - Current running queries snapshot
- queries/mysql/blocking-locks.sql - Identify lock waits and blocking sessions
- queries/mysql/table-stats.sql - Table size and statistics information
- queries/mysql/index-unused.sql - Find indexes not being used

---

### SQL Server
- queries/sqlserver/expensive-queries.sql - Top queries by CPU, duration, and reads
- queries/sqlserver/active-queries.sql - Current executing requests
- queries/sqlserver/blocking-chains.sql - Blocking hierarchy and head blockers
- queries/sqlserver/index-missing.sql - Missing index recommendations from DMVs
- queries/sqlserver/wait-stats.sql - Wait statistics breakdown

---

### PostgreSQL
- queries/postgres/expensive-queries.sql - Slowest queries from pg_stat_statements
- queries/postgres/active-queries.sql - Currently active backend processes
- queries/postgres/blocking-queries.sql - Lock conflicts and blocking sessions
- queries/postgres/table-stats.sql - Table bloat and statistics
- queries/postgres/index-unused.sql - Unused and redundant indexes

---

## Agent Workflow

1. **Identify engine** - Ask user if not mentioned (MySQL, SQL Server, PostgreSQL)
2. **Identify request type** - Determine what the user is asking for (execution plan analysis, sp_WhoIsActive output, general performance issue)
3. **Load specific skill** - Use the "Request Type → Skill Mapping" above to load only the relevant skill file
4. **Analyze** - Apply the methodology from the loaded skill
5. **Recommend queries** - Load and suggest specific queries only when more data is needed (see "When to Suggest Queries")

**Critical rules:**
- Load only the specific skill needed for the request type, not all skills for the engine
- Load query files only when recommending them to the user
- Never guess schema or indexes not in the plan
- Factor operational constraints if user mentions them (recovery model, HA, backup windows)

---

## When to Suggest Queries

### Performance Investigation - No Specific Query Yet
- **expensive-queries** - User reports general slowness, needs to identify problem queries
- **active-queries** - User needs current snapshot of running queries

### Following Execution Plan Analysis
- **table-stats** - Plan shows outdated statistics or unexpected cardinality estimates
- **index-unused** - Identified redundant or overlapping indexes in the plan
- **index-missing** (SQL Server) - Plan includes missing index recommendations

### Concurrency Issues
- **blocking-locks** (MySQL) / **blocking-queries** (PostgreSQL) / **blocking-chains** (SQL Server) - User reports blocking, deadlocks, or timeouts
- **active-queries** - Supplement blocking analysis with current session state

### SQL Server Specific
- **wait-stats** - High wait times observed, need to identify wait type patterns
- Use **sp_WhoIsActive** analysis skill if user provides that output

### Query Before Analyzing
Suggest running the appropriate expensive-queries or active-queries first if:
- User describes symptoms but hasn't shared specific query or execution plan
- User asks "where do I start?" or "how do I find the problem?"
