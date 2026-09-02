---
name: analyze-tempdb
description: Evaluates SQL Server TempDB configuration and identifies contention patterns, space usage issues, version store problems, and tempdb spills. Use when user reports PAGELATCH waits, tempdb growth issues, or spill-related performance problems.
---

# Skill: Analyze SQL Server TempDB

## When to use
- User reports tempdb-related waits (PAGELATCH_*, PAGEIOLATCH_*)
- High tempdb growth or space usage observed
- Performance degradation with heavy temp table usage
- Execution plans show tempdb spills
- General performance tuning assessment

## Goal
Identify tempdb configuration issues, contention patterns, and space usage problems that impact SQL Server performance.

## Inputs expected
- TempDB file configuration (number, size, growth settings, location)
- Wait statistics showing PAGELATCH or PAGEIOLATCH
- Space usage by object type
- Version pages usage
- sys.dm_db_file_space_usage output
- Query plans showing spills
- Server specifications (CPU count, disk configuration)

## Analysis steps
1. **File Configuration**
   - Number of data files vs CPU cores
   - File sizing consistency
   - Growth settings (avoid percentage, use MB)
   - File location (separate from user databases)

2. **Contention Detection**
   - PAGELATCH_UP on PFS, GAM, SGAM pages
   - Allocation contention patterns
   - High wait times during specific operations

3. **Space Usage**
   - Total space used vs allocated
   - Internal objects (temp tables, table variables, work tables)
   - Version store (snapshot isolation, triggers)
   - User objects (temp tables, table variables)
   - Space usage growth patterns

4. **Spill Analysis**
   - Sort spills to tempdb
   - Hash spills to tempdb
   - Frequency and size of spills
   - Queries causing spills

5. **Version Store**
   - Size of version store
   - Snapshot isolation usage
   - Long-running transactions holding versions

## Key queries to run
```sql
-- File configuration
SELECT name, physical_name, size * 8/1024 AS size_mb, 
       growth, is_percent_growth
FROM sys.master_files
WHERE database_id = 2;

-- Space usage breakdown
SELECT 
    SUM(user_object_reserved_page_count) * 8/1024 AS user_objects_mb,
    SUM(internal_object_reserved_page_count) * 8/1024 AS internal_objects_mb,
    SUM(version_store_reserved_page_count) * 8/1024 AS version_store_mb,
    SUM(unallocated_extent_page_count) * 8/1024 AS free_space_mb
FROM sys.dm_db_file_space_usage;
```

## Common problems and indicators
- **Allocation contention**: Multiple same-sized files needed (1 per core up to 8)
- **PFS/GAM/SGAM contention**: PAGELATCH_UP waits, need more files or TF 1118
- **Version store growth**: Long transactions, snapshot isolation, excessive triggers
- **Frequent spills**: Insufficient memory grants, need index or query optimization
- **Rapid growth**: Undersized tempdb, poor growth settings

## Best practices baseline
- **File count**: 1 per core up to 8 files, then add 4 at a time if needed
- **File size**: All equal size, pre-sized to prevent autogrowth
- **Growth**: Fixed MB increments (not percent), equal across all files
- **Location**: Fast storage, separate from user databases if possible
- **Model database**: Default settings affect tempdb recreation

## Constraints
- Do not recommend reducing file count below CPU core count without evidence
- TempDB changes require restart to apply
- Consider maintenance windows for changes
- Trace flags may not be needed on SQL Server 2016+

## Output format
### Summary
- TempDB health assessment
- Primary issues identified
- Performance impact

### Configuration Review
- Current file configuration
- Recommended file configuration
- Space usage analysis

### Contention Analysis
- Wait types observed
- Contention patterns
- Recommended resolution

### Space Issues
- Space usage breakdown
- Growth patterns
- Version store concerns
- Spill analysis (if applicable)

### Recommendations
- Configuration changes (file count, size, growth)
- Query optimization (if spills present)
- Version store cleanup (if applicable)
- Monitoring suggestions

### Follow-up
- Additional data needed (if any)
- Queries to run for deeper analysis
