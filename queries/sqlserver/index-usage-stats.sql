-- Index Usage Statistics and Definitions
-- Run in the target database. One row per index (partitions rolled up).
-- Feeds the review-missing-indexes skill: existing definitions + usage let the analysis
-- detect left-prefix duplicates, INCLUDE merge candidates, and clustered-key swap signals.
--
-- NOTE: sys.dm_db_index_usage_stats resets on service restart and when an index is rebuilt/recreated.
--       Check DmvDataSince below before treating a zero-read index as unused.
-- NOTE: CreateScript emits WITH (ONLINE = ON) - Enterprise/Developer edition only.

SET NOCOUNT ON;

-- Filters (exact names or LIKE patterns, e.g. N'%Sales%'). NULL = no filter.
DECLARE
    @TargetSchema SYSNAME = N'dbo',
    @TargetTable  SYSNAME = NULL;

DECLARE @DmvDataSince DATETIME = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info);

WITH PartitionAgg AS (
    SELECT
        PS.object_id,
        PS.index_id,
        [Rows]         = SUM(PS.row_count),
        PartitionCount = COUNT_BIG(*),
        IndexSizeMB    = CAST(SUM(PS.used_page_count) * 8.0 / 1024 AS DECIMAL(18, 2))
    FROM sys.dm_db_partition_stats AS PS
    GROUP BY PS.object_id, PS.index_id
),
IndexColumns AS (
    SELECT
        I.object_id,
        I.index_id,

        -- Key columns in key order - used for left-prefix comparison
        KeyColumns = STUFF((
            SELECT N', ' + C.name
            FROM sys.index_columns AS IC
            INNER JOIN sys.columns AS C
                ON C.object_id = IC.object_id
               AND C.column_id = IC.column_id
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 0
            ORDER BY IC.key_ordinal, IC.index_column_id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, N''),

        -- Key columns with sort direction - used for the rollback CREATE script
        KeyColumnsWithOrder = STUFF((
            SELECT N', ' + QUOTENAME(C.name) + CASE WHEN IC.is_descending_key = 1 THEN N' DESC' ELSE N' ASC' END
            FROM sys.index_columns AS IC
            INNER JOIN sys.columns AS C
                ON C.object_id = IC.object_id
               AND C.column_id = IC.column_id
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 0
            ORDER BY IC.key_ordinal, IC.index_column_id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, N''),

        IncludedColumns = NULLIF(STUFF((
            SELECT N', ' + C.name
            FROM sys.index_columns AS IC
            INNER JOIN sys.columns AS C
                ON C.object_id = IC.object_id
               AND C.column_id = IC.column_id
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 1
            ORDER BY IC.index_column_id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, N''), N''),

        -- Sorted so two indexes with the same includes in a different order compare equal
        IncludedColumnsSorted = NULLIF(STUFF((
            SELECT N', ' + C.name
            FROM sys.index_columns AS IC
            INNER JOIN sys.columns AS C
                ON C.object_id = IC.object_id
               AND C.column_id = IC.column_id
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 1
            ORDER BY C.name
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, N''), N''),

        KeyColumnCount = (
            SELECT COUNT_BIG(*)
            FROM sys.index_columns AS IC
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 0
        ),

        KeyWidthBytes = ISNULL((
            SELECT SUM(CASE WHEN C.max_length = -1 THEN 0 ELSE C.max_length END)
            FROM sys.index_columns AS IC
            INNER JOIN sys.columns AS C
                ON C.object_id = IC.object_id
               AND C.column_id = IC.column_id
            WHERE IC.object_id = I.object_id
              AND IC.index_id  = I.index_id
              AND IC.is_included_column = 0
        ), 0)
    FROM sys.indexes AS I
    INNER JOIN sys.tables  AS T ON T.object_id  = I.object_id
    INNER JOIN sys.schemas AS S ON S.schema_id  = T.schema_id
    WHERE (@TargetSchema IS NULL OR S.name LIKE @TargetSchema)
      AND (@TargetTable  IS NULL OR T.name LIKE @TargetTable)
)
SELECT
    DatabaseName     = DB_NAME(),
    DmvDataSince     = @DmvDataSince,
    ObjectName       = QUOTENAME(S.name) + N'.' + QUOTENAME(T.name),
    SchemaName       = S.name,
    TableName        = T.name,
    I.index_id,
    IndexName        = I.name,
    IndexType        = I.type_desc,
    IsUnique         = I.is_unique,
    IsPrimaryKey     = I.is_primary_key,
    IsUniqueConstraint = I.is_unique_constraint,
    IsDisabled       = I.is_disabled,
    IsFiltered       = I.has_filter,
    FilterDefinition = I.filter_definition,
    IndexFillPct     = I.fill_factor,
    FileGroupName    = DS.name,

    IX.KeyColumns,
    IX.IncludedColumns,
    IX.KeyColumnCount,
    IX.KeyWidthBytes,

    -- Duplicate-detection helpers: compare KeyColumnsNormalized with LIKE for left-prefix
    -- redundancy, and IndexSignature for exact duplicates.
    KeyColumnsNormalized     = LOWER(IX.KeyColumns),
    IncludeColumnsNormalized = LOWER(IX.IncludedColumnsSorted),
    IndexSignature           = LOWER(ISNULL(IX.KeyColumns, N'')
                                   + N'|' + ISNULL(IX.IncludedColumnsSorted, N'')
                                   + N'|' + ISNULL(I.filter_definition, N'')),

    PA.[Rows],
    PA.PartitionCount,
    PA.IndexSizeMB,

    DDIUS.user_seeks,
    DDIUS.user_scans,
    DDIUS.user_lookups,
    DDIUS.user_updates,
    Reads = COALESCE(DDIUS.user_seeks, 0) + COALESCE(DDIUS.user_scans, 0) + COALESCE(DDIUS.user_lookups, 0),
    ReadWriteRatio = CASE
                        WHEN COALESCE(DDIUS.user_updates, 0) = 0 THEN NULL
                        ELSE CAST((COALESCE(DDIUS.user_seeks, 0) + COALESCE(DDIUS.user_scans, 0) + COALESCE(DDIUS.user_lookups, 0))
                                  * 1.0 / DDIUS.user_updates AS DECIMAL(18, 2))
                     END,
    IndexPerformance = COALESCE(DDIUS.user_seeks, 0)
                     + COALESCE(DDIUS.user_scans, 0)
                     + COALESCE(DDIUS.user_lookups, 0)
                     - COALESCE(DDIUS.user_updates, 0),
    DDIUS.last_user_seek,
    DDIUS.last_user_scan,
    DDIUS.last_user_lookup,
    DDIUS.last_user_update,

    -- Rollback script: run this to recreate the index if a drop regresses performance
    CreateScript = CASE WHEN I.type IN (1, 2) AND I.name IS NOT NULL THEN
        N'CREATE ' + CASE WHEN I.is_unique = 1 THEN N'UNIQUE ' ELSE N'' END
        + I.type_desc + N' INDEX ' + QUOTENAME(I.name)
        + N' ON ' + QUOTENAME(S.name) + N'.' + QUOTENAME(T.name)
        + N' (' + IX.KeyColumnsWithOrder + N')'
        + CASE WHEN IX.IncludedColumns IS NOT NULL THEN N' INCLUDE (' + IX.IncludedColumns + N')' ELSE N'' END
        + CASE WHEN I.filter_definition IS NOT NULL THEN N' WHERE ' + I.filter_definition ELSE N'' END
        + N' WITH (DROP_EXISTING = OFF, ONLINE = ON'
        + CASE WHEN I.fill_factor BETWEEN 1 AND 99 THEN N', FILLFACTOR = ' + CAST(I.fill_factor AS NVARCHAR(3)) ELSE N'' END
        + N')'
        + CASE WHEN DS.name IS NOT NULL THEN N' ON ' + QUOTENAME(DS.name) ELSE N'' END + N';'
    END,

    DropScript = CASE
        WHEN I.name IS NULL THEN NULL
        WHEN I.is_primary_key = 1 OR I.is_unique_constraint = 1
            THEN N'-- Constraint-backed, review before dropping: ALTER TABLE ' + QUOTENAME(S.name) + N'.' + QUOTENAME(T.name)
                 + N' DROP CONSTRAINT ' + QUOTENAME(I.name) + N';'
        ELSE N'DROP INDEX ' + QUOTENAME(I.name) + N' ON ' + QUOTENAME(S.name) + N'.' + QUOTENAME(T.name) + N';'
    END
FROM sys.schemas AS S
INNER JOIN sys.tables  AS T ON T.schema_id = S.schema_id
INNER JOIN sys.indexes AS I ON I.object_id = T.object_id
INNER JOIN IndexColumns AS IX
        ON IX.object_id = I.object_id
       AND IX.index_id  = I.index_id
LEFT JOIN PartitionAgg AS PA
       ON PA.object_id = I.object_id
      AND PA.index_id  = I.index_id
LEFT JOIN sys.data_spaces AS DS
       ON DS.data_space_id = I.data_space_id
LEFT JOIN sys.dm_db_index_usage_stats AS DDIUS
       ON DDIUS.database_id = DB_ID()
      AND DDIUS.object_id   = I.object_id
      AND DDIUS.index_id    = I.index_id
WHERE (@TargetSchema IS NULL OR S.name LIKE @TargetSchema)
  AND (@TargetTable  IS NULL OR T.name LIKE @TargetTable)
ORDER BY PA.[Rows] DESC, ObjectName, I.index_id;
