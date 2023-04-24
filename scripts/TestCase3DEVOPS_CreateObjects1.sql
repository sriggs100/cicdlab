
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




-- 1. Create a new table transaction_log_new with the new layout

DROP TABLE IF EXISTS transaction_log1;

CREATE TABLE transaction_log1 (
   id bigint not null auto_increment,
    action_code smallint,
    additional_data varchar(500),
    amount decimal(19,2) not null,
    application_transaction_counter varchar(4),
    authorisation_code varchar(6),
    card_acceptor_name_and_location varchar(99) not null,
    card_scheme integer not null,
    chip_data varchar(512),
    encrypted_expiry_date varchar(96),
    encrypted_pan varchar(96) not null,
    function_code smallint not null,
    merchant_category_code smallint not null,
	
	transaction_token VARCHAR(36) NOT NULL,
	
    merchant_id varchar(15) not null,
    msg_type smallint not null,
    pan_hash varchar(64) not null,
    pan_sequence_number smallint not null,
    point_of_service_data_code varchar(12) not null,
    proc_code varchar(6) not null,
    reason_code smallint,
    stan integer not null,
    terminal_id varchar(8) not null,
    transaction_currency_code varchar(3),
    transaction_date_time varchar(12) not null,
    utc_capture_date_time datetime not null,
    transaction_emv_data_id bigint not null,
    primary key (id)
) engine=InnoDB;

ALTER TABLE transaction_log1 ROW_FORMAT=COMPRESSED;





DROP TABLE IF EXISTS PROGRESS_REPORT;

create table PROGRESS_REPORT
(
	timestampZ TIMESTAMP DEFAULT NOW(),
    msg varchar(200)
);


set sql_mode=PIPES_AS_CONCAT;


-- Create the procedure responsible for copying the transactions to the new table


DROP PROCEDURE IF EXISTS sp_copy_to_transaction_log1;

DELIMITER //
CREATE PROCEDURE sp_copy_to_transaction_log1(
        IN partitionLowId BIGINT,
        IN partitionHighId BIGINT,
		IN batchSize INT,
		IN withSleep TINYINT
        )
BEGIN
    DECLARE error_record_lock INTEGER DEFAULT 0;
    DECLARE currId BIGINT DEFAULT partitionLowId;
    DECLARE insertedRecQty BIGINT DEFAULT 0;
	DECLARE lastInsertedRecQty BIGINT DEFAULT 0;
    DECLARE loopCnt INT DEFAULT 1;
	
    -- Error due to record lock handler
    DECLARE CONTINUE HANDLER FOR 1205  -- Lock wait timeout exceeded
        SET error_record_lock = error_record_lock + 1;
		
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SHOW ERRORS;
        ROLLBACK;
    END;
	
	SET currId=partitionLowId;
	
	SET @@unique_checks=0, @@foreign_key_checks=0;

	TRANSACTION_LOOP: LOOP

		IF loopCnt % 200 = 0
        THEN
			insert into PROGRESS_REPORT(msg) SELECT partitionLowId||"-"|| partitionHighId || ": " ||loopCnt || " / " || currId || " / " || insertedRecQty AS msg;
		END IF;

		SET loopCnt = loopCnt + 1;
		
        START TRANSACTION;
		
		INSERT IGNORE INTO transaction_log1
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
			`transaction_token`,
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
		SELECT `id`,
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
			UUID(),
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
		  FROM transaction_log 
		  WHERE id >= currId AND id < currId+batchSize AND id < partitionHighId;
		  
		SET lastInsertedRecQty = ROW_COUNT();
		SET insertedRecQty = insertedRecQty + lastInsertedRecQty;

		COMMIT;

        SET currId=currId+batchSize;
		
		IF currId >= partitionHighId THEN
			LEAVE TRANSACTION_LOOP;
		END IF;
        
		IF withSleep = 1 AND lastInsertedRecQty <> 0 THEN
			DO SLEEP( 0.002 );
		END IF;
        
	END LOOP TRANSACTION_LOOP;

	SET @@unique_checks=1, @@foreign_key_checks=1;

    SELECT insertedRecQty AS "TOTAL inserted records", error_record_lock AS "Errors due to record lock";
END//
DELIMITER ;

