-- Active Queries with Execution Plans
-- Shows currently executing queries with basic metrics
-- Safe for production use

SELECT 
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    r.status,
    r.command,
    DB_NAME(r.database_id) AS database_name,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.logical_reads,
    r.writes,
    r.total_elapsed_time / 1000 AS elapsed_time_sec,
    SUBSTRING(
        qt.text,
        (r.statement_start_offset / 2) + 1,
        (CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset) / 2 + 1
    ) AS statement_text,
    qp.query_plan
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qp
WHERE s.is_user_process = 1
  AND r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
