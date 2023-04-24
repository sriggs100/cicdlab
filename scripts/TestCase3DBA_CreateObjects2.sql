
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
			IN pTransaction_token VARCHAR(36),
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
-- 	The following SELECT, in side the IF was causing some deadlock errors. This was due to the isolation level (REPETABLE READ) which requires
--	that all the records read inside a transaction to be locked with shared lock. For this reason it was commented out as this was actually not 
--	since we know we are doing an insert of a completely new record so the IF below was redundant. 
--    IF NOT EXISTS( SELECT 1 FROM transaction_log1 WHERE id = pId )
--    THEN
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
		pTransaction_token,
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

--    END IF;
END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS sp_update_new_table_from_trigger;

DELIMITER //
CREATE PROCEDURE sp_update_new_table_from_trigger(
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


    UPDATE `transaction_log_new` SET 
			`action_code` = pAction_code, 
			`additional_data` = pAdditional_data,
			`amount` = pAmount,
			`application_transaction_counter` = pApplication_transaction_counter,
			`authorisation_code` = pAuthorisation_code,
			`card_acceptor_name_and_location` = pCard_acceptor_name_and_location,
			`card_scheme` = pCard_scheme,
			`chip_data` = pChip_data,
			`encrypted_expiry_date` = pEncrypted_expiry_date,
			`encrypted_pan` = pEncrypted_pan,
			`function_code` = pFunction_code,
			`merchant_category_code` = pMerchant_category_code,
			`merchant_id` = pMerchant_id,
			`msg_type` = pMsg_type,
			`pan_hash` = pPan_hash,
			`pan_sequence_number` = pPan_sequence_number,
			`point_of_service_data_code` = pPoint_of_service_data_code,
			`proc_code` = pProc_code,
			`reason_code` = pReason_code,
			`stan` = pStan,
			`terminal_id` = pTerminal_id,
			`transaction_currency_code` = pTransaction_currency_code,
			`transaction_date_time` = pTransaction_date_time,
			`utc_capture_date_time` = pUtc_capture_date_time		
		WHERE `id` = pId;


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
			UUID(),
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





--
--	UPDATE trigger
--


DROP TRIGGER IF EXISTS transaction_log_AFTER_UPDATE;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER transaction_log_AFTER_UPDATE AFTER UPDATE ON transaction_log FOR EACH ROW
BEGIN
    CALL sp_update_new_table_from_trigger(
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


