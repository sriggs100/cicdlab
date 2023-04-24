

-- 1. Create a new table transaction_log_new with the new layout

DROP TABLE IF EXISTS transaction_log_new;

CREATE TABLE transaction_log_new (
   id bigint not null,
    action_code smallint,
    additional_data varchar(500),
    amount decimal(19,2) not null,
    application_transaction_counter varchar(4),
    authorisation_code varchar(6),
    card_acceptor_name_and_location varchar(99) not null,
    card_scheme integer not null,
    chip_data varchar(512),
    encrypted_expiry_date varchar(96) not null,
    encrypted_pan varchar(96) not null,
    function_code smallint not null,

    -- merchant_category_code smallint not null,
    merchant_category_code varchar(4) not null,

    merchant_id varchar(15) not null,
    msg_type smallint not null,
    pan_hash varchar(64) not null,
    pan_sequence_number smallint not null,
    point_of_service_data_code varchar(12) not null,
    proc_code varchar(6) not null,
    reason_code smallint not null,
    stan integer not null,
    terminal_id varchar(8) not null,
    transaction_currency_code varchar(3),
    transaction_date_time varchar(12) not null,
    utc_capture_date_time datetime not null,
    transaction_emv_data_id bigint not null,
    primary key (id)
) engine=InnoDB;

ALTER TABLE transaction_log_new ROW_FORMAT=COMPRESSED;

ALTER TABLE transaction_log_new ADD CONSTRAINT FKtb0lwheccb9uailspbkittqha_1 FOREIGN KEY (transaction_emv_data_id) REFERENCES transaction_emv_data (id);


-- 2. Create triggers on the transaction_log table to update the new table


--
--	INSERT trigger
--

DROP PROCEDURE IF EXISTS sp_insert_to_new_table_from_trigger;

DELIMITER //
CREATE PROCEDURE sp_insert_to_new_table_from_trigger(
            IN pId bigint,
            IN pAction_code smallint,
            IN pAdditional_data varchar(500),
            IN pAmount decimal(19,2),
            IN pApplication_transaction_counter varchar(4),
            IN pAuthorisation_code varchar(6),
            IN pCard_acceptor_name_and_location varchar(99),
            IN pCard_scheme integer,
            IN pChip_data varchar(512),
            IN pEncrypted_expiry_date varchar(96),
            IN pEncrypted_pan varchar(96),
            IN pFunction_code smallint,
            IN pMerchant_category_code smallint,
            IN pMerchant_id varchar(15),
            IN pMsg_type smallint,
            IN pPan_hash varchar(64),
            IN pPan_sequence_number smallint,
            IN pPoint_of_service_data_code varchar(12),
            IN pProc_code varchar(6),
            IN pReason_code smallint,
            IN pStan integer,
            IN pTerminal_id varchar(8),
            IN pTransaction_currency_code varchar(3),
            IN pTransaction_date_time varchar(12),
            IN pUtc_capture_date_time datetime,
            IN pTransaction_emv_data_id bigint
           )
BEGIN
    IF NOT EXISTS( SELECT 1 FROM transaction_log_new WHERE id = pId )
    THEN
    INSERT INTO `transaction_log_new`
        (
        `id`,
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
        `transaction_emv_data_id`
        )
        VALUES
        (
        pId,
        pAction_code,
        pAdditional_data,
        pAmount,
        pApplication_transaction_counter,
        pAuthorisation_code,
        pCard_acceptor_name_and_location,
        pCard_scheme,
        pChip_data,
        pEncrypted_expiry_date,
        pEncrypted_pan,
        pFunction_code,
        pMerchant_category_code,
        pMerchant_id,
        pMsg_type,
        pPan_hash,
        pPan_sequence_number,
        pPoint_of_service_data_code,
        pProc_code,
        pReason_code,
        pStan,
        pTerminal_id,
        pTransaction_currency_code,
        pTransaction_date_time,
        pUtc_capture_date_time,
        pTransaction_emv_data_id
        );

    END IF;
END;
//
DELIMITER ;


DROP TRIGGER IF EXISTS transaction_log_AFTER_INSERT;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER transaction_log_AFTER_INSERT AFTER INSERT ON transaction_log FOR EACH ROW
BEGIN
    CALL sp_insert_to_new_table_from_trigger(
            NEW.id,
            NEW.action_code,
            NEW.additional_data,
            NEW.amount,
            NEW.application_transaction_counter,
            NEW.authorisation_code,
            NEW.card_acceptor_name_and_location,
            NEW.card_scheme,
            NEW.chip_data,
            NEW.encrypted_expiry_date,
            NEW.encrypted_pan,
            NEW.function_code,
            NEW.merchant_category_code,
            NEW.merchant_id,
            NEW.msg_type,
            NEW.pan_hash,
            NEW.pan_sequence_number,
            NEW.point_of_service_data_code,
            NEW.proc_code,
            NEW.reason_code,
            NEW.stan,
            NEW.terminal_id,
            NEW.transaction_currency_code,
            NEW.transaction_date_time,
            NEW.utc_capture_date_time,
            NEW.transaction_emv_data_id
            );
END$$
DELIMITER ;






-- 3. Create a stored procedure to copy the data to the new table

DROP PROCEDURE IF EXISTS sp_copy_to_transaction_log_new;

DELIMITER //
CREATE PROCEDURE sp_copy_to_transaction_log_new()
BEGIN
    DECLARE not_found INTEGER DEFAULT 0;
    DECLARE error_record_lock INTEGER DEFAULT 0;
    DECLARE currId BIGINT DEFAULT 0;
    DECLARE insertedRecQty BIGINT DEFAULT 0;
    DECLARE loopJustStarted INT DEFAULT 0;

    DECLARE lId bigint;
    DECLARE lAction_code smallint;
    DECLARE lAdditional_data varchar(500);
    DECLARE lAmount decimal(19,2);
    DECLARE lApplication_transaction_counter varchar(4);
    DECLARE lAuthorisation_code varchar(6);
    DECLARE lCard_acceptor_name_and_location varchar(99);
    DECLARE lCard_scheme integer;
    DECLARE lChip_data varchar(512);
    DECLARE lEncrypted_expiry_date varchar(96);
    DECLARE lEncrypted_pan varchar(96);
    DECLARE lFunction_code smallint;
    DECLARE lMerchant_category_code smallint;
    DECLARE lMerchant_id varchar(15);
    DECLARE lMsg_type smallint;
    DECLARE lPan_hash varchar(64);
    DECLARE lPan_sequence_number smallint;
    DECLARE lPoint_of_service_data_code varchar(12);
    DECLARE lProc_code varchar(6);
    DECLARE lReason_code smallint;
    DECLARE lStan integer;
    DECLARE lTerminal_id varchar(8);
    DECLARE lTransaction_currency_code varchar(3);
    DECLARE lTransaction_date_time varchar(12);
    DECLARE lUtc_capture_date_time datetime;
    DECLARE lTransaction_emv_data_id bigint;


    DEClARE cur
        CURSOR FOR
            SELECT id,
                action_code,
                additional_data,
                amount,
                application_transaction_counter,
                authorisation_code,
                card_acceptor_name_and_location,
                card_scheme,
                chip_data,
                encrypted_expiry_date,
                encrypted_pan,
                function_code,
                merchant_category_code,
                merchant_id,
                msg_type,
                pan_hash,
                pan_sequence_number,
                point_of_service_data_code,
                proc_code,
                reason_code,
                stan,
                terminal_id,
                transaction_currency_code,
                transaction_date_time,
                utc_capture_date_time,
                transaction_emv_data_id
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
            FETCH cur INTO lId, lAction_code, lAdditional_data, lAmount, lApplication_transaction_counter, lAuthorisation_code,
                           lCard_acceptor_name_and_location, lCard_scheme, lChip_data, lEncrypted_expiry_date, lEncrypted_pan,
                           lFunction_code, lMerchant_category_code, lMerchant_id, lMsg_type, lPan_hash, lPan_sequence_number,
                           lPoint_of_service_data_code, lProc_code, lReason_code, lStan, lTerminal_id, lTransaction_currency_code,
                           lTransaction_date_time, lUtc_capture_date_time, lTransaction_emv_data_id;

            IF not_found = 1 THEN
                IF loopJustStarted = 1 THEN     -- There're no more records
                    LEAVE OUTER_BLOCK;
                ELSE
                    LEAVE TRANSACTION_BLOCK;
                END IF;
            END IF;

            SET loopJustStarted = 0;
            SET currId = lId;

            IF NOT EXISTS( SELECT 1 FROM transaction_log_new WHERE id = lId )
            THEN

                INSERT INTO transaction_log_new
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
                    (lId, lAction_code, lAdditional_data, lAmount, lApplication_transaction_counter, lAuthorisation_code,
                    lCard_acceptor_name_and_location, lCard_scheme, lChip_data, lEncrypted_expiry_date, lEncrypted_pan,
                    lFunction_code, lMerchant_category_code, lMerchant_id, lMsg_type, lPan_hash, lPan_sequence_number,
                    lPoint_of_service_data_code, lProc_code, lReason_code, lStan, lTerminal_id, lTransaction_currency_code,
                    lTransaction_date_time, lUtc_capture_date_time, lTransaction_emv_data_id );

                SET insertedRecQty = insertedRecQty + 1;

            END IF;

        END LOOP TRANSACTION_BLOCK;

        CLOSE cur;

        COMMIT;

        SET not_found = 0;

    END LOOP OUTER_BLOCK;

    COMMIT;

    SELECT insertedRecQty AS 'TOTAL copied records', error_record_lock AS "Errors due to record lock";
END;
//
DELIMITER ;



-- 4. Execute the stored procedure until it informs that no records have been copied

SELECT NOW(); CALL sp_copy_to_transaction_log_new(); SELECT NOW();



-- 5. Create the indexes and constraints on the new table

SELECT NOW(); CREATE INDEX cardSchemeIdx ON transaction_log_new (card_scheme) ALGORITHM=INPLACE LOCK=NONE; SELECT NOW();
SELECT NOW(); CREATE INDEX functionCodeIdx ON transaction_log_new (function_code) ALGORITHM=INPLACE LOCK=NONE; SELECT NOW();
SELECT NOW(); CREATE INDEX utcCaptureDateTimeIdx ON transaction_log_new (utc_capture_date_time) ALGORITHM=INPLACE LOCK=NONE; SELECT NOW();
SELECT NOW(); ALTER TABLE transaction_log_new ADD CONSTRAINT UniqueMerchantTerminalStan UNIQUE (merchant_id, terminal_id, stan), ALGORITHM=INPLACE, LOCK=NONE; SELECT NOW();


-- 6. Create the foreign keys on the new table

-- SET FOREIGN_KEY_CHECKS = 0;
-- SELECT NOW(); ALTER TABLE transaction_log_new ADD CONSTRAINT FKtb0lwheccb9uailspbkittqha_1 FOREIGN KEY (transaction_emv_data_id) REFERENCES transaction_emv_data (id), ALGORITHM=INPLACE, LOCK=NONE; SELECT NOW();
-- SET FOREIGN_KEY_CHECKS = 1;


-- 7. Remove the foreign keys from the transaction_log table

SELECT NOW(); ALTER TABLE transaction_log DROP FOREIGN KEY FKtb0lwheccb9uailspbkittqha, ALGORITHM=INPLACE, LOCK=NONE; SELECT NOW();


-- 8. Recreate foreign keys from other tables making them point to the new table

-- There're no such foreign keys in this case

-- 9. Inform the development team that the new table layout is ready


-- 10. As soon as the application is ready for the new layout, rename the tables

SELECT NOW(); ALTER TABLE transaction_log RENAME TO transaction_log_OLD, ALGORITHM=INPLACE; SELECT NOW();
SELECT NOW(); ALTER TABLE transaction_log_new RENAME TO transaction_log, ALGORITHM=INPLACE; SELECT NOW();

-- 11. Remove the old table

SELECT NOW(); DROP TABLE transaction_log_OLD; SELECT NOW();
