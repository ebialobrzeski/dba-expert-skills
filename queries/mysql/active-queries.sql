-- Active Queries (Processlist)
-- Shows currently executing queries
-- Safe for production use

SELECT 
    id,
    user,
    host,
    db,
    command,
    time AS duration_sec,
    state,
    LEFT(info, 500) AS query_text
FROM information_schema.processlist
WHERE command != 'Sleep'
  AND id != CONNECTION_ID()
ORDER BY time DESC;
