# DBA Expert Skills - AI Agent Framework

A skill-based agent framework for database performance analysis. The agent automatically loads and follows specialized methodologies based on your request type and database engine.

## 🚀 Quick Start

1. **Open this workspace in VS Code with GitHub Copilot**
2. **Attach your execution plan** (.sqlplan, .json, or paste XML/JSON)
3. **Ask:** "analyze my execution plan"
4. The agent will:
   - Detect your database engine
   - Load the appropriate skill methodology
   - Perform systematic analysis following best practices
   - Provide prioritized recommendations

## 📋 How It Works

This is a **skill-based framework** where the agent:

1. **Identifies** your database engine (SQL Server, PostgreSQL, MySQL/MariaDB)
2. **Maps** your request to a specific skill file using [agent-index.md](agent-index.md)
3. **Loads** the skill methodology from `skills/{engine}/{skill-name}.md`
4. **Executes** each check systematically (not from general knowledge)
5. **Recommends** diagnostic queries from `queries/{engine}/` when needed

The agent treats skill files as **executable procedures**, not documentation.

## 🎯 Supported Request Types

### Execution Plan Analysis
- **What:** Analyze query execution plans for performance issues
- **Files:** `.sqlplan` (SQL Server), JSON (PostgreSQL), `EXPLAIN` output (MySQL)
- **Example:** "analyze this execution plan" + attach file

### SQL Server Specific
- **sp_WhoIsActive Analysis** - Analyze sp_WhoIsActive output for blocking, waits
- **TempDB Analysis** - Review TempDB configuration and usage
- **Index Usage Review** - Evaluate index effectiveness
- **Missing Indexes** - Identify missing index opportunities

### General (All Engines)
- **Server Configuration Review** - Validate settings and configuration
- **Query Performance** - Identify slow queries when no plan available

## 📂 Framework Structure

```
dba-expert-skills/
├── .github/
│   ├── copilot-instructions.md    # Agent system prompt and skills protocol
│   └── skills/                    # Skill-based workflows
│       ├── sqlserver/
│       │   ├── analyze-execution-plan.md
│       │   ├── analyze-sp-whoisactive-output.md
│       │   ├── analyze-tempdb.md
│       │   ├── review-index-usage.md
│       │   ├── review-missing-indexes.md
│       │   └── review-server-configuration.md
│       ├── postgres/
│       │   └── analyze-execution-plan.md
│       ├── mysql/
│       │   └── analyze-execution-plan.md
│       └── standard/
│           └── standard.md        # Cross-skill DBA principles (P0/P1/P2 rules)
├── queries/                       # Diagnostic SQL queries
│   ├── sqlserver/
│   │   ├── expensive-queries.sql
│   │   ├── active-queries.sql
│   │   ├── blocking-chains.sql
│   │   ├── index-missing.sql
│   │   ├── index-usage-stats.sql
│   │   └── wait-stats.sql
│   ├── postgres/
│   │   ├── expensive-queries.sql
│   │   ├── active-queries.sql
│   │   ├── blocking-queries.sql
│   │   ├── table-stats.sql
│   │   └── index-unused.sql
│   └── mysql/
│       ├── expensive-queries.sql
│       ├── active-queries.sql
│       ├── blocking-locks.sql
│       ├── table-stats.sql
│       └── index-unused.sql
├── templates/
│   └── execution-plan-analysis.md # Template for analysis requests
├── assets/                        # Product schemas kept for reuse
│   └── insightia/schemas/
├── workspace/                     # Drop zone for your inputs, one folder per product
│   └── insightia/
├── README.md                      # This file
└── skills-summary.md              # Skills architecture documentation
```

## 🔧 Supported Engines

### SQL Server
- **Version:** SQL Server 2019 Enterprise (default assumption)
- **Workload:** OLTP (default assumption)
- **Analysis Types:** Execution plans, sp_WhoIsActive, TempDB, index usage

### PostgreSQL
- **Analysis Types:** EXPLAIN output, pg_stat_statements
- **Tools:** pg_stat_statements, query plans

### MySQL/MariaDB
- **Analysis Types:** EXPLAIN output, performance_schema
- **Tools:** performance_schema, slow query log

## 💡 Usage Examples

### Execution Plan Analysis
```
You: [attach ExecutionPlan.sqlplan]
You: "analyze my execution plan"

Agent:
- Detects SQL Server from .sqlplan extension
- Loads .github/skills/sqlserver/analyze-execution-plan.md
- Checks: SARG-ability, key lookups, parameter sniffing, 
         implicit conversions, ActualRows vs EstimatedRows,
         tempdb spills, wait statistics
- Provides prioritized recommendations
```

### Performance Investigation (No Plan Yet)
```
You: "my database is slow, where do I start?"

Agent:
- Suggests running queries/sqlserver/expensive-queries.sql
- Helps identify problem queries
- Guides you to capture execution plan
- Then performs execution plan analysis
```

### Blocking Issues
```
You: "users are experiencing timeouts"

Agent:
- Suggests queries/sqlserver/blocking-chains.sql
- Analyzes blocking hierarchy
- Recommends isolation level changes or query optimization
```

## 🎓 For Developers: Creating New Skills

1. **Create skill file:** `.github/skills/{engine}/{skill-name}.md`
2. **Add YAML frontmatter:**
   ```yaml
   ---
   name: skill-name
   description: What this skill does and when to use it
   ---
   ```
3. **Define methodology:**
   - When to use (triggers and user phrases)
   - Engine assumptions
   - Specific checks to perform (in order)
   - Constraints (what not to recommend)
   - Output format and prioritization

4. **Register in .github/copilot-instructions.md:**
   - Add to the `<skills>` section with proper metadata
   - Include description that matches frontmatter

5. **Create supporting queries** in `queries/{engine}/` if needed

6. **Follow standards:** Reference `.github/skills/standard/standard.md` for P0/P1/P2 rules

Example skill structure:
```markdown
---
name: analyze-execution-plan
description: Analyzes execution plans to identify performance issues
---

# Skill: Analyze Execution Plan

## When to use
- User provides execution plan
- Query performance issue reported

## Engine assumptions
- Version and edition
- Workload type

## Analysis steps
1. Check 1
2. Check 2
3. Check 3

## Constraints
- Don't recommend X unless requested
- Always assess risk level (LOW/MEDIUM/HIGH)

## Output format
- Follow standard.md template
- Prioritize low-risk changes first
```

## 📘 Philosophy

This framework ensures:
- **Consistency:** Every analysis follows the same methodology
- **Completeness:** No checks are skipped
- **Best Practices:** Skills encode expert knowledge
- **Adaptability:** Easy to add new engines, skills, and queries
- **Transparency:** Users see what checks were performed

The agent is **procedural**, not heuristic - it follows explicit instructions rather than relying solely on general knowledge.

---

## 📖 See Also

- [.github/copilot-instructions.md](.github/copilot-instructions.md) - Agent system prompt and skills protocol
- [.github/skills/standard/standard.md](.github/skills/standard/standard.md) - Cross-skill DBA principles and standards
- [skills-summary.md](skills-summary.md) - Detailed skills architecture documentation