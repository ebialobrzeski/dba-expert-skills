---
name: review-server-configuration
description: Reviews SQL Server instance configuration settings including memory, parallelism, TempDB, and database options to identify misconfigurations affecting performance and stability. Use for general health checks or when performance issues lack a specific query culprit.
---

# Skill: Review SQL Server Configuration

## When to use
- User reports performance issues without specific query identified
- General server health check requested
- Following identification of resource bottlenecks
- Part of initial performance assessment

## Goal
Evaluate SQL Server instance configuration settings and identify misconfigurations that could impact performance, stability, or scalability.

## Inputs expected
- sp_configure output (show advanced options)
- sys.configurations query results
- Server specifications (CPU, RAM, disk configuration)
- SQL Server version and edition
- Workload type (OLTP, OLAP, mixed)

## Analysis steps
1. **Memory Configuration**
   - Max server memory setting
   - Min server memory setting
   - Lock pages in memory
   - Verify appropriate for available RAM

2. **Parallelism Settings**
   - Max degree of parallelism (MAXDOP)
   - Cost threshold for parallelism
   - Alignment with CPU core count and workload

3. **TempDB Configuration**
   - Number of data files
   - File sizing and growth settings
   - File placement

4. **Database Settings**
   - Auto-close / auto-shrink (should be OFF)
   - Recovery models
   - Backup compression

5. **Instant File Initialization**
   - Service account permissions
   - Impact on database restores and growth

6. **Trace Flags**
   - Global trace flags in use
   - Appropriateness for version and workload

## Key configurations to check
- max server memory (MB)
- max degree of parallelism
- cost threshold for parallelism
- optimize for ad hoc workloads
- backup compression default
- remote admin connections

## Best practices baseline
- **MAXDOP**: Generally 8 or less, align with NUMA node
- **Cost Threshold**: 50 (default is too low at 5)
- **Max Memory**: Leave 4-8GB for OS, more for large systems
- **TempDB files**: 1 file per core up to 8 files
- **Auto-close/shrink**: OFF for production databases

## Constraints
- Do not recommend changes without understanding workload
- Consider HA/DR configuration before suggesting restarts
- Highlight settings requiring restart separately
- Note edition limitations (Standard vs Enterprise)

## Output format
### Summary
- Overall configuration assessment
- Critical issues identified

### Findings
For each configuration area:
- Current setting
- Recommended setting (if different)
- Impact of change
- Requires restart: Yes/No

### Recommendations
- Priority order (critical, important, optional)
- Implementation steps
- Testing considerations

### Follow-up questions
Ask only if critical context is missing (server specs, workload type, etc.)
