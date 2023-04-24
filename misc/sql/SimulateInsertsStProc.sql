

DROP TABLE IF EXISTS last_terminal_stan;

CREATE TABLE last_terminal_stan(
    terminals_id bigint not null,
    last_stan int NOT NULL DEFAULT 0,
    primary key (terminals_id)
    ) engine=MEMORY;


DROP PROCEDURE IF EXISTS getStanForTerminalWithMinimum;

DELIMITER //
CREATE PROCEDURE getStanForTerminalWithMinimum(
               IN termId bigint,
               IN minStan int,
               OUT stan int
           )
BEGIN
DECLARE id int DEFAULT termId % 1000;

    IF( NOT EXISTS( SELECT last_stan FROM last_terminal_stan WHERE terminals_id = id ) )
    THEN
        SET stan = minStan;

        INSERT INTO last_terminal_stan(terminals_id, last_stan) VALUES( id, stan );
    ELSE
        SELECT last_stan + 1 INTO stan FROM last_terminal_stan WHERE terminals_id = id;
        UPDATE last_terminal_stan SET last_stan = stan WHERE terminals_id = id;
    END IF;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS simulateInserts;


DELIMITER //
CREATE PROCEDURE simulateInserts(
    IN DATE_DAY DATE,
    IN DURATION_MINUTES INT
)
BEGIN
DECLARE transactionsCnt INT DEFAULT 0;
DECLARE startingMaxTransactionId INT DEFAULT 0;
DECLARE startingMaxTransactionEmvDataId INT DEFAULT 0;
DECLARE transactionsPerDay INT DEFAULT 3700000;			-- Transactions per day
-- DECLARE transactionsPerDay INT DEFAULT 740000;			-- Transactions per day     (Medium database 30GB memory)
-- DECLARE transactionsPerDay INT DEFAULT 150000;			-- Transactions per day     (Small database 8GB memory)
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

DECLARE iterationStartTime BIGINT;

DECLARE totalTransactions INT DEFAULT tps * 60 * DURATION_MINUTES;
DECLARE sleepInterval FLOAT;


DECLARE CONTINUE HANDLER FOR 1205  -- Lock wait timeout exceeded
    SELECT 'Error, Lock wait timeout exceeded';

DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SHOW ERRORS;
        ROLLBACK;
    END;

SELECT COALESCE( MIN(id), 0 ), COALESCE( MAX(id), 0 ) INTO minTerminalId, maxTerminalId FROM terminal;
SELECT COALESCE( MAX(id), 0 ) + 1 INTO startingMaxTransactionId FROM transaction_log;
SELECT COALESCE( MAX(id), 0 ) + 1 INTO startingMaxTransactionEmvDataId FROM transaction_emv_data;


WHILE (transactionsCnt < totalTransactions)
-- WHILE (transactionsCnt < 100)
DO
    SET iterationStartTime = ROUND(UNIX_TIMESTAMP(CURTIME(4)) * 1000);

    -- get a random terminal id
    SET randomTermId = FLOOR(RAND()*(maxTerminalId-minTerminalId+1)+minTerminalId);


    -- get the corresponding terminal Id and merchant Id
    SELECT t.terminal_id, m.merchant_id INTO termid, merchid FROM terminal t, merchant m WHERE t.id = randomTermId AND t.merchant_id = m.id;

    -- SELECT "random term id: " || randomTermId || " / termid: " || termid || " / merhid: " || merchid;

    CALL getStanForTerminalWithMinimum( randomTermId, 400000, stan );


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
    SET currentSecondInDay = transactionsCnt/tps;
    SET txnDateTime = DATE_ADD( DATE_DAY, INTERVAL currentSecondInDay SECOND );


    -- SELECT "txnDateTime: " || txnDateTime || " / amount: " || amount || " / cardScheme: " || cardScheme || " / functionCode: " || functionCode;


    START TRANSACTION;

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



    COMMIT;


    SET transactionsCnt = transactionsCnt + 1;


    IF( (transactionsCnt % 10000) = 0 )
    THEN
        SELECT transactionsCnt;
    END IF;

    SET sleepInterval = 1/tps - ( ROUND(UNIX_TIMESTAMP(CURTIME(4)) * 1000) - iterationStartTime )/1000;
    IF( sleepInterval > 0 )
    THEN
        DO SLEEP( sleepInterval );
    END IF;

END WHILE;

SELECT transactionsCnt AS TOTAL;

END//
DELIMITER ;

CALL simulateInserts( '2022-08-20', 18 * 60 * 60 );
