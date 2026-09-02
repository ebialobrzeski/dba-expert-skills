-- Missing Index Recommendations
-- Run in the target database. These are optimizer wishes, not validated designs -
-- always cross-check against queries/sqlserver/index-usage-stats.sql before creating anything.
--
-- NOTE: The missing index DMVs reset on service restart and drop entries when the referenced
--       object changes. Compare DmvDataSince against a full business cycle before acting.
-- NOTE: The generated statement omits ONLINE = ON; add it only on Enterprise/Developer edition.

SET NOCOUNT ON;

-- Filters. Defaults show everything so nothing is silently hidden.
DECLARE
    @MinImpact    DECIMAL(5, 2) = 0,     -- migs.avg_user_impact percent
    @MinSeeks     BIGINT        = 0,     -- user_seeks + user_scans
    @TargetSchema SYSNAME       = NULL,  -- exact name or LIKE pattern, NULL = all
    @TargetTable  SYSNAME       = NULL;

DECLARE @DmvDataSince DATETIME = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info);

WITH MissingIndexes AS (
    SELECT
        mid.index_handle,
        mid.object_id,
        SchemaName = OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id),
        TableName  = OBJECT_NAME(mid.object_id, mid.database_id),
        mid.statement,
        mid.equality_columns,
        mid.inequality_columns,
        mid.included_columns,
        migs.user_seeks,
        migs.user_scans,
        migs.avg_user_impact,
        migs.avg_total_user_cost,
        migs.unique_compiles,
        migs.last_user_seek,
        migs.last_user_scan,
        -- Standard weighting: cost x impact x usage. Use for relative ranking only.
        ImprovementMeasure = CAST(migs.avg_total_user_cost
                                  * (migs.avg_user_impact / 100.0)
                                  * (migs.user_seeks + migs.user_scans) AS DECIMAL(28, 2)),
        -- Equality first, then inequality - this is the key order to create.
        KeyColumns = ISNULL(mid.equality_columns, N'')
                   + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN N', ' ELSE N'' END
                   + ISNULL(mid.inequality_columns, N'')
    FROM sys.dm_db_missing_index_details AS mid
    INNER JOIN sys.dm_db_missing_index_groups AS mig
            ON mig.index_handle = mid.index_handle
    INNER JOIN sys.dm_db_missing_index_group_stats AS migs
            ON migs.group_handle = mig.index_group_handle
    WHERE mid.database_id = DB_ID()
      AND migs.avg_user_impact >= @MinImpact
      AND (migs.user_seeks + migs.user_scans) >= @MinSeeks
)
SELECT
    DatabaseName = DB_NAME(),
    DmvDataSince = @DmvDataSince,
    MI.index_handle,
    MI.SchemaName,
    MI.TableName,
    MI.ImprovementMeasure,
    MI.avg_user_impact,
    MI.avg_total_user_cost,
    MI.user_seeks,
    MI.user_scans,
    MI.unique_compiles,
    MI.last_user_seek,
    MI.last_user_scan,

    -- Kept separate so consolidation rules can reason about key order vs coverage
    MI.equality_columns,
    MI.inequality_columns,
    MI.included_columns,
    MI.KeyColumns,

    -- Matches KeyColumnsNormalized in index-usage-stats.sql for left-prefix comparison
    KeyColumnsNormalized = LOWER(REPLACE(REPLACE(MI.KeyColumns, N'[', N''), N']', N'')),

    KeyColumnCount = LEN(MI.KeyColumns) - LEN(REPLACE(MI.KeyColumns, N',', N'')) + 1,

    ProposedIndexName = LEFT(N'IX_' + MI.TableName + N'_'
                             + REPLACE(REPLACE(REPLACE(REPLACE(MI.KeyColumns, N'[', N''), N']', N''), N', ', N'_'), N' ', N''), 128),

    CreateStatement = N'CREATE NONCLUSTERED INDEX '
        + QUOTENAME(LEFT(N'IX_' + MI.TableName + N'_'
                         + REPLACE(REPLACE(REPLACE(REPLACE(MI.KeyColumns, N'[', N''), N']', N''), N', ', N'_'), N' ', N''), 128))
        + N' ON ' + MI.statement
        + N' (' + MI.KeyColumns + N')'
        + CASE WHEN MI.included_columns IS NOT NULL THEN N' INCLUDE (' + MI.included_columns + N')' ELSE N'' END
        + N'; -- Enterprise/Developer: append WITH (ONLINE = ON, MAXDOP = 0)'
FROM MissingIndexes AS MI
WHERE (@TargetSchema IS NULL OR MI.SchemaName LIKE @TargetSchema)
  AND (@TargetTable  IS NULL OR MI.TableName  LIKE @TargetTable)
ORDER BY MI.ImprovementMeasure DESC;
