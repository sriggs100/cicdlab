use experiment;



SELECT COUNT(*)  AS COUNT_MERCHANTS FROM merchant;

SELECT COUNT(*)  AS COUNT_TERMINALS FROM terminal;

-- MasterCard transactions must be ~14%
SELECT (SELECT count(*) FROM transaction_log WHERE CARD_SCHEME = 1) / (SELECT count(*) FROM transaction_log) * 100 AS MC_TXN_PERC;

-- Credit transactions must be ~20%
SELECT (SELECT count(*) FROM transaction_log WHERE function_code = 100) / (SELECT count(*) FROM transaction_log) * 100 AS CREDIT_TXN_PERC;


-- Average Txn value debit:			£22.82
SELECT AVG(amount) AS AVG_DEBIT_TXN_VALUE, SUM(amount) AS SUM_DEBIT_TXN_VALUE, COUNT(*) AS DEBIT_TXN_QTY FROM transaction_log WHERE function_code = 200;

-- MasterCard transactions
SELECT AVG(amount) AS AVG_DEBIT_MC_TXN_VALUE, SUM(amount) AS SUM_DEBIT_MC_TXN_VALUE, COUNT(*) AS DEBIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 200;

-- Visa Transactions
SELECT AVG(amount) AS AVG_DEBIT_VISA_TXN_VALUE, SUM(amount) AS SUM_DEBIT_VISA_TXN_VALUE, COUNT(*) AS DEBIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 200;


-- Average Txn value credit:		£33.52
SELECT AVG(amount) AS AVG_CREDIT_TXN_VALUE, SUM(amount) AS SUM_CREDIT_TXN_VALUE, COUNT(*) AS CREDIT_TXN_QTY FROM transaction_log WHERE function_code = 100;

-- Mastercard transactions
SELECT AVG(amount) AS AVG_CREDIT_MC_TXN_VALUE, SUM(amount) AS SUM_CREDIT_MC_TXN_VALUE, COUNT(*) AS CREDIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 100;

-- Visa transactions
SELECT AVG(amount) AS AVG_CREDIT_VISA_TXN_VALUE, SUM(amount) AS SUM_CREDIT_VISA_TXN_VALUE, COUNT(*) AS CREDIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 100;



-- How much is the sum of all transactions and how many transactions
SELECT SUM(amount) AS TXN_AMOUNT_TOTAL, COUNT(*) AS TXN_QTY FROM transaction_log;


-- Interval
SELECT MIN(utc_capture_date_time) AS TXN_INTERVAL_MIN, MAX(utc_capture_date_time) AS TXN_INTERVAL_MAX FROM transaction_log WHERE function_code = 200;


-- Useful for quickly clean the database after a test involving the insert of new transactions
SELECT max(id) AS MAX_ID_TRANSACTION_LOG FROM transaction_log;

-- Useful for quickly clean the database after a test involving the insert of new transactions
SELECT max(id) AS MAX_ID_TRANSACTION_EMV_DATA FROM transaction_emv_data;



