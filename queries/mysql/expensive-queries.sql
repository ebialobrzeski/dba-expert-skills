-- Expensive Queries by Execution Time
-- Requires performance_schema and statement digests enabled
-- Shows queries with highest total execution time

SELECT 
    schema_name,
    SUBSTRING(digest_text, 1, 200) AS query_text,
    count_star AS exec_count,
    ROUND(sum_timer_wait / 1000000000000, 2) AS total_exec_time_sec,
    ROUND(avg_timer_wait / 1000000000000, 2) AS avg_exec_time_sec,
    ROUND(min_timer_wait / 1000000000000, 2) AS min_exec_time_sec,
    ROUND(max_timer_wait / 1000000000000, 2) AS max_exec_time_sec,
    sum_rows_examined,
    ROUND(sum_rows_examined / NULLIF(count_star, 0), 0) AS avg_rows_examined,
    sum_rows_sent,
    ROUND(sum_rows_sent / NULLIF(count_star, 0), 0) AS avg_rows_sent,
    sum_rows_affected,
    sum_created_tmp_tables,
    sum_created_tmp_disk_tables,
    sum_sort_rows,
    first_seen,
    last_seen
FROM performance_schema.events_statements_summary_by_digest
WHERE schema_name IS NOT NULL
  AND schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
ORDER BY sum_timer_wait DESC
LIMIT 50;
