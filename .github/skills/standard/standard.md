# DBA Skills Standard

This document defines cross-skill standards that apply to all DBA performance analysis skills.

---

## Rule Hierarchy

- **P0 (Critical)**: Must always follow - these prevent incorrect analysis and recommendations
- **P1 (Important)**: Follow unless you have a documented exception
- **P2 (Best Practice)**: Follow when practical and appropriate

---

## P0 Rules (Critical - Always Follow)

### P0.1: Evidence-Based Analysis
**What**: Never recommend changes based on assumptions. Only cite issues that appear in provided data (execution plans, DMV output, configuration dumps).

**Why**: Guessing schema, indexes, or statistics based on table/column names leads to incorrect recommendations.

**Example**:
❌ Bad: "The Orders table probably needs an index on CustomerId"
✅ Good: "The execution plan shows a clustered index scan on Orders with 500k ActualRows filtering to 12 rows. The predicate is on CustomerId without an index seek."

### P0.2: No Destructive Actions Without Warning
**What**: Always warn users and require confirmation before recommending:
- Dropping indexes (provide rollback scripts)
- Changing recovery models
- Killing sessions
- Force operations (FORCE ORDER, --force recompile, etc.)

**Why**: These actions can impact availability, data safety, or require significant effort to reverse.

### P0.3: Risk Assessment Required
**What**: Every recommendation must include a risk assessment:
- **LOW**: Statistics updates, query rewrites, adding WHERE clauses
- **MEDIUM**: Creating indexes (with ONLINE if Enterprise), query hints
- **HIGH**: Dropping indexes, schema changes, trace flags, configuration changes requiring restart

**Why**: Users need to understand potential impact before implementing changes.

### P0.4: Engine-Specific Analysis
**What**: Load and follow only the skill file matching the database engine. Do not mix patterns from different engines.

**Why**: Each engine has different optimizer behavior, syntax, and tuning approaches.

**Example**: Don't reference SQL Server's sp_WhoIsActive when analyzing a PostgreSQL issue.

### P0.5: Operational Constraints Matter
**What**: When users mention operational constraints, factor them into recommendations:
- Maintenance windows
- High availability requirements
- Recovery model
- 24/7 operations
- Read replicas or replication

**Why**: The "best" technical solution may be impractical given operational requirements.

**Example**: If user mentions "24/7 OLTP with AlwaysOn AG", recommend `WITH (ONLINE = ON)` for index operations and note replication delay impact.

---

## P1 Rules (Important - Follow Unless Exception Documented)

### P1.1: Prioritize Low-Risk Changes
**What**: Structure recommendations from safest to most impactful:
1. Statistics updates (safe, quick, reversible)
2. Query modifications (SELECT column list, WHERE filters, pagination)
3. Index additions (with ONLINE option if available)
4. Configuration changes (test in non-prod first)
5. Schema changes (coordinate with development teams)

**Why**: Users prefer quick wins and risk-averse approaches first.

### P1.2: Validate Before Recommending
**What**: Check for conditions that invalidate common recommendations:
- Is statistics update needed or are stats already current?
- Does a similar index already exist?
- Would a filtered index be more appropriate?
- Is the query returning too many rows to benefit from indexing?

**Why**: Prevents recommending unnecessary or duplicate changes.

### P1.3: Quantify Impact
**What**: Provide specific metrics when possible:
- Execution time (CPU ms, Elapsed ms)
- Rows affected (EstimatedRows vs ActualRows)
- Cost percentages (operator cost, subtree cost)
- Wait time (CXPACKET, PAGEIOLATCH, etc.)
- Resource consumption (reads, writes, memory grant)

**Why**: Helps users prioritize and measure improvement.

### P1.4: Suggest Diagnostic Queries
**What**: When analysis reveals potential issues but lacks complete data, suggest relevant diagnostic queries from the queries/ directory:
- expensive-queries.sql - Identify slowest queries
- active-queries.sql - Current executing queries
- blocking-chains.sql / blocking-queries.sql / blocking-locks.sql - Blocking analysis
- table-stats.sql - Statistics information
- index-unused.sql / index-missing.sql - Index analysis

**Why**: More data enables better analysis and recommendations.

### P1.5: Follow Skill Structure
**What**: All skills should contain these sections:
- **When to use**: Specific triggers and user phrases
- **Goal**: What the skill accomplishes
- **Inputs expected**: Required and optional information
- **Analysis steps**: Ordered procedure to follow
- **Constraints**: What not to recommend
- **Output format**: How to present findings

**Why**: Consistency makes skills predictable and maintainable.

### P1.6: Consider Write Impact
**What**: When recommending indexes, calculate and communicate the write overhead:
- How many writes (INSERTs, UPDATEs, DELETEs) occur on the table?
- What is the read/write ratio?
- Is this an OLTP or OLAP workload?

**Why**: Over-indexing hurts write performance and increases maintenance overhead.

---

## P2 Rules (Best Practice - Follow When Practical)

### P2.1: Explain Root Cause
**What**: Don't just identify symptoms; explain why the issue occurs.

**Example**:
❌ Symptom only: "Query is slow because of a clustered index scan"
✅ With root cause: "Query performs a clustered index scan (500k rows) because the predicate on StatusId uses an NVARCHAR parameter but the column is VARCHAR, causing an implicit conversion that prevents index seek"

### P2.2: Provide Examples
**What**: Include concrete SQL examples in recommendations:
- Index creation scripts with proper syntax
- Query rewrites showing before/after
- Configuration commands with appropriate options

**Why**: Users can implement immediately without syntax research.

### P2.3: Version and Edition Awareness
**What**: Note when features or recommendations depend on SQL Server edition or version:
- `WITH (ONLINE = ON)` requires Enterprise Edition
- Automatic plan correction requires SQL Server 2017+
- Filtered indexes require SQL Server 2008+
- Resource Governor requires Enterprise Edition

**Why**: Prevents recommending unavailable features.

### P2.4: Suggest Testing Approach
**What**: Recommend how to validate changes:
- Test in non-production first
- Capture baseline metrics before change
- Monitor specific metrics after change
- Use Database Experimentation Assistant (DEA) for regression testing
- Enable Query Store for plan comparison

**Why**: Ensures changes deliver expected benefits and catch regressions.

### P2.5: Consolidation Over Proliferation
**What**: When multiple similar issues exist, suggest consolidated solutions:
- Combine multiple narrow missing indexes into one covering index
- Identify patterns across multiple queries that share common optimization
- Suggest multi-column statistics for correlated predicates

**Why**: Reduces index bloat and maintenance overhead.

### P2.6: Progressive Disclosure
**What**: Start with summary and high-level findings, provide detailed evidence on request:
- Lead with 2-3 most critical issues
- Offer deeper analysis if user wants details
- Don't overwhelm with every minor observation

**Why**: Matches information density to user needs and avoids overwhelming output.

---

## Output Template

All analysis output should follow this structure:

```markdown
### Summary
- Primary metric: [query cost, execution time, etc.]
- Key bottleneck: [specific issue]
- Overall assessment: [1-2 sentences]

### Critical Issues (High Priority)
1. **[Issue Type]**: [Brief description]
   - **Evidence**: [What appears in the plan/data]
   - **Impact**: [Why this matters - quantified if possible]
   - **Fix**: [Specific action with SQL example]
   - **Risk**: [LOW/MEDIUM/HIGH + explanation]

### Optimization Opportunities (Lower Priority)
- [List ordered by effort/impact ratio]

### Verification Steps
```sql
-- Specific queries to validate improvement
-- Include expected results or metrics
```

### Follow-up Analysis
- [ ] Run [specific diagnostic query] to gather [missing data]
- [ ] Check [related aspect] if issue persists
```

---

## Skill Communication Standards

### When to Load Additional Skills
- Load other skills when analysis reveals related issues requiring specialized expertise
- Example: After execution plan analysis identifies unused indexes, load `review-index-usage` skill

### When to Suggest Queries
- When analysis identifies a pattern but lacks complete data
- When user describes symptoms but hasn't provided specific artifacts
- When follow-up investigation is needed to confirm hypotheses

### When to Ask for Clarification
- Database engine not specified (MySQL/MariaDB, SQL Server, PostgreSQL)
- Workload type unclear when it impacts recommendations (OLTP vs OLAP)
- Missing critical context (server specs, HA configuration, maintenance windows)
- User expectation unclear (troubleshooting vs optimization vs general review)

---

## Anti-Patterns to Avoid

### ❌ Speculative Recommendations
Don't recommend changes based on general knowledge without evidence in provided data.

### ❌ Query Hints as First Solution
Avoid suggesting optimizer hints (FORCE ORDER, MAXDOP, RECOMPILE hints) as initial recommendations. Fix root causes first.

### ❌ Over-Engineering
Don't suggest complex solutions (query store, plan guides, custom statistics) when simple fixes (update statistics, add WHERE clause) would work.

### ❌ Generic Advice
Don't provide boilerplate tuning advice ("consider indexes", "check statistics"). Be specific with evidence from actual data.

### ❌ Mixing Engine Patterns
Don't blend PostgreSQL, MySQL, and SQL Server recommendations in the same analysis.

### ❌ Skipping Risk Assessment
Never recommend changes without stating the risk level and potential impact.

---

## Skill Discovery Protocol

When user request arrives:

1. **Identify engine** - Ask if not explicitly mentioned
2. **Identify request type** - Determine the specific task (execution plan analysis, blocking analysis, configuration review, etc.)
3. **Load specific skill** - Use the skills mapping in copilot-instructions.md
4. **Follow skill procedure** - Execute checks systematically, don't skip steps
5. **Validate completeness** - Ensure all critical checks performed before concluding

---

## Maintenance and Evolution

### When to Update This Standard
- New cross-skill pattern identified
- Common mistake observed across multiple skills
- New engine version introduces capabilities affecting multiple skills
- User feedback indicates missing guidance

### Version History
- **v1.0** (2026-02-12): Initial standard for DBA expert skills framework
