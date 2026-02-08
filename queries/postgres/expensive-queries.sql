-- Expensive Queries from pg_stat_statements
-- Requires pg_stat_statements extension
-- Shows queries with highest resource consumption

SELECT 
    queryid,
    LEFT(query, 100) AS query_text,
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_exec_time_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
    ROUND(stddev_exec_time::numeric, 2) AS stddev_exec_time_ms,
    ROUND(min_exec_time::numeric, 2) AS min_exec_time_ms,
    ROUND(max_exec_time::numeric, 2) AS max_exec_time_ms,
    rows,
    ROUND((100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0))::numeric, 2) AS cache_hit_percent,
    shared_blks_read AS blocks_read,
    shared_blks_dirtied AS blocks_dirtied,
    shared_blks_written AS blocks_written,
    temp_blks_read,
    temp_blks_written
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_exec_time DESC
LIMIT 50;
