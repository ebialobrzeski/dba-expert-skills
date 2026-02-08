# Skill: Analyze SQL Server 2019 Execution Plan

This skill extends the shared execution plan analysis skill with SQL Server–specific behavior.

## Engine assumptions
- SQL Server 2019
- Cost-based optimizer
- OLTP workload unless stated otherwise

## SQL Server–specific checks
- Key lookups and lookup cost
- Missing index recommendations
- Tempdb spills (hash or sort warnings)
- Parameter sniffing indicators
- Implicit conversions
- Nested loops with large inputs

## Plan features to inspect
- ActualRows vs EstimatedRows
- Memory grant warnings
- SpillToTempDb indicators

## Constraints
- Do not recommend FORCE or query hints unless explicitly requested
- Avoid over-indexing
- Prefer query or index changes over hints

## Output additions
- Call out missing index suggestions separately
- Highlight parameter sniffing risk when applicable
