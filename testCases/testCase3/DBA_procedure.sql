


-- 1. Create a new table transaction_log.transaction_token with default NULL without the UNIQUE constraint


SELECT NOW(); ALTER TABLE transaction_log ADD COLUMN transaction_token CHAR(36) NOT NULL DEFAULT "change me", ALGORITHM=INPLACE, LOCK=NONE;  SELECT NOW();


-- 2. Create triggers on the transaction_log table to update the new column by generating a new Token for every insert


--
--	INSERT trigger
--

DROP TRIGGER IF EXISTS sp_generate_transaction_token_from_trigger_BEFORE_INSERT;

DELIMITER //
CREATE DEFINER = CURRENT_USER TRIGGER sp_generate_transaction_token_from_trigger_BEFORE_INSERT BEFORE INSERT ON transaction_log FOR EACH ROW
BEGIN
DECLARE lUpdated SMALLINT DEFAULT 0;

    SET NEW.transaction_token = UUID();

END//
DELIMITER ;


-- 3. Create a stored procedure to generate new transaction tokens for the new column


DROP PROCEDURE IF EXISTS sp_generate_transaction_token;

DELIMITER //
CREATE PROCEDURE sp_generate_transaction_token(
        IN pPartition INTEGER,
        IN pTotalPartitions INTEGER,
        IN maxId BIGINT
        )
BEGIN
    DECLARE not_found INTEGER DEFAULT 0;
    DECLARE error_record_lock INTEGER DEFAULT 0;
    DECLARE currId BIGINT DEFAULT 0;
    DECLARE updatedRecQty BIGINT DEFAULT 0;
    DECLARE loopJustStarted INT DEFAULT 0;
    DECLARE lUpdated SMALLINT DEFAULT 0;
    DECLARE idsPerPartition BIGINT DEFAULT 0;
    DECLARE partitionLowId BIGINT DEFAULT 0;
    DECLARE partitionHighId BIGINT DEFAULT 0;
    DECLARE lId bigint;
    DECLARE lTransactionToken CHAR(36);


    DEClARE cur
        CURSOR FOR
            SELECT id, transaction_token
            FROM transaction_log
            WHERE id >= currId AND id < partitionHighId
            LIMIT 1000;

    -- Error due to record lock handler
    DECLARE CONTINUE HANDLER FOR 1205  -- Lock wait timeout exceeded
        SET error_record_lock = error_record_lock + 1;

    -- declare NOT FOUND handler
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET not_found = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SHOW ERRORS;
        ROLLBACK;
    END;

    SET idsPerPartition = maxId / pTotalPartitions;

    SET partitionLowId = idsPerPartition * pPartition;
    SET partitionHighId = partitionLowId + idsPerPartition;

    SELECT partitionLowId AS "low id", partitionHighId AS "high id";


    SET currId = partitionLowId;

    OUTER_BLOCK: LOOP

        IF currId > 0 THEN
            SET currId = currId + 1;
        END IF;

        OPEN cur;

        SET loopJustStarted = 1;

        DO SLEEP( 0.1 );

        START TRANSACTION;

        TRANSACTION_BLOCK: LOOP
            FETCH cur INTO lId, lTransactionToken;

            IF not_found = 1 THEN
                IF loopJustStarted = 1 THEN     -- There're no more records
                    LEAVE OUTER_BLOCK;
                ELSE
                    LEAVE TRANSACTION_BLOCK;
                END IF;
            END IF;

            SET loopJustStarted = 0;
            SET currId = lId;

            SET lUpdated = 0;

            IF lTransactionToken = "change me"
            THEN
                UPDATE transaction_log SET transaction_token = UUID() WHERE id = lId;
                SET updatedRecQty = updatedRecQty + 1;
            END IF;

        END LOOP TRANSACTION_BLOCK;

        CLOSE cur;

        COMMIT;

        SET not_found = 0;

    END LOOP OUTER_BLOCK;

    COMMIT;

    SELECT updatedRecQty AS "TOTAL updated records", error_record_lock AS "Errors due to record lock";
END//
DELIMITER ;


-- 4. Execute the stored procedure several times until it informs that no records have been updated

-- In order to maximize database server resources usage, execute the following in parallel


SELECT MAX(id) FROM transaction_log;
132287849

SELECT NOW(); CALL sp_generate_transaction_token( 0, 3, 132287849 ); SELECT NOW();
SELECT NOW(); CALL sp_generate_transaction_token( 1, 3, 132287849 ); SELECT NOW();
SELECT NOW(); CALL sp_generate_transaction_token( 2, 3, 132287849 ); SELECT NOW();


-- 5. Create the indexes and constraints for the new field and remove the previously created default value

SELECT NOW(); CREATE UNIQUE INDEX transaction_tokenIdx ON transaction_log(transaction_token); SELECT NOW();
SELECT NOW(); ALTER TABLE transaction_log ALTER COLUMN transaction_token DROP DEFAULT, ALGORITHM=INSTANT; SELECT NOW();


-- 6. Inform the development team that the new table layout is ready


-- 7. As soon as the application is ready for the new layout, drop the triggers created on step 2

DROP TRIGGER sp_generate_transaction_token_from_trigger_BEFORE_INSERT;





