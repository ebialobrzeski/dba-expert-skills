-- Active Queries with Current State
-- Shows currently executing queries with wait events
-- Safe for production use

SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    wait_event_type,
    wait_event,
    query_start,
    EXTRACT(EPOCH FROM (now() - query_start)) AS query_runtime_sec,
    backend_start,
    xact_start,
    state_change,
    LEFT(query, 500) AS query_text
FROM pg_stat_activity
WHERE state != 'idle'
  AND pid != pg_backend_pid()
ORDER BY query_start;
