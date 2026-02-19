---
name: analyze-sql-server-execution-plan
description: Analyzes SQL Server execution plans to identify performance bottlenecks including statistics issues, key lookups, parameter sniffing, implicit conversions, parallelism problems, and cardinality estimation errors. Use when user provides .sqlplan file or XML execution plan.
---

# Skill: Analyze SQL Server Execution Plan

This skill provides advanced execution plan analysis instructions for SQL Server.

## Context assumptions
- SQL Server 2019 Enterprise Edition unless stated otherwise
- OLTP workload unless stated otherwise
- User expects actionable recommendations with priority order

## Analysis workflow

### 1. Quick health check (first 30 seconds)
Extract and report these metrics immediately:
- **Execution time**: CPU time vs Elapsed time (if CPU << Elapsed, look for waits)
- **Row accuracy**: Largest ActualRows vs EstimatedRows discrepancies (ratio > 10x = critical)
- **Memory**: Check MemoryGrantInfo for `MaxUsedMemory` vs `GrantedMemory` (if close or exceeded, potential spill risk)
- **Parallelism**: Check DegreeOfParallelism and ThreadStat distribution (one thread >> others = skew)
- **Top waits**: If WaitStats present, focus on non-benign waits (CXPACKET, PAGEIOLATCH_*, SOS_SCHEDULER_YIELD)

### 2. Pattern recognition (match to known issues)

#### Pattern: Statistics stale or missing
**Indicators:**
- ActualRows / EstimatedRows ratio > 10x OR < 0.1x
- `ModificationCount` in OptimizerStatsUsage is high relative to table size (>20% changes)
- Statistics `LastUpdate` > 7 days old for active tables

**Response:**
```
IMMEDIATE ACTION: Update statistics on [TableName]
UPDATE STATISTICS [Schema].[Table] WITH FULLSCAN;

Then retest query. If estimates improve but plan doesn't change, check:
- Cardinality estimator version (CE 120 vs 130 vs 160)
- Trace flag 2453 for histogram amendments
```

#### Pattern: Key lookup storm
**Indicators:**
- Operators: Index Seek → Key Lookup (Clustered) → Nested Loops
- Key Lookup `EstimatedRows` > 1000
- Key Lookup cost > 30% of subtree cost

**Example from plan:**
```
Index Seek on IX_Orders_CustomerId (cost 0.5)
  → Key Lookup on PK_Orders (cost 45.2, 50,000 rows)
```

**Response:**
```
COVERING INDEX needed. Current index: IX_Orders_CustomerId (CustomerId)
Recommend adding INCLUDE columns for lookup columns.

CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_Covering
ON Orders(CustomerId)
INCLUDE (OrderDate, Status, TotalAmount, ShipAddress)
WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);
```

⚠️ **Warning**: This adds ~X MB index size. Review with skills/sqlserver/review-index-usage.md first.

#### Pattern: Scan + wide row + sort
**Indicators:**
- Large table scan (Clustered Index Scan with 100k+ rows)
- Followed by Sort operator with high cost
- ORDER BY columns not matching scan order
- AvgRowSize > 500 bytes

**Response:**
```
PROBLEM: Scanning and sorting 500k rows × 800 bytes/row in memory.

Options by impact:
1. REDUCE RESULT SET (best):
   - Add date filter: WHERE OrderDate >= DATEADD(day, -90, GETDATE())
   - Add pagination: OFFSET @Skip ROWS FETCH NEXT 50 ROWS ONLY

2. ALIGN SCAN WITH SORT:
   - Current: Scan on PK_Orders(OrderId ASC), Sort on OrderDate DESC
   - Create index: (OrderDate DESC) INCLUDE (commonly selected columns)
   
3. REDUCE ROW WIDTH:
   - Return only needed columns (currently selecting * = 45 columns)
```

#### Pattern: Parallel plan with extreme skew
**Indicators:**
- DegreeOfParallelism > 1
- In ThreadStat or RunTimeCountersPerThread: one thread ActualRows >> other threads
- CXPACKET wait time > 50% of elapsed time

**Example:**
```
Thread 0: ActualRows = 450,000
Thread 1: ActualRows = 8,000
Thread 2: ActualRows = 12,000
Thread 3: ActualRows = 5,000
Thread 4: ActualRows = 10,000
```

**Response:**
```
SKEWED PARALLELISM detected. Thread 0 processed 92% of rows.

Root cause likely:
- Data distribution skew on partition/hash column
- Non-uniform predicate (e.g., StatusId = 1 has 90% of rows)

Fixes:
1. If skew is data-inherent: Consider MAXDOP 1 or lower MAXDOP for THIS query pattern
2. Check if filtered index can isolate the hot value
3. Review partition strategy if table is partitioned
```

#### Pattern: Implicit conversion blocking seek
**Indicators:**
- Table/Index Scan with predicate
- Predicate shows CONVERT_IMPLICIT or CONVERT
- Estimated vs Actual rows are reasonable (so not stats issue)

**Example from plan:**
```xml
<Predicate>
  <ScalarOperator>
    CONVERT_IMPLICIT(nvarchar(50),[Table].[VarcharColumn],0)=@NVarcharParam
  </ScalarOperator>
</Predicate>
```

**Response:**
```
IMPLICIT CONVERSION preventing index seek.

Column type: VARCHAR(50)
Parameter type: NVARCHAR(50)

Fixes (in priority order):
1. Change application parameter from NVARCHAR to VARCHAR
2. If column should be NVARCHAR, alter table (requires testing):
   ALTER TABLE [Table] ALTER COLUMN [VarcharColumn] NVARCHAR(50);
3. As last resort, explicitly convert parameter in query:
   WHERE VarcharColumn = CAST(@Param AS VARCHAR(50))
```

#### Pattern: Parameter sniffing
**Indicators:**
- Plan shows specific parameter values in `<ParameterList>` (compiled for X)
- Plan reused from cache (`RetrievedFromCache="true"`)
- EstimatedRows wildly different from ActualRows for parameterized predicates
- Query performance varies dramatically between executions

**Response:**
```
PARAMETER SNIFFING detected. Plan compiled for @CustomerId = 12345, 
now executing with @CustomerId = 99999 (different data distribution).

Solutions (from least to most invasive):
1. UPDATE STATISTICS - if stats are stale
2. RECOMPILE for specific query: Add OPTION (RECOMPILE) if query is infrequent
3. OPTIMIZE FOR UNKNOWN: Makes optimizer use average density
4. USE QUERY STORE with automatic plan correction (SQL 2017+)
   - Only if workload has stable query patterns (not ad-hoc)
```

### 3. Cardinality estimation issues

**Thresholds:**
- **Minor**: 2x–10x off → probably okay
- **Moderate**: 10x–100x off → update stats, check for correlation
- **Severe**: >100x off → multi-column stats, JOIN issues, or complex predicates

**Response for severe:**
```
EstimatedRows: 100 | ActualRows: 45,000 (450x underestimate)

This usually means:
- Multi-column predicate with correlated columns (e.g., City + State)
- JOIN predicate assumptions broken
- Filtered index stats not used

Actions:
1. Create multi-column statistic:
   CREATE STATISTICS Stats_City_State ON Customers(City, State);
2. If filtered index exists, ensure query matches filter exactly
3. Consider trace flag 2453 or 9481 for additional histogram detail
```

### 4. Wait analysis

Interpret WaitStats and map to actionable changes:

| Wait Type | Threshold | Meaning | Action |
|-----------|-----------|---------|--------|
| CXPACKET | >40% elapsed | Parallel coordination overhead | Check thread skew; consider lower MAXDOP or query refactor |
| ASYNC_NETWORK_IO | >20% elapsed | Client slow to consume | Reduce result set size; check network/client app |
| PAGEIOLATCH_SH/EX | >30% elapsed | Disk reads | Missing index? Check for scans; review buffer pool hit ratio |
| SOS_SCHEDULER_YIELD | >15% CPU time | CPU pressure | Check MAXDOP, optimize CPU-heavy operators (sorts, hashes) |
| LCK_M_* | Any significant | Blocking | Use queries/sqlserver/blocking-chains.sql to find head blocker |

## Output format

Structure every analysis as:

### Summary
- Query cost: [value]
- Execution time: CPU [x] ms / Elapsed [y] ms
- Rows returned: Estimated [X] / Actual [Y]
- Top bottleneck: [operator name and cost %]

### Critical issues (fix these first)
1. **[Issue type]**: [brief description]
   - Evidence: [what you see in plan]
   - Impact: [why it's slow]
   - Fix: [concrete code or action]
   - Risk: [LOW/MEDIUM/HIGH + explanation]

### Optimization opportunities (lower priority)
- Ordered by effort/impact ratio

### Verification steps
```sql
-- Specific query to run after changes
-- Include expected improvement metrics
```

### Follow-up analysis needed
- [ ] Run queries/sqlserver/expensive-queries.sql to compare before/after
- [ ] Use skills/sqlserver/review-index-usage.md before creating index
- [ ] Check queries/sqlserver/wait-stats.sql for server-wide patterns

## Constraints
- NEVER recommend query hints (FORCE ORDER, MAXDOP, etc.) as first solution
- ALWAYS prioritize low-risk changes: stats updates, query WHERE clause additions, pagination
- WARN when suggesting indexes wider than 3-4 INCLUDE columns or keys > 900 bytes
- CHECK if LEFT JOIN can become INNER JOIN when WHERE clause filters out NULLs
- For Enterprise Edition, ALWAYS include `WITH (ONLINE = ON)` for index operations

## When to escalate / defer
- If multiple patterns overlap (e.g., bad stats + implicit conversion + skew), fix stats FIRST, retest, then re-analyze
- If plan shows missing index recommendations but they're extremely wide (>10 columns), suggest reviewing actual query usage patterns before implementing
- If query is fundamentally doing too much work (cartesian join, no filter), state that index tuning won't fix architectural issues