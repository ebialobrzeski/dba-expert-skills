# Skills Architecture Summary

## Overview

This document describes the skill-based agent architecture implemented in the `.claude` directory. It provides domain-specific database performance analysis workflows that Claude Code discovers and executes automatically based on the request type and database engine.

The architecture enables:

- **Autonomous skill discovery** - Claude reads each skill's `description` frontmatter to find the relevant workflow
- **Consistent execution** - Skills provide standard, repeatable procedures for common DBA tasks
- **Progressive disclosure** - The bootstrap file (`CLAUDE.md`) lists skills by name; full procedures load only when a skill is invoked
- **Shared standards** - A single `dba-standard` skill holds the cross-cutting P0/P1/P2 rules and output template, so individual skills don't duplicate them
- **Evidence-based analysis** - Skills require recommendations to cite data actually present in the provided plan/DMV output

---

## Directory Structure

```
dba-expert-skills/
├── CLAUDE.md                     # Bootstrap instructions: engine detection + skill routing
├── skills-summary.md             # This document
├── README.md                     # Human-facing project overview
├── .claude/
│   ├── skills/                   # One folder per skill; each holds a SKILL.md
│   │   ├── dba-standard/SKILL.md                    # Shared P0/P1/P2 rules + output template
│   │   ├── analyze-sql-server-execution-plan/SKILL.md
│   │   ├── analyze-mysql-execution-plan/SKILL.md
│   │   ├── analyze-postgresql-execution-plan/SKILL.md
│   │   ├── analyze-sp-whoisactive-output/SKILL.md
│   │   ├── analyze-tempdb/SKILL.md
│   │   ├── review-index-usage/SKILL.md
│   │   ├── review-missing-indexes/SKILL.md
│   │   ├── review-server-configuration/SKILL.md
│   │   ├── entities-report-script-builder/SKILL.md
│   │   └── idn-create-user-add-script/SKILL.md
│   └── assets/                   # Supporting files referenced by skills
│       └── entities/
│           └── DatabaseSchema.sql                    # Sample schema for the report builder
├── queries/                      # Diagnostic queries suggested by skills, per engine
│   ├── sqlserver/                # expensive-queries, active-queries, blocking-chains,
│   │                             #   index-missing, index-usage-stats, wait-stats
│   ├── postgres/                 # expensive-queries, active-queries, blocking-queries,
│   │                             #   table-stats, index-unused
│   └── mysql/                    # expensive-queries, active-queries, blocking-locks,
│                                 #   table-stats, index-unused├── assets/                       # Product schemas saved for reuse: <product-name>/schemas/
│   └── insightia/schemas/
├── workspace/                    # User drop zone for analysis inputs: <product-name>/
│   └── insightia/└── templates/
    └── execution-plan-analysis.md
```

> Note: This repository was converted from a GitHub Copilot layout (`.github/skills/`,
> `copilot-instructions.md`). The `.github` copy is retained for reference; `.claude` is the
> active Claude Code framework.

---

## Core Components

### 1. CLAUDE.md (Bootstrap)

The entry point Claude Code loads automatically. It defines:

- The **Skills Protocol** — identify engine, match request to a skill, invoke it, follow the procedure, and always load `dba-standard`
- The **skill routing table** — which skill handles each request type and engine
- **Sample requests** by type and the **request-type → skill mapping**
- The catalog of **diagnostic queries** under `queries/` and **when to suggest** each

Skills are invoked by name; Claude discovers them from their `description`, so `CLAUDE.md`
does not hard-code file paths for loading.

### 2. Skills (`.claude/skills/<name>/SKILL.md`)

Each skill is a self-contained directory holding a `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: Third-person statement of what the skill does AND when to use it (the trigger).
---
```

The `description` is critical — it is what Claude matches against a user request to decide
whether to invoke the skill, so it must state both the capability and the trigger conditions.

### 3. Shared Standard (`dba-standard`)

`dba-standard` is a skill loaded alongside every analysis. It centralizes:

- **Rule hierarchy** — P0 (critical, always), P1 (important, document exceptions), P2 (best practice)
- **Risk assessment** — every recommendation labeled LOW / MEDIUM / HIGH
- **Evidence-based analysis** — never recommend against assumptions; cite the provided data
- **Output template** — Summary → Critical Issues → Optimization Opportunities → Verification → Follow-up
- **Anti-patterns** — speculative recommendations, query hints as first solution, mixing engine patterns, etc.

### 4. Assets (`.claude/assets/`)

Supporting files skills reference but that aren't procedures themselves. Kept in a top-level
`assets/` folder (mirroring the source `.github` layout) rather than inside skill folders. Current
contents: `entities/DatabaseSchema.sql`, referenced by `entities-report-script-builder`.

Product database schemas live in a separate repo-root `assets/<product-name>/schemas/` folder.
`review-missing-indexes` looks there first and, when the user supplies a schema for a product not
yet stored, saves it there so later reviews can validate index recommendations without re-asking.
Analysis inputs the user supplies for a single review (query output, execution plans, notes) go in
`workspace/<product-name>/`; file names are free-form and the skill classifies them by content.
Currently scaffolded product: **insightia**.

### 5. Diagnostic Queries (`queries/<engine>/`)

Ready-to-run `.sql` files, grouped by engine, that skills suggest when analysis needs more data
(e.g. `expensive-queries`, `active-queries`, blocking analysis, index/stats queries). `CLAUDE.md`
documents when each is appropriate.

---

## Skill Catalog

| Skill | Engine | Purpose |
|-------|--------|---------|
| `analyze-sql-server-execution-plan` | SQL Server | Execution plan analysis: stats, key lookups, parameter sniffing, implicit conversions, parallelism, cardinality |
| `analyze-mysql-execution-plan` | MySQL/MariaDB | EXPLAIN analysis: full scans, index usage, filesorts, temp tables, join order, access types |
| `analyze-postgresql-execution-plan` | PostgreSQL | EXPLAIN analysis: seq scans, join strategy, bitmap index usage, planner estimate accuracy, stats |
| `analyze-sp-whoisactive-output` | SQL Server | Blocking chains, resource-intensive sessions, wait patterns from sp_WhoIsActive |
| `analyze-tempdb` | SQL Server | TempDB configuration, PAGELATCH contention, version store, spills |
| `review-index-usage` | SQL Server | Identify unused, rarely used, and redundant indexes |
| `review-missing-indexes` | SQL Server | Guided review: missing-index DMV stats + index usage + product schema, duplicate/consolidation rules (R1-R5), ONLINE and rollback guidance |
| `review-server-configuration` | SQL Server | Instance settings: memory, parallelism, TempDB, database options |
| `entities-report-script-builder` | SQL Server | Generate a script that runs a query across many databases and aggregates results |
| `idn-create-user-add-script` | SQL Server | Generate the `dev.AdmAddUser` execution script (TeamCode always `'BA'`) |
| `dba-standard` | All | Shared P0/P1/P2 rules, risk assessment, output template — load with every analysis |

---

## Agent Workflow

1. **Identify engine** — MySQL/MariaDB, SQL Server, or PostgreSQL; ask if not stated
2. **Identify request type** — execution plan, sp_WhoIsActive, blocking, config review, script generation
3. **Invoke the specific skill** — only the one matching the engine and request type
4. **Load `dba-standard`** — apply cross-skill rules and the output template
5. **Analyze** — follow the skill's procedure systematically; don't skip steps
6. **Suggest diagnostic queries** — from `queries/<engine>/` only when more data is needed

---

## Key Patterns & Principles

### Discovery over hard-coding
Skills are found on demand via their `description` frontmatter, keeping `CLAUDE.md` small and
maintainable rather than embedding every procedure inline.

### Progressive disclosure
`CLAUDE.md` carries only the routing table and query catalog. A skill's full procedure loads only
when invoked; large supporting content lives in `assets/` or `queries/`.

### Evidence before assertions
Per `dba-standard` P0.1, recommendations must cite what appears in the provided plan/DMV/config
output. Guessing schema, indexes, or statistics from names is prohibited.

### Risk-labeled, safety-gated recommendations
Every recommendation carries a LOW/MEDIUM/HIGH risk level (P0.3), and destructive actions (dropping
indexes, changing recovery models, killing sessions) require an explicit warning (P0.2).

### Engine isolation
Never blend SQL Server, PostgreSQL, and MySQL tuning patterns in one analysis (P0.4). Each engine
has its own skill.

### Frontmatter metadata
Every `SKILL.md` uses `name` + `description` frontmatter so the skill is machine-discoverable.

---

## Adding or Modifying Skills

1. Create `.claude/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Write a `description` that states both what the skill does and when to use it (its trigger).
3. Put any supporting files under `.claude/assets/<area>/` and reference them by path from the skill.
4. Add the skill to the routing table in `CLAUDE.md` (and to the catalog in this file).
5. Ensure the skill follows `dba-standard` for structure, risk assessment, and output format.
6. If the skill relies on diagnostic data, point to the relevant file(s) under `queries/<engine>/`.

---

**Document Version**: 2.0
**Last Updated**: 2026-07-01
**Framework**: Claude Code (`.claude/skills`), converted from GitHub Copilot (`.github/skills`)
