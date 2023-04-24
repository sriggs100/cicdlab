use experiment;

-- Enable row compression for the biggest table: transaction_log (only on medium and big dbs)
ALTER TABLE transaction_log ROW_FORMAT=COMPRESSED;


-- The following has been replaced with server config params

-- 5GBytes in memory table
-- SET max_heap_table_size = 5 * 1024 * 1024 * 1024;

-- As root
-- SET GLOBAL tmp_table_size = 5 * 1024 * 1024 * 1024;
-- SET GLOBAL max_heap_table_size = 5 * 1024 * 1024 * 1024;

-- Automatically remove binlog files
-- SET GLOBAL expire_logs_days = 1;