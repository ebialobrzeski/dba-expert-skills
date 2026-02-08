# Skill: Analyze sp_WhoIsActive Output

## When to use
- The user provides output from sp_WhoIsActive
- The user is investigating blocking, long-running queries, high CPU usage, or concurrency issues
- As a companion to execution plan analysis

## Goal
Identify active performance issues in SQL Server by analyzing session-level runtime data from sp_WhoIsActive output.

## Inputs expected
- sp_WhoIsActive result set (grid output or text export)
- Optional: capture time or repeated samples
- Optional: related query text or execution plan

## Analysis steps
1. Identify the most resource-intensive sessions
   - CPU
   - Reads
   - Writes
   - Elapsed time
2. Identify blocking chains
   - Head blockers
   - Long blocking durations
3. Examine wait types and wait resources
4. Identify idle vs actively running sessions
5. Detect common problem patterns:
   - CXPACKET / CXCONSUMER
   - PAGEIOLATCH
   - LCK_M_*
   - WRITELOG
6. Correlate session activity to query text when available
7. Determine whether issues are transient or systemic

## Key columns to inspect
- session_id
- login_name
- status
- wait_info
- blocking_session_id
- cpu
- reads / writes
- elapsed_time
- query_text

## Heuristics
- High elapsed time with low CPU often indicates blocking or waits
- High CPU with low reads suggests inefficient computation
- Many blocked sessions often point to a single root blocker
- Repeated long-running sessions indicate workload or index issues

## Constraints
- Do not recommend killing sessions unless explicitly requested
- Do not assume application bugs without evidence
- Avoid speculative conclusions
- State assumptions clearly if data is incomplete

## Output format
### Summary
- Primary issue observed
- Scope of impact

### Findings
- Session or pattern identified
- Evidence from output
- Why it matters

### Recommendations
- Immediate actions (low risk)
- Follow-up investigation steps
- Whether execution plan analysis is recommended

### Follow-up questions
Ask only if critical information is missing.
