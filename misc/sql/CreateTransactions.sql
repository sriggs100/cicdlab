use experiment;


SET FOREIGN_KEY_CHECKS = 0;
truncate table transaction_log;
truncate table transaction_emv_data;
SET FOREIGN_KEY_CHECKS = 1;


DROP TABLE IF EXISTS last_terminal_stan;

CREATE TABLE last_terminal_stan(
    terminals_id bigint not null,
    last_stan int NOT NULL DEFAULT 0,
    primary key (terminals_id)
    ) engine=MEMORY;


DROP PROCEDURE IF EXISTS getStanForTerminal;

DELIMITER //
CREATE PROCEDURE getStanForTerminal(
               IN termId bigint,
               OUT stan int
           )
BEGIN
DECLARE id int DEFAULT termId % 1000;

    IF( NOT EXISTS( SELECT last_stan FROM last_terminal_stan WHERE terminals_id = id ) )
    THEN
        INSERT INTO last_terminal_stan(terminals_id, last_stan) VALUES( id, 1 );

        SET stan = 1;
    ELSE
        SELECT last_stan + 1 INTO stan FROM last_terminal_stan WHERE terminals_id = id;
        UPDATE last_terminal_stan SET last_stan = stan WHERE terminals_id = id;
    END IF;
END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS createTransactions;


SET @old_sql_mode=@@sql_mode;
SET @@sql_mode=PIPES_AS_CONCAT;


DELIMITER //
CREATE PROCEDURE createTransactions(
    IN DATE_DAY DATE
)
BEGIN
DECLARE transactionsCnt INT DEFAULT 1;
DECLARE startingMaxTransactionId INT DEFAULT 0;
DECLARE startingMaxTransactionEmvDataId INT DEFAULT 0;
DECLARE transactionsPerDay INT DEFAULT 3700000;			-- Transactions per day
-- DECLARE transactionsPerDay INT DEFAULT 740000;			-- Transactions per day     (Medium database 30GB memory)
-- DECLARE transactionsPerDay INT DEFAULT 150000;			-- Transactions per day     (Small database 8GB memory)
-- DECLARE transactionsPerDay INT DEFAULT 100;			    -- Transactions per day     (Test environment)
DECLARE tps INT DEFAULT transactionsPerDay / 24 / 3600;	-- Transactions per second
DECLARE minTerminalId INT DEFAULT 0;
DECLARE maxTerminalId INT DEFAULT 0;
DECLARE randomTermId INT DEFAULT 0;
DECLARE termid VARCHAR(8);
DECLARE stan INT DEFAULT 0;
DECLARE merchid VARCHAR(15);

DECLARE functionCode INT;		-- 100 = Credit / 200 = Debit
DECLARE cardScheme INT;			-- 0 = VISA / 1 = MASTERCARD
DECLARE amount DECIMAL(12,2);	-- Transaction Amount
DECLARE txnDateTime DATETIME;	-- Transaction date and time

DECLARE currentSecondInDay INT;	-- Calculated second in the specific day


select COALESCE( min(id), 0 ), COALESCE( max(id), 0 ) INTO minTerminalId, maxTerminalId from terminal;
select COALESCE( max(id), 0 ) INTO startingMaxTransactionId from transaction_log;
select COALESCE( max(id), 0 ) INTO startingMaxTransactionEmvDataId from transaction_emv_data;


SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
ALTER TABLE transaction_log DISABLE KEYS;
ALTER TABLE transaction_emv_data DISABLE KEYS;

START TRANSACTION;

WHILE (transactionsCnt < transactionsPerDay)
-- WHILE (transactionsCnt < 100)
DO

    -- get a random terminal id
    SET randomTermId = FLOOR(RAND()*(maxTerminalId-minTerminalId+1)+minTerminalId);


    -- get the corresponding terminal Id and merchant Id
    SELECT t.terminal_id, m.merchant_id INTO termid, merchid FROM terminal t, merchant m WHERE t.id = randomTermId AND t.merchant_id = m.id;

    -- SELECT "random term id: " || randomTermId || " / termid: " || termid || " / merhid: " || merchid;

    CALL getStanForTerminal( randomTermId, stan );

    -- Define transaction type (credit / debit)
    if( RAND() <= 0.2 )
    THEN
        SET functionCode = 100;		-- 20% if transactions are Credit transactions
    ELSE
        SET functionCode = 200;
    END IF;


    -- Define card scheme (Mastercard / Visa)
    if( RAND() <= 0.14 )
    THEN
        SET cardScheme = 1;		-- 14% of transactions are MasterCard
    ELSE
        SET cardScheme = 0;
    END IF;


    -- Define Amount according to transaction type (average 22.82 for debit and 33.52 for credit)
    if( functionCode = 100 )
    THEN
        -- credit transactions average amount is ~ £33.52
        SET amount = RAND()*(33.52+30-(33.52-30))+33.52-30;
    ELSE
        -- debit transactions average amount is ~ £22.82
        SET amount = RAND()*(22.82+20-(22.82-20))+22.82-20;
    END IF;


    -- Define transaction date and time as well as timestamp (based on transaction count and tps)
    if( tps = 0 )
    THEN
        SET tps = 1;
    END IF;

    SET currentSecondInDay = transactionsCnt/tps;
    SET txnDateTime = DATE_ADD( DATE_DAY, INTERVAL currentSecondInDay SECOND );


    -- SELECT "txnDateTime: " || txnDateTime || " / amount: " || amount || " / cardScheme: " || cardScheme || " / functionCode: " || functionCode;



    -- Create transaction record
    INSERT INTO `transaction_log`
    (`id`,
    `action_code`,
    `additional_data`,
    `amount`,
    `application_transaction_counter`,
    `authorisation_code`,
    `card_acceptor_name_and_location`,
    `card_scheme`,
    `chip_data`,
    `encrypted_expiry_date`,
    `encrypted_pan`,
    `function_code`,
    `merchant_category_code`,
    `merchant_id`,
    `msg_type`,
    `pan_hash`,
    `pan_sequence_number`,
    `point_of_service_data_code`,
    `proc_code`,
    `reason_code`,
    `stan`,
    `terminal_id`,
    `transaction_currency_code`,
    `transaction_date_time`,
    `utc_capture_date_time`,
    `transaction_emv_data_id`)
    VALUES
    ( transactionsCnt + startingMaxTransactionId,
    0, -- <{action_code: }>,
    "6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E", -- <{additional_data: }>,
    amount,
    FLOOR( RAND()*1000 ), -- <{application_transaction_counter: }>,
    FLOOR( RAND()*1000000 ), -- <{authorisation_code: }>,
    "INSURANCE LTD\Main Street\London\    E143GJ   UK", -- <{card_acceptor_name_and_location: }>,
    cardScheme, -- <{card_scheme: }>,
    "820212908407A0000000041010950500000000019A030201229C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152", -- <{chip_data: }>,
    "1084b677409027b484d4b7eca26aa732", -- <{encrypted_expiry_date: }>,
    "1084b677409027b484d4b7eca26aa732", -- <{encrypted_pan: }>,
    functionCode, -- <{function_code: }>,
    FLOOR( RAND()*1000 ), -- <{merchant_category_code: }>,
    merchid,
    1100,
    "1084b677409027b484d4b7eca26aa7321084b677409027b484d4b7eca26aa732", -- <{pan_hash: }>,
    03, -- <{pan_sequence_number: }>,
    "03M012887675", -- <{point_of_service_data_code: }>,
    "000000", -- <{proc_code: }>,
    0, -- <{reason_code: }>,
    stan, -- (transactionsCnt + startingMaxTransactionId) % 1000000, -- <{stan: }>,
    termid,
    826, -- <{transaction_currency_code: }>,
    DATE_FORMAT(txnDateTime, "%y%m%d%H%i%s" ), -- <{transaction_date_time: }>,		-- format: YYMMDDhhmmss
    txnDateTime, -- <{utc_capture_date_time: }>,
    transactionsCnt + startingMaxTransactionEmvDataId );


    INSERT INTO `transaction_emv_data`
    (`id`,
    `application_expiration_date`,
    `interface_device_serial_number`,
    `terminal_capabilities`)
    VALUES
    ( transactionsCnt + startingMaxTransactionEmvDataId,
    "220716", -- <{application_expiration_date: }>,
    "12345678", -- <{interface_device_serial_number: }>,
    null -- <{terminal_capabilities: }>
    );


    SET transactionsCnt = transactionsCnt + 1;

    IF( (transactionsCnt % 40000) = 0 )
    THEN
        SELECT transactionsCnt;

        COMMIT;
        START TRANSACTION;
    END IF;

END WHILE;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
ALTER TABLE transaction_log ENABLE KEYS;
ALTER TABLE transaction_emv_data ENABLE KEYS;

END;
//
DELIMITER ;

SET @@sql_mode=@old_sql_mode;





--
-- createTransactionsLoop()
--

drop procedure if exists createTransactionsLoop;

DELIMITER //
CREATE PROCEDURE createTransactionsLoop()
BEGIN
DECLARE daysCnt INT DEFAULT 0;
DECLARE dateDay DATE;


WHILE (daysCnt < 35)
DO
    SET dateDay = '2022-07-14' + INTERVAL daysCnt DAY;

    SELECT CONCAT('About to create transactions for date: ', dateDay );

    CALL createTransactions( dateDay );

    SET daysCnt = daysCnt + 1;

END WHILE;

END;
//
DELIMITER ;


SET @@session.sql_log_bin=0;
CALL createTransactionsLoop();
SET @@session.sql_log_bin=1;