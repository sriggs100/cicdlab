use experiment;

SELECT COUNT(*)  AS COUNT_MERCHANTS FROM merchant;

SELECT COUNT(*)  AS COUNT_TERMINALS FROM terminal;


-- MasterCard transactions must be ~14%
SELECT (SELECT count(*) FROM transaction_log WHERE CARD_SCHEME = 1) / (SELECT count(*) FROM transaction_log) * 100 AS MC_TXN_PERC;

-- Credit transactions must be ~20%
SELECT (SELECT count(*) FROM transaction_log WHERE function_code = 100) / (SELECT count(*) FROM transaction_log) * 100 AS CREDIT_TXN_PERC;


ALTER TABLE transaction_log ADD INDEX OnlyForTheRrportsIdx (card_scheme,function_code,action_code,amount);


-- Average Txn value debit:			£22.82
SELECT AVG(amount) AS AVG_DEBIT_TXN_VALUE, SUM(amount) AS SUM_DEBIT_TXN_VALUE, COUNT(*) AS DEBIT_TXN_QTY FROM transaction_log WHERE function_code = 200;

-- Injected Average Txn value debit:			£22.82
SELECT AVG(amount) AS INJECTED_AVG_DEBIT_TXN_VALUE, SUM(amount) AS INJECTED_SUM_DEBIT_TXN_VALUE, COUNT(*) AS INJECTED_DEBIT_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND function_code = 200;


-- MasterCard Debit transactions
SELECT AVG(amount) AS AVG_DEBIT_MC_TXN_VALUE, SUM(amount) AS SUM_DEBIT_MC_TXN_VALUE, COUNT(*) AS DEBIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 200;


-- Injected MasterCard Debit transactions
SELECT AVG(amount) AS INJECTED_AVG_DEBIT_MC_TXN_VALUE, SUM(amount) AS INJECTED_SUM_DEBIT_MC_TXN_VALUE, COUNT(*) AS INJECTED_DEBIT_MC_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 1 AND function_code = 200;


-- MasterCard APPROVED Debit transactions
SELECT AVG(amount) AS AVG_APPROVED_DEBIT_MC_TXN_VALUE, SUM(amount) AS SUM_APPROVED_DEBIT_MC_TXN_VALUE, COUNT(*) AS APPROVED_DEBIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 200 AND action_code = 0;


-- Injected MasterCard APPROVED Debit transactions
SELECT AVG(amount) AS INJECTED_AVG_APPROVED_DEBIT_MC_TXN_VALUE, SUM(amount) AS INJECTED_SUM_APPROVED_DEBIT_MC_TXN_VALUE, COUNT(*) AS INJECTED_APPROVED_DEBIT_MC_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 1 AND function_code = 200 AND action_code = 0;


-- Visa Debit Transactions
SELECT AVG(amount) AS AVG_DEBIT_VISA_TXN_VALUE, SUM(amount) AS SUM_DEBIT_VISA_TXN_VALUE, COUNT(*) AS DEBIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 200;


-- Injected Visa Debit Transactions
SELECT AVG(amount) AS INJECTED_AVG_DEBIT_VISA_TXN_VALUE, SUM(amount) AS INJECTED_SUM_DEBIT_VISA_TXN_VALUE, COUNT(*) AS INJECTED_DEBIT_VISA_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 0 AND function_code = 200;


-- Visa APPROVED Debit Transactions
SELECT AVG(amount) AS AVG_APPROVED_DEBIT_VISA_TXN_VALUE, SUM(amount) AS SUM_APPROVED_DEBIT_VISA_TXN_VALUE, COUNT(*) AS APPROVED_DEBIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 200 AND action_code = 0;


-- Injected Visa APPROVED Debit Transactions
SELECT AVG(amount) AS INJECTED_AVG_APPROVED_DEBIT_VISA_TXN_VALUE, SUM(amount) AS INJECTED_SUM_APPROVED_DEBIT_VISA_TXN_VALUE, COUNT(*) AS INJECTED_APPROVED_DEBIT_VISA_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 0 AND function_code = 200 AND action_code = 0;



-- Average Txn value credit:		£33.52
SELECT AVG(amount) AS AVG_CREDIT_TXN_VALUE, SUM(amount) AS SUM_CREDIT_TXN_VALUE, COUNT(*) AS CREDIT_TXN_QTY FROM transaction_log WHERE function_code = 100;


-- Injected Average Txn value credit:		£33.52
SELECT AVG(amount) AS INJECTED_AVG_CREDIT_TXN_VALUE, SUM(amount) AS INJECTED_SUM_CREDIT_TXN_VALUE, COUNT(*) AS INJECTED_CREDIT_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND function_code = 100;



-- Mastercard Credit transactions
SELECT AVG(amount) AS AVG_CREDIT_MC_TXN_VALUE, SUM(amount) AS SUM_CREDIT_MC_TXN_VALUE, COUNT(*) AS CREDIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 100;


-- Injected Mastercard Credit transactions
SELECT AVG(amount) AS INJECTED_AVG_CREDIT_MC_TXN_VALUE, SUM(amount) AS INJECTED_SUM_CREDIT_MC_TXN_VALUE, COUNT(*) AS INJECTED_CREDIT_MC_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 1 AND function_code = 100;



-- Mastercard Approved Credit transactions
SELECT AVG(amount) AS AVG_APPROVED_CREDIT_MC_TXN_VALUE, SUM(amount) AS SUM_APPROVED_CREDIT_MC_TXN_VALUE, COUNT(*) AS APPROVED_CREDIT_MC_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 1 AND function_code = 100 AND action_code = 0;


-- Injected Mastercard Approved Credit transactions
SELECT AVG(amount) AS INJECTED_AVG_APPROVED_CREDIT_MC_TXN_VALUE, SUM(amount) AS INJECTED_SUM_APPROVED_CREDIT_MC_TXN_VALUE, COUNT(*) AS INJECTED_APPROVED_CREDIT_MC_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 1 AND function_code = 100 AND action_code = 0;



-- Visa Credit transactions
SELECT AVG(amount) AS AVG_CREDIT_VISA_TXN_VALUE, SUM(amount) AS SUM_CREDIT_VISA_TXN_VALUE, COUNT(*) AS CREDIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 100;


-- Injected Visa Credit transactions
SELECT AVG(amount) AS INJECTED_AVG_CREDIT_VISA_TXN_VALUE, SUM(amount) AS INJECTED_SUM_CREDIT_VISA_TXN_VALUE, COUNT(*) AS INJECTED_CREDIT_VISA_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 0 AND function_code = 100;



-- Visa Approved Credit transactions
SELECT AVG(amount) AS AVG_APPROVED_CREDIT_VISA_TXN_VALUE, SUM(amount) AS SUM_APPROVED_CREDIT_VISA_TXN_VALUE, COUNT(*) AS APPROVED_CREDIT_VISA_TXN_QTY FROM transaction_log WHERE CARD_SCHEME = 0 AND function_code = 100 AND action_code = 0;


-- Injected Visa Approved Credit transactions
SELECT AVG(amount) AS INJECTED_AVG_APPROVED_CREDIT_VISA_TXN_VALUE, SUM(amount) AS INJECTED_SUM_APPROVED_CREDIT_VISA_TXN_VALUE, COUNT(*) AS INJECTED_APPROVED_CREDIT_VISA_TXN_QTY FROM transaction_log WHERE id >= 130000000 AND CARD_SCHEME = 0 AND function_code = 100 AND action_code = 0;



-- How much is the sum of all transactions and how many transactions
SELECT SUM(amount) AS TXN_AMOUNT_TOTAL, COUNT(*) AS TXN_QTY FROM transaction_log;


-- How much is the sum of all injected transactions and how many transactions
SELECT SUM(amount) AS INJECTED_TXN_AMOUNT_TOTAL, COUNT(*) AS INJECTED_TXN_QTY FROM transaction_log WHERE id >= 130000000;



-- How much is the sum of all APPROVED transactions and how many transactions are APPROVED
SELECT SUM(amount) AS TXN_APPROVED_AMOUNT_TOTAL, COUNT(*) AS TXN_APPROVED_QTY FROM transaction_log WHERE action_code = 0;


-- How much is the sum of all injected APPROVED transactions and how many transactions are APPROVED
SELECT SUM(amount) AS INJECTED_TXN_APPROVED_AMOUNT_TOTAL, COUNT(*) AS INJECTED_TXN_APPROVED_QTY FROM transaction_log WHERE id >= 130000000 AND action_code = 0;




-- Interval
SELECT MIN(utc_capture_date_time) AS TXN_INTERVAL_MIN, MAX(utc_capture_date_time) AS TXN_INTERVAL_MAX FROM transaction_log WHERE function_code = 200;


-- Injected transactions interval
SELECT MIN(utc_capture_date_time) AS INJECTED_TXN_INTERVAL_MIN, MAX(utc_capture_date_time) AS INJECTED_TXN_INTERVAL_MAX FROM transaction_log WHERE id >= 130000000 AND function_code = 200;



-- Useful for quickly clean the database after a test involving the insert of new transactions
SELECT max(id) AS MAX_ID_TRANSACTION_LOG FROM transaction_log;

-- Useful for quickly clean the database after a test involving the insert of new transactions
SELECT max(id) AS MAX_ID_TRANSACTION_EMV_DATA FROM transaction_emv_data;


ALTER TABLE transaction_log DROP INDEX OnlyForTheRrportsIdx;

