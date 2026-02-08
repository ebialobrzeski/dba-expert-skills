-- Unused Indexes
-- Identifies indexes that have not been used
-- Requires performance_schema enabled

SELECT 
    t.table_schema,
    t.table_name,
    t.index_name,
    ROUND(((t.data_length + t.index_length) / 1024 / 1024), 2) AS total_size_mb,
    t.table_rows
FROM information_schema.tables t
INNER JOIN information_schema.statistics s 
    ON t.table_schema = s.table_schema 
    AND t.table_name = s.table_name
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage i
    ON i.object_schema = t.table_schema
    AND i.object_name = t.table_name
    AND i.index_name = s.index_name
WHERE t.table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
  AND s.index_name != 'PRIMARY'
  AND (i.count_star = 0 OR i.count_star IS NULL)
GROUP BY t.table_schema, t.table_name, t.index_name, t.data_length, t.index_length, t.table_rows
ORDER BY total_size_mb DESC;
