-- Blocking Chain Analysis
-- Identifies head blockers and blocked sessions
-- Safe for production use

;WITH BlockingHierarchy AS (
    SELECT 
        s.session_id,
        s.blocking_session_id,
        s.login_name,
        s.host_name,
        s.program_name,
        DB_NAME(r.database_id) AS database_name,
        r.wait_type,
        r.wait_time,
        r.wait_resource,
        CAST(s.session_id AS VARCHAR(MAX)) AS blocking_chain,
        0 AS level
    FROM sys.dm_exec_sessions s
    LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
    WHERE s.blocking_session_id = 0
      AND EXISTS (SELECT 1 FROM sys.dm_exec_sessions WHERE blocking_session_id = s.session_id)
    
    UNION ALL
    
    SELECT 
        s.session_id,
        s.blocking_session_id,
        s.login_name,
        s.host_name,
        s.program_name,
        DB_NAME(r.database_id) AS database_name,
        r.wait_type,
        r.wait_time,
        r.wait_resource,
        CAST(bh.blocking_chain + ' -> ' + CAST(s.session_id AS VARCHAR(MAX)) AS VARCHAR(MAX)),
        bh.level + 1
    FROM sys.dm_exec_sessions s
    INNER JOIN BlockingHierarchy bh ON s.blocking_session_id = bh.session_id
    LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
)
SELECT 
    blocking_chain,
    level,
    session_id,
    blocking_session_id,
    login_name,
    database_name,
    wait_type,
    wait_time,
    wait_resource
FROM BlockingHierarchy
ORDER BY blocking_chain, level;
