-- Missing Index Recommendations
-- Shows indexes that SQL Server optimizer has identified as potentially useful
-- Review carefully before implementing

SELECT 
    DB_NAME(mid.database_id) AS database_name,
    OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_user_impact AS avg_improvement_percent,
    migs.avg_total_user_cost * (migs.user_seeks + migs.user_scans) AS total_cost_saved,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    'CREATE NONCLUSTERED INDEX IX_' + OBJECT_NAME(mid.object_id, mid.database_id) + '_Missing
    ON ' + mid.statement + ' (' + 
    ISNULL(mid.equality_columns, '') + 
    CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END +
    ISNULL(mid.inequality_columns, '') + ')' +
    CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END AS create_statement
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_user_impact > 20
  AND (migs.user_seeks + migs.user_scans) > 100
ORDER BY migs.avg_total_user_cost * (migs.user_seeks + migs.user_scans) DESC;
