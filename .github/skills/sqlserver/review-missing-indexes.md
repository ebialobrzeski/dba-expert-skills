---
name: review-missing-indexes
description: Evaluates missing index recommendations from SQL Server DMVs and execution plans, validates their usefulness, identifies consolidation opportunities, and balances query performance with maintenance overhead. Use when execution plans show missing index hints or during performance optimization.
---

# Skill: Review and Suggest Missing Indexes for SQL Server

## When to use
- Execution plan includes missing index recommendations
- Query performance issues identified
- Following expensive query analysis
- Periodic index review and optimization
- High read/scan activity on specific tables

## Goal
Evaluate missing index suggestions from SQL Server DMVs and execution plans, assess their validity, and provide actionable recommendations that balance query performance with maintenance overhead.

## Inputs expected
- Missing index DMV data (sys.dm_db_missing_index_details, sys.dm_db_missing_index_group_stats)
- Execution plans with missing index hints
- Table structure and existing indexes
- Workload characteristics (OLTP vs OLAP, read vs write ratio)
- Current index maintenance overhead

## Analysis steps
1. **Gather Missing Index Data**
   - Review DMV recommendations with impact scores
   - Extract missing index hints from execution plans
   - Prioritize by impact (improvement_measure)

2. **Validate Recommendations**
   - Check for similar existing indexes
   - Assess key column selectivity
   - Evaluate included column necessity
   - Consider query frequency vs potential benefit

3. **Consolidation Opportunities**
   - Identify overlapping recommendations
   - Combine multiple narrow indexes into one broader index
   - Avoid redundancy with existing indexes

4. **Impact Assessment**
   - Estimated improvement for reads
   - Write overhead (INSERT, UPDATE, DELETE impact)
   - Index size and storage requirements
   - Maintenance window impact (rebuilds, updates stats)

5. **Implementation Priority**
   - High impact, low overhead (implement first)
   - High impact, high overhead (test thoroughly)
   - Low impact (defer or skip)

## Key queries
```sql
-- Missing indexes with highest impact
SELECT 
    OBJECT_NAME(mid.object_id) AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.avg_user_impact,
    migs.user_seeks,
    migs.user_scans,
    (migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig 
    ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs 
    ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID()
ORDER BY improvement_measure DESC;
```

## Validation checks
- **Existing indexes**: Query sys.indexes for similar indexes on the same table
- **Column selectivity**: Low-selectivity columns may not benefit from indexes
- **Include column size**: Excessive includes can bloat index size
- **Key column order**: Equality before inequality, most selective first
- **Composite key limits**: Avoid overly wide keys (>16 columns or >900 bytes)

## Common anti-patterns
- Including all columns from SELECT clause
- Creating indexes with single low-selectivity column
- Overlapping indexes that could be consolidated
- Over-indexing write-heavy tables
- Ignoring index intersection opportunities

## Best practices
- **Consolidate**: Combine related missing index requests
- **Test first**: Create in non-production to validate benefit
- **Monitor writes**: Check INSERT/UPDATE/DELETE impact
- **Include only essentials**: Don't include every column in query
- **Consider filtered indexes**: For subset queries (SQL Server 2008+)
- **Review periodically**: Missing index DMVs reset on restart

## Constraints
- Do not blindly implement all missing index suggestions
- Avoid over-indexing (index maintenance cost)
- Warn about write impact on OLTP systems
- Consider existing index strategy
- Note when statistics update may be alternative solution
- Recommend testing in lower environment first

## Output format
### Summary
- Number of missing index recommendations reviewed
- High-priority recommendations count
- Overall assessment

### High-Priority Recommendations
For each recommended index:
- **Table**: Table name
- **Proposed index**: CREATE INDEX statement
- **Impact score**: Improvement measure calculation
- **Benefit**: Expected query improvement
- **Cost**: Write overhead and maintenance impact
- **Notes**: Consolidation opportunities, alternatives, caveats

### Medium/Low-Priority
- Brief list with reasons for lower priority
- Consolidation suggestions

### Existing Index Review
- Overlapping indexes identified
- Potential for consolidation
- Unused indexes to consider removing

### Implementation Guidance
- Recommended implementation order
- Testing approach
- Monitoring metrics
- Rollback plan

### Follow-up
- Additional data needed for better assessment
- Monitoring plan post-implementation
