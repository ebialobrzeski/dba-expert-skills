-- Blocking and Lock Waits
-- Shows transactions waiting for locks
-- Safe for production use

SELECT 
    r.trx_id AS waiting_trx_id,
    r.trx_mysql_thread_id AS waiting_thread,
    r.trx_query AS waiting_query,
    r.trx_state AS waiting_state,
    TIMESTAMPDIFF(SECOND, r.trx_wait_started, NOW()) AS wait_duration_sec,
    b.trx_id AS blocking_trx_id,
    b.trx_mysql_thread_id AS blocking_thread,
    b.trx_query AS blocking_query,
    b.trx_state AS blocking_state,
    TIMESTAMPDIFF(SECOND, b.trx_started, NOW()) AS blocking_trx_duration_sec
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id
ORDER BY wait_duration_sec DESC;
