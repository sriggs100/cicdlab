
-- 1. Create a new column transaction_emv_data.application_transaction_counter varchar(4)

SELECT NOW(); ALTER TABLE transaction_emv_data ADD COLUMN application_transaction_counter VARCHAR(4) DEFAULT NULL, ALGORITHM=INPLACE, LOCK=NONE;  SELECT NOW();

-- 2. Create triggers on the transaction_log table to update the new table column on transaction_emv_data




--
--	INSERT trigger
--

DROP PROCEDURE IF EXISTS sp_update_emv_data_atc_from_trigger;

DELIMITER //
CREATE PROCEDURE sp_update_emv_data_atc_from_trigger(
            IN pId bigint,
            IN pApplication_transaction_counter VARCHAR(4),
            INOUT pUpdated SMALLINT
           )
BEGIN
    DECLARE not_found INTEGER DEFAULT 0;
    DECLARE lATC VARCHAR(4);

    DEClARE cur
        CURSOR FOR
            SELECT application_transaction_counter FROM transaction_emv_data WHERE id = pId;

    -- declare NOT FOUND handler
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET not_found = 1;

    OPEN cur;

    BLOCK:BEGIN
        FETCH cur INTO lATC;
        IF not_found = 1
        THEN
            SET pUpdated = 0;

            LEAVE BLOCK;
        END IF;

        IF lATC = pApplication_transaction_counter
        THEN
            -- Nothing to do
            SET pUpdated = 0;

            LEAVE BLOCK;
        END IF;

        UPDATE transaction_emv_data SET application_transaction_counter = lATC WHERE id = pId;

        SET pUpdated = 1;

    END BLOCK;

    CLOSE cur;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS transaction_log_update_emv_data_atc_AFTER_INSERT;

DELIMITER //
CREATE DEFINER = CURRENT_USER TRIGGER transaction_log_update_emv_data_atc_AFTER_INSERT AFTER INSERT ON transaction_log FOR EACH ROW
BEGIN
DECLARE lUpdated SMALLINT DEFAULT 0;

    CALL sp_update_emv_data_atc_from_trigger(
            NEW.transaction_emv_data_id,
            NEW.application_transaction_counter,
            lUpdated
            );
END//
DELIMITER ;


--
--	UPDATE trigger
--


DROP TRIGGER IF EXISTS transaction_log_update_emv_data_atc_AFTER_UPDATE;

DELIMITER //
CREATE DEFINER = CURRENT_USER TRIGGER transaction_log_update_emv_data_atc_AFTER_UPDATE AFTER UPDATE ON transaction_log FOR EACH ROW
BEGIN
DECLARE lUpdated SMALLINT DEFAULT 0;

    CALL sp_update_emv_data_atc_from_trigger(
            NEW.transaction_emv_data_id,
            NEW.application_transaction_counter,
            lUpdated
            );
END//
DELIMITER ;



-- 3. Create a stored procedure to copy the data to the new table column

DROP PROCEDURE IF EXISTS sp_copy_to_transaction_emv_data_atc;

DELIMITER //
CREATE PROCEDURE sp_copy_to_transaction_emv_data_atc()
BEGIN
    DECLARE not_found INTEGER DEFAULT 0;
    DECLARE error_record_lock INTEGER DEFAULT 0;
    DECLARE currId BIGINT DEFAULT 0;
    DECLARE updatedRecQty BIGINT DEFAULT 0;
    DECLARE loopJustStarted INT DEFAULT 0;
    DECLARE lUpdated SMALLINT DEFAULT 0;


    DECLARE lId bigint;
    DECLARE lApplication_transaction_counter varchar(4);
    DECLARE lTransaction_emv_data_id bigint;


    DEClARE cur
        CURSOR FOR
            SELECT id,
                transaction_emv_data_id,
                application_transaction_counter
            FROM transaction_log
            WHERE id >= currId
            ORDER BY id ASC
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

    OUTER_BLOCK: LOOP

        IF currId > 0 THEN
            SET currId = currId + 1;
        END IF;

        OPEN cur;

        SET loopJustStarted = 1;

        DO SLEEP( 0.2 );

        START TRANSACTION;

        TRANSACTION_BLOCK: LOOP
            FETCH cur INTO lId, lTransaction_emv_data_id, lApplication_transaction_counter;

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
            CALL sp_update_emv_data_atc_from_trigger( lTransaction_emv_data_id, lApplication_transaction_counter, lUpdated );

            IF lUpdated = 1
            THEN
                SET updatedRecQty = updatedRecQty + 1;
            END IF;

        END LOOP TRANSACTION_BLOCK;

        CLOSE cur;

        COMMIT;

        SET not_found = 0;

    END LOOP OUTER_BLOCK;

    COMMIT;

    SELECT updatedRecQty AS 'TOTAL updated records', error_record_lock AS "Errors due to record lock";
END//
DELIMITER ;


-- 4. Execute the stored procedure several times until it informs that no updates have been performed

SELECT NOW(); CALL sp_copy_to_transaction_emv_data_atc(); SELECT NOW();


-- Check that the contents are the same on both tables
CREATE INDEX logApplication_transaction_counterIdx ON transaction_log (application_transaction_counter);
CREATE INDEX dataApplication_transaction_counterIdx ON transaction_emv_data (application_transaction_counter);

-- The following select must return 0
SELECT COUNT(*) FROM transaction_log l, transaction_emv_data d WHERE l.transaction_emv_data_id = d.id AND l.application_transaction_counter <> d.application_transaction_counter;


-- 5. Inform the development team that the new table layout is ready


-- 6. As soon as the application is ready for the new layout, drop the triggers and remove transaction_log.application_transaction_counter column

DROP TRIGGER transaction_log_update_emv_data_atc_AFTER_INSERT;
DROP TRIGGER transaction_log_update_emv_data_atc_AFTER_UPDATE;
SELECT NOW(); ALTER TABLE transaction_log DROP COLUMN application_transaction_counter, ALGORITHM=INPLACE; SELECT NOW();




