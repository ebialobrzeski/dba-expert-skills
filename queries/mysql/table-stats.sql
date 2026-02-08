-- Table and Index Statistics
-- Shows table sizes and index usage
-- Safe for production use

SELECT 
    t.table_schema,
    t.table_name,
    t.engine,
    ROUND((t.data_length + t.index_length) / 1024 / 1024, 2) AS total_size_mb,
    ROUND(t.data_length / 1024 / 1024, 2) AS data_size_mb,
    ROUND(t.index_length / 1024 / 1024, 2) AS index_size_mb,
    t.table_rows,
    ROUND(t.data_length / NULLIF(t.table_rows, 0), 2) AS avg_row_length,
    t.auto_increment,
    t.create_time,
    t.update_time
FROM information_schema.tables t
WHERE t.table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
  AND t.table_type = 'BASE TABLE'
ORDER BY (t.data_length + t.index_length) DESC
LIMIT 50;
