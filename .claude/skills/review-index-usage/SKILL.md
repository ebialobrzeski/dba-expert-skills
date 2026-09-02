---
name: review-index-usage
description: Reviews SQL Server index usage statistics to identify unused, rarely used, and redundant indexes that consume resources without providing query benefits. Use for periodic index cleanup, database size concerns, or slow write operations.
---

# Skill: Review Index Usage and Identify Unused Indexes for SQL Server

## When to use
- Periodic index maintenance and cleanup
- Database size concerns
- Slow write operations (INSERT, UPDATE, DELETE)
- Index maintenance windows taking too long
- Following performance assessment or missing index implementation

## Goal
Identify unused, rarely used, and redundant indexes that consume resources without providing query performance benefits, and provide recommendations for consolidation or removal.

## Inputs expected
- sys.dm_db_index_usage_stats data
- sys.indexes catalog view
- Database size and growth patterns
- Index maintenance statistics (rebuild/reorg duration)
- Workload type (OLTP, OLAP, mixed)
- Server restart/stats reset date

## Analysis steps
1. **Identify Unused Indexes**
   - No seeks, scans, or lookups since stats reset
   - Has writes (updates) but no reads
   - Calculate waste ratio

2. **Identify Rarely Used Indexes**
   - Very low read activity relative to write activity
   - Infrequent usage compared to maintenance cost
   - Consider workload patterns (daily, monthly)

3. **Identify Redundant Indexes**
   - Duplicate indexes (same keys, same order)
   - Overlapping indexes (one index prefix of another)
   - Near-duplicates differing only in includes

4. **Identify Write-Heavy Indexes**
   - High user_updates with low user_seeks
   - Calculate read/write ratio
   - Assess cost/benefit

5. **Special Index Types**
   - Filtered indexes usage
   - Columnstore indexes
   - Full-text indexes
   - XML indexes

6. **Assess Impact of Removal**
   - Storage savings
   - Write performance improvement
   - Risk of query regression

## Key queries
```sql
-- Unused indexes (no reads, only writes)
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    s.user_updates,
    s.user_seeks,
    s.user_scans,
    s.user_lookups
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i 
    ON s.object_id = i.object_id 
    AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
    AND s.user_seeks = 0
    AND s.user_scans = 0
    AND s.user_lookups = 0
    AND s.user_updates > 0
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0;

-- Identify redundant indexes
SELECT 
    t.name AS table_name,
    i1.name AS index1,
    i2.name AS index2,
    'Potential duplicate' AS reason
FROM sys.tables t
INNER JOIN sys.indexes i1 ON t.object_id = i1.object_id
INNER JOIN sys.indexes i2 ON t.object_id = i2.object_id
WHERE i1.index_id < i2.index_id
    AND i1.type = i2.type
    -- Further column comparison needed
;
```

## Usage metrics to evaluate
- **user_seeks**: Index used in seek operations (highly efficient)
- **user_scans**: Index used in scan operations (less efficient)
- **user_lookups**: Key lookups (RID/Key lookups from nonclustered index)
- **user_updates**: Index maintenance on writes
- **Read/Write ratio**: (seeks + scans) / updates

## Classification criteria
- **Unused**: Zero reads, has writes
- **Rarely used**: Read/write ratio < 1:100
- **Redundant**: Overlapping or duplicate with another index
- **Candidate for removal**: Low usage + high maintenance cost

## Important considerations
- **Stats reset**: DMV data resets on SQL Server restart
- **Workload coverage**: Stats may not reflect all usage patterns (monthly reports, etc.)
- **Primary keys**: Never drop (required for foreign keys)
- **Unique constraints**: Support data integrity
- **Foreign keys**: May be needed for constraint enforcement
- **Replication/CDC**: May require certain indexes

## Best practices
- Collect usage data over full business cycle (month, quarter)
- Disable rather than drop initially (SQL Server 2016+)
- Script index creation before dropping
- Test in non-production first
- Monitor query performance after removal
- Check for execution plan regressions

## Constraints
- Do not recommend dropping primary keys or unique constraints
- Do not drop indexes supporting foreign keys without analysis
- Consider maintenance windows and replication impact
- Warn about data collection period (recent restart = incomplete data)
- Recommend testing in lower environment first
- Provide rollback scripts

## Output format
### Summary
- Total indexes analyzed
- Unused indexes count
- Redundant indexes count
- Estimated space savings
- Data collection period warning

### Unused Indexes
For each unused index:
- **Table**: Table name
- **Index**: Index name
- **Type**: Clustered/Nonclustered
- **Writes**: user_updates count
- **Space**: Index size
- **Recommendation**: Disable or drop
- **Script**: DROP INDEX statement

### Rarely Used Indexes
- Similar format with read/write ratio
- Usage context consideration

### Redundant Indexes
- Index pair comparison
- Overlap explanation
- Consolidation or removal recommendation

### Write-Heavy Indexes
- Indexes with poor read/write ratio
- Cost/benefit analysis

### Implementation Plan
- Recommended removal order (safe to risky)
- Disable first, drop later approach
- Rollback scripts
- Monitoring plan

### Follow-up
- Suggest longer data collection period if stats recently reset
- Query performance monitoring post-removal
- Additional indexes to investigate manually
