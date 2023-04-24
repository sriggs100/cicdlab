
-- MIT License
-- 
-- Copyright (c) 2022 Sergio Andres Penen
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.




-- 1. Create triggers on the transaction_log table to update the new table column on transaction_emv_data


--
--	INSERT trigger
--

DROP PROCEDURE IF EXISTS sp_update_emv_data_atc_from_trigger;

DELIMITER //
CREATE PROCEDURE sp_update_emv_data_atc_from_trigger(
            IN pId bigint,
            IN pApplication_transaction_counter VARCHAR(4)
           )
BEGIN
    UPDATE transaction_emv_data SET application_transaction_counter = pApplication_transaction_counter WHERE id = pId;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS transaction_log_update_emv_data_atc_AFTER_INSERT;

DELIMITER //
CREATE DEFINER = CURRENT_USER TRIGGER transaction_log_update_emv_data_atc_AFTER_INSERT AFTER INSERT ON transaction_log FOR EACH ROW
BEGIN
    CALL sp_update_emv_data_atc_from_trigger(
            NEW.transaction_emv_data_id,
            NEW.application_transaction_counter
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
    CALL sp_update_emv_data_atc_from_trigger(
            NEW.transaction_emv_data_id,
            NEW.application_transaction_counter
            );
END//
DELIMITER ;


DROP TABLE IF EXISTS PROGRESS_REPORT;

create table PROGRESS_REPORT
(
	timestampZ TIMESTAMP DEFAULT NOW(),
    msg varchar(200)
);


set sql_mode=PIPES_AS_CONCAT;



-- 2. Create a stored procedure to copy the data to the new table column

DROP PROCEDURE IF EXISTS sp_copy_to_transaction_emv_data_atc;

DELIMITER //
CREATE PROCEDURE sp_copy_to_transaction_emv_data_atc()
BEGIN
    DECLARE not_found INTEGER DEFAULT 0;
    DECLARE error_record_lock INTEGER DEFAULT 0;
    DECLARE currId BIGINT DEFAULT 0;
    DECLARE updatedRecQty BIGINT DEFAULT 0;
    DECLARE loopJustStarted INT DEFAULT 0;
	DECLARE maxId bigint;
	DECLARE loopCnt INT DEFAULT 1;

    DECLARE lId bigint;
    DECLARE lApplication_transaction_counter varchar(4);
    DECLARE lTransaction_emv_data_id bigint;


    DEClARE cur
        CURSOR FOR
            SELECT id,
                transaction_emv_data_id,
                application_transaction_counter
            FROM transaction_log
            WHERE id >= currId AND id <= maxId
            ORDER BY id ASC
            LIMIT 3000;


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
	
	SET maxId = (SELECT max(id) FROM transaction_log);

    OUTER_BLOCK: LOOP

        IF currId > 0 THEN
            SET currId = currId + 1;
        END IF;

        OPEN cur;

        SET loopJustStarted = 1;

        DO SLEEP( 0.1 );

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

            UPDATE transaction_emv_data SET application_transaction_counter = lApplication_transaction_counter WHERE id = lTransaction_emv_data_id;
            SET updatedRecQty = updatedRecQty + ROW_COUNT();

        END LOOP TRANSACTION_BLOCK;

        CLOSE cur;

        COMMIT;

        SET not_found = 0;
		
		IF loopCnt % 500 = 0
        THEN
			insert into PROGRESS_REPORT(msg) SELECT "Copy to EMV DATA: " || loopCnt || " / " || currId || " / " || updatedRecQty AS msg;
		END IF;

		SET loopCnt = loopCnt + 1;

    END LOOP OUTER_BLOCK;

    COMMIT;

    SELECT updatedRecQty AS 'TOTAL updated records', error_record_lock AS "Errors due to record lock";
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS sp_verify_contents_transaction_emv_data_atc;

DELIMITER //
CREATE PROCEDURE sp_verify_contents_transaction_emv_data_atc()
BEGIN
    DECLARE diffRecQty BIGINT DEFAULT 0;
	DECLARE iINTERVAL BIGINT DEFAULT 10000;
    DECLARE CNT INT Default 0 ;
	DECLARE maxId bigint;

	SET maxId = (SELECT max(id) FROM transaction_emv_data);

	TRANSACTION_LOOP: LOOP
			START TRANSACTION;
			
			SET CNT=CNT+iINTERVAL;
			
			SET diffRecQty = diffRecQty + (SELECT count(*) FROM transaction_log l, transaction_emv_data d WHERE d.id > CNT-iINTERVAL AND d.id < CNT AND l.transaction_emv_data_id = d.id AND l.application_transaction_counter <> d.application_transaction_counter);
			
			IF CNT >= maxId THEN
				LEAVE TRANSACTION_LOOP;
			END IF;
			COMMIT;
	END LOOP TRANSACTION_LOOP;
   
	COMMIT;

    SELECT CONCAT( "DIFFROWS=", diffRecQty) AS 'TOTAL different records';
END //
DELIMITER ;
